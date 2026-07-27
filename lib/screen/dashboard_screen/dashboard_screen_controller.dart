import 'dart:async';
import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:shortzz/common/widget/kingdom_reveal/kingdom_reveal_overlay.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:zego_uikit_prebuilt_call/zego_uikit_prebuilt_call.dart';
import 'package:zego_uikit_signaling_plugin/zego_uikit_signaling_plugin.dart';
import 'package:shortzz/common/controller/ads_controller.dart';
import 'package:shortzz/common/controller/base_controller.dart';
import 'package:shortzz/common/controller/firebase_firestore_controller.dart';
import 'package:shortzz/common/manager/firebase_notification_manager.dart';
import 'package:shortzz/common/manager/logger.dart';
import 'package:shortzz/common/manager/session_manager.dart';
import 'package:shortzz/common/service/api/user_service.dart';
import 'package:shortzz/common/service/subscription/subscription_manager.dart';
import 'package:shortzz/common/service/video_cache_helper/video_cache_helper.dart';
import 'package:shortzz/common/widget/restart_widget.dart';
import 'package:shortzz/languages/languages_keys.dart';
import 'package:shortzz/model/chat/chat_thread.dart';
import 'package:shortzz/model/general/settings_model.dart';
import 'package:shortzz/model/user_model/user_model.dart';
import 'package:shortzz/screen/camera_screen/camera_screen.dart';
import 'package:shortzz/screen/feed_screen/feed_screen_controller.dart';
import 'package:shortzz/screen/gif_sheet/gif_sheet_controller.dart';
import 'package:shortzz/utilities/asset_res.dart';
import 'package:shortzz/utilities/firebase_const.dart';
import 'package:zego_express_engine/zego_express_engine.dart';

