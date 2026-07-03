import 'package:flutter/material.dart';

class PodcastScreen extends StatefulWidget {
  const PodcastScreen({super.key});
  @override
  State<PodcastScreen> createState() => _PodcastScreenState();
}

class _PodcastScreenState extends State<PodcastScreen> {
  int _selectedCat = 0;
  final cats = [
    'All',
    'Faith',
    'Business',
    'Health',
    'Tech',
    'Music',
    'Culture'
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0F),
      body: SafeArea(
          child: Column(children: [
        _buildHeader(),
        _buildFeatured(),
        _buildCategories(),
        Expanded(child: _buildEpisodeList()),
      ])),
      bottomSheet: _buildMiniPlayer(),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      child: Row(children: [
        Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: const LinearGradient(
                    colors: [Color(0xFF7B2FF7), Color(0xFFFF006E)])),
            child: const Icon(Icons.mic, color: Colors.white, size: 22)),
        const SizedBox(width: 12),
        const Expanded(
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Podcasts for Everyone',
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold)),
          Text('Listen, learn, and be inspired',
              style: TextStyle(color: Colors.white54, fontSize: 12)),
        ])),
        Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
                gradient: const LinearGradient(
                    colors: [Color(0xFF7B2FF7), Color(0xFF00C6FF)]),
                borderRadius: BorderRadius.circular(20)),
            child: const Text('+ Create',
                style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 12))),
      ]),
    );
  }

  Widget _buildFeatured() {
    final shows = [
      {
        'title': 'Kingdom Business',
        'host': 'Prophetess Char',
        'episodes': '48 episodes',
        'emoji': '👑'
      },
      {
        'title': 'Faith & Finance',
        'host': 'WealthShift',
        'episodes': '32 episodes',
        'emoji': '💰'
      },
      {
        'title': 'Tech Mission',
        'host': 'KS Tech Team',
        'episodes': '21 episodes',
        'emoji': '🔬'
      },
    ];
    return SizedBox(
      height: 180,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
        itemCount: shows.length,
        itemBuilder: (_, i) {
          final s = shows[i];
          return Container(
            width: 160,
            margin: const EdgeInsets.only(right: 12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              gradient: LinearGradient(colors: [
                const Color(0xFF7B2FF7).withValues(alpha: 0.3),
                const Color(0xFF12121E)
              ], begin: Alignment.topLeft, end: Alignment.bottomRight),
              border: Border.all(
                  color: const Color(0xFF7B2FF7).withValues(alpha: 0.3)),
            ),
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(s['emoji']!, style: const TextStyle(fontSize: 40)),
                    const Spacer(),
                    Text(s['title']!,
                        style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 14)),
                    Text(s['host']!,
                        style: const TextStyle(
                            color: Colors.white54, fontSize: 12)),
                    Text(s['episodes']!,
                        style: const TextStyle(
                            color: Color(0xFF7B2FF7), fontSize: 11)),
                  ]),
            ),
          );
        },
      ),
    );
  }

  Widget _buildCategories() {
    return SizedBox(
      height: 44,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
        itemCount: cats.length,
        itemBuilder: (_, i) {
          final sel = _selectedCat == i;
          return GestureDetector(
            onTap: () => setState(() => _selectedCat = i),
            child: Container(
              margin: const EdgeInsets.only(right: 8),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              decoration: BoxDecoration(
                color: sel ? const Color(0xFF7B2FF7) : const Color(0xFF12121E),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                    color: sel ? const Color(0xFF7B2FF7) : Colors.white12),
              ),
              child: Text(cats[i],
                  style: TextStyle(
                      color: sel ? Colors.white : Colors.white54,
                      fontSize: 13)),
            ),
          );
        },
      ),
    );
  }

  Widget _buildEpisodeList() {
    final episodes = [
      {
        'title': 'Building a Kingdom Business from Zero',
        'host': 'Prophetess Char',
        'duration': '48 min',
        'emoji': '👑',
        'new': true
      },
      {
        'title': 'Faith That Moves Financial Mountains',
        'host': 'Bishop Johnson',
        'duration': '35 min',
        'emoji': '⛰️',
        'new': false
      },
      {
        'title': 'How I Built a 7-Figure Ministry Online',
        'host': 'Pastor David W.',
        'duration': '52 min',
        'emoji': '📱',
        'new': true
      },
      {
        'title': 'Kingdom Principles for Real Estate',
        'host': 'WealthShift',
        'duration': '41 min',
        'emoji': '🏠',
        'new': false
      },
      {
        'title': 'The Anointing That Breaks the Yoke',
        'host': 'Prophetess Char',
        'duration': '28 min',
        'emoji': '🔥',
        'new': false
      },
    ];
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: episodes.length,
      itemBuilder: (_, i) {
        final ep = episodes[i];
        return Container(
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
              color: const Color(0xFF12121E),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.white12)),
          child: Row(children: [
            Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                    color: const Color(0xFF1A1A2E),
                    borderRadius: BorderRadius.circular(10)),
                child: Center(
                    child: Text(ep['emoji'] as String,
                        style: const TextStyle(fontSize: 28)))),
            const SizedBox(width: 12),
            Expanded(
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                  if (ep['new'] as bool)
                    Container(
                        margin: const EdgeInsets.only(bottom: 4),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                            color: Colors.green.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(4)),
                        child: const Text('NEW',
                            style: TextStyle(
                                color: Colors.green,
                                fontSize: 10,
                                fontWeight: FontWeight.bold))),
                  Text(ep['title'] as String,
                      style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 13),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis),
                  Text('${ep['host']} • ${ep['duration']}',
                      style:
                          const TextStyle(color: Colors.white54, fontSize: 12)),
                ])),
            Column(children: [
              const Icon(Icons.play_circle_fill,
                  color: Color(0xFF7B2FF7), size: 36),
              const SizedBox(height: 4),
              const Icon(Icons.download_outlined,
                  color: Colors.white38, size: 18),
            ]),
          ]),
        );
      },
    );
  }

  Widget _buildMiniPlayer() {
    return Container(
      height: 64,
      decoration: BoxDecoration(
          color: const Color(0xFF12121E),
          border: Border(
              top: BorderSide(color: Colors.white.withValues(alpha: 0.08)))),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(children: [
        const Text('👑', style: TextStyle(fontSize: 28)),
        const SizedBox(width: 12),
        const Expanded(
            child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
              Text('Building a Kingdom Business from Zero',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis),
              Text('Prophetess Char',
                  style: TextStyle(color: Colors.white54, fontSize: 11)),
            ])),
        Row(children: [
          IconButton(
              icon: const Icon(Icons.skip_previous, color: Colors.white70),
              onPressed: () {}),
          Container(
              width: 36,
              height: 36,
              decoration: const BoxDecoration(
                  color: Color(0xFF7B2FF7), shape: BoxShape.circle),
              child:
                  const Icon(Icons.play_arrow, color: Colors.white, size: 20)),
          IconButton(
              icon: const Icon(Icons.skip_next, color: Colors.white70),
              onPressed: () {}),
        ]),
      ]),
    );
  }
}
