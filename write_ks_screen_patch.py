from pathlib import Path

brand = r"""
const ksBg = Color(0xFF08141F);
const ksCard = Color(0xFF0D2035);
const ksTeal = Color(0xFF005574);
const ksAqua = Color(0xFF00D4C7);
const ksGold = Color(0xFFD4AF37);
const ksPink = Color(0xFFFF4FA3);
const ksWhite = Color(0xFFFFFFFF);
const ksMuted = Color(0xFFA7B7CC);
"""

Path("lib/screen/explore_screen/explore_screen.dart").write_text(r'''
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shortzz/screen/search_screen/search_screen.dart';

const ksBg = Color(0xFF08141F);
const ksCard = Color(0xFF0D2035);
const ksTeal = Color(0xFF005574);
const ksAqua = Color(0xFF00D4C7);
const ksGold = Color(0xFFD4AF37);
const ksPink = Color(0xFFFF4FA3);
const ksWhite = Color(0xFFFFFFFF);
const ksMuted = Color(0xFFA7B7CC);

class ExploreScreen extends StatelessWidget {
  const ExploreScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final chips = ['For You', 'Trending', 'Creators', 'Live', 'Marketplace', 'Groups'];
    final cards = [
      ['Creator Spotlights', Icons.auto_awesome, ksGold],
      ['Trending Videos', Icons.play_circle_fill_rounded, ksPink],
      ['Marketplace Finds', Icons.shopping_bag_rounded, ksAqua],
      ['Community Groups', Icons.groups_rounded, ksGold],
      ['Live Rooms', Icons.sensors_rounded, ksPink],
      ['Podcasts', Icons.mic_rounded, ksAqua],
    ];

    return Scaffold(
      backgroundColor: ksBg,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 110),
          children: [
            Row(
              children: [
                Image.asset('assets/images/ks_logo.png', width: 42, height: 42),
                const SizedBox(width: 10),
                const Expanded(
                  child: Text(
                    'Explore',
                    style: TextStyle(color: ksWhite, fontSize: 26, fontWeight: FontWeight.w900),
                  ),
                ),
                IconButton(
                  onPressed: () => Get.to(() => const SearchScreen()),
                  icon: const Icon(Icons.search_rounded, color: ksWhite),
                ),
              ],
            ),
            const SizedBox(height: 16),
            GestureDetector(
              onTap: () => Get.to(() => const SearchScreen()),
              child: Container(
                height: 48,
                padding: const EdgeInsets.symmetric(horizontal: 14),
                decoration: BoxDecoration(
                  color: ksCard,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: ksAqua.withValues(alpha: .25)),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.search_rounded, color: ksMuted),
                    SizedBox(width: 10),
                    Text('Search creators, videos, groups, products...', style: TextStyle(color: ksMuted)),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 18),
            SizedBox(
              height: 38,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: chips.length,
                separatorBuilder: (_, __) => const SizedBox(width: 8),
                itemBuilder: (_, i) {
                  final selected = i == 0;
                  return Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: selected ? ksTeal : ksCard,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: selected ? ksAqua : Colors.white12),
                    ),
                    child: Text(chips[i], style: TextStyle(color: selected ? ksWhite : ksMuted, fontWeight: FontWeight.w700)),
                  );
                },
              ),
            ),
            const SizedBox(height: 22),
            const Text('Discover what is moving now', style: TextStyle(color: ksWhite, fontSize: 18, fontWeight: FontWeight.w800)),
            const SizedBox(height: 12),
            GridView.builder(
              itemCount: cards.length,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: .92,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
              ),
              itemBuilder: (_, i) {
                final c = cards[i];
                return Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [ksCard, (c[2] as Color).withValues(alpha: .12)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: (c[2] as Color).withValues(alpha: .35)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(c[1] as IconData, color: c[2] as Color, size: 34),
                      const Spacer(),
                      Text(c[0] as String, style: const TextStyle(color: ksWhite, fontSize: 16, fontWeight: FontWeight.w900)),
                      const SizedBox(height: 6),
                      const Text('Tap to explore live content', style: TextStyle(color: ksMuted, fontSize: 12)),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
''', encoding="utf-8")

