import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:supabase_flutter/supabase_flutter.dart' as supabase;
import 'package:shortzz/common/manager/session_manager.dart';

class NotificationScreenController extends GetxController {
  var selectedTab = 0.obs;

  final RxList activityNotifications = [].obs;
  final RxList systemNotifications = [].obs;
  final RxBool isLoading = false.obs;

  final newNotifications = <Map<String, dynamic>>[].obs;
  final earlierNotifications = <Map<String, dynamic>>[].obs;

  @override
  void onInit() {
    super.onInit();
    fetchNotifications();
  }

  Future<void> fetchNotifications() async {
    isLoading.value = true;
    try {
      final userKey = firebase_auth.FirebaseAuth.instance.currentUser?.uid ??
          SessionManager.instance.getUserID().toString();

      final rows = await supabase.Supabase.instance.client
          .from('notifications')
          .select()
          .eq('receiver_id', userKey)
          .order('created_at', ascending: false)
          .limit(50);

      final mapped = (rows as List).map((item) {
        final type = (item['type'] ?? 'system').toString();
        final message = (item['message'] ?? '').toString();

        return {
          'id': item['id'],
          'avatar': '👑',
          'name': 'KingdomShift',
          'action': message,
          'subtitle': type,
          'time': 'Now',
          'thumb': 'KS',
          'icon': _iconForType(type),
          'iconColor': _colorForType(type),
          'unread': item['is_read'] != true,
          'type': type,
          'sender_id': item['sender_id'],
        };
      }).toList();

      newNotifications.assignAll(
          mapped.where((item) => item['unread'] == true).toList());
      earlierNotifications.assignAll(
          mapped.where((item) => item['unread'] != true).toList());
    } catch (_) {
      newNotifications.clear();
      earlierNotifications.clear();
    } finally {
      isLoading.value = false;
    }
  }

  IconData _iconForType(String type) {
    switch (type) {
      case 'like':
        return Icons.favorite;
      case 'comment':
        return Icons.chat_bubble;
      case 'follow':
        return Icons.person_add;
      case 'mention':
        return Icons.alternate_email;
      case 'live':
        return Icons.sensors;
      default:
        return Icons.notifications;
    }
  }

  Color _colorForType(String type) {
    switch (type) {
      case 'like':
        return Colors.red;
      case 'comment':
        return Colors.blue;
      case 'follow':
        return Colors.teal;
      case 'mention':
        return Colors.purple;
      case 'live':
        return Colors.orange;
      default:
        return Colors.amber;
    }
  }

  void onUserTap(dynamic notification) {}
  void onDescriptionTap(dynamic notification, {bool isReply = false}) {}
  void onPostTap(dynamic notification) {}

  void clearAll() {
    newNotifications.clear();
    earlierNotifications.clear();
  }
}
