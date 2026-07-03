import 'package:flutter/material.dart';

class MinistriesScreen extends StatelessWidget {
  const MinistriesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0F),
      body: SafeArea(
          child: SingleChildScrollView(
        child: Column(children: [
          _buildHeader(),
          _buildFeaturedMinistries(),
          _buildCategories(),
          _buildNearYou(),
          const SizedBox(height: 80),
        ]),
      )),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          const Expanded(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                Text('Ministries',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 26,
                        fontWeight: FontWeight.bold)),
                Text('Connect with Kingdom builders worldwide',
                    style: TextStyle(color: Colors.white54, fontSize: 13)),
              ])),
          Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                  gradient: const LinearGradient(
                      colors: [Color(0xFF7B2FF7), Color(0xFF00C6FF)]),
                  borderRadius: BorderRadius.circular(10)),
              child: const Text('+ Add Ministry',
                  style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 13))),
        ]),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14),
          decoration: BoxDecoration(
              color: const Color(0xFF12121E),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.white12)),
          child: const Row(children: [
            Icon(Icons.search, color: Colors.white38),
            SizedBox(width: 8),
            Expanded(
                child: TextField(
              style: TextStyle(color: Colors.white),
              decoration: InputDecoration(
                  border: InputBorder.none,
                  hintText: 'Search ministries...',
                  hintStyle: TextStyle(color: Colors.white38)),
            )),
          ]),
        ),
      ]),
    );
  }

  Widget _buildFeaturedMinistries() {
    final List<Map<String, dynamic>> featured = [
      {
        'name': 'KingdomShift Church',
        'followers': '12.4K',
        'emoji': '⛪',
        'tag': 'Featured',
        'color': const Color(0xFF7B2FF7)
      },
      {
        'name': 'WealthShift Ministry',
        'followers': '8.2K',
        'emoji': '💰',
        'tag': 'Live Now',
        'color': Colors.red
      },
      {
        'name': 'Prophetess Char',
        'followers': '24.8K',
        'emoji': '👑',
        'tag': 'New',
        'color': Colors.green
      },
    ];
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const Padding(
          padding: EdgeInsets.fromLTRB(16, 0, 16, 12),
          child: Text('Featured Ministries',
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold))),
      SizedBox(
          height: 160,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: featured.length,
            itemBuilder: (_, i) {
              final m = featured[i];
              return Container(
                width: 160,
                margin: const EdgeInsets.only(right: 12),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: const Color(0xFF12121E),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                      color: (m['color'] as Color).withValues(alpha: 0.3)),
                ),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(m['emoji'] as String,
                                style: const TextStyle(fontSize: 36)),
                            Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                    color: (m['color'] as Color)
                                        .withValues(alpha: 0.2),
                                    borderRadius: BorderRadius.circular(6)),
                                child: Text(m['tag'] as String,
                                    style: TextStyle(
                                        color: m['color'] as Color,
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold))),
                          ]),
                      const Spacer(),
                      Text(m['name'] as String,
                          style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 13)),
                      Text('${m['followers']} followers',
                          style: const TextStyle(
                              color: Colors.white54, fontSize: 11)),
                      const SizedBox(height: 8),
                      Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(vertical: 6),
                          decoration: BoxDecoration(
                              color: const Color(0xFF7B2FF7),
                              borderRadius: BorderRadius.circular(8)),
                          child: const Text('Follow',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12),
                              textAlign: TextAlign.center)),
                    ]),
              );
            },
          )),
    ]);
  }

  Widget _buildCategories() {
    final List<Map<String, String>> cats = [
      {'icon': '📖', 'label': 'Teaching'},
      {'icon': '🙏', 'label': 'Prayer'},
      {'icon': '🎵', 'label': 'Worship'},
      {'icon': '💰', 'label': 'Kingdom Wealth'},
      {'icon': '👨‍👩‍👧', 'label': 'Family'},
      {'icon': '🌍', 'label': 'Missions'},
    ];
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text('Browse by Category',
            style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
              childAspectRatio: 1.2),
          itemCount: cats.length,
          itemBuilder: (_, i) => Container(
            decoration: BoxDecoration(
                color: const Color(0xFF12121E),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.white12)),
            child:
                Column(mainAxisAlignment: MainAxisAlignment.center, children: [
              Text(cats[i]['icon']!, style: const TextStyle(fontSize: 28)),
              const SizedBox(height: 4),
              Text(cats[i]['label']!,
                  style: const TextStyle(color: Colors.white70, fontSize: 11),
                  textAlign: TextAlign.center),
            ]),
          ),
        ),
      ]),
    );
  }

  Widget _buildNearYou() {
    final List<Map<String, String>> ministries = [
      {
        'name': 'Grace and Glory Church',
        'location': 'Hilo, Hawaii',
        'members': '342',
        'emoji': '⛪'
      },
      {
        'name': 'Kingdom Entrepreneurs Network',
        'location': 'Online',
        'members': '2.1K',
        'emoji': '💼'
      },
      {
        'name': 'Prophetic Voices Alliance',
        'location': 'Nationwide',
        'members': '890',
        'emoji': '🎤'
      },
    ];
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text('Near You',
            style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        ...ministries.map((m) => Container(
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                  color: const Color(0xFF12121E),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.white12)),
              child: Row(children: [
                Text(m['emoji']!, style: const TextStyle(fontSize: 32)),
                const SizedBox(width: 12),
                Expanded(
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                      Text(m['name']!,
                          style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold)),
                      Text('${m['location']} - ${m['members']} members',
                          style: const TextStyle(
                              color: Colors.white54, fontSize: 12)),
                    ])),
                Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                        color: const Color(0xFF7B2FF7).withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: const Color(0xFF7B2FF7))),
                    child: const Text('Join',
                        style: TextStyle(
                            color: Color(0xFF7B2FF7),
                            fontWeight: FontWeight.bold,
                            fontSize: 12))),
              ]),
            )),
      ]),
    );
  }
}
