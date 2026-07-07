import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shortzz/common/service/logger.dart';
import 'package:shortzz/common/widget/loader_widget.dart';
import 'package:shortzz/common/widget/my_refresh_indicator.dart';
import 'package:shortzz/common/widget/no_data_widget.dart';
import 'package:shortzz/languages/languages_keys.dart';
import 'package:shortzz/model/post_story/post_by_id.dart';
import 'package:shortzz/model/post_story/post_model.dart';
import 'package:shortzz/screen/comment_sheet/widget/hashtag_and_mention_view.dart';
import 'package:shortzz/screen/reels_screen/reel/reel_page.dart';
import 'package:shortzz/screen/reels_screen/reels_screen_controller.dart';
import 'package:shortzz/screen/reels_screen/widget/reels_text_field.dart';
import 'package:shortzz/screen/reels_screen/widget/reels_top_bar.dart';
import 'package:shortzz/utilities/theme_res.dart';
import 'package:shortzz/utilities/text_style_custom.dart';
import 'package:video_player/video_player.dart';

class ReelsScreen extends StatelessWidget {
  final RxList<Post> reels;
  final int position;
  final Widget? widget;
  final Future<void> Function()? onFetchMoreData;
  final Future<void> Function()? onRefresh;
  final RxBool? isLoading;
  final PostByIdData? postByIdData;
  final bool isHomePage;
  final bool isFromChat;
  final RxBool? hasMoreData;

  const ReelsScreen(
      {super.key,
      required this.reels,
      required this.position,
      this.onFetchMoreData,
      this.widget,
      this.onRefresh,
      this.isLoading,
      this.hasMoreData,
      this.postByIdData,
      this.isHomePage = false,
      this.isFromChat = false});

  @override
  Widget build(BuildContext context) {
    final ReelsScreenController controller = Get.put(
        ReelsScreenController(
            reels: reels,
            position: position.obs,
            onFetchMoreData: onFetchMoreData,
            onRefresh: onRefresh,
            isHomePage: isHomePage),
        tag: isHomePage
            ? ReelsScreenController.tag
            : '${DateTime.now().millisecondsSinceEpoch}');

    return Scaffold(
      backgroundColor: blackPure(context),
      body: Stack(
        fit: StackFit.expand,
        children: [
          Column(
            children: [
              Expanded(
                child: MyRefreshIndicator(
                  onRefresh: onRefresh ?? () async {},
                  shouldRefresh: onRefresh != null,
                  child: Stack(
                    alignment: Alignment.bottomCenter,
                    children: [
                      Obx(() {
                        final reels = controller.reels;
                        bool _isLoading = isLoading?.value ?? false;
                        return _isLoading && reels.isEmpty
                            ? const LoaderWidget()
                            : !_isLoading && reels.isEmpty
                                ? NoDataWidgetWithScroll(
                                    title: LKey.reelsEmptyTitle.tr,
                                    description: LKey.reelsEmptyDescription.tr)
                                : PageView.builder(
                                    controller: controller.pageController,
                                    itemCount: reels.length + 1,
                                    physics: const PageScrollPhysics(),
                                    onPageChanged: controller.onPageChanged,
                                    scrollDirection: Axis.vertical,
                                    clipBehavior: Clip.none,
                                    itemBuilder: (context, index) {
                                      if (index >= reels.length) {
                                        return Container(
                                          decoration: BoxDecoration(
                                            gradient: LinearGradient(
                                              begin: Alignment.topCenter,
                                              end: Alignment.bottomCenter,
                                              colors: [
                                                blackPure(context),
                                                themeColor(context)
                                                    .withValues(alpha: 0.8),
                                                blackPure(context),
                                              ],
                                            ),
                                          ),
                                          child: Center(
                                            child: Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                Container(
                                                  padding:
                                                      const EdgeInsets.all(20),
                                                  decoration: BoxDecoration(
                                                    color: themeAccentSolid(
                                                            context)
                                                        .withValues(alpha: 0.1),
                                                    shape: BoxShape.circle,
                                                  ),
                                                  child: Icon(
                                                    Icons.check_circle_rounded,
                                                    size: 80,
                                                    color: themeAccentSolid(
                                                        context),
                                                  ),
                                                ),
                                                const SizedBox(height: 30),
                                                Text(
                                                  "You're all caught up",
                                                  style: TextStyleCustom
                                                      .outFitBold700(
                                                    color: whitePure(context),
                                                    fontSize: 26,
                                                  ),
                                                ),
                                                const SizedBox(height: 12),
                                                Padding(
                                                  padding: const EdgeInsets
                                                      .symmetric(
                                                      horizontal: 40),
                                                  child: Text(
                                                    "You've seen all the latest reels for now. Check back later for more!",
                                                    textAlign: TextAlign.center,
                                                    style: TextStyleCustom
                                                        .outFitLight300(
                                                      color: whitePure(context)
                                                          .withValues(
                                                              alpha: 0.7),
                                                      fontSize: 15,
                                                      // height: 1.5,
                                                    ),
                                                  ),
                                                ),
                                                const SizedBox(height: 40),
                                                InkWell(
                                                  onTap: () {
                                                    controller.pageController
                                                        .animateToPage(
                                                      0,
                                                      duration: const Duration(
                                                          milliseconds: 500),
                                                      curve: Curves.easeInOut,
                                                    );
                                                  },
                                                  child: Container(
                                                    padding: const EdgeInsets
                                                        .symmetric(
                                                        horizontal: 25,
                                                        vertical: 12),
                                                    decoration: BoxDecoration(
                                                      color: whitePure(context),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              30),
                                                    ),
                                                    child: Text(
                                                      "Back to Top",
                                                      style: TextStyleCustom
                                                          .outFitSemiBold600(
                                                        color:
                                                            blackPure(context),
                                                        fontSize: 16,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        );
                                      }
                                      final reel = reels[index];
                                      return Obx(() {
                                        VideoPlayerController? videoController =
                                            controller.videoControllers[index];
                                        logger(
                                            "videoController.... ${videoController?.dataSource}");
                                        return ReelPage(
                                          videoPlayerController:
                                              videoController,
                                          likeKey: GlobalKey(),
                                          reelData: reel,
                                          postByIdData: postByIdData,
                                          isFromChat: isFromChat,
                                          reelsScreenController: controller,
                                        );
                                      });
                                    },
                                  );
                      }),
                      HashTagAndMentionUserView(
                          helper: controller.commentHelper),
                    ],
                  ),
                ),
              ),
              ReelsTextField(controller: controller),
            ],
          ),
          Obx(
            () => ReelsTopBar(
              controller: controller,
              widget: widget,
              reelData: controller.reel?.value,
              postByIdData: postByIdData,
              isFromChat: isFromChat,
            ),
          )
        ],
      ),
    );
  }
}

class CustomPageViewScrollPhysics extends ScrollPhysics {
  const CustomPageViewScrollPhysics({super.parent});

  @override
  CustomPageViewScrollPhysics applyTo(ScrollPhysics? ancestor) {
    return CustomPageViewScrollPhysics(parent: buildParent(ancestor)!);
  }

  @override
  SpringDescription get spring => const SpringDescription(
        mass: 1,
        stiffness: 600,
        damping: 60,
      );
}