Path("lib/screen/notification_screen/notification_screen.dart").write_text(r'''
import 'package:flutter/material.dart';

const ksBg = Color(0xFF08141F);
const ksCard = Color(0xFF0D2035);
const ksTeal = Color(0xFF005574);
const ksAqua = Color(0xFF00D4C7);
const ksGold = Color(0xFFD4AF37);
const ksPink = Color(0xFFFF4FA3);
const ksWhite = Color(0xFFFFFFFF);
const ksMuted = Color(0xFFA7B7CC);

class NotificationScreen extends StatelessWidget {
  const NotificationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final items = [
      ['New follower', 'A creator started following you.', Icons.person_add_alt_1_rounded, ksAqua],
      ['Live reminder', 'A live room is ready to join.', Icons.sensors_rounded, ksPink],
      ['Marketplace', 'Someone viewed your product listing.', Icons.shopping_bag_rounded, ksGold],
      ['Comment activity', 'New replies are showing on your post.', Icons.chat_bubble_rounded, ksAqua],
      ['KingdomAI', 'Your idea prompt is ready to continue.', Icons.auto_awesome_rounded, ksGold],
    ];

    return Scaffold(
      backgroundColor: ksBg,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 110),
          children: [
            Row(
              children: [
                Image.asset('assets/images/ks_logo.png', width: 42, height: 42),
                const SizedBox(width: 10),
                const Expanded(
                  child: Text('Alerts', style: TextStyle(color: ksWhite, fontSize: 26, fontWeight: FontWeight.w900)),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(color: ksTeal, borderRadius: BorderRadius.circular(14)),
                  child: const Text('Live', style: TextStyle(color: ksWhite, fontWeight: FontWeight.w800, fontSize: 12)),
                ),
              ],
            ),
            const SizedBox(height: 18),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: ksCard,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: ksGold.withValues(alpha: .35)),
              ),
              child: const Row(
                children: [
                  Icon(Icons.notifications_active_rounded, color: ksGold, size: 32),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Stay connected to creators, lives, messages, marketplace updates, and community activity.',
                      style: TextStyle(color: ksMuted, height: 1.35),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),
            const Text('Today', style: TextStyle(color: ksWhite, fontSize: 18, fontWeight: FontWeight.w800)),
            const SizedBox(height: 10),
            ...items.map((item) {
              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: ksCard,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: (item[3] as Color).withValues(alpha: .25)),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 46,
                      height: 46,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: (item[3] as Color).withValues(alpha: .12),
                        border: Border.all(color: item[3] as Color),
                      ),
                      child: Icon(item[2] as IconData, color: item[3] as Color),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Text(item[0] as String, style: const TextStyle(color: ksWhite, fontWeight: FontWeight.w900)),
                        const SizedBox(height: 4),
                        Text(item[1] as String, style: const TextStyle(color: ksMuted, fontSize: 12)),
                      ]),
                    ),
                    const Icon(Icons.chevron_right_rounded, color: ksMuted),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}
''', encoding="utf-8")

