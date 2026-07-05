import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shortzz/screen/search_screen/search_screen.dart';
import 'package:shortzz/screen/explore_screen/explore_screen_controller.dart';

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
    final controller = Get.put(ExploreScreenController());
    final chips = [
      'For You',
      'Trending',
      'Creators',
      'Live',
      'Marketplace',
      'Groups'
    ];
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
                    style: TextStyle(
                        color: ksWhite,
                        fontSize: 26,
                        fontWeight: FontWeight.w900),
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
                    Text('Search creators, videos, groups, products...',
                        style: TextStyle(color: ksMuted)),
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
                      border:
                          Border.all(color: selected ? ksAqua : Colors.white12),
                    ),
                    child: Text(chips[i],
                        style: TextStyle(
                            color: selected ? ksWhite : ksMuted,
                            fontWeight: FontWeight.w700)),
                  );
                },
              ),
            ),
            const SizedBox(height: 22),
            const Text('Discover what is moving now',
                style: TextStyle(
                    color: ksWhite, fontSize: 18, fontWeight: FontWeight.w800)),
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
                return InkWell(
                  onTap: () {
                    if (i == 0 || i == 1) {
                      Get.to(() => const SearchScreen());
                    } else if (i == 5) {
                      controller.openPodcasts();
                    } else {
                      Get.to(() => const SearchScreen());
                    }
                  },
                  borderRadius: BorderRadius.circular(24),
                  child: Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [ksCard, (c[2] as Color).withValues(alpha: .12)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(
                        color: (c[2] as Color).withValues(alpha: .35)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(c[1] as IconData, color: c[2] as Color, size: 34),
                      const Spacer(),
                      Text(c[0] as String,
                          style: const TextStyle(
                              color: ksWhite,
                              fontSize: 16,
                              fontWeight: FontWeight.w900)),
                      const SizedBox(height: 6),
                      const Text('Tap to explore live content',
                          style: TextStyle(color: ksMuted, fontSize: 12)),
                    ],
                  ),
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
