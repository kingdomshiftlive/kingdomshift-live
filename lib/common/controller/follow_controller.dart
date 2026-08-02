import 'package:get/get.dart';
import 'package:shortzz/common/controller/base_controller.dart';
import 'package:shortzz/common/manager/firebase_notification_manager.dart';
import 'package:shortzz/common/manager/logger.dart';
import 'package:shortzz/common/manager/session_manager.dart';
import 'package:shortzz/languages/languages_keys.dart';
import 'package:shortzz/model/user_model/user_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as supabase;

class FollowController extends BaseController {
  Rx<User?> user;
  FollowController(this.user);

  void updateUser(User? user) {
    this.user.value = user;
  }

  Future<User?> followUnFollowUser() async {
    final targetUid = user.value?.firebaseUid;
    if (targetUid == null || targetUid.isEmpty) {
      Loggers.error('Invalid target firebaseUid');
      return null;
    }
    try {
      final result = await supabase.Supabase.instance.client
          .rpc('toggle_follow', params: {'p_target_user_id': targetUid});
      final isNowFollowing = result == true;

      user.update((val) {
        val?.isFollowing = isNowFollowing;
        val?.updateFollowerCount(isNowFollowing);
      });
      Loggers.success(user.value?.isFollowing);

      final User? _user = user.value;
      if (_user != null &&
          isNowFollowing &&
          _user.notifyFollow == 1 &&
          _user.firebaseUid != SessionManager.instance.getUser()?.firebaseUid) {
        FirebaseNotificationManager.instance.sendLocalisationNotification(
            LKey.notifyStartedFollowing,
            type: NotificationType.user,
            languageCode: _user.appLanguage,
            deviceToken: _user.deviceToken,
            deviceType: _user.device,
            body: NotificationInfo(id: SessionManager.instance.getUserID()));
      }
      return user.value;
    } catch (e) {
      Loggers.error('Error in followUnFollowUser : $e');
      return null;
    }
  }
}
