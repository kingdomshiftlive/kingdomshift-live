import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../theme/ks_theme.dart';
import '../../services/api_service.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});
  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  String selectedFilter = 'All';
  final filters = ['All', 'Likes', 'Comments', 'Mentions', 'Follows'];
  bool isLoading = true;
  List<Map> notifications = [];

  final newNotifications = [
    {'icon': Icons.sensors, 'color': 0xFFFF0000, 'title': 'Live Stream Starting Soon', 'desc': '"Kingdom Q&A Live" with Pastor James is starting in 15 minutes.', 'time': '2m ago', 'isNew': true},
    {'icon': Icons.calendar_today_outlined, 'color': 0xFF00C9C8, 'title': 'Upcoming Event Reminder', 'desc': '"Prayer & Fasting" is happening tomorrow at 9:00 AM. We hope to see you there!', 'time': '10m ago', 'isNew': true},
    {'icon': Icons.shopping_bag_outlined, 'color': 0xFFC9A227, 'title': 'Order Confirmed', 'desc': 'Your order #KS1024 has been confirmed and is being processed.', 'time': '1h ago', 'isNew': true},
    {'icon': Icons.chat_bubble_outline, 'color': 0xFF00C9C8, 'title': 'New Message', 'desc': 'Pastor James sent you a message.', 'time': '2h ago', 'isNew': true},
    {'icon': Icons.favorite_outline, 'color': 0xFFFF2D9B, 'title': 'Thank You for Your Support', 'desc': 'Your donation is making an impact. Thank you for partnering with us!', 'time': '3h ago', 'isNew': true},
  ];

  final earlierNotifications = [
    {'icon': Icons.play_circle_outline, 'color': 0xFF9B59B6, 'title': 'New Podcast Episode', 'desc': '"Faith Over Fear" is now available. Listen now!', 'time': 'Yesterday, 8:30 PM', 'isNew': false},
    {'icon': Icons.groups_outlined, 'color': 0xFF00C9C8, 'title': 'Ministry Update', 'desc': 'The Outreach team shared a new update. Check it out!', 'time': 'Yesterday, 5:15 PM', 'isNew': false},
    {'icon': Icons.local_shipping_outlined, 'color': 0xFFC9A227, 'title': 'Order Shipped', 'desc': 'Your order #KS1018 has been shipped and is on its way!', 'time': 'May 20, 10:22 AM', 'isNew': false},
    {'icon': Icons.notifications_outlined, 'color': 0xFF00C9C8, 'title': 'Welcome to KingdomShift.Live!', 'desc': 'Thank you for joining us. We\'re excited to have you!', 'time': 'May 19, 9:00 AM', 'isNew': false},
  ];

  @override
  void initState() {
    super.initState();
    _loadNotifications();
  }

  Future<void> _loadNotifications() async {
    await Future.delayed(const Duration(milliseconds: 500));
    if (mounted) setState(() => isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: KSTheme.bgDark,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
              child: Row(children: [
                GestureDetector(onTap: () => Navigator.pop(context), child: const Icon(Icons.arrow_back, color: Colors.white)),
                const SizedBox(width: 12),
                ClipOval(child: Image.asset('assets/images/ks_logo.png', width: 36, height: 36, fit: BoxFit.cover)),
                const SizedBox(width: 10),
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  const Text('KingdomShift.Live', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                  Text('MEDIA', style: TextStyle(color: KSTheme.teal, fontSize: 10, fontWeight: FontWeight.w600, letterSpacing: 2)),
                ]),
                const Spacer(),
                IconButton(icon: const Icon(Icons.search, color: Colors.white), onPressed: () {}),
                IconButton(icon: const Icon(Icons.more_vert, color: Colors.white), onPressed: () {}),
              ]),
            ),
            // Title
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Row(children: [
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  const Text('Notifications', style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
                  Text('Stay updated with the latest from KingdomShift.', style: TextStyle(color: KSTheme.textSecondary, fontSize: 12)),
                ]),
              ]),
            ),
            // Filter chips
            SizedBox(
              height: 40,
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
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: isSelected ? KSTheme.teal : KSTheme.bgCard,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: isSelected ? KSTheme.teal : KSTheme.divider),
                      ),
                      child: Text(filters[i], style: TextStyle(color: isSelected ? Colors.white : KSTheme.textSecondary, fontSize: 13, fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal)),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 12),
            // Notifications list
            Expanded(
              child: isLoading
                  ? const Center(child: CircularProgressIndicator(color: KSTheme.teal))
                  : ListView(
                      children: [
                        // New section
                        Padding(
                          padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                          child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                            const Text('New', style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold)),
                            GestureDetector(onTap: () {}, child: Text('Mark all as read', style: TextStyle(color: KSTheme.teal, fontSize: 13, fontWeight: FontWeight.w600))),
                          ]),
                        ),
                        ...newNotifications.map((n) => _buildNotificationItem(n)),
                        const Divider(color: KSTheme.divider, height: 1),
                        // Earlier section
                        const Padding(
                          padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
                          child: Text('Earlier', style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold)),
                        ),
                        ...earlierNotifications.map((n) => _buildNotificationItem(n)),
                        const SizedBox(height: 24),
                      ],
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotificationItem(Map n) {
    final isNew = n['isNew'] as bool;
    return GestureDetector(
      onTap: () {},
      child: Container(
        color: isNew ? KSTheme.teal.withValues(alpha: 0.05) : Colors.transparent,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 48, height: 48,
              decoration: BoxDecoration(
                color: Color(n['color'] as int).withValues(alpha: 0.15),
                shape: BoxShape.circle,
                border: Border.all(color: Color(n['color'] as int).withValues(alpha: 0.3)),
              ),
              child: Icon(n['icon'] as IconData, color: Color(n['color'] as int), size: 22),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(n['title'] as String, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
                const SizedBox(height: 2),
                Text(n['desc'] as String, style: TextStyle(color: KSTheme.textSecondary, fontSize: 13, height: 1.4)),
              ]),
            ),
            const SizedBox(width: 8),
            Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
              Text(n['time'] as String, style: TextStyle(color: KSTheme.textSecondary, fontSize: 11)),
              if (isNew) ...[
                const SizedBox(height: 6),
                Container(width: 8, height: 8, decoration: const BoxDecoration(color: KSTheme.teal, shape: BoxShape.circle)),
              ],
            ]),
          ],
        ),
      ),
    );
  }
}
