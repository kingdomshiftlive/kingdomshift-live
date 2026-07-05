import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:app_links/app_links.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:shortzz/common/controller/base_controller.dart';
import 'package:shortzz/common/manager/firebase_notification_manager.dart';
import 'package:shortzz/common/manager/logger.dart';
import 'package:shortzz/common/manager/session_manager.dart';
import 'package:shortzz/common/service/api/api_service.dart';
import 'package:shortzz/common/service/api/common_service.dart';
import 'package:shortzz/common/service/api/post_service.dart';
import 'package:shortzz/common/service/api/user_service.dart';
import 'package:shortzz/common/service/location/location_service.dart';
import 'package:shortzz/common/service/navigation/navigate_with_controller.dart';
import 'package:shortzz/common/service/utils/params.dart';
import 'package:shortzz/model/general/place_detail.dart';
import 'package:shortzz/model/post_story/post_by_id.dart';
import 'package:shortzz/model/post_story/post_model.dart';
import 'package:shortzz/model/user_model/user_model.dart';
import 'package:shortzz/screen/post_screen/single_post_screen.dart';
import 'package:shortzz/screen/reels_screen/reels_screen.dart';
import 'package:shortzz/screen/reels_screen/reels_screen_controller.dart';
import 'package:shortzz/utilities/app_res.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shortzz/model/livestream/livestream.dart';
import 'package:shortzz/screen/live_stream/livestream_screen/audience/live_stream_audience_screen.dart';
import 'package:shortzz/utilities/firebase_const.dart';
import 'package:shortzz/screen/dashboard_screen/dashboard_screen_controller.dart';

