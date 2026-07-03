import 'package:flutter/material.dart';
import 'package:get/get.dart';

class NotificationScreenController extends GetxController {
  var selectedTab = 0.obs;

  // Required by existing widgets
  final RxList activityNotifications = [].obs;
  final RxList systemNotifications = [].obs;
  final RxBool isLoading = false.obs;

  final newNotifications = <Map<String, dynamic>>[
    {
      'avatar': '👩🏾',
      'name': 'Tasha Entrepreneur',
      'action': 'liked your post.',
      'subtitle': 'Kingdom business tips',
      'time': '2m ago',
      'thumb': '5 TIPS',
      'icon': Icons.favorite,
      'iconColor': Colors.red,
      'unread': true
    },
    {
      'avatar': '👨🏾',
      'name': 'Pastor David Wilson',
      'action': 'commented on your live stream.',
      'subtitle': 'Great word! So powerful',
      'time': '5m ago',
      'thumb': 'LIVE',
      'isLive': true,
      'icon': Icons.chat_bubble,
      'iconColor': Colors.blue,
      'unread': true
    },
    {
      'avatar': '👑',
      'name': 'WealthShift Community',
      'action': 'invited you to join the group.',
      'subtitle': 'Kingdom Entrepreneurs',
      'time': '10m ago',
      'thumb': 'KE',
      'icon': Icons.group,
      'iconColor': Colors.purple,
      'unread': true
    },
    {
      'avatar': '👩🏽',
      'name': 'Sarah J.',
      'action': 'mentioned you in a comment.',
      'subtitle': 'Keep going! You are an inspiration!',
      'time': '15m ago',
      'thumb': 'MIC',
      'icon': Icons.alternate_email,
      'iconColor': Colors.teal,
      'unread': true
    },
    {
      'avatar': '🛡️',
      'name': 'Your live stream',
      'action': 'has ended.',
      'subtitle': 'Building Your Brand with Purpose',
      'time': '1h ago',
      'thumb': 'KS',
      'icon': Icons.settings,
      'iconColor': Colors.grey,
      'unread': true
    },
  ].obs;

  final earlierNotifications = <Map<String, dynamic>>[
    {
      'avatar': '👨🏿',
      'name': 'Marcus Johnson',
      'action': 'liked your comment.',
      'subtitle': 'Well said!',
      'time': '2h ago',
      'thumb': 'FAITH',
      'icon': Icons.thumb_up,
      'iconColor': Colors.blue,
      'unread': false
    },
    {
      'avatar': '🎬',
      'name': 'Cast AI',
      'action': 'generated your video.',
      'subtitle': 'Motivation for Kingdom Creators',
      'time': '3h ago',
      'thumb': 'VIDEO',
      'icon': Icons.notifications,
      'iconColor': Colors.orange,
      'unread': false
    },
    {
      'avatar': '👩🏽',
      'name': 'New order received',
      'action': 'in your shop.',
      'subtitle': 'Tote Bag Collection - Black and Gold',
      'time': 'Yesterday',
      'thumb': 'BAG',
      'icon': Icons.shopping_bag,
      'iconColor': Colors.green,
      'unread': false
    },
    {
      'avatar': '🌅',
      'name': 'Daily Decree',
      'action': 'is ready.',
      'subtitle': 'Speak it. Believe it. Receive it.',
      'time': 'Yesterday',
      'thumb': 'DECREE',
      'icon': Icons.wb_sunny,
      'iconColor': Colors.amber,
      'unread': false
    },
  ].obs;

  // Stub methods required by existing activity_notification_page.dart
  void onUserTap(dynamic notification) {}
  void onDescriptionTap(dynamic notification, {bool isReply = false}) {}
  void onPostTap(dynamic notification) {}

  void clearAll() => earlierNotifications.clear();
}
