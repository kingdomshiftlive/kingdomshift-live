import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'dart:io';
import 'package:pip/pip.dart';
import 'package:readmore/readmore.dart';
import 'package:shortzz/common/controller/base_controller.dart';
import 'package:shortzz/common/extensions/string_extension.dart';
import 'package:shortzz/common/extensions/common_extension.dart';
import 'package:shortzz/common/service/video_cache_helper/video_cache_helper.dart';
import 'package:shortzz/common/widget/custom_image.dart';
import 'package:shortzz/languages/languages_keys.dart';
import 'package:shortzz/model/post_story/post_model.dart';
import 'package:shortzz/screen/comment_sheet/comment_sheet_controller.dart';
import 'package:shortzz/screen/comment_sheet/helper/comment_helper.dart';
import 'package:shortzz/screen/comment_sheet/widget/comment_bottom_text_field_view.dart';
import 'package:shortzz/screen/comment_sheet/widget/comments_view.dart';
import 'package:shortzz/utilities/text_style_custom.dart';
import 'package:video_player/video_player.dart';
import 'package:chewie/chewie.dart';
import 'package:shortzz/screen/gift_sheet/send_gift_sheet_controller.dart';
import 'package:shortzz/utilities/asset_res.dart';

class PodcastDetailScreen extends StatelessWidget {
  final Post post;

  const PodcastDetailScreen({super.key, required this.post});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(PodcastDetailController(post), tag: '${post.id}');

    return Obx(() {
      if (controller.isPipMode.value) {
        // PiP View: Only show video
        return Scaffold(
          backgroundColor: Colors.black,
          body: Center(
            child: controller.isInitialized.value && controller.videoController != null
                ? AspectRatio(
                    aspectRatio: controller.videoController!.value.aspectRatio,
                    child: VideoPlayer(controller.videoController!),
                  )
                : const SizedBox(),
          ),
        );
      }

      // Normal View
      return Scaffold(
        backgroundColor: Colors.black, // YouTube-like dark background
        appBar: AppBar(
          title: Text(LKey.podcast.tr),
          backgroundColor: Colors.black,
          iconTheme: const IconThemeData(color: Colors.white),
        ),
        body: Column(
          children: [
            // 1. Video Player Section (Pinned at top)
            AspectRatio(
              aspectRatio: 16 / 9,
              child: Obx(() {
                if (controller.isInitialized.value &&
                    controller.chewieController != null &&
                    controller.chewieController!.videoPlayerController.value.isInitialized) {
                  return Stack(
                    alignment: Alignment.center,
                    children: [
                      Chewie(controller: controller.chewieController!),
                      // Top Right: Gift Button
                      Positioned(
                        top: 10,
                        right: 10,
                        child: InkWell(
                          onTap: controller.onGiftTap,
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.6),
                              shape: BoxShape.circle,
                            ),
                            child: Image.asset(AssetRes.icGiftNew, width: 24, height: 24),
                          ),
                        ),
                      ),
                    ],
                  );
                }
                return Stack(
                  children: [
                    CustomImage(
                      image: post.thumbnail?.addBaseURL(),
                      fit: BoxFit.cover,
                      size: const Size(double.infinity, double.infinity),
                      radius: 0,
                    ),
                    const Center(child: CircularProgressIndicator(color: Colors.white)),
                  ],
                );
              }),
            ),

            // 2. Scrollable Content: Info & Comments
            Expanded(
              child: NestedScrollView(
                headerSliverBuilder: (context, innerBoxIsScrolled) {
                  return [
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.all(15),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Title (Description as title for now)
                            ReadMoreText(
                              post.description ?? '',
                              trimLines: 2,
                              colorClickableText: Colors.white,
                              trimMode: TrimMode.Line,
                              trimCollapsedText: ' Show more',
                              trimExpandedText: ' Show less',
                              style: TextStyleCustom.outFitSemiBold600(fontSize: 18, color: Colors.white),
                              moreStyle: TextStyleCustom.outFitSemiBold600(fontSize: 14, color: Colors.grey),
                            ),
                            const SizedBox(height: 8),
                            // Stats
                            Row(
                              children: [
                                Text(
                                  '${(post.views ?? 0).numberFormat} ${LKey.views.tr}',
                                  style: TextStyleCustom.outFitRegular400(fontSize: 12, color: Colors.grey),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  (post.createdAt != null && post.createdAt!.isNotEmpty) ? post.createdAt!.timeAgo : '',
                                  style: TextStyleCustom.outFitRegular400(fontSize: 12, color: Colors.grey),
                                ),
                              ],
                            ),
                            const SizedBox(height: 15),
                            // User Row
                            Row(
                              children: [
                                CustomImage(
                                  image: post.user?.profilePhoto?.addBaseURL(),
                                  size: const Size(40, 40),
                                  radius: 20,
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        post.user?.fullname ?? '',
                                        style: TextStyleCustom.outFitSemiBold600(fontSize: 14, color: Colors.white),
                                      ),
                                      Text(
                                        '@${post.user?.username ?? ''}',
                                        style: TextStyleCustom.outFitRegular400(fontSize: 12, color: Colors.grey),
                                      ),
                                    ],
                                  ),
                                ),
                                // Follow Button (Mock for now, or implement logic)
                              ],
                            ),
                            const SizedBox(height: 15),
                            const Divider(color: Colors.white24),
                          ],
                        ),
                      ),
                    ),
                  ];
                },
                body: Column(
                  children: [
                    // Comments Header
                    Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                        child: Align(
                            alignment: Alignment.centerLeft,
                            child: Text("Comments",
                                style: TextStyleCustom.outFitSemiBold600(color: Colors.white, fontSize: 16)))),
                    Expanded(
                        child: Obx(() => controller.commentController.getCommentsList.isEmpty &&
                                controller.commentController.isLoading.value
                            ? const Center(child: CircularProgressIndicator())
                            : CommentsView(
                                controller: controller.commentController,
                                shrinkWrap: false,
                                cardBackgroundColor: Colors.black,
                                cardTextColor: Colors.white,
                              )))
                  ],
                ),
              ),
            ),

            // 3. Comment Input (Pinned at bottom)
            CommentBottomTextFieldView(
              helper: controller.commentHelper,
              isFromBottomSheet: false,
              controller: controller.commentController,
              backgroundColor: Colors.black,
              textColor: Colors.white,
            ),
          ],
        ),
      );
    });
  }
}

