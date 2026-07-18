import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as sb;
import '../../theme/ks_theme.dart';
import '../../services/api_service.dart';
import 'live_stream_screen.dart';

class LiveListScreen extends StatefulWidget {
  const LiveListScreen({super.key});
  @override
  State<LiveListScreen> createState() => _LiveListScreenState();
}

class _LiveListScreenState extends State<LiveListScreen> {
  List<Map> liveStreams = [];
  bool isLoading = true;

  final upcomingStreams = [
    {'date': 'MAY', 'day': '24', 'dayName': 'SAT', 'time': '7:00 PM', 'title': 'Worship Night Live', 'host': 'with Worship Team'},
    {'date': 'MAY', 'day': '25', 'dayName': 'SUN', 'time': '10:00 AM', 'title': 'Sunday Service Live', 'host': 'with Pastor James'},
  ];

  @override
  void initState() {
    super.initState();
    _loadLiveStreams();
  }

  Future<void> _loadLiveStreams() async {
    setState(() => isLoading = true);
    try {
      final liveData = await sb.Supabase.instance.client
          .from('live_streams').select().eq('status', 'live').order('created_at', ascending: false);
      final list = liveData as List;
      if (list.isNotEmpty) {
        final creatorIds = list.map((l) => l['creator_id']).toSet().toList();
        final profiles = await sb.Supabase.instance.client
            .from('app_profiles').select('id, username, full_name, avatar_url').inFilter('id', creatorIds);
        final profileMap = {for (final p in profiles) p['id']: p};
        if (mounted) setState(() { liveStreams = list.map((l) => {...l, 'creator': profileMap[l['creator_id']]}).toList().cast<Map>(); });
      }
    } catch (e) {}
    if (mounted) setState(() => isLoading = false);
  }

