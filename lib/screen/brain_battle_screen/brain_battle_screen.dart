import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as supabase;
import 'package:shortzz/screen/brain_battle_screen/brain_battle_game_screen.dart';
import 'package:shortzz/screen/brain_battle_screen/brain_battle_game_controller.dart';

class BrainBattleScreen extends StatefulWidget {
  const BrainBattleScreen({super.key});
  @override
  State<BrainBattleScreen> createState() => _BrainBattleScreenState();
}

class _BrainBattleScreenState extends State<BrainBattleScreen> {
  int _selectedCategory = 0;

  final List<Map<String, String>> categories = [
    {'icon': '📖', 'label': 'Bible'},
    {'icon': '💼', 'label': 'Business'},
    {'icon': '💰', 'label': 'Finance'},
    {'icon': '🏥', 'label': 'Health'},
    {'icon': '🏛️', 'label': 'History'},
    {'icon': '🔬', 'label': 'Science'},
    {'icon': '🎵', 'label': 'Music'},
    {'icon': '🌍', 'label': 'Culture'},
  ];

  List<Map<String, dynamic>> realLeaderboard = [];
  bool isLeaderboardLoading = true;

  static const _rankEmojis = ['👑', '🥈', '🥉', '4️⃣', '5️⃣'];

  @override
  void initState() {
    super.initState();
    _fetchLeaderboard();
  }

  Future<void> _fetchLeaderboard() async {
    setState(() => isLeaderboardLoading = true);
    try {
      final response = await supabase.Supabase.instance.client
          .from('brain_battle_scores')
          .select('username, score')
          .order('score', ascending: false)
          .limit(5);
      setState(() {
        realLeaderboard = List<Map<String, dynamic>>.from(response as List);
        isLeaderboardLoading = false;
      });
    } catch (e) {
      setState(() => isLeaderboardLoading = false);
    }
  }

  void _startBattle(BrainBattleMode mode) {
    final category = categories[_selectedCategory]['label']!;
    Get.to(() => BrainBattleGameScreen(category: category, mode: mode))
        ?.then((_) => _fetchLeaderboard());
  }