class DashboardScreenController extends BaseController
    with GetSingleTickerProviderStateMixin, WidgetsBindingObserver {
  List<String> bottomIconList = [
    AssetRes.icHome, // icReel
    AssetRes.icFeed, // icPost
    AssetRes.icLiveStreamNew,
    AssetRes.icSearchNew,
    AssetRes.icChatNew,
    AssetRes.icProfileNew
  ];
  RxInt selectedPageIndex = 0.obs;
  RxDouble scaleValue = 1.0.obs;
  Function(int index)? onBottomIndexChanged;
  Rx<PostUploadingProgress> postProgress = Rx(PostUploadingProgress());
  Function(PostUploadingProgress progress) onProgress = (_) {};

  late AnimationController animationController;

  FirebaseFirestore db = FirebaseFirestore.instance;
  RxInt unReadCount = 0.obs;

  late StreamSubscription _unReadCountSubscription;
  late Animation<double> scaleAnimation;
  User? user = SessionManager.instance.getUser();

  Timer? _usageTimer;
  int _usageDurationSeconds = 0;
  static const int breakThresholdSeconds = 30 * 60; // 30 minutes

  @override
  void onInit() {
    super.onInit();
    Get.put(GifSheetController());
    animationController = AnimationController(
        duration: const Duration(milliseconds: 200), vsync: this);
    scaleAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(parent: animationController, curve: Curves.easeInOut),
    )..addListener(() {
        scaleValue.value = scaleAnimation.value; // Update reactive scale value
      });
    onProgress = (progress) {
      postProgress.value = progress;
    };
    Get.put(AdsController());

    WidgetsBinding.instance.addObserver(this);
    _startUsageTimer();
  }

  @override
  void onReady() async {
    super.onReady();
    SubscriptionManager.shared.subscriptionListener();

    // Run below in parallel
    _createZegoEngine();
    _initCallInvitationService();
    _fetchLanguageFromUser();
    _fetchUnReadCount();
    startCacheCleanupScheduler();
    _subscribeFollowUserIds();
  }

  void startCacheCleanupScheduler() {
    UserService.instance.updateLastUsedAt();
    VideoCacheHelper.clearAllCache();
    Timer.periodic(const Duration(minutes: 15), (_) {
      VideoCacheHelper.clearExpiredVideos();
      UserService.instance.updateLastUsedAt();
    });
  }

  @override
  void onClose() {
    WidgetsBinding.instance.removeObserver(this);
    _usageTimer?.cancel();
    animationController.dispose();
    _unReadCountSubscription.cancel();
    VideoCacheHelper.clearAllCache();
    super.onClose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _startUsageTimer();
    } else if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive) {
      _usageTimer?.cancel();
    }
  }

  void _startUsageTimer() {
    _usageTimer?.cancel();
    _usageTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      _usageDurationSeconds++;
      if (_usageDurationSeconds >= breakThresholdSeconds) {
        _showBreakReminder();
        _usageDurationSeconds = 0; // reset after showing
      }
    });
  }

  void _showBreakReminder() {
    if (Get.context != null) {
      Get.dialog(
        AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          backgroundColor: Theme.of(Get.context!).scaffoldBackgroundColor,
          title: Row(
            children: [
              Icon(Icons.timer, color: Theme.of(Get.context!).primaryColor),
              const SizedBox(width: 10),
              const Text('Time for a Break!',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ],
          ),
          content: const Text(
              'You\'ve been using the app for 30 minutes. Consider taking a short break to rest your eyes and stretch.'),
          actions: [
            TextButton(
              onPressed: () {
                if (Get.isDialogOpen == true) {
                  Get.back();
                }
              },
              child: Text('Got it',
                  style: TextStyle(color: Theme.of(Get.context!).primaryColor)),
            ),
          ],
        ),
      );
    }
  }

  void onChanged(int index) {
    if (index == 1) {
      onFeedPostScrollDown(index);
    }
    if (selectedPageIndex.value == index) return;
    HapticFeedback.lightImpact();
    onBottomIndexChanged?.call(index);
    // The Home tab (index 0) is kept alive in the background by the
    // IndexedStack, so its Kingdom Reveal overlay never naturally disposes
    // when switching tabs. Since the overlay is inserted at the root level
    // (paints above everything), it must be explicitly paused/resumed here
    // or it bleeds through onto every other tab.
    if (index != 0) {
      KingdomRevealOverlay.pauseForModal();
    } else {
      KingdomRevealOverlay.resumeAfterModal();
    }
    selectedPageIndex.value = index;
    animationController
      ..reset()
      ..forward();
  }

  void onFeedPostScrollDown(int index) {
    if (selectedPageIndex.value != index) return;
    if (Get.isRegistered<FeedScreenController>()) {
      final controller = Get.find<FeedScreenController>();
      if (controller.posts.isNotEmpty && !controller.isLoading.value) {
        controller.postScrollController.animateTo(0.0,
            duration: const Duration(milliseconds: 150), curve: Curves.linear);
        controller.refreshKey.currentState?.show();
      }
    }
  }

  void _fetchUnReadCount() {
    _unReadCountSubscription = db
        .collection(FirebaseConst.users)
        .doc(user?.id.toString())
        .collection(FirebaseConst.usersList)
        .where(FirebaseConst.isDeleted, isEqualTo: false)
        .withConverter(
            fromFirestore: (snapshot, options) =>
                ChatThread.fromJson(snapshot.data()!),
            toFirestore: (ChatThread value, options) => value.toJson())
        .snapshots()
        .listen((event) {
      final count =
          event.docs.where((doc) => (doc.data().msgCount ?? 0) > 0).length;
      unReadCount.value = count;
    });
  }

  Future<void> _initCallInvitationService() async {
    await Future.delayed(const Duration(seconds: 3));
    try {
      final currentUser = SessionManager.instance.getUser();
      final firebaseUid = firebase_auth.FirebaseAuth.instance.currentUser?.uid;
      if (firebaseUid == null || firebaseUid.isEmpty) return;
      final userId = firebaseUid;
      final userName = (currentUser?.username?.isNotEmpty ?? false)
          ? currentUser!.username!
          : (currentUser?.fullname ?? 'User');
      ZegoUIKitPrebuiltCallInvitationService().setNavigatorKey(Get.key);
      await ZegoUIKitPrebuiltCallInvitationService().init(
        appID: 1974018811,
        appSign:
            'b8fcc1eede562f781a1310a6c1fc38696d43f8c854a3f9534c509eb7fba4fa9b',
        userID: userId,
        userName: userName,
        plugins: [ZegoUIKitSignalingPlugin()],
      );
      Get.snackbar('Call service', 'Started OK, ID: $userId',
          duration: const Duration(seconds: 8));
    } catch (e) {
      Loggers.error('Call invitation service init failed: $e');
      Get.snackbar('Call service', 'FAILED: $e',
          duration: const Duration(seconds: 15));
    }
  }
  Future<void> _createZegoEngine() async {
    Setting? appSetting = SessionManager.instance.getSettings();
    int appId = 1974018811;
    if (appId == 0) {
      return Loggers.info('The Zego App ID is not configured.');
    }
    try {
      if (Platform.isIOS) {
        ZegoEngineConfig config = ZegoEngineConfig();
        config.advancedConfig = {"app_group_id": "group.com.godinflunce.vr"};
        ZegoExpressEngine.setEngineConfig(config);
      }
      await ZegoExpressEngine.createEngineWithProfile(ZegoEngineProfile(
          appId, ZegoScenario.Default,
          appSign:
              'b8fcc1eede562f781a1310a6c1fc38696d43f8c854a3f9534c509eb7fba4fa9b'));
    } on MissingPluginException catch (e) {
      Loggers.error('Create Zego Engine : ${e.message}');
    }
  }

  Future<void> _fetchLanguageFromUser() async {
    String savedLanguage = SessionManager.instance.getLang();
    String userLanguage = user?.appLanguage ?? 'en';
    if (userLanguage != savedLanguage) {
      SessionManager.instance.setLang(userLanguage);
      WidgetsBinding.instance.addPostFrameCallback((_) {
        RestartWidget.restartApp(Get.context!);
      });
    }
  }

  void _subscribeFollowUserIds() async {
    Future.wait([addUserInFirebase()]);
    for (int id in (user?.followingIds ?? [])) {
      // Delay slightly to avoid overloading FCM
      await Future.delayed(const Duration(milliseconds: 100));
      Future.wait([
        FirebaseNotificationManager.instance.subscribeToTopic(topic: '$id')
      ]);
    }
  }

  Future addUserInFirebase() async {
    if (Get.isRegistered<FirebaseFirestoreController>()) {
      Get.find<FirebaseFirestoreController>().addUser(user);
    } else {
      Get.put(FirebaseFirestoreController()).addUser(user);
    }
  }
}

class PostUploadingProgress {
  final CameraScreenType type;
  final UploadType uploadType;
  final double progress;

  PostUploadingProgress(
      {this.type = CameraScreenType.post,
      this.progress = 0,
      this.uploadType = UploadType.none});
}

enum UploadType {
  none,
  finish,
  error,
  uploading;

  String title(CameraScreenType type) {
    switch (this) {
      case UploadType.none:
        return '';
      case UploadType.finish:
        return type == CameraScreenType.post
            ? LKey.postUploadSuccessfully.tr
            : LKey.storyUploadSuccess.tr;
      case UploadType.error:
        return LKey.uploadingFailed.tr;
      case UploadType.uploading:
        return type == CameraScreenType.post
            ? LKey.postIsBeginUploading.tr
            : LKey.storyIsBeginUploading.tr;
    }
  }
}
