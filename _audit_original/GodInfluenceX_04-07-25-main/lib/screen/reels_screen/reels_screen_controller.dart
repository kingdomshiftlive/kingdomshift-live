import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shortzz/common/controller/base_controller.dart';
import 'package:shortzz/common/extensions/string_extension.dart';
import 'package:shortzz/common/functions/debounce_action.dart';
import 'package:shortzz/common/manager/logger.dart';
import 'package:shortzz/common/manager/session_manager.dart';
import 'package:shortzz/common/service/api/post_service.dart';
import 'package:shortzz/common/service/logger.dart';
import 'package:shortzz/common/service/video_cache_helper/video_cache_helper.dart';
import 'package:shortzz/model/post_story/comment/fetch_comment_model.dart';
import 'package:shortzz/model/post_story/post_model.dart';
import 'package:shortzz/screen/comment_sheet/helper/comment_helper.dart';
import 'package:shortzz/screen/dashboard_screen/dashboard_screen_controller.dart';
import 'package:shortzz/screen/home_screen/home_screen_controller.dart';
import 'package:shortzz/screen/reels_screen/reel/reel_page_controller.dart';
import 'package:shortzz/screen/report_sheet/report_sheet.dart';
import 'package:shortzz/utilities/app_res.dart';
import 'package:video_player/video_player.dart';

class ReelsScreenController extends BaseController {
  static const tag = 'REEL';
  RxBool isVideoDisposing = false.obs;

  DashboardScreenController dashboardController = Get.find<DashboardScreenController>();

  HomeScreenController homeScreenController = Get.find<HomeScreenController>();
  final RxDouble previousPosition = 0.0.obs;

  RxMap<int, VideoPlayerController> videoControllers = <int, VideoPlayerController>{}.obs;

  RxList<Post> reels = <Post>[].obs;
  Rx<Post>? reel = Post().obs;
  RxInt position = 0.obs;
  Rx<TabType> selectedReelCategory = TabType.values.first.obs;
  PageController pageController = PageController();
  CommentHelper commentHelper = CommentHelper();
  Future<void> Function()? onFetchMoreData;
  Future<void> Function()? onRefresh;
  bool isHomePage;

  ReelsScreenController(
      {required this.reels,
      required this.position,
      required this.onFetchMoreData,
      this.onRefresh,
      required this.isHomePage});

  @override
  void onInit() {
    super.onInit();
    pageController = PageController(initialPage: position.value);
    if (isHomePage) {
      _setupDashboardController();
    }
    if (!isHomePage) {
      initVideoPlayer();
    }
    reel ??= Post().obs;
    if (reels.isNotEmpty) {
      reel?.value = reels[0];
    }
  }

  @override
  void onClose() {
    super.onClose();
    disposeAllController();
  }

  void _setupDashboardController() {
    dashboardController.onBottomIndexChanged = (index) {
      if (index == 0) {
        videoControllers[position.value]?.play();
      } else {
        videoControllers[position.value]?.pause();
      }
    };
  }

  Future<void> _fetchMoreData() async {
    if (position >= reels.length - 3) {
      await onFetchMoreData?.call().then((value) {
        _initializeControllerAtIndex(position.value + 1);
      });
    }
  }

  void onReportTap() {
    Get.bottomSheet(ReportSheet(reportType: ReportType.post, id: reels[position.value].id?.toInt()),
        isScrollControlled: true);
  }

  Future<void> initVideoPlayer() async {
    await _initializeControllerAtIndex(position.value);
    _playControllerAtIndex(position.value);
    if (position.value > 0) {
      unawaited(_initializeControllerAtIndex(position.value - 1));
    }
    unawaited(_initializeControllerAtIndex(position.value + 1));
    unawaited(_initializeControllerAtIndex(position.value + 2));
    _warmNext(position.value);
  }

