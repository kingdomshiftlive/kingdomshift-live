import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../theme/ks_theme.dart';
import '../../services/api_service.dart';
import '../../models/app_user.dart';
import '../profile/profile_screen.dart';

class FollowingScreen extends StatefulWidget {
  const FollowingScreen({super.key});
  @override
  State<FollowingScreen> createState() => _FollowingScreenState();
}

class _FollowingScreenState extends State<FollowingScreen> {
  String selectedFilter = 'All';
  final filters = ['All', 'People', 'Ministries', 'Channels', 'Podcasts'];
  List<AppUser> following = [];
  bool isLoading = true;

  final ministries = [
    {'name': 'Kingdom Authority', 'handle': '@kingdomauthority', 'desc': 'Equipping believers to walk in spiritual authority and live victoriously.', 'icon': Icons.workspace_premium, 'color': 0xFF1A1A0A},
    {'name': 'Kingdom Bible Institute', 'handle': '@kbionline', 'desc': 'Biblical teaching and resources to help you grow in the Word.', 'icon': Icons.menu_book_outlined, 'color': 0xFF0A1A1A},
    {'name': 'Kingdom Outreach', 'handle': '@kingdomoutreach', 'desc': 'Reaching our communities with love, compassion, and the Gospel.', 'icon': Icons.volunteer_activism_outlined, 'color': 0xFF0A1A2A},
  ];

  final channels = [
    {'name': 'Kingdom Worship', 'handle': '1.2M subscribers • 348 videos', 'desc': 'Worship moments and songs that draw us closer to God.', 'color': 0xFF0A1A2A},
    {'name': 'Kingdom Messages', 'handle': '980K subscribers • 612 videos', 'desc': 'Powerful messages to inspire faith and transformation.', 'color': 0xFF0A1A2A},
    {'name': 'KingdomShift.Live Podcast', 'handle': '320K subscribers • 156 episodes', 'desc': 'Conversations on faith, life, and spiritual growth.', 'color': 0xFF1A0A0A},
  ];

  @override
  void initState() {
    super.initState();
    _loadFollowing();
  }

