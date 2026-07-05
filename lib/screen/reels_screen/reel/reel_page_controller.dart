import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shortzz/common/controller/base_controller.dart';
import 'package:shortzz/common/functions/debounce_action.dart';
import 'package:shortzz/common/manager/branch_io_manager.dart';
import 'package:shortzz/common/manager/firebase_notification_manager.dart';
import 'package:shortzz/common/manager/haptic_manager.dart';
import 'package:shortzz/common/manager/logger.dart';
import 'package:shortzz/common/manager/session_manager.dart';
import 'package:shortzz/common/service/api/post_service.dart';
import 'package:shortzz/common/service/navigation/navigate_with_controller.dart';
import 'package:shortzz/languages/languages_keys.dart';
import 'package:shortzz/model/general/status_model.dart';
import 'package:shortzz/model/post_story/music/music_model.dart';
import 'package:shortzz/model/post_story/post_by_id.dart';
import 'package:shortzz/model/post_story/post_model.dart';
import 'package:shortzz/model/user_model/user_model.dart';
import 'package:shortzz/screen/audio_details_screen/audio_sheet.dart';
import 'package:shortzz/screen/comment_sheet/comment_sheet.dart';
import 'package:shortzz/screen/gift_sheet/send_gift_sheet_controller.dart';
import 'package:shortzz/screen/post_screen/post_screen_controller.dart';
import 'package:shortzz/screen/saved_post_screen/saved_post_screen_controller.dart';

class ReelController extends BaseController {
  DateTime? _watchStartedAt;
  bool _takeBreakShown = false;
  Rx<Post> reelData;
  bool isLikeLoading = false;
  bool isSavedLoading = false;

  User? get myUser => SessionManager.instance.getUser();
  Timer? _debounce;

  ReelController(this.reelData) {
    reelData.listen((p0) {
      if (p0.postType == PostType.video &&
          Get.isRegistered<PostScreenController>(tag: '${p0.id}')) {
        final controller = Get.find<PostScreenController>(tag: '${p0.id}');
        controller.updatePost(p0);
      }
    });
  }

  @override
  void onClose() {
    super.onClose();
    reelData.close();
    _debounce?.cancel();
  }

  void updateReelData({Post? reel, bool isIncreaseCoin = false}) {
    if (reel != null) {
      if (isIncreaseCoin) {
        reelData.update((val) => val?.increaseViews());
      } else {
        reelData.value = reel;
      }
    }
  }