Path("lib/screen/profile_screen/profile_screen.dart").write_text(r'''
import 'package:flutter/material.dart';
import 'package:shortzz/common/manager/session_manager.dart';
import 'package:shortzz/model/user_model/user_model.dart';

const ksBg = Color(0xFF08141F);
const ksCard = Color(0xFF0D2035);
const ksTeal = Color(0xFF005574);
const ksAqua = Color(0xFF00D4C7);
const ksGold = Color(0xFFD4AF37);
const ksPink = Color(0xFFFF4FA3);
const ksWhite = Color(0xFFFFFFFF);
const ksMuted = Color(0xFFA7B7CC);

class ProfileScreen extends StatelessWidget {
  final User? user;
  final bool isTopBarVisible;
  final bool isDashBoard;
  final Function(User? user)? onUserUpdate;

  const ProfileScreen({
    super.key,
    this.user,
    this.isTopBarVisible = true,
    this.isDashBoard = false,
    this.onUserUpdate,
  });

  @override
  Widget build(BuildContext context) {
    final current = user ?? SessionManager.instance.getUser();
    final name = current?.fullname?.trim().isNotEmpty == true ? current!.fullname! : 'KingdomShift Creator';
    final username = current?.username?.trim().isNotEmpty == true ? current!.username! : 'creator';
    final avatar = current?.profilePhoto;

    return Scaffold(
      backgroundColor: ksBg,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 120),
          children: [
            Row(
              children: [
                Image.asset('assets/images/ks_logo.png', width: 42, height: 42),
                const SizedBox(width: 10),
                const Expanded(
                  child: Text('Profile', style: TextStyle(color: ksWhite, fontSize: 26, fontWeight: FontWeight.w900)),
                ),
                IconButton(onPressed: () {}, icon: const Icon(Icons.settings_outlined, color: ksWhite)),
              ],
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: ksCard,
                borderRadius: BorderRadius.circular(28),
                border: Border.all(color: ksAqua.withValues(alpha: .28)),
                boxShadow: [BoxShadow(color: ksAqua.withValues(alpha: .12), blurRadius: 18)],
              ),
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 46,
                    backgroundColor: ksTeal,
                    backgroundImage: avatar != null && avatar.isNotEmpty ? NetworkImage(avatar) : null,
                    child: avatar == null || avatar.isEmpty
                        ? const Icon(Icons.person_rounded, color: ksWhite, size: 46)
                        : null,
                  ),
                  const SizedBox(height: 12),
                  Text(name, textAlign: TextAlign.center, style: const TextStyle(color: ksWhite, fontSize: 22, fontWeight: FontWeight.w900)),
                  const SizedBox(height: 4),
                  Text('@$username', style: const TextStyle(color: ksAqua, fontWeight: FontWeight.w700)),
                  const SizedBox(height: 10),
                  const Text(
                    'Build your purpose, share your voice, connect with community, and grow your marketplace influence.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: ksMuted, height: 1.35),
                  ),
                  const SizedBox(height: 18),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _stat('0', 'Posts'),
                      _stat('${current?.followerCount ?? 0}', 'Followers'),
                      _stat('${current?.followingCount ?? 0}', 'Following'),
                      _stat('${current?.totalPostLikesCount ?? 0}', 'Likes'),
                    ],
                  ),
                  const SizedBox(height: 18),
                  Row(
                    children: [
                      Expanded(child: _button('Edit Profile', ksTeal, ksWhite)),
                      const SizedBox(width: 10),
                      Expanded(child: _outlineButton('Creator Hub')),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            const Text('Creator Spaces', style: TextStyle(color: ksWhite, fontSize: 18, fontWeight: FontWeight.w900)),
            const SizedBox(height: 12),
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              childAspectRatio: 1.25,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              children: const [
                _space(Icons.video_collection_rounded, 'Videos', ksPink),
                _space(Icons.storefront_rounded, 'Marketplace', ksGold),
                _space(Icons.groups_rounded, 'Groups', ksAqua),
                _space(Icons.mic_rounded, 'Podcasts', ksGold),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _stat(String value, String label) {
    return Column(
      children: [
        Text(value, style: const TextStyle(color: ksWhite, fontSize: 17, fontWeight: FontWeight.w900)),
        const SizedBox(height: 3),
        Text(label, style: const TextStyle(color: ksMuted, fontSize: 11)),
      ],
    );
  }

  Widget _button(String text, Color bg, Color fg) {
    return Container(
      height: 42,
      alignment: Alignment.center,
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(22)),
      child: Text(text, style: TextStyle(color: fg, fontWeight: FontWeight.w900)),
    );
  }

  Widget _outlineButton(String text) {
    return Container(
      height: 42,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        border: Border.all(color: ksGold.withValues(alpha: .7)),
        borderRadius: BorderRadius.circular(22),
      ),
      child: Text(text, style: const TextStyle(color: ksGold, fontWeight: FontWeight.w900)),
    );
  }
}

class _space extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;

  const _space(this.icon, this.label, this.color);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: ksCard,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: color.withValues(alpha: .3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 30),
          const Spacer(),
          Text(label, style: const TextStyle(color: ksWhite, fontWeight: FontWeight.w900)),
          const SizedBox(height: 3),
          const Text('Open space', style: TextStyle(color: ksMuted, fontSize: 11)),
        ],
      ),
    );
  }
}
''', encoding="utf-8")

print("Patched Explore, Notifications, Profile.")