class PodcastDetailController extends BaseController {
  final Post post;
  VideoPlayerController? videoController;
  ChewieController? chewieController;
  RxBool isInitialized = false.obs;
  RxBool isPipMode = false.obs;

  late CommentSheetController commentController;
  final CommentHelper commentHelper = CommentHelper();

  PodcastDetailController(this.post);

  @override
  void onInit() {
    super.onInit();
    if (Platform.isAndroid) {
      Pip().registerStateChangedObserver(PipStateChangedObserver(
        onPipStateChanged: (state, error) {
          isPipMode.value = (state == PipState.pipStateStarted);
        },
      ));
    }
    _initVideo();
    _initComments();
  }

  void _initVideo() async {
    String videoUrl = post.video?.addBaseURL() ?? '';
    if (videoUrl.isEmpty) return;

    // Initial setup (will be updated after video loads)
    if (Platform.isAndroid) {
      Pip().setup(const PipOptions(autoEnterEnabled: true));
    }

    final cached = await VideoCacheHelper.getValidCachedVideo(videoUrl);
    if (cached != null) {
      videoController = VideoPlayerController.file(cached.file,
          videoPlayerOptions: VideoPlayerOptions(allowBackgroundPlayback: true, mixWithOthers: false));
    } else {
      videoController = VideoPlayerController.networkUrl(Uri.parse(videoUrl),
          videoPlayerOptions: VideoPlayerOptions(allowBackgroundPlayback: true, mixWithOthers: false));
      VideoCacheHelper.downloadAndCacheVideo(videoUrl);
    }

    try {
      await videoController?.initialize();
      // isInitialized.value = true; // Moved after chewie init
      videoController?.play();
      // isPlaying.value = true;
      videoController?.setLooping(true); // Loops by default for now

      // Initialize Chewie Controller
      chewieController = ChewieController(
        videoPlayerController: videoController!,
        aspectRatio: videoController!.value.aspectRatio,
        autoPlay: true,
        looping: true,
        allowFullScreen: true,
        allowPlaybackSpeedChanging: true,
        showControls: true,
      );
      isInitialized.value = true;

      // Update PiP aspect ratio based on video dimensions
      if (videoController != null && Platform.isAndroid) {
        Pip().setup(PipOptions(
          autoEnterEnabled: true,
          aspectRatioX: videoController!.value.size.width.toInt(),
          aspectRatioY: videoController!.value.size.height.toInt(),
        ));
      }

      // Listen to state changes for UI (if needed locally, though Chewie handles most)
      videoController?.addListener(() {
        if (videoController == null) return;
        // isPlaying.value = videoController!.value.isPlaying;
      });
    } catch (e) {
      print("Error initializing video: $e");
    }
  }

  void _initComments() {
    // Reusing CommentSheetController logic
    commentController =
        Get.put(CommentSheetController(post.obs, null, null, false, commentHelper), tag: 'podcast_comment_${post.id}');
  }

  void onGiftTap() {
    GiftManager.openGiftSheet(
      userId: post.userId ?? -1,
      onCompletion: (giftManager) {
        GiftManager.showAnimationDialog(giftManager.gift);
        GiftManager.sendNotification(post);
      },
    );
  }

  @override
  void onClose() {
    // Disable Auto PiP
    if (Platform.isAndroid) {
      Pip().setup(const PipOptions(autoEnterEnabled: false));
      Pip().unregisterStateChangedObserver();
    }
    chewieController?.dispose();
    videoController?.dispose();
    super.onClose();
  }
}