  void onLikeTap() {
    if (reelData.value.isLiked == false) {
      HapticManager.shared.light();
    }
    FocusManager.instance.primaryFocus?.unfocus();
    int reelId = reelData.value.id?.toInt() ?? -1;

    if (reelId == -1) {
      return Loggers.error('Invalid Post id : $reelId');
    }

    reelData.update((val) {
      val?.likeToggle(val.isLiked == true ? false : true);
    });

    if (_debounce?.isActive ?? false) _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 700), () async {
      try {
        if ((reelData.value.supabaseId ?? '').isNotEmpty) {
          await PostService.instance.setSupabaseVideoLike(
            supabaseId: reelData.value.supabaseId!,
            isLiked: reelData.value.isLiked == true,
          );
        } else {
          await (reelData.value.isLiked == true
              ? _likePostApi(reelId)
              : _disLikePostApi(reelId));
        }
        // if (reelData.value.postType == PostType.video &&
        //     Get.isRegistered<PostScreenController>(tag: '$reelId')) {
        //   final controller = Get.find<PostScreenController>(tag: '$reelId');
        //   controller.updatePost(reelData.value);
        // }
      } catch (e) {
        Loggers.error('ERROR IN LIKE  REEL $e');
      }
    });
  }

  Future<void> _likePostApi(int id) async {
    StatusModel result = await PostService.instance.likePost(postId: id);
    if (result.status == true) {
      Post? reel = reelData.value;
      if (reel.user?.notifyPostLike == 1 && myUser?.id != reel.userId) {
        FirebaseNotificationManager.instance.sendLocalisationNotification(
            LKey.activityLikedPost,
            type: NotificationType.post,
            body: NotificationInfo(id: reel.id),
            deviceType: reel.user?.device ?? 0,
            deviceToken: reel.user?.deviceToken ?? '',
            languageCode: reel.user?.appLanguage);
      }
    }
  }

  Future<void> _disLikePostApi(int id) async {
    await PostService.instance.disLikePost(postId: id);
  }

  Future<void> onCommentTap(
      {PostByIdData? postByIdData, bool isFromNotification = false}) async {
    FocusManager.instance.primaryFocus?.unfocus();

    await Get.bottomSheet(
        CommentSheet(
          replyComment: postByIdData?.reply,
          comment: postByIdData?.comment,
          post: reelData.value,
          isFromNotification: isFromNotification,
        ),
        isScrollControlled: true,
        backgroundColor: Colors.transparent);
  }

  void onSaved() {
    FocusManager.instance.primaryFocus?.unfocus();
    int reelId = reelData.value.id?.toInt() ?? -1;
    if (reelId == -1) {
      return Loggers.error('Invalid Post id : $reelId');
    }

    if (isSavedLoading) {
      return Loggers.error('Is saved loading : $isSavedLoading');
    }
    isSavedLoading = true;
    HapticManager.shared.light();
    reelData.update((val) {
      val?.saveToggle(val.isSaved == true ? false : true);
    });

    DebounceAction.shared.call(() async {
      if (reelData.value.id == null) {
        return Loggers.error('Reel value not found');
      }
      if ((reelData.value.supabaseId ?? '').isNotEmpty) {
        await PostService.instance.setSupabaseVideoSave(
          supabaseId: reelData.value.supabaseId!,
          isSaved: reelData.value.isSaved == true,
        );
      } else {
        await ((reelData.value.isSaved ?? false)
            ? _savePostApi(reelId)
            : _unSavePostApi(reelId));
      }
      isSavedLoading = false;
    });
  }

  Future<void> _savePostApi(int id) async {
    StatusModel result = await PostService.instance.savePost(postId: id);
    if (result.status == true) {
      if (Get.isRegistered<SavedPostScreenController>()) {
        final controller = Get.find<SavedPostScreenController>();
        controller.unsavedIds.removeWhere((element) => element == id);
      }
    }
  }

  Future<void> _unSavePostApi(int id) async {
    StatusModel result = await PostService.instance.unSavePost(postId: id);
    if (result.status == true) {
      if (Get.isRegistered<SavedPostScreenController>()) {
        final controller = Get.find<SavedPostScreenController>();
        controller.unsavedIds.add(id);
      }
    }
  }

  void showPremiumActionToast(String message) {
    Get.showSnackbar(GetSnackBar(
      message: message,
      duration: const Duration(seconds: 2),
      snackPosition: SnackPosition.BOTTOM,
      margin: const EdgeInsets.all(16),
      borderRadius: 18,
      backgroundColor: const Color(0xFF08141F).withValues(alpha: 0.95),
      borderColor: const Color(0xFFD4AF37).withValues(alpha: 0.45),
      borderWidth: 1,
      icon: const Icon(Icons.check_circle_rounded, color: Color(0xFF00D4C7)),
    ));
  }

  void maybeShowTakeBreakPopup() {
    _watchStartedAt ??= DateTime.now();
    if (_takeBreakShown) return;

    final watched = DateTime.now().difference(_watchStartedAt!);
    if (watched.inMinutes < 45) return;

    _takeBreakShown = true;
    Get.dialog(
      AlertDialog(
        backgroundColor: const Color(0xFF08141F),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const Text(
          'Take a Moment',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        content: const Text(
          'You\'ve been watching for a while. Stretch, hydrate, or take a moment to reset before continuing.',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Get.back();
              _watchStartedAt = DateTime.now();
              _takeBreakShown = false;
            },
            child: const Text(
              'Continue Watching',
              style: TextStyle(color: Color(0xFF00D4C7)),
            ),
          ),
          TextButton(
            onPressed: () => Get.back(),
            child: const Text(
              'Take a Break',
              style: TextStyle(color: Color(0xFFD4AF37)),
            ),
          ),
        ],
      ),
    );
  }

  void onShareTap() {
    FocusManager.instance.primaryFocus?.unfocus();
    BranchIoManager.instance.shareContent(
        type: ShareBranchType.post,
        post: reelData.value,
        onShareSuccess: () {
          reelData.update((val) => val?.increaseShares(1));
        });
  }

  void onGiftTap() {
    FocusManager.instance.primaryFocus?.unfocus();
    GiftManager.openGiftSheet(
      userId: reelData.value.userId ?? -1,
      onCompletion: (giftManager) {
        GiftManager.showAnimationDialog(giftManager.gift);
        GiftManager.sendNotification(reelData.value);
      },
    );
  }

  void onAudioTap(Music? music) async {
    FocusManager.instance.primaryFocus?.unfocus();

    await Get.bottomSheet(AudioSheet(music: music), isScrollControlled: true);
  }

  void onUserTap(User? user) {
    if (reelData.value.id == -1) return;
    NavigationService.shared.openProfileScreen(user);
  }

  void notifyCommentSheet(PostByIdData? data) {
    if (data != null && (data.comment != null || data.reply != null)) {
      DebounceAction.shared.call(() {
        onCommentTap(postByIdData: data, isFromNotification: true);
      }, milliseconds: 1000);
    }
  }
}
