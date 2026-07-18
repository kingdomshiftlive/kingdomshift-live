import 'package:flutter/material.dart';
import '../../theme/ks_theme.dart';

class PodcastScreen extends StatefulWidget {
  const PodcastScreen({super.key});
  @override
  State<PodcastScreen> createState() => _PodcastScreenState();
}

class _PodcastScreenState extends State<PodcastScreen> {
  String selectedFilter = 'All';
  final filters = ['All', 'Faith', 'Leadership', 'Family', 'Purpose', 'Bible Study', 'More'];

  final topEpisodes = [
    {'title': 'Faith Over Fear', 'desc': 'How to trust God in uncertain times.', 'date': 'May 18, 2024', 'duration': '32 min', 'color': 0xFF1A2A1A},
    {'title': 'Walk by Faith, Not by Sight', 'desc': 'Living with confidence in God\'s plan.', 'date': 'May 11, 2024', 'duration': '28 min', 'color': 0xFF0A1A2A},
    {'title': 'Kingdom Leadership', 'desc': 'Leading with humility and vision.', 'date': 'May 4, 2024', 'duration': '35 min', 'color': 0xFF1A1A2A},
    {'title': 'The Heart of Worship', 'desc': 'Worship that pleases God.', 'date': 'Apr 27, 2024', 'duration': '30 min', 'color': 0xFF2A1A0A},
  ];