  Future<void> _loadFollowing() async {
    final res = await ApiService.fetchUserDetails();
    if (res['status'] == true) {
      // Load following list
    }
    if (mounted) setState(() => isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: KSTheme.bgDark,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
              child: Row(children: [
                GestureDetector(onTap: () => Navigator.pop(context), child: const Icon(Icons.arrow_back, color: Colors.white)),
                const SizedBox(width: 12),
                ClipOval(child: Image.asset('assets/images/ks_logo.png', width: 36, height: 36, fit: BoxFit.cover)),
                const SizedBox(width: 10),
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  const Text('KingdomShift.Live', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                  Text('MEDIA', style: TextStyle(color: KSTheme.teal, fontSize: 10, fontWeight: FontWeight.w600, letterSpacing: 2)),
                ]),
                const Spacer(),
                Stack(children: [
                  IconButton(icon: const Icon(Icons.notifications_outlined, color: Colors.white), onPressed: () {}),
                  Positioned(top: 8, right: 8, child: Container(width: 16, height: 16, decoration: const BoxDecoration(color: KSTheme.teal, shape: BoxShape.circle), child: const Center(child: Text('3', style: TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold))))),
                ]),
              ]),
            ),
            // Title
            const Padding(
              padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('Following', style: TextStyle(color: Colors.white, fontSize: 26, fontWeight: FontWeight.bold)),
                Text('People, ministries, and channels you follow.', style: TextStyle(color: KSTheme.textSecondary, fontSize: 13)),
              ]),
            ),
            // Filter chips
            SizedBox(
              height: 40,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: filters.length,
                separatorBuilder: (_, __) => const SizedBox(width: 8),
                itemBuilder: (_, i) {
                  final isSelected = selectedFilter == filters[i];
                  return GestureDetector(
                    onTap: () => setState(() => selectedFilter = filters[i]),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: isSelected ? KSTheme.teal : KSTheme.bgCard,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: isSelected ? KSTheme.teal : KSTheme.divider),
                      ),
                      child: Text(filters[i], style: TextStyle(color: isSelected ? Colors.white : KSTheme.textSecondary, fontSize: 13, fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal)),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 8),
            // Content
            Expanded(
              child: ListView(
                children: [
                  // People section
                  if (selectedFilter == 'All' || selectedFilter == 'People') ...[
                    _sectionHeader('People', 'View All >'),
                    if (following.isEmpty) ...[
                      _personItem('Pastor James', '@pastorjames', 'Leader of KingdomShift.Live. Preaching faith, hope, and the power of Jesus.', null),
                      _personItem('Sarah Jakes Roberts', '@sarahjakesroberts', 'Speaker, author, and women\'s advocate. Empowering women to walk in purpose.', null),
                      _personItem('Mike Todd', '@miketodd', 'Pastor, speaker, and author. Helping people discover their God-given identity.', null),
                    ] else
                      ...following.map((u) => _personItem(u.fullname, '@${u.username}', u.bio, u.profilePhoto.isNotEmpty ? u.profilePhoto : null)),
                  ],
                  // Ministries section
                  if (selectedFilter == 'All' || selectedFilter == 'Ministries') ...[
                    _sectionHeader('Ministries', 'View All >'),
                    ...ministries.map((m) => _ministryItem(m)),
                  ],
                  // Channels section
                  if (selectedFilter == 'All' || selectedFilter == 'Channels') ...[
                    _sectionHeader('Channels', 'View All >'),
                    ...channels.map((c) => _channelItem(c)),
                  ],
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _sectionHeader(String title, String action) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Text(title, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
        Text(action, style: TextStyle(color: KSTheme.teal, fontSize: 13, fontWeight: FontWeight.w600)),
      ]),
    );
  }

  Widget _personItem(String name, String handle, String bio, String? photoUrl) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  radius: 28,
                  backgroundColor: KSTheme.bgCard,
                  backgroundImage: photoUrl != null ? CachedNetworkImageProvider(photoUrl) : null,
                  child: photoUrl == null ? Text(name[0], style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)) : null,
                ),
                const SizedBox(width: 12),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Row(children: [
                    Text(name, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15)),
                    const SizedBox(width: 4),
                    const Icon(Icons.verified, color: KSTheme.teal, size: 14),
                  ]),
                  Text(handle, style: TextStyle(color: KSTheme.teal, fontSize: 12)),
                  const SizedBox(height: 2),
                  Text(bio, style: TextStyle(color: KSTheme.textSecondary, fontSize: 12), maxLines: 2, overflow: TextOverflow.ellipsis),
                ])),
                const SizedBox(width: 8),
                Column(children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                    decoration: BoxDecoration(color: Colors.transparent, borderRadius: BorderRadius.circular(8), border: Border.all(color: KSTheme.teal)),
                    child: const Text('Following', style: TextStyle(color: KSTheme.teal, fontSize: 12, fontWeight: FontWeight.w600)),
                  ),
                ]),
                const SizedBox(width: 4),
                const Icon(Icons.more_vert, color: KSTheme.textSecondary, size: 18),
              ],
            ),
          ),
          const Divider(color: KSTheme.divider, height: 1),
        ],
      ),
    );
  }

  Widget _ministryItem(Map m) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 56, height: 56,
                  decoration: BoxDecoration(color: Color(m['color'] as int), borderRadius: BorderRadius.circular(12)),
                  child: Icon(m['icon'] as IconData, color: KSTheme.gold, size: 28),
                ),
                const SizedBox(width: 12),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(m['name'] as String, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15)),
                  Text(m['handle'] as String, style: TextStyle(color: KSTheme.teal, fontSize: 12)),
                  const SizedBox(height: 2),
                  Text(m['desc'] as String, style: TextStyle(color: KSTheme.textSecondary, fontSize: 12), maxLines: 2, overflow: TextOverflow.ellipsis),
                ])),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                  decoration: BoxDecoration(color: Colors.transparent, borderRadius: BorderRadius.circular(8), border: Border.all(color: KSTheme.teal)),
                  child: const Text('Following', style: TextStyle(color: KSTheme.teal, fontSize: 12, fontWeight: FontWeight.w600)),
                ),
                const SizedBox(width: 4),
                const Icon(Icons.more_vert, color: KSTheme.textSecondary, size: 18),
              ],
            ),
          ),
          const Divider(color: KSTheme.divider, height: 1),
        ],
      ),
    );
  }

  Widget _channelItem(Map c) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 70, height: 56,
                  decoration: BoxDecoration(color: Color(c['color'] as int), borderRadius: BorderRadius.circular(10)),
                  child: Center(child: c['name'] == 'KingdomShift.Live Podcast'
                      ? ClipRRect(borderRadius: BorderRadius.circular(10), child: Image.asset('assets/images/ks_logo.png', fit: BoxFit.cover, width: 70, height: 56))
                      : Icon(Icons.play_circle_outline, color: KSTheme.teal, size: 28)),
                ),
                const SizedBox(width: 12),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(c['name'] as String, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15)),
                  Text(c['handle'] as String, style: TextStyle(color: KSTheme.textSecondary, fontSize: 11)),
                  const SizedBox(height: 2),
                  Text(c['desc'] as String, style: TextStyle(color: KSTheme.textSecondary, fontSize: 12), maxLines: 2, overflow: TextOverflow.ellipsis),
                ])),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                  decoration: BoxDecoration(color: Colors.transparent, borderRadius: BorderRadius.circular(8), border: Border.all(color: KSTheme.teal)),
                  child: const Text('Following', style: TextStyle(color: KSTheme.teal, fontSize: 12, fontWeight: FontWeight.w600)),
                ),
                const SizedBox(width: 4),
                const Icon(Icons.more_vert, color: KSTheme.textSecondary, size: 18),
              ],
            ),
          ),
          const Divider(color: KSTheme.divider, height: 1),
        ],
      ),
    );
  }
}
