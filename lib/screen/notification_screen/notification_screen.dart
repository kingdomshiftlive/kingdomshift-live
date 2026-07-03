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
      [
        'New follower',
        'A creator started following you.',
        Icons.person_add_alt_1_rounded,
        ksAqua
      ],
      [
        'Live reminder',
        'A live room is ready to join.',
        Icons.sensors_rounded,
        ksPink
      ],
      [
        'Marketplace',
        'Someone viewed your product listing.',
        Icons.shopping_bag_rounded,
        ksGold
      ],
      [
        'Comment activity',
        'New replies are showing on your post.',
        Icons.chat_bubble_rounded,
        ksAqua
      ],
      [
        'KingdomAI',
        'Your idea prompt is ready to continue.',
        Icons.auto_awesome_rounded,
        ksGold
      ],
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
                  child: Text('Alerts',
                      style: TextStyle(
                          color: ksWhite,
                          fontSize: 26,
                          fontWeight: FontWeight.w900)),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                      color: ksTeal, borderRadius: BorderRadius.circular(14)),
                  child: const Text('Live',
                      style: TextStyle(
                          color: ksWhite,
                          fontWeight: FontWeight.w800,
                          fontSize: 12)),
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
                  Icon(Icons.notifications_active_rounded,
                      color: ksGold, size: 32),
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
            const Text('Today',
                style: TextStyle(
                    color: ksWhite, fontSize: 18, fontWeight: FontWeight.w800)),
            const SizedBox(height: 10),
            ...items.map((item) {
              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: ksCard,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                      color: (item[3] as Color).withValues(alpha: .25)),
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
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(item[0] as String,
                                style: const TextStyle(
                                    color: ksWhite,
                                    fontWeight: FontWeight.w900)),
                            const SizedBox(height: 4),
                            Text(item[1] as String,
                                style: const TextStyle(
                                    color: ksMuted, fontSize: 12)),
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