  final popularShows = [
    {'title': 'Kingdom\nConversations', 'host': 'Pastor James', 'episodes': '24 Episodes', 'color': 0xFF0A2A2A},
    {'title': 'Built to\nInspire', 'host': 'Sarah Johnson', 'episodes': '18 Episodes', 'color': 0xFF1A1A2A},
    {'title': 'Purpose\nUnleashed', 'host': 'David Miller', 'episodes': '20 Episodes', 'color': 0xFF1A2A3A},
    {'title': 'Daily Word', 'host': 'Randy Smith', 'episodes': '28 Episodes', 'color': 0xFF2A1A0A},
    {'title': 'Faith in\nAction', 'host': 'Lisa Brown', 'episodes': '16 Episodes', 'color': 0xFF2A2A1A},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: KSTheme.bgDark,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            // Header
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                child: Row(
                  children: [
                    Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      const Text('Podcasts', style: TextStyle(color: Colors.white, fontSize: 26, fontWeight: FontWeight.bold)),
                      Text('Faith-filled conversations to inspire and equip you.', style: TextStyle(color: KSTheme.textSecondary, fontSize: 12)),
                    ]),
                    const Spacer(),
                    IconButton(icon: const Icon(Icons.search, color: Colors.white), onPressed: () {}),
                    Stack(children: [
                      IconButton(icon: const Icon(Icons.notifications_outlined, color: Colors.white), onPressed: () {}),
                      Positioned(top: 8, right: 8, child: Container(width: 16, height: 16, decoration: const BoxDecoration(color: KSTheme.teal, shape: BoxShape.circle), child: const Center(child: Text('3', style: TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold))))),
                    ]),
                  ],
                ),
              ),
            ),
            // Filter chips
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: SizedBox(
                  height: 36,
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
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                          decoration: BoxDecoration(color: isSelected ? KSTheme.teal : KSTheme.bgCard, borderRadius: BorderRadius.circular(20), border: Border.all(color: isSelected ? KSTheme.teal : KSTheme.divider)),
                          child: Text(filters[i], style: TextStyle(color: isSelected ? Colors.white : KSTheme.textSecondary, fontSize: 13, fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal)),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
            // Featured podcast hero
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Container(
                  height: 200,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: KSTheme.teal.withValues(alpha: 0.5)),
                    gradient: const LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [Color(0xFF0D2137), Color(0xFF0A1628)]),
                  ),
                  child: Stack(
                    children: [
                      Positioned(right: 16, top: 0, bottom: 0,
                        child: const Icon(Icons.mic, color: Color(0xFF00C9C8), size: 100, shadows: [Shadow(color: Color(0xFF00C9C8), blurRadius: 20)])),
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4), decoration: BoxDecoration(color: KSTheme.teal, borderRadius: BorderRadius.circular(6)), child: const Text('FEATURED', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold))),
                            const SizedBox(height: 8),
                            const Text('Kingdom Conversations', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                            Text('with Pastor James', style: TextStyle(color: KSTheme.teal, fontSize: 14, fontWeight: FontWeight.w600)),
                            const SizedBox(height: 6),
                            const Text('Real talk. Kingdom impact.\nNew episodes every week.', style: TextStyle(color: Colors.white70, fontSize: 12)),
                            const Spacer(),
                            Row(children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                                decoration: BoxDecoration(color: KSTheme.teal, borderRadius: BorderRadius.circular(20)),
                                child: const Row(children: [Icon(Icons.play_arrow, color: Colors.white, size: 16), SizedBox(width: 4), Text('Latest Episode', style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold))]),
                              ),
                              const SizedBox(width: 10),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                                decoration: BoxDecoration(color: Colors.transparent, borderRadius: BorderRadius.circular(20), border: Border.all(color: KSTheme.teal)),
                                child: const Row(children: [Icon(Icons.add_circle_outline, color: KSTheme.teal, size: 16), SizedBox(width: 4), Text('Follow', style: TextStyle(color: KSTheme.teal, fontSize: 12, fontWeight: FontWeight.bold))]),
                              ),
                            ]),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            // Page dots
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 10),
                child: Row(mainAxisAlignment: MainAxisAlignment.center, children: List.generate(4, (i) => Container(
                  margin: const EdgeInsets.symmetric(horizontal: 3),
                  width: i == 0 ? 16 : 6, height: 6,
                  decoration: BoxDecoration(color: i == 0 ? KSTheme.teal : KSTheme.divider, borderRadius: BorderRadius.circular(3)),
                ))),
              ),
            ),
            // Top Episodes
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
                child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                  const Text('Top Episodes', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                  Text('See All >', style: TextStyle(color: KSTheme.teal, fontSize: 13, fontWeight: FontWeight.w600)),
                ]),
              ),
            ),
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (_, i) {
                  final ep = topEpisodes[i];
                  return Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                    child: Row(
                      children: [
                        Container(
                          width: 60, height: 60,
                          decoration: BoxDecoration(color: Color(ep['color'] as int), borderRadius: BorderRadius.circular(10)),
                          child: Center(child: Text(ep['title']!.split(' ').take(2).join('\n'), style: const TextStyle(color: Colors.white, fontSize: 8, fontWeight: FontWeight.bold), textAlign: TextAlign.center)),
                        ),
                        const SizedBox(width: 12),
                        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          Text(ep['title']!, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 14)),
                          Text(ep['desc']!, style: TextStyle(color: KSTheme.textSecondary, fontSize: 12)),
                          const SizedBox(height: 2),
                          Text('${ep['date']}  •  ${ep['duration']}', style: TextStyle(color: KSTheme.textSecondary, fontSize: 11)),
                        ])),
                        Container(width: 36, height: 36, decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: KSTheme.teal), color: Colors.transparent), child: const Icon(Icons.play_arrow, color: KSTheme.teal, size: 20)),
                        const SizedBox(width: 8),
                        const Icon(Icons.more_vert, color: KSTheme.textSecondary, size: 20),
                      ],
                    ),
                  );
                },
                childCount: topEpisodes.length,
              ),
            ),
            // Popular Shows
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
                child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                  const Text('Popular Shows', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
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
                  itemCount: popularShows.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 10),
                  itemBuilder: (_, i) {
                    final show = popularShows[i];
                    return Container(
                      width: 120,
                      decoration: BoxDecoration(color: KSTheme.bgCard, borderRadius: BorderRadius.circular(14), border: Border.all(color: KSTheme.divider)),
                      child: Column(
                        children: [
                          Expanded(child: Container(
                            decoration: BoxDecoration(color: Color(show['color'] as int), borderRadius: const BorderRadius.vertical(top: Radius.circular(14))),
                            child: Center(child: Text(show['title']!, style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold), textAlign: TextAlign.center)),
                          )),
                          Padding(
                            padding: const EdgeInsets.all(8),
                            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                              Text(show['title']!.replaceAll('\n', ' '), style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold), maxLines: 1, overflow: TextOverflow.ellipsis),
                              Text(show['host']!, style: TextStyle(color: KSTheme.teal, fontSize: 10)),
                              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                                Text(show['episodes']!, style: TextStyle(color: KSTheme.textSecondary, fontSize: 9)),
                                const Icon(Icons.more_vert, color: KSTheme.textSecondary, size: 14),
                              ]),
                            ]),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ),
            // Continue Listening
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 20, 16, 12),
                child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                  const Text('Continue Listening', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                  Text('See All >', style: TextStyle(color: KSTheme.teal, fontSize: 13, fontWeight: FontWeight.w600)),
                ]),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: KSTheme.cardDecoration,
                  child: Row(children: [
                    Container(width: 56, height: 56, decoration: BoxDecoration(color: const Color(0xFF1A2A1A), borderRadius: BorderRadius.circular(8)),
                      child: const Center(child: Text('FAITH\nOVER\nFEAR', style: TextStyle(color: Colors.white, fontSize: 7, fontWeight: FontWeight.bold), textAlign: TextAlign.center))),
                    const SizedBox(width: 12),
                    Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      const Text('Faith Over Fear', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
                      Text('Pastor James', style: TextStyle(color: KSTheme.textSecondary, fontSize: 12)),
                      const SizedBox(height: 6),
                      ClipRRect(borderRadius: BorderRadius.circular(4), child: LinearProgressIndicator(value: 18.4 / 32.0, backgroundColor: KSTheme.divider, valueColor: const AlwaysStoppedAnimation<Color>(KSTheme.teal), minHeight: 4)),
                      const SizedBox(height: 4),
                      const Text('18:40 / 32:00', style: TextStyle(color: KSTheme.textSecondary, fontSize: 10)),
                    ])),
                    const SizedBox(width: 8),
                    Container(width: 36, height: 36, decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: KSTheme.teal)), child: const Icon(Icons.play_arrow, color: KSTheme.teal, size: 20)),
                    const SizedBox(width: 6),
                    Container(width: 32, height: 32, decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: KSTheme.divider)), child: const Icon(Icons.replay_30, color: Colors.white, size: 16)),
                  ]),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