  // void _playNextReel(int index) {
  //   _stopControllerAtIndex(index - 1);
  //   _disposeControllerAtIndex(index - 2);
  //   _playControllerAtIndex(index);
  //   // Initialize only the next neighbor; remove +2 initialization.
  //   _initializeControllerAtIndex(index + 1);
  //   // Warm cache only (no initialize) for +2
  //   _warmNext(index); // already caches +1,+2
  // }
  //
  // void _playPreviousReel(int index) {
  //   _stopControllerAtIndex(index + 1);
  //   _disposeControllerAtIndex(index + 2);
  //   _playControllerAtIndex(index);
  //   _initializeControllerAtIndex(index - 1);
  //   _initializeControllerAtIndex(index - 2); // optional for reverse scrolls
  // }
  //
  // Future _initializeControllerAtIndex(int index) async {
  //   if (index < 0 || index >= reels.length) return;
  //   final url = reels[index].video?.addBaseURL() ?? '';
  //   if (url.isEmpty) return Loggers.error('Video URL not found!!!');
  //
  //   // Prefer local file if already cached
  //   final cached = await VideoCacheHelper.getValidCachedVideo(url);
  //   late final VideoPlayerController ctrl;
  //   if (cached != null) {
  //     ctrl = VideoPlayerController.file(cached.file);
  //   } else {
  //     // For non-current items: avoid initializing; just cache and return
  //     if (index != position.value) {
  //       unawaited(VideoCacheHelper.downloadAndCacheVideo(url));
  //       return;
  //     }
  //     ctrl = VideoPlayerController.networkUrl(Uri.parse(url));
  //     unawaited(VideoCacheHelper.downloadAndCacheVideo(url));
  //   }
  //
  //   videoControllers[index] = ctrl;
  //   try {
  //     await ctrl.initialize();
  //   } catch (e) {
  //     Loggers.error('Initialize failed @ $index: $e');
  //     await ctrl.dispose();
  //     videoControllers.remove(index);
  //     return;
  //   }
  //   Loggers.info('INITIALIZED $index');
  // }

  void _playNextReel(int index) {
    _stopControllerAtIndex(index - 1);
    _disposeControllerAtIndex(index - 2);
    _playControllerAtIndex(index);
    _initializeControllerAtIndex(index + 1);
    _initializeControllerAtIndex(index + 2);
  }

  void _playPreviousReel(int index) {
    _stopControllerAtIndex(index + 1);
    _disposeControllerAtIndex(index + 2);
    _playControllerAtIndex(index);
    _initializeControllerAtIndex(index - 1);
    _initializeControllerAtIndex(index - 2);
  }

  Future<void> _initializeControllerAtIndex(int index) async {
    if (index < 0 || index >= reels.length) return;
    if (videoControllers[index]?.value.isInitialized == true) return;

    final VideoPlayerController controller;
    if (reels.firstOrNull?.id == -1) {
      controller = VideoPlayerController.file(File(reels.first.video ?? ''));
    } else {
      final String videoUrl = reels[index].video?.addBaseURL() ?? '';
      logger("videoUrl.... $videoUrl");
      if (videoUrl.isEmpty) return Loggers.error('Video URL not found!!!');

      final cached = await VideoCacheHelper.getValidCachedVideo(videoUrl);
      if (cached != null) {
        controller = VideoPlayerController.file(cached.file);
        Loggers.success('LOCAL VIDEO RUNNING $index');
      } else {
        Loggers.warning('NETWORK VIDEO RUNNING $index');
        controller = VideoPlayerController.networkUrl(Uri.parse(videoUrl));
        unawaited(VideoCacheHelper.downloadAndCacheVideo(videoUrl));
      }
    }

    videoControllers[index] = controller;
    try {
      await controller.initialize();
      controller.setLooping(true);
    } catch (e) {
      Loggers.error('Initialize failed @ $index: $e');
      await controller.dispose();
      videoControllers.remove(index);
      return;
    }
    Loggers.info('🚀🚀🚀 INITIALIZED $index');
  }

  void _playControllerAtIndex(int index) async {
    if (dashboardController.selectedPageIndex.value != 0 && isHomePage) {
      return;
    }
    if (reels.length > index && index >= 0) {
      VideoPlayerController? controller = videoControllers[index];
      if (controller != null && controller.value.isInitialized) {
        controller.play();
        controller.setLooping(true);
        videoControllers.refresh();
        DebounceAction.shared.call(() {
          _increaseViewsCount(reels[index]);
        }, milliseconds: 1000);
        Loggers.info('🚀🚀🚀 PLAYING $index');
      } else {
        await _initializeControllerAtIndex(index);
        _playControllerAtIndex(index);
      }
    }
  }

