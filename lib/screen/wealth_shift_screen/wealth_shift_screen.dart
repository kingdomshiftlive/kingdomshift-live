import 'package:flutter/material.dart';

class WealthShiftScreen extends StatelessWidget {
  const WealthShiftScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0F),
      body: SafeArea(
          child: SingleChildScrollView(
        child: Column(children: [
          _buildHero(),
          _buildStats(),
          _buildCourses(),
          _buildTools(),
          _buildCommunity(),
          const SizedBox(height: 80),
        ]),
      )),
    );
  }

  Widget _buildHero() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: const LinearGradient(
            colors: [Color(0xFF0D2000), Color(0xFF1A3500)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight),
        border: Border.all(color: Colors.green.withValues(alpha: 0.3)),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
                color: Colors.green.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(8)),
            child: const Text('WEALTHSHIFT',
                style: TextStyle(
                    color: Colors.green,
                    fontSize: 12,
                    fontWeight: FontWeight.bold))),
        const SizedBox(height: 12),
        const Text('SHIFT YOUR MINDSET. BUILD YOUR WEALTH.',
            style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        const Text(
            'Kingdom principles for financial freedom and generational legacy.',
            style: TextStyle(color: Colors.white70, fontSize: 13)),
        const SizedBox(height: 16),
        Row(children: [
          _wealthBtn('Start Learning', Colors.green, () {}),
          const SizedBox(width: 12),
          _wealthBtn('Wealth Check', const Color(0xFF1A1A2E), () {}),
        ]),
      ]),
    );
  }

  Widget _buildStats() {
    final List<Map<String, String>> stats = [
      {'label': 'Members', 'value': '24.8K'},
      {'label': 'Courses', 'value': '48'},
      {'label': 'Avg Growth', 'value': '+312%'},
      {'label': 'Coaches', 'value': '12'},
    ];
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
          children: stats
              .map((s) => Expanded(
                      child: Container(
                    margin: const EdgeInsets.only(right: 8),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                        color: const Color(0xFF0D2000),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                            color: Colors.green.withValues(alpha: 0.2))),
                    child: Column(children: [
                      Text(s['value']!,
                          style: const TextStyle(
                              color: Colors.green,
                              fontWeight: FontWeight.bold,
                              fontSize: 16)),
                      Text(s['label']!,
                          style: const TextStyle(
                              color: Colors.white54, fontSize: 11),
                          textAlign: TextAlign.center),
                    ]),
                  )))
              .toList()),
    );
  }

  Widget _buildCourses() {
    final List<Map<String, dynamic>> courses = [
      {
        'icon': '🏦',
        'title': 'Kingdom Banking',
        'lessons': '12 lessons',
        'color': Colors.blue
      },
      {
        'icon': '📊',
        'title': 'Stock and Crypto',
        'lessons': '18 lessons',
        'color': Colors.green
      },
      {
        'icon': '🏠',
        'title': 'Real Estate',
        'lessons': '15 lessons',
        'color': Colors.orange
      },
      {
        'icon': '💼',
        'title': 'Business Credit',
        'lessons': '10 lessons',
        'color': Colors.purple
      },
    ];
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text('Wealth Courses',
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
              childAspectRatio: 1.3),
          itemCount: courses.length,
          itemBuilder: (_, i) {
            final course = courses[i];
            return Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFF12121E),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                    color: (course['color'] as Color).withValues(alpha: 0.3)),
              ),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(course['icon'] as String,
                        style: const TextStyle(fontSize: 30)),
                    const Spacer(),
                    Text(course['title'] as String,
                        style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 13)),
                    Text(course['lessons'] as String,
                        style: const TextStyle(
                            color: Colors.white54, fontSize: 11)),
                  ]),
            );
          },
        ),
      ]),
    );
  }

  Widget _buildTools() {
    final List<Map<String, String>> tools = [
      {
        'icon': '📋',
        'title': 'Budget Builder',
        'desc': 'Plan your Kingdom finances'
      },
      {
        'icon': '💳',
        'title': 'Debt Eliminator',
        'desc': 'Pay off debt the Kingdom way'
      },
      {
        'icon': '📈',
        'title': 'Investment Tracker',
        'desc': 'Watch your wealth grow'
      },
      {
        'icon': '🎯',
        'title': 'Goal Setter',
        'desc': 'Set and hit financial goals'
      },
    ];
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text('Wealth Tools',
            style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        ...tools.map((t) => Container(
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                  color: const Color(0xFF12121E),
                  borderRadius: BorderRadius.circular(12),
                  border:
                      Border.all(color: Colors.green.withValues(alpha: 0.15))),
              child: Row(children: [
                Text(t['icon']!, style: const TextStyle(fontSize: 28)),
                const SizedBox(width: 14),
                Expanded(
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                      Text(t['title']!,
                          style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold)),
                      Text(t['desc']!,
                          style: const TextStyle(
                              color: Colors.white54, fontSize: 12)),
                    ])),
                const Icon(Icons.arrow_forward_ios,
                    color: Colors.white38, size: 16),
              ]),
            )),
      ]),
    );
  }

  Widget _buildCommunity() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
            colors: [Color(0xFF0D2000), Color(0xFF0A0A0F)]),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.green.withValues(alpha: 0.3)),
      ),
      child: Row(children: [
        const Text('🌳', style: TextStyle(fontSize: 44)),
        const SizedBox(width: 16),
        const Expanded(
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Wealth is a Fruit. Heaven is the Root.',
              style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 14)),
          SizedBox(height: 4),
          Text('Join 24.8K Kingdom wealth builders.',
              style: TextStyle(color: Colors.white54, fontSize: 12)),
        ])),
        _wealthBtn('Join Now', Colors.green, () {}),
      ]),
    );
  }

  Widget _wealthBtn(String label, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
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
