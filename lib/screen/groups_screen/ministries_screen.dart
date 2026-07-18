import 'package:flutter/material.dart';
import '../../theme/ks_theme.dart';

class MinistriesScreen extends StatelessWidget {
  const MinistriesScreen({super.key});

  final ministryAreas = const [
    {'icon': Icons.music_note_outlined, 'title': 'Worship', 'desc': 'Leading hearts\nin worship'},
    {'icon': Icons.menu_book_outlined, 'title': 'Teaching', 'desc': 'Equipping through\nGod\'s Word'},
    {'icon': Icons.volunteer_activism_outlined, 'title': 'Outreach', 'desc': 'Reaching our\ncommunity'},
    {'icon': Icons.self_improvement_outlined, 'title': 'Prayer', 'desc': 'Building a culture\nof prayer'},
    {'icon': Icons.groups_outlined, 'title': 'Youth', 'desc': 'Raising the next\ngeneration'},
    {'icon': Icons.woman_outlined, 'title': 'Women', 'desc': 'Empowering\nwomen in faith'},
    {'icon': Icons.man_outlined, 'title': 'Men', 'desc': 'Building godly\nleaders'},
    {'icon': Icons.child_care_outlined, 'title': 'Kids', 'desc': 'Nurturing young\nhearts'},
    {'icon': Icons.play_circle_outline, 'title': 'Media', 'desc': 'Spreading the\nmessage'},
    {'icon': Icons.public_outlined, 'title': 'Missions', 'desc': 'Taking the Gospel\nto the world'},
  ];