  void _comingSoon(String feature) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('$feature is coming in a future update!')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0F),
      body: SafeArea(
          child: SingleChildScrollView(
        child: Column(children: [
          _buildHeroBanner(),
          _buildCategories(),
          _buildBattleModes(),
          _buildLeaderboard(),
          _buildStudyMode(),
          const SizedBox(height: 80),
        ]),
      )),
    );
  }

  Widget _buildHeroBanner() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: const LinearGradient(
            colors: [Color(0xFF1A0533), Color(0xFF0D1B4B)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight),
        border:
            Border.all(color: const Color(0xFF7B2FF7).withValues(alpha: 0.3)),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
                color: const Color(0xFF7B2FF7).withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(8)),
            child: const Text('BRAIN BATTLE',
                style: TextStyle(
                    color: Color(0xFF7B2FF7),
                    fontSize: 12,
                    fontWeight: FontWeight.bold))),
        const SizedBox(height: 12),
        const Text('CHALLENGE MINDS. WIN VICTORY.',
            style: TextStyle(
                color: Colors.white,
                fontSize: 26,
                fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        const Text(
            'Test your knowledge. Beat opponents. Earn coins and climb the leaderboard.',
            style: TextStyle(color: Colors.white70, fontSize: 13)),
        const SizedBox(height: 16),
        Row(children: [
          _statBox('Active Battles', '1,284'),
          const SizedBox(width: 12),
          _statBox('Players Today', '8,429'),
          const SizedBox(width: 12),
          _statBox('Prize Pool', '50K coins'),
        ]),
        const SizedBox(height: 16),
        Row(children: [
          Expanded(
              child:
                  _primaryBtn('Start Battle', const Color(0xFF7B2FF7), () => _startBattle(BrainBattleMode.speedRound))),
          const SizedBox(width: 12),
          Expanded(
              child: _primaryBtn(
                  'Challenge Friend', const Color(0xFF1A1A2E), () {})),
        ]),
      ]),
    );
  }

  Widget _statBox(String label, String value) {
    return Expanded(
        child: Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.07),
          borderRadius: BorderRadius.circular(10)),
      child: Column(children: [
        Text(value,
            style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 16)),
        Text(label,
            style: const TextStyle(color: Colors.white54, fontSize: 10),
            textAlign: TextAlign.center),
      ]),
    ));
  }

  Widget _buildCategories() {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const Padding(
          padding: EdgeInsets.fromLTRB(16, 0, 16, 12),
          child: Text('Choose Category',
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold))),
      SizedBox(
          height: 80,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: categories.length,
            itemBuilder: (_, i) {
              final sel = _selectedCategory == i;
              return GestureDetector(
                onTap: () => setState(() => _selectedCategory = i),
                child: Container(
                  width: 68,
                  margin: const EdgeInsets.only(right: 10),
                  decoration: BoxDecoration(
                    color:
                        sel ? const Color(0xFF7B2FF7) : const Color(0xFF12121E),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                        color: sel ? const Color(0xFF7B2FF7) : Colors.white12),
                  ),
                  child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(categories[i]['icon']!,
                            style: const TextStyle(fontSize: 24)),
                        const SizedBox(height: 4),
                        Text(categories[i]['label']!,
                            style: TextStyle(
                                color: sel ? Colors.white : Colors.white54,
                                fontSize: 11)),
                      ]),
                ),
              );
            },
          )),
    ]);
  }

  Widget _buildBattleModes() {
    final List<Map<String, dynamic>> modes = [
      {
        'icon': '⚔️',
        'title': '1v1 Battle',
        'desc': 'Face off against one opponent',
        'color': const Color(0xFF7B2FF7)
      },
      {
        'icon': '👥',
        'title': 'Tournament',
        'desc': 'Compete against 8 players',
        'color': const Color(0xFFFF6B00)
      },
      {
        'icon': '⚡',
        'title': 'Speed Round',
        'desc': '60 seconds, max questions',
        'color': const Color(0xFF00C6FF)
      },
      {
        'icon': '📚',
        'title': 'Study Mode',
        'desc': 'Learn without pressure',
        'color': const Color(0xFF00C851)
      },
    ];
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text('Battle Modes',
            style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 1.4),
          itemCount: modes.length,
          itemBuilder: (_, i) {
            final m = modes[i];
            return GestureDetector(
              onTap: () {
                if (i == 0) {
                  _comingSoon('1v1 Battle');
                } else if (i == 1) {
                  _comingSoon('Tournament');
                } else if (i == 2) {
                  _startBattle(BrainBattleMode.speedRound);
                } else {
                  _startBattle(BrainBattleMode.study);
                }
              },
              child: Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: const Color(0xFF12121E),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                      color: (m['color'] as Color).withValues(alpha: 0.3)),
                ),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(m['icon'] as String,
                          style: const TextStyle(fontSize: 28)),
                      const Spacer(),
                      Text(m['title'] as String,
                          style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 14)),
                      Text(m['desc'] as String,
                          style: const TextStyle(
                              color: Colors.white54, fontSize: 11)),
                    ]),
              ),
            );
          },
        ),
      ]),
    );
  }

  Widget _buildLeaderboard() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          const Text('Top Champions',
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold)),
          TextButton(
              onPressed: _fetchLeaderboard,
              child: const Text('Refresh',
                  style: TextStyle(color: Color(0xFFFFB800)))),
        ]),
        if (isLeaderboardLoading)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 16),
            child: Center(
                child: CircularProgressIndicator(color: Color(0xFF7B2FF7))),
          )
        else if (realLeaderboard.isEmpty)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 16),
            child: Text('No scores yet - be the first champion!',
                style: TextStyle(color: Colors.white54)),
          )
        else
          ...realLeaderboard.asMap().entries.map((entry) {
            final i = entry.key;
            final p = entry.value;
            return ListTile(
              contentPadding: EdgeInsets.zero,
              leading: Text(i < _rankEmojis.length ? _rankEmojis[i] : '${i + 1}',
                  style: const TextStyle(fontSize: 24)),
              title: Text(p['username']?.toString() ?? 'Player',
                  style: const TextStyle(
                      color: Colors.white, fontWeight: FontWeight.bold)),
              trailing: Text('${p['score']} pts',
                  style: const TextStyle(
                      color: Color(0xFFFFB800), fontWeight: FontWeight.bold)),
            );
          }),
      ]),
    );
  }

  Widget _buildStudyMode() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
            colors: [Color(0xFF0D2137), Color(0xFF0A0A0F)]),
        borderRadius: BorderRadius.circular(16),
        border:
            Border.all(color: const Color(0xFF00C6FF).withValues(alpha: 0.3)),
      ),
      child: Row(children: [
        const Text('🧠', style: TextStyle(fontSize: 40)),
        const SizedBox(width: 16),
        const Expanded(
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Study. Train. Dominate.',
              style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 15)),
          Text('Practice daily to stay sharp and rise on the leaderboard.',
              style: TextStyle(color: Colors.white54, fontSize: 12)),
        ])),
        _primaryBtn('Start', const Color(0xFF00C6FF), () => _startBattle(BrainBattleMode.study)),
      ]),
    );
  }

  Widget _primaryBtn(String label, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
        decoration: BoxDecoration(
            color: color, borderRadius: BorderRadius.circular(10)),
        child: Text(label,
            style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 13)),
      ),
    );
  }
}
