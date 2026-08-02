import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shortzz/screen/live_stream/create_live_stream_screen/create_live_stream_screen.dart';
import 'package:shortzz/screen/live_stream/live_stream_search_screen/live_stream_search_screen.dart';
import 'package:shortzz/screen/live_stream/my_live_streams/my_live_streams_screen.dart';
import 'package:shortzz/common/manager/session_manager.dart';

const kLiveBg = Color(0xFF08141F);
const kLiveBg2 = Color(0xFF0A1A2A);
const kLiveCard = Color(0xFF0D2035);
const kLiveTeal = Color(0xFF005574);
const kLiveGold = Color(0xFFD4AF37);
const kLivePink = Color(0xFFFF2D8D);
const kLiveText = Color(0xFFFFFFFF);
const kLiveMuted = Color(0xFFA7B7CC);

class LiveDashboardScreen extends StatelessWidget {
  const LiveDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kLiveBg,
      body: SafeArea(
          child: Column(children: [
        _buildHeader(),
        Expanded(
            child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            _buildGreeting(),
            const SizedBox(height: 20),
            _buildLiveNowButton(),
            const SizedBox(height: 20),
            _buildLiveTypes(),
            const SizedBox(height: 24),
            _buildStats(),
            const SizedBox(height: 24),
            _buildUpcomingLives(),
            const SizedBox(height: 24),
            _buildProducts(),
            const SizedBox(height: 24),
            _buildLiveSettings(),
            const SizedBox(height: 20),
          ]),
        )),
      ])),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
      child: Row(children: [
        Container(
            width: 40,
            height: 40,
            decoration:
                const BoxDecoration(shape: BoxShape.circle, color: kLiveGold),
            child: const Icon(Icons.workspace_premium_rounded,
                color: Colors.white, size: 24)),
        const SizedBox(width: 8),
        RichText(
            text: const TextSpan(children: [
          TextSpan(
              text: 'KINGDOM',
              style: TextStyle(
                  color: kLiveGold, fontSize: 14, fontWeight: FontWeight.w900)),
          TextSpan(
              text: 'SHIFT',
              style: TextStyle(
                  color: kLiveTeal, fontSize: 14, fontWeight: FontWeight.w900)),
          TextSpan(
              text: '.LIVE',
              style: TextStyle(
                  color: kLivePink, fontSize: 14, fontWeight: FontWeight.w900)),
        ])),
        const Spacer(),
        Stack(children: [
          Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                  color: kLiveCard,
                  shape: BoxShape.circle,
                  border: Border.all(color: kLiveTeal.withValues(alpha: 0.3))),
              child: const Icon(Icons.notifications_outlined,
                  color: kLiveText, size: 18)),
          Positioned(
              top: 2,
              right: 2,
              child: Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                      color: kLivePink, shape: BoxShape.circle))),
        ]),
        const SizedBox(width: 8),
        Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
                color: kLiveCard,
                shape: BoxShape.circle,
                border: Border.all(color: kLiveTeal.withValues(alpha: 0.3))),
            child: const Icon(Icons.chat_bubble_outline,
                color: kLiveText, size: 18)),
        const SizedBox(width: 8),
        GestureDetector(
          onTap: () => Get.to(() => const MyLiveStreamsScreen()),
          child: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                  color: kLiveCard,
                  shape: BoxShape.circle,
                  border: Border.all(color: kLiveTeal.withValues(alpha: 0.3))),
              child: const Icon(Icons.video_library_rounded,
                  color: kLiveText, size: 18)),
        ),
        const SizedBox(width: 8),
        Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: kLiveCard,
                border: Border.all(
                    color: kLiveGold.withValues(alpha: 0.4), width: 1.5)),
            child:
                const Icon(Icons.person_rounded, color: kLiveMuted, size: 20)),
      ]),
    );
  }


  Widget _buildLiveNowButton() {
    return ElevatedButton.icon(
      onPressed: () {
        Get.to(() => LiveStreamSearchScreen(
              myUser: SessionManager.instance.getUser(),
            ));
      },
      icon: const Icon(Icons.live_tv_rounded),
      label: const Text('LIVE NOW — Watch Active Streams'),
    );
  }

  Widget _buildGreeting() {
    return Row(children: [
      Expanded(
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text('Good Morning,',
            style: TextStyle(color: kLiveMuted, fontSize: 14)),
        Row(children: [
          const Text('Charo',
              style: TextStyle(
                  color: kLiveGold, fontSize: 26, fontWeight: FontWeight.bold)),
          const SizedBox(width: 6),
          const Icon(Icons.workspace_premium_rounded,
              color: kLiveGold, size: 22),
        ]),
        const SizedBox(height: 4),
        const Text('You have a purpose. Go live and impact someone today!',
            style: TextStyle(color: kLiveMuted, fontSize: 12, height: 1.4)),
      ])),
      const SizedBox(width: 12),
      // GO LIVE button
      GestureDetector(
        onTap: () => Get.to(() => const CreateLiveStreamScreen()),
        child: Container(
          width: 140,
          height: 80,
          decoration: BoxDecoration(
              color: kLiveCard,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: kLiveTeal, width: 1.5),
              boxShadow: [
                BoxShadow(
                    color: kLiveTeal.withValues(alpha: 0.2), blurRadius: 12)
              ]),
          child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                    color: kLiveTeal.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(10)),
                child: const Icon(Icons.sensors_rounded,
                    color: kLiveTeal, size: 22)),
            const SizedBox(height: 6),
            const Text('GO LIVE',
                style: TextStyle(
                    color: kLiveGold,
                    fontSize: 14,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1)),
            const Text('Start Your Live Stream',
                style: TextStyle(color: kLiveMuted, fontSize: 8)),
          ]),
        ),
      ),
    ]);
  }

  Widget _buildLiveTypes() {
    final types = [
      {
        'icon': Icons.videocam_rounded,
        'label': 'Camera Live',
        'color': kLiveTeal
      },
      {'icon': Icons.mic_rounded, 'label': 'Audio Live', 'color': kLiveGold},
      {
        'icon': Icons.screen_share_rounded,
        'label': 'Screen Share',
        'color': kLiveGold
      },
      {
        'icon': Icons.shopping_bag_rounded,
        'label': 'Live Shopping',
        'color': kLiveGold
      },
      {
        'icon': Icons.people_rounded,
        'label': 'Invite Co-Host',
        'color': kLiveGold
      },
    ];
    return SizedBox(
      height: 90,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: types.length,
        itemBuilder: (_, i) {
          final t = types[i];
          final color = t['color'] as Color;
          final icon = t['icon'] as IconData;
          return GestureDetector(
            onTap: () => Get.to(() => const CreateLiveStreamScreen()),
            child: Container(
              width: 80,
              margin: const EdgeInsets.only(right: 10),
              decoration: BoxDecoration(
                  color: kLiveCard,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: color.withValues(alpha: 0.3))),
              child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                        width: 36,
                        height: 28,
                        decoration: BoxDecoration(
                            color: color.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(6)),
                        child: Stack(alignment: Alignment.center, children: [
                          Icon(icon, color: color, size: 16),
                          Positioned(
                              top: 2,
                              right: 2,
                              child: Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 2, vertical: 1),
                                  decoration: BoxDecoration(
                                      color: kLivePink,
                                      borderRadius: BorderRadius.circular(2)),
                                  child: const Text('LIVE',
                                      style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 5,
                                          fontWeight: FontWeight.bold)))),
                        ])),
                    const SizedBox(height: 6),
                    Text(t['label'] as String,
                        style: const TextStyle(color: kLiveText, fontSize: 9),
                        textAlign: TextAlign.center,
                        maxLines: 2),
                  ]),
            ),
          );
        },
      ),
    );
  }

  Widget _buildStats() {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        const Text('Your Live Stats',
            style: TextStyle(
                color: kLiveText, fontSize: 16, fontWeight: FontWeight.bold)),
        GestureDetector(
            onTap: () {},
            child: const Text('View Insights >',
                style: TextStyle(color: kLiveTeal, fontSize: 12))),
      ]),
      const SizedBox(height: 12),
      Row(children: [
        _statCard(Icons.people_rounded, '24,582', 'Followers', kLiveTeal),
        const SizedBox(width: 10),
        _statCard(Icons.attach_money_rounded, '\$0.00', 'Today\'s Earnings',
            kLiveGold),
        const SizedBox(width: 10),
        _statCard(
            Icons.shopping_bag_outlined, '3', 'Pending Orders', kLivePink),
        const SizedBox(width: 10),
        _statCard(
            Icons.calendar_today_rounded, '2', 'Scheduled Lives', kLiveTeal),
      ]),
    ]);
  }

  Widget _statCard(IconData icon, String value, String label, Color color) {
    return Expanded(
        child: Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
          color: kLiveCard,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withValues(alpha: 0.2))),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Icon(icon, color: color, size: 18),
        const SizedBox(height: 6),
        Text(value,
            style: const TextStyle(
                color: kLiveText, fontSize: 14, fontWeight: FontWeight.bold)),
        Text(label, style: const TextStyle(color: kLiveMuted, fontSize: 9)),
      ]),
    ));
  }

  Widget _buildUpcomingLives() {
    final lives = [
      {
        'date': 'MAY 25',
        'time': '7:00 PM',
        'title': 'Faith & Finance Live',
        'desc': 'Building wealth God\'s way',
        'tag': 'Finance'
      },
      {
        'date': 'MAY 26',
        'time': '8:30 PM',
        'title': 'Prophetic Word',
        'desc': 'Receive your word for today',
        'tag': 'Faith'
      },
      {
        'date': 'MAY 27',
        'time': '12:00 PM',
        'title': 'Kingdom Women',
        'desc': 'Empowered to Impact',
        'tag': 'Women'
      },
    ];
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        const Text('Upcoming Lives',
            style: TextStyle(
                color: kLiveText, fontSize: 16, fontWeight: FontWeight.bold)),
        const Text('View Calendar >',
            style: TextStyle(color: kLiveTeal, fontSize: 12)),
      ]),
      const SizedBox(height: 12),
      ...lives.map((l) => Container(
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
                color: kLiveCard,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: kLiveTeal.withValues(alpha: 0.15))),
            child: Row(children: [
              Column(children: [
                Text(l['date']!,
                    style: const TextStyle(color: kLiveMuted, fontSize: 9)),
                Text(l['time']!,
                    style: const TextStyle(
                        color: kLiveGold,
                        fontSize: 10,
                        fontWeight: FontWeight.bold)),
              ]),
              const SizedBox(width: 12),
              Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: kLiveTeal.withValues(alpha: 0.2),
                      border:
                          Border.all(color: kLiveTeal.withValues(alpha: 0.3))),
                  child: const Icon(Icons.person_rounded,
                      color: kLiveTeal, size: 20)),
              const SizedBox(width: 10),
              Expanded(
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                    Text(l['title']!,
                        style: const TextStyle(
                            color: kLiveText,
                            fontSize: 13,
                            fontWeight: FontWeight.w600)),
                    Text(l['desc']!,
                        style:
                            const TextStyle(color: kLiveMuted, fontSize: 11)),
                    const SizedBox(height: 4),
                    Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                            color: kLiveTeal.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(8)),
                        child: Text(l['tag']!,
                            style: const TextStyle(
                                color: kLiveTeal, fontSize: 10))),
                  ])),
              const Icon(Icons.notifications_outlined,
                  color: kLiveGold, size: 18),
              const SizedBox(width: 8),
              const Icon(Icons.more_vert, color: kLiveMuted, size: 18),
            ]),
          )),
    ]);
  }

  Widget _buildProducts() {
    final products = [
      {'name': 'Portion & Purpose Bag', 'price': '\$49.99'},
      {'name': 'Kingdom Shift Book', 'price': '\$19.99'},
      {'name': 'Kingdom Shift Course', 'price': '\$99.99'},
    ];
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        const Text('Products Ready to Feature',
            style: TextStyle(
                color: kLiveText, fontSize: 16, fontWeight: FontWeight.bold)),
        const Text('Manage Products >',
            style: TextStyle(color: kLiveTeal, fontSize: 12)),
      ]),
      const SizedBox(height: 12),
      SizedBox(
          height: 140,
          child: ListView(scrollDirection: Axis.horizontal, children: [
            ...products.map((p) => Container(
                  width: 110,
                  margin: const EdgeInsets.only(right: 10),
                  decoration: BoxDecoration(
                      color: kLiveCard,
                      borderRadius: BorderRadius.circular(12),
                      border:
                          Border.all(color: kLiveGold.withValues(alpha: 0.2))),
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                            height: 80,
                            decoration: BoxDecoration(
                                color: kLiveBg2,
                                borderRadius: const BorderRadius.vertical(
                                    top: Radius.circular(12))),
                            child: Stack(children: [
                              const Center(
                                  child: Icon(Icons.shopping_bag_rounded,
                                      color: kLiveGold, size: 36)),
                              Positioned(
                                  top: 6,
                                  left: 6,
                                  child: Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 4, vertical: 1),
                                      decoration: BoxDecoration(
                                          color: kLiveTeal,
                                          borderRadius:
                                              BorderRadius.circular(4)),
                                      child: const Text('PIN',
                                          style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 8,
                                              fontWeight: FontWeight.bold)))),
                            ])),
                        Padding(
                            padding: const EdgeInsets.all(6),
                            child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(p['name']!,
                                      style: const TextStyle(
                                          color: kLiveText, fontSize: 9),
                                      maxLines: 2),
                                  const SizedBox(height: 2),
                                  Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(p['price']!,
                                            style: const TextStyle(
                                                color: kLiveGold,
                                                fontSize: 10,
                                                fontWeight: FontWeight.bold)),
                                        const Text('In Stock',
                                            style: TextStyle(
                                                color: Colors.green,
                                                fontSize: 8)),
                                      ]),
                                ])),
                      ]),
                )),
            Container(
                width: 110,
                decoration: BoxDecoration(
                    color: kLiveCard,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                        color: kLiveTeal.withValues(alpha: 0.3),
                        style: BorderStyle.solid)),
                child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(color: kLiveTeal, width: 1.5)),
                          child: const Icon(Icons.add,
                              color: kLiveTeal, size: 20)),
                      const SizedBox(height: 6),
                      const Text('Add Product',
                          style: TextStyle(color: kLiveTeal, fontSize: 11)),
                    ])),
          ])),
    ]);
  }

  Widget _buildLiveSettings() {
    final settings = [
      {'icon': Icons.videocam_rounded, 'label': 'Camera', 'color': kLiveTeal},
      {'icon': Icons.mic_rounded, 'label': 'Microphone', 'color': kLiveTeal},
      {
        'icon': Icons.face_retouching_natural,
        'label': 'Beauty',
        'color': kLiveTeal
      },
      {
        'icon': Icons.shield_outlined,
        'label': 'Moderators',
        'color': kLiveTeal
      },
      {
        'icon': Icons.chat_bubble_outline,
        'label': 'Comments',
        'color': kLiveTeal
      },
      {
        'icon': Icons.fiber_manual_record,
        'label': 'Recording',
        'color': kLivePink
      },
      {'icon': Icons.replay_rounded, 'label': 'Replay', 'color': kLiveTeal},
    ];
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const Text('Live Settings',
          style: TextStyle(
              color: kLiveText, fontSize: 16, fontWeight: FontWeight.bold)),
      const SizedBox(height: 12),
      Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
            color: kLiveCard,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: kLiveTeal.withValues(alpha: 0.15))),
        child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: settings
                .map((s) => Column(children: [
                      Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                              color:
                                  (s['color'] as Color).withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                  color: (s['color'] as Color)
                                      .withValues(alpha: 0.3))),
                          child: Icon(s['icon'] as IconData,
                              color: s['color'] as Color, size: 20)),
                      const SizedBox(height: 4),
                      Text(s['label'] as String,
                          style:
                              const TextStyle(color: kLiveMuted, fontSize: 8)),
                    ]))
                .toList()),
      ),
    ]);
  }
}