  Future<void> _goLive() async {
    final firebaseUser = FirebaseAuth.instance.currentUser;
    if (firebaseUser == null) return;
    final res = await ApiService.fetchUserDetails();
    final username = res['data']?['username'] ?? 'Host';
    final fullname = res['data']?['full_name'] ?? username;
    final roomID = 'live_${firebaseUser.uid}';
    try {
      await sb.Supabase.instance.client.from('live_streams').delete().eq('creator_id', firebaseUser.uid);
      await sb.Supabase.instance.client.from('live_streams').insert({
        'creator_id': firebaseUser.uid,
        'room_id': roomID,
        'title': '$fullname is Live',
        'status': 'live',
        'viewer_count': 0,
      });
    } catch (e) {}
    if (!mounted) return;
    Navigator.push(context, MaterialPageRoute(
      builder: (_) => LiveStreamScreen(roomID: roomID, isHost: true, userName: username.replaceAll(RegExp(r'[^a-zA-Z0-9_]'), '_')),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: KSTheme.bgDark,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _loadLiveStreams,
          color: KSTheme.teal,
          child: CustomScrollView(
            slivers: [
              // Header
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                  child: Row(
                    children: [
                      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        const Text('Live Stream', style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
                        Text('Experience Kingdom conversations in real time.', style: TextStyle(color: KSTheme.textSecondary, fontSize: 12)),
                      ]),
                      const Spacer(),
                      GestureDetector(
                        onTap: _goLive,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                          decoration: BoxDecoration(gradient: KSTheme.tealGradient, borderRadius: BorderRadius.circular(20), border: Border.all(color: KSTheme.teal)),
                          child: const Row(children: [
                            Icon(Icons.sensors, color: Colors.white, size: 16),
                            SizedBox(width: 6),
                            Text('Go Live', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
                          ]),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              // Featured live stream hero
              if (liveStreams.isNotEmpty)
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: _buildFeaturedLive(liveStreams[0]),
                  ),
                )
              else
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: _buildNoLiveCard(),
                  ),
                ),
              // Live with Guests
              if (liveStreams.length > 1) ...[
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
                    child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                      const Text('Live with Guests', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                      Text('See All >', style: TextStyle(color: KSTheme.teal, fontSize: 13, fontWeight: FontWeight.w600)),
                    ]),
                  ),
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: _buildLiveWithGuests(),
                  ),
                ),
              ],
              // Upcoming Live Streams
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 20, 16, 12),
                  child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                    const Text('Upcoming Live Streams', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                    Text('See All >', style: TextStyle(color: KSTheme.teal, fontSize: 13, fontWeight: FontWeight.w600)),
                  ]),
                ),
              ),
              SliverToBoxAdapter(
                child: SizedBox(
                  height: 180,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: upcomingStreams.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 12),
                    itemBuilder: (_, i) => _buildUpcomingCard(upcomingStreams[i]),
                  ),
                ),
              ),
              // Past Live Streams
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 20, 16, 12),
                  child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                    const Text('Past Live Streams', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                    Text('See All >', style: TextStyle(color: KSTheme.teal, fontSize: 13, fontWeight: FontWeight.w600)),
                  ]),
                ),
              ),
              SliverToBoxAdapter(
                child: SizedBox(
                  height: 140,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: 5,
                    separatorBuilder: (_, __) => const SizedBox(width: 10),
                    itemBuilder: (_, i) => _buildPastLiveCard(i),
                  ),
                ),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: 24)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFeaturedLive(Map live) {
    final creator = live['creator'] as Map?;
    final username = creator?['username'] ?? 'Host';
    final fullName = creator?['full_name'] ?? username;
    return GestureDetector(
      onTap: () => Navigator.push(context, MaterialPageRoute(
        builder: (_) => LiveStreamScreen(roomID: 'live_${live['creator_id']}', isHost: false, userName: username.replaceAll(RegExp(r'[^a-zA-Z0-9_]'), '_')),
      )),
      child: Container(
        height: 280,
        decoration: BoxDecoration(
          color: KSTheme.bgCard,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: KSTheme.teal, width: 1.5),
          gradient: const LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [Color(0xFF0D2137), Color(0xFF0A1628)]),
        ),
        child: Stack(
          children: [
            if (creator?['avatar_url'] != null)
              Positioned(right: 0, top: 0, bottom: 0,
                child: ClipRRect(
                  borderRadius: const BorderRadius.horizontal(right: Radius.circular(16)),
                  child: CachedNetworkImage(imageUrl: creator!['avatar_url'], fit: BoxFit.cover, width: 180),
                )),
            Container(decoration: BoxDecoration(borderRadius: BorderRadius.circular(16), gradient: LinearGradient(begin: Alignment.centerRight, end: Alignment.centerLeft, colors: [Colors.transparent, KSTheme.bgDark.withValues(alpha: 0.9)]))),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(children: [
                    Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4), decoration: BoxDecoration(color: Colors.red, borderRadius: BorderRadius.circular(6)), child: const Text('LIVE', style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold))),
                    const SizedBox(width: 8),
                    const Icon(Icons.visibility_outlined, color: Colors.white, size: 14),
                    const SizedBox(width: 4),
                    Text('${live['viewer_count'] ?? 0}', style: const TextStyle(color: Colors.white, fontSize: 12)),
                  ]),
                  const Spacer(),
                  Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4), decoration: BoxDecoration(color: KSTheme.bgCard, borderRadius: BorderRadius.circular(6)), child: const Text('Host', style: TextStyle(color: KSTheme.teal, fontSize: 11))),
                  const SizedBox(height: 6),
                  Text(fullName, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                  Text(live['title'] ?? 'KingdomShift.Live', style: const TextStyle(color: KSTheme.teal, fontSize: 16, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  const Text('Let\'s grow together in faith and truth.', style: TextStyle(color: Colors.white70, fontSize: 12)),
                  const SizedBox(height: 12),
                  Row(children: [
                    GestureDetector(
                      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => LiveStreamScreen(roomID: 'live_${live['creator_id']}', isHost: false, userName: username.replaceAll(RegExp(r'[^a-zA-Z0-9_]'), '_')))),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                        decoration: BoxDecoration(color: KSTheme.teal.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(20), border: Border.all(color: KSTheme.teal)),
                        child: const Row(children: [Icon(Icons.sensors, color: KSTheme.teal, size: 16), SizedBox(width: 6), Text('Join Live', style: TextStyle(color: KSTheme.teal, fontWeight: FontWeight.bold))]),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      decoration: BoxDecoration(color: KSTheme.bgCardLight, borderRadius: BorderRadius.circular(20), border: Border.all(color: KSTheme.divider)),
                      child: const Row(children: [Icon(Icons.share_outlined, color: Colors.white, size: 16), SizedBox(width: 6), Text('Share', style: TextStyle(color: Colors.white))]),
                    ),
                  ]),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNoLiveCard() {
    return Container(
      height: 200,
      decoration: BoxDecoration(color: KSTheme.bgCard, borderRadius: BorderRadius.circular(16), border: Border.all(color: KSTheme.divider)),
      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        const Icon(Icons.sensors, color: KSTheme.teal, size: 48),
        const SizedBox(height: 12),
        const Text('No live streams right now', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
        const SizedBox(height: 4),
        Text('Be the first to go live on KingdomShift.Live!', style: TextStyle(color: KSTheme.textSecondary, fontSize: 13)),
        const SizedBox(height: 16),
        GestureDetector(
          onTap: _goLive,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            decoration: BoxDecoration(gradient: KSTheme.tealGradient, borderRadius: BorderRadius.circular(20)),
            child: const Text('Go Live Now', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ),
      ]),
    );
  }

  Widget _buildLiveWithGuests() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: KSTheme.cardDecoration,
      child: Column(
        children: [
          Row(children: [
            Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4), decoration: BoxDecoration(color: Colors.red, borderRadius: BorderRadius.circular(6)), child: const Text('LIVE', style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold))),
            const SizedBox(width: 8),
            const Icon(Icons.visibility_outlined, color: Colors.white, size: 14),
            const SizedBox(width: 4),
            const Text('843', style: TextStyle(color: Colors.white, fontSize: 12)),
            const Spacer(),
            const Text('Kingdom Roundtable', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            const Spacer(),
            Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4), decoration: BoxDecoration(color: KSTheme.bgCardLight, borderRadius: BorderRadius.circular(8)), child: const Text('11 in room', style: TextStyle(color: Colors.white, fontSize: 11))),
          ]),
          const SizedBox(height: 4),
          const Text('Building Strong Families in Faith', style: TextStyle(color: KSTheme.teal, fontSize: 12)),
          const SizedBox(height: 12),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 5, crossAxisSpacing: 6, mainAxisSpacing: 6, childAspectRatio: 0.8),
            itemCount: 10,
            itemBuilder: (_, i) => Column(children: [
              Container(
                decoration: BoxDecoration(borderRadius: BorderRadius.circular(8), color: KSTheme.bgCardLight, border: i == 0 ? Border.all(color: KSTheme.gold, width: 1.5) : null),
                child: Stack(children: [
                  ClipRRect(borderRadius: BorderRadius.circular(8), child: Container(color: KSTheme.bgCardLight, child: const Icon(Icons.person, color: Colors.white54, size: 30))),
                  if (i == 0) Positioned(top: 2, left: 2, child: Container(padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1), decoration: BoxDecoration(color: KSTheme.gold, borderRadius: BorderRadius.circular(4)), child: const Text('Host', style: TextStyle(color: Colors.white, fontSize: 7)))),
                  const Positioned(bottom: 2, right: 2, child: Icon(Icons.mic, color: KSTheme.teal, size: 10)),
                ]),
              ),
              const SizedBox(height: 2),
              Text(['Pastor J.', 'Sarah J.', 'David M.', 'Lisa R.', 'Michael T.', 'Angela W.', 'John K.', 'Rachel P.', 'Matthew G.', 'Daniel C.'][i], style: const TextStyle(color: Colors.white, fontSize: 8), overflow: TextOverflow.ellipsis),
            ]),
          ),
          const SizedBox(height: 10),
          Row(children: [
            _guestActionBtn(Icons.pan_tool_outlined, 'Raise Hand'),
            const SizedBox(width: 6),
            _guestActionBtn(Icons.screen_share_outlined, 'Share Screen'),
            const SizedBox(width: 6),
            _guestActionBtn(Icons.mic_off_outlined, 'Mute All'),
            const SizedBox(width: 6),
            _guestActionBtn(Icons.exit_to_app, 'Leave', color: Colors.red),
          ]),
        ],
      ),
    );
  }

  Widget _guestActionBtn(IconData icon, String label, {Color? color}) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(color: KSTheme.bgCardLight, borderRadius: BorderRadius.circular(8), border: Border.all(color: color != null ? color.withValues(alpha: 0.3) : KSTheme.divider)),
        child: Column(children: [Icon(icon, color: color ?? Colors.white, size: 16), const SizedBox(height: 2), Text(label, style: TextStyle(color: color ?? Colors.white, fontSize: 9))]),
      ),
    );
  }

  Widget _buildUpcomingCard(Map stream) {
    return Container(
      width: 200,
      decoration: KSTheme.cardDecoration,
      child: Stack(
        children: [
          Container(decoration: BoxDecoration(borderRadius: BorderRadius.circular(16), gradient: const LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Color(0xFF0D2137), KSTheme.bgCard]))),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(stream['date']!, style: const TextStyle(color: KSTheme.teal, fontSize: 10, fontWeight: FontWeight.w600)),
                  Text(stream['day']!, style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold, height: 1)),
                  Text(stream['dayName']!, style: TextStyle(color: KSTheme.textSecondary, fontSize: 10)),
                ]),
                const Spacer(),
                Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4), decoration: BoxDecoration(color: KSTheme.teal.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(8), border: Border.all(color: KSTheme.teal)),
                  child: Text(stream['time']!, style: const TextStyle(color: KSTheme.teal, fontSize: 11, fontWeight: FontWeight.w600))),
              ]),
              const Spacer(),
              Text(stream['title']!, style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold)),
              Text(stream['host']!, style: TextStyle(color: KSTheme.textSecondary, fontSize: 11)),
              const SizedBox(height: 8),
              Row(children: [
                Expanded(child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  decoration: BoxDecoration(color: KSTheme.bgCardLight, borderRadius: BorderRadius.circular(8), border: Border.all(color: KSTheme.divider)),
                  child: const Row(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(Icons.notifications_outlined, color: Colors.white, size: 14), SizedBox(width: 4), Text('Set Reminder', style: TextStyle(color: Colors.white, fontSize: 11))]),
                )),
                const SizedBox(width: 6),
                Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: KSTheme.bgCardLight, borderRadius: BorderRadius.circular(8), border: Border.all(color: KSTheme.divider)), child: const Icon(Icons.share_outlined, color: Colors.white, size: 14)),
              ]),
            ]),
          ),
        ],
      ),
    );
  }

  Widget _buildPastLiveCard(int i) {
    final titles = ['Faith Over Fear', 'Power of Prayer', 'Trust in His Plan', 'Kingdom Mindset', 'Walking in Purpose'];
    final hosts = ['Pastor James', 'Sarah J.', 'David Miller', 'Ministry Team', 'Lisa R.'];
    final views = ['2.4K', '1.8K', '3.1K', '2.7K', '2.2K'];
    final durations = ['1:12:45', '58:30', '1:05:20', '45:15', '1:22:10'];
    return Container(
      width: 120,
      decoration: BoxDecoration(color: KSTheme.bgCard, borderRadius: BorderRadius.circular(12)),
      child: Stack(children: [
        ClipRRect(borderRadius: BorderRadius.circular(12), child: Container(color: KSTheme.bgCardLight, child: const Center(child: Icon(Icons.play_circle_outline, color: Colors.white24, size: 40)))),
        Positioned(top: 6, right: 6, child: Container(padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2), decoration: BoxDecoration(color: Colors.black54, borderRadius: BorderRadius.circular(4)), child: Text(durations[i], style: const TextStyle(color: Colors.white, fontSize: 9)))),
        Positioned(bottom: 0, left: 0, right: 0, child: Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(borderRadius: const BorderRadius.vertical(bottom: Radius.circular(12)), gradient: LinearGradient(begin: Alignment.bottomCenter, end: Alignment.topCenter, colors: [Colors.black.withValues(alpha: 0.9), Colors.transparent])),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(titles[i], style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
            Text(hosts[i], style: TextStyle(color: KSTheme.textSecondary, fontSize: 9)),
            Row(children: [const Icon(Icons.visibility_outlined, color: Colors.white54, size: 10), const SizedBox(width: 2), Text(views[i], style: const TextStyle(color: Colors.white54, fontSize: 9))]),
          ]),
        )),
      ]),
    );
  }
}
