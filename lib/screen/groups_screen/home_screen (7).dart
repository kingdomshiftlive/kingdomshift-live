import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:share_plus/share_plus.dart';
import 'package:video_player/video_player.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shortzz/common/service/api/post_service.dart';
import 'package:shortzz/common/manager/session_manager.dart';
import 'package:shortzz/utilities/colors.dart';
import 'package:shortzz/screen/comment_sheet/comment_sheet.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  int _selectedTab = 0;
  final _tabs = ['For You', 'Following', 'Creator Network', 'Live'];

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
      backgroundColor: const Color(0xFF0A0E1A),
      body: SafeArea(
        child: Column(children: [
          _buildHeader(),
          _buildStoriesRow(),
          _buildTabBar(),
          Expanded(child: _buildFeed()),
        ]),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(children: [
        // Logo
        Row(children: [
          Container(
            width: 36, height: 36,
            decoration: const BoxDecoration(shape: BoxShape.circle),
            child: const Icon(Icons.workspace_premium_rounded, color: Color(0xFFC9A84C), size: 32),
          ),
          const SizedBox(width: 6),
          RichText(text: const TextSpan(children: [
            TextSpan(text: 'KINGDOM\n', style: TextStyle(color: Color(0xFFC9A84C), fontSize: 13, fontWeight: FontWeight.w900, height: 1.1)),
            TextSpan(text: 'SHIFT', style: TextStyle(color: Color(0xFF00D4C8), fontSize: 13, fontWeight: FontWeight.w900)),
            TextSpan(text: '.LIVE', style: TextStyle(color: Color(0xFFFF1493), fontSize: 13, fontWeight: FontWeight.w900)),
          ])),
        ]),
        const Spacer(),
        // Search
        IconButton(icon: const Icon(Icons.search, color: Colors.white, size: 24), onPressed: () {}),
        // Notifications
        Stack(children: [
          IconButton(icon: const Icon(Icons.notifications_outlined, color: Colors.white, size: 24), onPressed: () {}),
          Positioned(top: 8, right: 8, child: Container(
            width: 16, height: 16,
            decoration: const BoxDecoration(color: Color(0xFFFF1493), shape: BoxShape.circle),
            child: const Center(child: Text('3', style: TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold))),
          )),
        ]),
        // Coins/Profile
        Container(
          width: 36, height: 36,
          decoration: BoxDecoration(
            gradient: const LinearGradient(colors: [Color(0xFFC9A84C), Color(0xFFFFD700)]),
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.workspace_premium_rounded, color: Colors.white, size: 20),
        ),
      ]),
    );
  }

  Widget _buildStoriesRow() {
    final stories = [
      ('KS Live', true, true),
      ('@ministerjay', false, false),
      ('@iamfaith', false, false),
      ('@dbaker', false, false),
      ('@chri', false, false),
    ];
    return SizedBox(
      height: 95,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        children: [
          // Your Story
          Padding(
            padding: const EdgeInsets.only(right: 14),
            child: Column(children: [
              Stack(children: [
                Container(
                  width: 60, height: 60,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: const Color(0xFF00D4C8), width: 2),
                    color: const Color(0xFF1A2035),
                  ),
                  child: const Icon(Icons.person, color: Colors.white54, size: 30),
                ),
                Positioned(bottom: 0, right: 0, child: Container(
                  width: 20, height: 20,
                  decoration: BoxDecoration(
                    color: const Color(0xFF00D4C8),
                    shape: BoxShape.circle,
                    border: Border.all(color: const Color(0xFF0A0E1A), width: 2),
                  ),
                  child: const Icon(Icons.add, color: Colors.white, size: 12),
                )),
              ]),
              const SizedBox(height: 4),
              const Text('Your Story', style: TextStyle(color: Colors.white70, fontSize: 10)),
            ]),
          ),
          ...stories.map((s) => Padding(
            padding: const EdgeInsets.only(right: 14),
            child: Column(children: [
              Stack(children: [
                Container(
                  padding: const EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: s.$2
                          ? [const Color(0xFFFF1493), const Color(0xFFC9A84C)]
                          : [const Color(0xFF00D4C8), const Color(0xFF1A6BFF)],
                    ),
                  ),
                  child: Container(
                    padding: const EdgeInsets.all(2),
                    decoration: const BoxDecoration(color: Color(0xFF0A0E1A), shape: BoxShape.circle),
                    child: Container(
                      width: 52, height: 52,
                      decoration: const BoxDecoration(color: Color(0xFF1A2035), shape: BoxShape.circle),
                      child: s.$2
                          ? const Icon(Icons.workspace_premium_rounded, color: Color(0xFFC9A84C), size: 28)
                          : const Icon(Icons.person, color: Colors.white54, size: 26),
                    ),
                  ),
                ),
                if (s.$2) Positioned(bottom: 2, left: 0, right: 0, child: Center(child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                  decoration: BoxDecoration(color: const Color(0xFFFF1493), borderRadius: BorderRadius.circular(4)),
                  child: const Text('LIVE', style: TextStyle(color: Colors.white, fontSize: 7, fontWeight: FontWeight.bold)),
                ))),
              ]),
              const SizedBox(height: 4),
              Text(s.$1, style: const TextStyle(color: Colors.white70, fontSize: 10)),
            ]),
          )),
        ],
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Color(0xFF1A2035), width: 1)),
      ),
      height: 44,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        itemCount: _tabs.length,
        itemBuilder: (_, i) {
          final isActive = _selectedTab == i;
          return GestureDetector(
            onTap: () => setState(() => _selectedTab = i),
            child: Container(
              margin: const EdgeInsets.only(right: 8),
              padding: const EdgeInsets.symmetric(horizontal: 4),
              decoration: BoxDecoration(
                border: Border(bottom: BorderSide(
                  color: isActive ? const Color(0xFF00D4C8) : Colors.transparent,
                  width: 2.5,
                )),
              ),
              child: Row(mainAxisSize: MainAxisSize.min, children: [
                Center(child: Text(_tabs[i], style: TextStyle(
                  color: isActive ? const Color(0xFF00D4C8) : Colors.white54,
                  fontSize: 13,
                  fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
                ))),
                if (i == 2) ...[
                  const SizedBox(width: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                    decoration: BoxDecoration(color: const Color(0xFFFF1493), borderRadius: BorderRadius.circular(4)),
                    child: const Text('NEW', style: TextStyle(color: Colors.white, fontSize: 8, fontWeight: FontWeight.bold)),
                  ),
                ],
              ]),
            ),
          );
        },
      ),
    );
  }

  Widget _buildFeed() {
    // Sample posts for UI demonstration
    final posts = [
      {
        'name': 'Minister Jay',
        'handle': '@ministerjay',
        'time': '2h ago',
        'text': "You don't have to see the whole staircase, just take the first step in faith.",
        'hashtag': '#KingdomMindset',
        'likes': '12.4K',
        'comments': '342',
        'shares': '1.2K',
        'verified': true,
      },
      {
        'name': 'Faith Walker',
        'handle': '@iamfaith',
        'time': '4h ago',
        'text': 'Worship is more than a song, it\'s a lifestyle.',
        'hashtag': '#ShiftHappens',
        'likes': '8.2K',
        'comments': '218',
        'shares': '945',
        'verified': true,
      },
      {
        'name': 'David Baker',
        'handle': '@dbaker',
        'time': '6h ago',
        'text': 'Kingdom principles work in every area of life. Business, family, health.',
        'hashtag': '#KingdomBusiness',
        'likes': '5.1K',
        'comments': '127',
        'shares': '432',
        'verified': false,
      },
    ];

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      itemCount: posts.length,
      itemBuilder: (_, i) => _buildPostCard(posts[i]),
    );
  }

  Widget _buildPostCard(Map post) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF0F1628),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF1A2035), width: 1),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        // Header
        Padding(
          padding: const EdgeInsets.all(12),
          child: Row(children: [
            Container(
              width: 42, height: 42,
              decoration: const BoxDecoration(color: Color(0xFF1A2035), shape: BoxShape.circle),
              child: const Icon(Icons.person, color: Colors.white54, size: 22),
            ),
            const SizedBox(width: 10),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                Text(post['name'], style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
                if (post['verified'] == true) ...[
                  const SizedBox(width: 4),
                  const Icon(Icons.verified, color: Color(0xFF00D4C8), size: 14),
                ],
              ]),
              Text('${post['handle']} • ${post['time']}', style: const TextStyle(color: Colors.white54, fontSize: 12)),
            ])),
            const Icon(Icons.more_horiz, color: Colors.white54),
          ]),
        ),
        // Text
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(post['text'], style: const TextStyle(color: Colors.white, fontSize: 14, height: 1.4)),
            const SizedBox(height: 4),
            Text(post['hashtag'], style: const TextStyle(color: Color(0xFF00D4C8), fontSize: 13, fontWeight: FontWeight.w600)),
          ]),
        ),
        const SizedBox(height: 10),
        // Video thumbnail
        Stack(children: [
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 12),
            height: 180,
            decoration: BoxDecoration(
              color: const Color(0xFF1A2035),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Center(child: Icon(Icons.play_circle_outline, color: Color(0xFF00D4C8), size: 50)),
          ),
          Positioned(bottom: 8, left: 20, child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(color: Colors.black54, borderRadius: BorderRadius.circular(4)),
            child: const Text('01:32', style: TextStyle(color: Colors.white, fontSize: 11)),
          )),
          Positioned(bottom: 8, right: 20, child: Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(color: Colors.black54, borderRadius: BorderRadius.circular(4)),
            child: const Icon(Icons.fullscreen, color: Colors.white, size: 16),
          )),
        ]),
        const SizedBox(height: 10),
        // Actions
        Padding(
          padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
          child: Row(children: [
            _actionBtn(Icons.favorite_border, post['likes'], const Color(0xFFFF1493)),
            const SizedBox(width: 16),
            _actionBtn(Icons.chat_bubble_outline, post['comments'], Colors.white70),
            const SizedBox(width: 16),
            _actionBtn(Icons.reply_outlined, post['shares'], Colors.white70),
            const Spacer(),
            const Icon(Icons.bookmark_border, color: Colors.white54, size: 20),
          ]),
        ),
      ]),
    );
  }

  Widget _actionBtn(IconData icon, String count, Color color) {
    return Row(children: [
      Icon(icon, color: color, size: 20),
      const SizedBox(width: 4),
      Text(count, style: TextStyle(color: color, fontSize: 13, fontWeight: FontWeight.w600)),
    ]);
  }
}