  void _increaseViewsCount(Post? post) async {
    if (post == null || post.id == null) {
      return Loggers.error('Post not found or ID is null');
    }

    final postId = post.id ?? -1;
    if (postId == -1) {
      return Loggers.error('Post ID $postId not found in reels');
    }

    final reelIndex = reels.indexWhere((element) => element.id == postId);
    if (reelIndex == -1) {
      return Loggers.error('Post ID $postId not found in reels');
    }

    final response = await PostService.instance.increaseViewsCount(postId: postId);

    if (response.status == true) {
      // Loggers.info('🚀 INCREASE VIEWS COUNT SUCCESSFUL');
      post.increaseViews();
      reels[reelIndex] = post;

      final controllerTag = postId.toString();
      if (Get.isRegistered<ReelController>(tag: controllerTag)) {
        Get.find<ReelController>(tag: controllerTag).updateReelData(reel: post, isIncreaseCoin: true);
      }
    }
  }

  void _stopControllerAtIndex(int index) {
    if (reels.length > index && index >= 0) {
      final controller = videoControllers[index];
      if (controller != null) {
        controller.pause();
        controller.seekTo(const Duration()); // Reset position
        Loggers.info('🚀🚀🚀 STOPPED $index');
      }
    }
  }

  void _disposeControllerAtIndex(int index) {
    if (reels.length > index && index >= 0) {
      final VideoPlayerController? controller = videoControllers[index];
      if (controller != null) {
        _stopControllerAtIndex(index);
        controller.dispose();
        videoControllers.remove(index);
        Loggers.info('🚀🚀🚀 DISPOSED $index');
      }
    }
  }

  Future<void> disposeAllController() async {
    final controllersToDispose = videoControllers.values.toList(); // clone to avoid concurrent modification
    videoControllers.clear(); // clear early to prevent usage during async dispose

    for (var controller in controllersToDispose) {
      try {
        if (controller.value.isInitialized) {
          await controller.pause(); // Optional: pause before disposing
        }
        await controller.dispose();
      } catch (e, _) {
        Loggers.error('❌ Failed to dispose controller: $e');
      }
    }
  }

  // When user lands on index, kick off background caches for +1 and +2
  // Future _warmNext(int index) async {
  //   for (final i in [index + 1, index + 2]) {
  //     if (i < 0 || i >= reels.length) continue;
  //     final url = reels[i].video?.addBaseURL() ?? '';
  //     if (url.isEmpty) continue;
  //     // fire-and-forget: cache next videos in background
  //     unawaited(VideoCacheHelper.downloadAndCacheVideo(url));
  //   }
  // }

  final Set<String> _warmed = {};

  Future _warmNext(int index) async {
    for (final i in [index + 1, index + 2]) {
      if (i < 0 || i >= reels.length) continue;
      final url = reels[i].video?.addBaseURL() ?? '';
      if (url.isEmpty || _warmed.contains(url)) continue;
      _warmed.add(url);
      unawaited(VideoCacheHelper.downloadAndCacheVideo(url));
    }
  }

  void onPageChanged(int index) {
    commentHelper.detectableTextFocusNode.unfocus();
    commentHelper.detectableTextController.clear();
    if (index > position.value) {
      _fetchMoreData();
      _playNextReel(index);
    } else {
      _playPreviousReel(index);
    }
    reel ??= Post().obs;
    reel?.value = reels[index];
    position.value = index;
    _warmNext(index);
  }

  void onUpdateComment(Comment comment, bool isReplyComment) {
    final post = reels.firstWhereOrNull((e) => e.id == comment.postId);
    if (post == null) {
      return Loggers.error('Post not found');
    }
    final controllerTag = post.id.toString();
    if (Get.isRegistered<ReelController>(tag: controllerTag)) {
      Get.find<ReelController>(tag: controllerTag).reelData.update((val) => val?.updateCommentCount(1));
    }
  }

  Future<void> onRefreshPage(List<Post> reels) async {
    if (reels.isEmpty) {
      return;
    }
    if (onRefresh != null) {
      position.value = 0;

      if (pageController.hasClients) {
        pageController.jumpToPage(position.value);
      }

      String videoUrl = reels[position.value].video?.addBaseURL() ?? '';

      final cached = await VideoCacheHelper.getValidCachedVideo(videoUrl);
      File file;
      final VideoPlayerController controller;
      if (cached != null) {
        file = cached.file;
        controller = VideoPlayerController.file(file);
      } else {
        controller = VideoPlayerController.networkUrl(Uri.parse(videoUrl));
        VideoCacheHelper.downloadAndCacheVideo(videoUrl);
      }
      await controller.initialize();

      // Step 2: Dispose old controllers not needed anymore
      disposeAllController();
      videoControllers[position.value] = controller;

      /// Play 1st video
      _playControllerAtIndex(position.value);
      await _initializeControllerAtIndex(position.value + 1);
    }
  }
}