class HomeScreenController extends BaseController
    with GetSingleTickerProviderStateMixin, WidgetsBindingObserver {
  Rx<TabType> selectedReelCategory = TabType.values.first.obs;
  RxList<Post> reels = <Post>[].obs;
  late AnimationController controller;
  late Animation<double> animation;
  StreamSubscription<Uri>? streamSubscription;
  CancelToken token = CancelToken();
  final AppLinks _appLinks = AppLinks();
  RxInt currentPage = 1.obs;
  RxBool hasMoreData = true.obs;

  Rx<User?> get myUser => Rx(SessionManager.instance.getUser());

  @override
  void onInit() {
    WidgetsBinding.instance.addObserver(this); // Register observer

    controller = AnimationController(
        duration: const Duration(milliseconds: 250), vsync: this);
    animation = CurvedAnimation(parent: controller, curve: Curves.linear);

    // Call both methods concurrently
    Future.delayed(const Duration(milliseconds: 500), () {
      onRefreshPage();
    });
    _onNotificationTap();
    _fetchLocation();
    _readDeepLink();

    super.onInit();
  }

  @override
  void onReady() {
    isLoading.value = true;
    super.onReady();
  }

  @override
  void onClose() {
    WidgetsBinding.instance.removeObserver(this); // Unregister observer

    super.onClose();
    controller.dispose();
    streamSubscription?.cancel();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.resumed:
        Loggers.warning("App Resumed");
        break;
      case AppLifecycleState.inactive:
        Loggers.warning("App Inactive");
        break;
      case AppLifecycleState.paused:
        Loggers.warning("App Paused");
        break;
      case AppLifecycleState.detached:
        Loggers.warning("App Detached");
        break;
      case AppLifecycleState.hidden:
        Loggers.warning("App Hidden");
        break;
    }
  }

  Future<void> _onNotificationTap() async {
    if (Platform.isIOS) {
      // Handle the iOS notification payload once
      final payload =
          FirebaseNotificationManager.instance.notificationPayload.value;
      if (payload.isNotEmpty) {
        FirebaseNotificationManager.instance.handleNotification(payload);
      }
    } else {
      // Set up a listener to handle future payload changes
      // Android: Get the message if the app was opened via notification
      RemoteMessage? message =
          await FirebaseMessaging.instance.getInitialMessage();

      if (message != null) {
        await FirebaseNotificationManager.instance
            .handleNotification(jsonEncode(message.toMap()));
      }
    }

    FirebaseNotificationManager.instance.notificationPayload.listen((p0) {
      if (p0.isNotEmpty) {
        FirebaseNotificationManager.instance.handleNotification(p0);
      }
    });
  }

  Future<void> _readDeepLink() async {
    // Get initial link if app was opened from a deep link
    try {
      final initialUri = await _appLinks.getInitialLink();
      if (initialUri != null) {
        await _handleDeepLink(initialUri);
      }
    } catch (e) {
      Loggers.error('Error getting initial link: $e');
    }

    // Subscribe to all events (initial link and further)
    streamSubscription = _appLinks.uriLinkStream.listen((uri) async {
      await _handleDeepLink(uri);
    }, onError: (error) {
      Loggers.error('Deep link error: ${error.toString()}');
    });
  }

  Future<void> _handleDeepLink(Uri uri) async {
    await Future.delayed(const Duration(milliseconds: 500));

    final queryParams = uri.queryParameters;

    if (queryParams.containsKey(Params.postId)) {
      try {
        int postId = int.parse(queryParams[Params.postId]!);
        PostByIdModel model =
            await PostService.instance.fetchPostById(postId: postId);
        if (model.status == true) {
          Post? post = model.data?.post;
          if (post != null) {
            if (post.postType == PostType.reel) {
              await Get.to(() => ReelsScreen(reels: [post].obs, position: 0),
                  preventDuplicates: false);
            } else if ([PostType.image, PostType.video, PostType.text]
                .contains(post.postType)) {
              await Get.to(
                  () => SinglePostScreen(post: post, isFromNotification: true));
            }
          }
        }
      } catch (e) {
        Loggers.error('Error handling post deep link: $e');
      }
    } else if (queryParams.containsKey(Params.userId)) {
      try {
        int userId = int.parse(queryParams[Params.userId]!);
        User? user =
            await UserService.instance.fetchUserDetails(userId: userId);
        if (user != null) {
          await NavigationService.shared.openProfileScreen(user);
        }
      } catch (e) {
        Loggers.error('Error handling user deep link: $e');
      }
    } else if (queryParams.containsKey(Params.liveStreamId)) {
      try {
        String liveStreamId = queryParams[Params.liveStreamId]!;
        if (liveStreamId.isNotEmpty) {
          DocumentSnapshot<Map<String, dynamic>> snapshot =
              await FirebaseFirestore.instance
                  .collection(FirebaseConst.liveStreams)
                  .doc(liveStreamId)
                  .get();
          if (snapshot.exists && snapshot.data() != null) {
            Livestream livestream = Livestream.fromJson(snapshot.data()!);
            livestream.roomID = liveStreamId; // Ensure roomID is set
            if (Get.isRegistered<DashboardScreenController>()) {
              Get.find<DashboardScreenController>().onChanged(2);
            }
            await Get.to(() => LiveStreamAudienceScreen(
                livestream: livestream, isHost: false));
          }
        }
      } catch (e) {
        Loggers.error('Error handling live stream deep link: $e');
      }
    }
  }

  Future<void> onRefreshPage({bool reset = true}) async {
    if (reset) {
      isLoading.value = true;
      currentPage.value = 1;
      hasMoreData.value = true;
    }

    // if (!hasMoreData.value || (isLoading.value && !reset)) return;

    if (!reset) {
      isLoading.value = true;
    }

    switch (selectedReelCategory.value) {
      case TabType.discover:
        await fetchDiscoverPost(reset);
        break;
      case TabType.following:
        await _fetchFollowingPost(reset);
        break;
      case TabType.nearby:
        try {
          await _fetchPostsNearBy(reset);
        } catch (e) {
          selectedReelCategory.value = TabType.discover;
        }
        break;
    }
  }

  Future<void> onTabTypeChanged(TabType tabType) async {
    if (selectedReelCategory.value == tabType) {
      return;
    }
    selectedReelCategory.value = tabType;
    await onRefreshPage.call(reset: true);
  }

  Future<void> fetchDiscoverPost(bool resetData) async {
    print('FETCHING DISCOVER POSTS...');
    List<Post> newPosts = await PostService.instance.fetchPostsDiscover(
        type: PostType.reels, page: currentPage.value, cancelToken: token);
    print('DISCOVER POSTS COUNT: ${newPosts.length}');
    addResponseData(newPosts, resetData);
  }

  Future<void> _fetchFollowingPost(bool resetData) async {
    // Note: Assuming there is a page parameter internally in PostService API for following,
    // but the method currently doesn't expose it. For now just passing new pagination tracking if limits are handled.
    // If PostService doesn't have it, we just limit hasMoreData
    List<Post> newPosts = await PostService.instance
        .fetchPostsFollowing(type: PostType.reels, cancelToken: token);

    addResponseData(newPosts, resetData);
    hasMoreData.value =
        false; // Disable pagination for following if api doesn't support
  }

  Future<void> _fetchPostsNearBy(bool resetData) async {
    Position position = await LocationService.instance
        .getCurrentLocation(isPermissionDialogShow: true);
    List<Post> newPosts = await PostService.instance.fetchPostsNearBy(
        type: PostType.reels,
        placeLat: position.latitude,
        placeLon: position.longitude,
        cancelToken: token); // API doesn't have pagination yet
    addResponseData(newPosts, resetData);
    hasMoreData.value = false;
  }

  void addResponseData(List<Post> newPosts, bool resetData) {
    if (newPosts.isEmpty) {
      hasMoreData.value = false;
    } else {
      currentPage.value++;
    }

    if (resetData) {
      if (Get.isRegistered<ReelsScreenController>(
          tag: ReelsScreenController.tag)) {
        var controller =
            Get.find<ReelsScreenController>(tag: ReelsScreenController.tag);
        controller.onRefreshPage(newPosts);
      }
    }
    if (newPosts.isNotEmpty) {
      if (resetData) {
        reels.assignAll(newPosts);
      } else {
        for (final post in newPosts) {
          if (!reels.any((existing) => existing.supabaseId == post.supabaseId)) {
            reels.add(post);
          }
        }
      }
    }
    isLoading.value = false;
  }

  Future<void> _fetchLocation() async {
    PlaceDetail? detail;
    try {
      detail = await CommonService.instance.getIPPlaceDetail();
    } catch (e) {
      Loggers.error('Location error : $e');
    }

    if (detail != null) {
      UserService.instance.updateUserDetails(
          region: detail.region,
          regionName: detail.regionName,
          timezone: detail.timezone);
    }
  }
}
