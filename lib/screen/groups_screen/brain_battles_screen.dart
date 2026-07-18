import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as sb;
import 'battle_lobby_screen.dart';

class BrainBattlesScreen extends StatefulWidget {
  const BrainBattlesScreen({super.key});

  @override
  State<BrainBattlesScreen> createState() => _BrainBattlesScreenState();
}

class _BrainBattlesScreenState extends State<BrainBattlesScreen> {
  List<dynamic> battles = [];
  bool isLoading = true;
  bool isCreating = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => isLoading = true);
    try {
      final data = await sb.Supabase.instance.client
          .from('brain_battles')
          .select()
          .neq('status', 'ended')
          .order('created_at', ascending: false);
      setState(() {
        battles = data as List;
        isLoading = false;
      });
    } catch (e) {
      setState(() => isLoading = false);
    }
  }

  Future<void> _createBattle() async {
    final firebaseUser = FirebaseAuth.instance.currentUser;
    if (firebaseUser == null) return;

    // Fetch currently live hosts (excluding self)
    List<dynamic> liveHosts = [];
    try {
      final data = await sb.Supabase.instance.client
          .from('live_streams')
          .select('creator_id')
          .eq('status', 'live')
          .neq('creator_id', firebaseUser.uid);

      final creatorIds = (data as List).map((l) => l['creator_id']).toSet().toList();
      if (creatorIds.isNotEmpty) {
        final profiles = await sb.Supabase.instance.client
            .from('app_profiles')
            .select('id, username, avatar_url, full_name')
            .inFilter('id', creatorIds);
        liveHosts = profiles;
      }
    } catch (e) {
      // ignore
    }

    if (liveHosts.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No one else is live right now to battle')),
        );
      }
      return;
    }

    final selected = await showDialog<Map>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.grey[900],
        title: const Text('Challenge a Live Host', style: TextStyle(color: Colors.white)),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: liveHosts.length,
            itemBuilder: (context, i) {
              final h = liveHosts[i] as Map;
              return ListTile(
                leading: CircleAvatar(
                  backgroundColor: Colors.deepPurple,
                  backgroundImage: (h['avatar_url']?.isNotEmpty == true) ? NetworkImage(h['avatar_url']) : null,
                  child: (h['avatar_url']?.isEmpty != false) ? const Icon(Icons.person, color: Colors.white) : null,
                ),
                title: Text('@${h['username'] ?? 'unknown'}', style: const TextStyle(color: Colors.white)),
                trailing: const Icon(Icons.live_tv, color: Colors.red, size: 16),
                onTap: () => Navigator.pop(context, h),
              );
            },
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel', style: TextStyle(color: Colors.grey))),
        ],
      ),
    );

    if (selected == null) return;

    setState(() => isCreating = true);
    try {
      final roomID = 'battle_${firebaseUser.uid}_${DateTime.now().millisecondsSinceEpoch}';

      final battle = await sb.Supabase.instance.client.from('brain_battles').insert({
        'host1_id': firebaseUser.uid,
        'host2_id': selected['id'],
        'room_id': roomID,
        'status': 'waiting',
      }).select().single();

      // Seed default questions
      final defaultQuestions = [
        {'q': 'What is the first book of the Bible?', 'a': 'Genesis', 'b': 'Exodus', 'c': 'Matthew', 'd': 'Psalms', 'correct': 'A'},
        {'q': 'How many days did it take God to create the world?', 'a': '5', 'b': '6', 'c': '7', 'd': '8', 'correct': 'B'},
        {'q': 'Who led the Israelites out of Egypt?', 'a': 'David', 'b': 'Moses', 'c': 'Abraham', 'd': 'Noah', 'correct': 'B'},
        {'q': 'What is the fruit of the Spirit (Galatians 5)?', 'a': 'Love, joy, peace...', 'b': 'Wealth', 'c': 'Power', 'd': 'Fame', 'correct': 'A'},
        {'q': 'Which city did Jesus grow up in?', 'a': 'Bethlehem', 'b': 'Jerusalem', 'c': 'Nazareth', 'd': 'Capernaum', 'correct': 'C'},
      ];

      for (int i = 0; i < defaultQuestions.length; i++) {
        final qq = defaultQuestions[i];
        await sb.Supabase.instance.client.from('battle_questions').insert({
          'battle_id': battle['id'],
          'question': qq['q'],
          'option_a': qq['a'],
          'option_b': qq['b'],
          'option_c': qq['c'],
          'option_d': qq['d'],
          'correct_option': qq['correct'],
          'question_order': i,
        });
      }

      if (mounted) {
        await Navigator.push(context, MaterialPageRoute(
          builder: (_) => BattleLobbyScreen(battleId: battle['id']),
        ));
        _load();
      }
    } finally {
      if (mounted) setState(() => isCreating = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text('Brain Battles', style: TextStyle(color: Colors.white)),
      ),
      body: RefreshIndicator(
        onRefresh: _load,
        child: isLoading
            ? const Center(child: CircularProgressIndicator())
            : battles.isEmpty
                ? ListView(
                    children: const [
                      Padding(
                        padding: EdgeInsets.all(40),
                        child: Center(child: Text('No active battles. Challenge someone!', style: TextStyle(color: Colors.grey))),
                      ),
                    ],
                  )
                : ListView.builder(
                    itemCount: battles.length,
                    itemBuilder: (context, index) {
                      final battle = battles[index] as Map;
                      return ListTile(
                        leading: const Icon(Icons.psychology, color: Colors.deepPurple),
                        title: Text('Battle #${battle['id'].toString().substring(0, 8)}', style: const TextStyle(color: Colors.white)),
                        subtitle: Text('Status: ${battle['status']} • ${battle['host1_score']} - ${battle['host2_score']}', style: const TextStyle(color: Colors.grey)),
                        trailing: const Icon(Icons.chevron_right, color: Colors.white),
                        onTap: () {
                          Navigator.push(context, MaterialPageRoute(
                            builder: (_) => BattleLobbyScreen(battleId: battle['id']),
                          ));
                        },
                      );
                    },
                  ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: isCreating ? null : _createBattle,
        backgroundColor: Colors.deepPurple,
        icon: isCreating
            ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
            : const Icon(Icons.psychology, color: Colors.white),
        label: const Text('Challenge', style: TextStyle(color: Colors.white)),
      ),
    );
  }
}