  final upcomingEvents = const [
    {'month': 'MAY', 'day': '25', 'dayName': 'SAT', 'title': 'Prayer & Fasting', 'desc': 'A day of prayer and seeking God', 'time': '9:00 AM - 12:00 PM', 'location': 'Main Sanctuary'},
    {'month': 'JUN', 'day': '02', 'dayName': 'SUN', 'title': 'Outreach Program', 'desc': 'Serving our community together', 'time': '8:00 AM - 1:00 PM', 'location': 'City Center'},
    {'month': 'JUN', 'day': '15', 'dayName': 'SAT', 'title': 'Youth Encounter', 'desc': 'Empowering youth in their faith', 'time': '6:00 PM - 9:00 PM', 'location': 'Youth Hall'},
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
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                child: Row(children: [
                  GestureDetector(onTap: () => Navigator.pop(context), child: const Icon(Icons.arrow_back, color: Colors.white)),
                  const SizedBox(width: 12),
                  ClipOval(child: Image.asset('assets/images/ks_logo.png', width: 36, height: 36, fit: BoxFit.cover)),
                  const SizedBox(width: 10),
                  Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    const Text('KingdomShift', style: TextStyle(color: KSTheme.gold, fontSize: 16, fontWeight: FontWeight.bold)),
                    Text('MINISTRIES', style: TextStyle(color: KSTheme.teal, fontSize: 10, fontWeight: FontWeight.w600, letterSpacing: 2)),
                  ]),
                  const Spacer(),
                  Stack(children: [
                    IconButton(icon: const Icon(Icons.notifications_outlined, color: Colors.white), onPressed: () {}),
                    Positioned(top: 8, right: 8, child: Container(width: 16, height: 16, decoration: const BoxDecoration(color: KSTheme.teal, shape: BoxShape.circle), child: const Center(child: Text('3', style: TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold))))),
                  ]),
                  IconButton(icon: const Icon(Icons.search, color: Colors.white), onPressed: () {}),
                ]),
              ),
            ),
            // Title
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  const Text('Ministries', style: TextStyle(color: Colors.white, fontSize: 26, fontWeight: FontWeight.bold)),
                  Text('Equipping lives. Building the Kingdom.', style: TextStyle(color: KSTheme.textSecondary, fontSize: 13)),
                ]),
              ),
            ),
            // Mission banner
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Container(
                  height: 200,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    gradient: const LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Color(0xFF0D2137), Color(0xFF0A1628)]),
                    border: Border.all(color: KSTheme.teal.withValues(alpha: 0.3)),
                  ),
                  child: Stack(children: [
                    // Cross icon background
                    Center(child: Icon(Icons.add, color: Colors.white.withValues(alpha: 0.05), size: 160)),
                    Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Text('OUR MISSION', style: TextStyle(color: KSTheme.teal, fontSize: 11, fontWeight: FontWeight.w600, letterSpacing: 1.5)),
                        const SizedBox(height: 10),
                        RichText(text: const TextSpan(children: [
                          TextSpan(text: 'To lead people into a ', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w500, height: 1.5)),
                          TextSpan(text: 'growing relationship', style: TextStyle(color: KSTheme.teal, fontSize: 16, fontWeight: FontWeight.bold, height: 1.5)),
                          TextSpan(text: ' with Jesus Christ and empower them to fulfill their God-given purpose.', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w500, height: 1.5)),
                        ])),
                        const Spacer(),
                        GestureDetector(
                          onTap: () {},
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                            decoration: BoxDecoration(color: Colors.transparent, borderRadius: BorderRadius.circular(20), border: Border.all(color: Colors.white)),
                            child: const Row(mainAxisSize: MainAxisSize.min, children: [Text('Learn More', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)), SizedBox(width: 8), Icon(Icons.arrow_forward, color: Colors.white, size: 16)]),
                          ),
                        ),
                      ]),
                    ),
                  ]),
                ),
              ),
            ),
            // Ministry Areas
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 20, 16, 12),
                child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                  const Text('Ministry Areas', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                  Text('View All >', style: TextStyle(color: KSTheme.teal, fontSize: 13, fontWeight: FontWeight.w600)),
                ]),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              sliver: SliverGrid(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 5, crossAxisSpacing: 8, mainAxisSpacing: 8, childAspectRatio: 0.75),
                delegate: SliverChildBuilderDelegate(
                  (_, i) {
                    final area = ministryAreas[i];
                    return GestureDetector(
                      onTap: () {},
                      child: Container(
                        decoration: BoxDecoration(color: KSTheme.bgCard, borderRadius: BorderRadius.circular(12), border: Border.all(color: KSTheme.divider)),
                        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                          Icon(area['icon'] as IconData, color: KSTheme.teal, size: 22),
                          const SizedBox(height: 4),
                          Text(area['title'] as String, style: const TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold), textAlign: TextAlign.center),
                          const SizedBox(height: 2),
                          Text(area['desc'] as String, style: TextStyle(color: KSTheme.textSecondary, fontSize: 7), textAlign: TextAlign.center, maxLines: 2),
                          const SizedBox(height: 4),
                          Container(width: 18, height: 18, decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: KSTheme.teal)), child: const Icon(Icons.arrow_forward, color: KSTheme.teal, size: 10)),
                        ]),
                      ),
                    );
                  },
                  childCount: ministryAreas.length,
                ),
              ),
            ),
            // Upcoming Events
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 20, 16, 12),
                child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                  const Text('Upcoming Ministry Events', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                  Text('View All >', style: TextStyle(color: KSTheme.teal, fontSize: 13, fontWeight: FontWeight.w600)),
                ]),
              ),
            ),
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (_, i) {
                  final event = upcomingEvents[i];
                  return Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: KSTheme.cardDecoration,
                      child: Row(children: [
                        // Date
                        Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                          Text(event['month']!, style: TextStyle(color: KSTheme.teal, fontSize: 10, fontWeight: FontWeight.w600)),
                          Text(event['day']!, style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold, height: 1)),
                          Text(event['dayName']!, style: TextStyle(color: KSTheme.textSecondary, fontSize: 10)),
                        ]),
                        const SizedBox(width: 16),
                        // Info
                        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          Text(event['title']!, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
                          Text(event['desc']!, style: TextStyle(color: KSTheme.textSecondary, fontSize: 12)),
                          const SizedBox(height: 4),
                          Row(children: [const Icon(Icons.access_time, color: KSTheme.teal, size: 12), const SizedBox(width: 4), Text(event['time']!, style: TextStyle(color: KSTheme.textSecondary, fontSize: 11))]),
                          Row(children: [const Icon(Icons.location_on_outlined, color: KSTheme.teal, size: 12), const SizedBox(width: 4), Text(event['location']!, style: TextStyle(color: KSTheme.textSecondary, fontSize: 11))]),
                        ])),
                        const SizedBox(width: 8),
                        // Thumbnail + Register
                        Column(children: [
                          Container(width: 60, height: 50, decoration: BoxDecoration(color: KSTheme.bgCardLight, borderRadius: BorderRadius.circular(8)), child: const Icon(Icons.event, color: KSTheme.teal, size: 24)),
                          const SizedBox(height: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                            decoration: BoxDecoration(color: Colors.transparent, borderRadius: BorderRadius.circular(8), border: Border.all(color: KSTheme.teal)),
                            child: const Text('Register', style: TextStyle(color: KSTheme.teal, fontSize: 11, fontWeight: FontWeight.w600)),
                          ),
                        ]),
                      ]),
                    ),
                  );
                },
                childCount: upcomingEvents.length,
              ),
            ),
            // Support the Ministry
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: KSTheme.bgCard,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: KSTheme.gold.withValues(alpha: 0.3)),
                  ),
                  child: Row(children: [
                    Container(width: 60, height: 60, decoration: BoxDecoration(color: KSTheme.bgCardLight, borderRadius: BorderRadius.circular(12)), child: const Icon(Icons.favorite, color: KSTheme.gold, size: 32)),
                    const SizedBox(width: 14),
                    Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      const Text('Support the Ministry', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15)),
                      Text('Your giving helps us reach more people and impact more lives for the Kingdom.', style: TextStyle(color: KSTheme.textSecondary, fontSize: 12)),
                      const SizedBox(height: 10),
                      GestureDetector(
                        onTap: () {},
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          decoration: BoxDecoration(gradient: KSTheme.tealGradient, borderRadius: BorderRadius.circular(20)),
                          child: const Row(mainAxisSize: MainAxisSize.min, children: [Icon(Icons.favorite_outline, color: Colors.white, size: 14), SizedBox(width: 6), Text('Give Now', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)), SizedBox(width: 6), Icon(Icons.arrow_forward, color: Colors.white, size: 14)]),
                        ),
                      ),
                    ])),
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
