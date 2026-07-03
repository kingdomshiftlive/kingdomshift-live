import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shortzz/common/widget/loader_widget.dart';
import 'package:shortzz/common/widget/my_refresh_indicator.dart';
import 'package:shortzz/common/widget/no_data_widget.dart';
import 'package:shortzz/common/widget/post_list.dart';
import 'package:shortzz/languages/languages_keys.dart';
import 'package:shortzz/model/user_model/user_model.dart';
import 'package:shortzz/screen/feed_screen/feed_screen_controller.dart';
import 'package:shortzz/screen/feed_screen/widget/feed_top_view.dart';
import 'package:shortzz/screen/feed_screen/widget/story_view.dart';
import 'package:shortzz/utilities/text_style_custom.dart';
import 'package:shortzz/utilities/theme_res.dart';

class FeedScreen extends StatelessWidget {
  final User? myUser;

  const FeedScreen({super.key, this.myUser});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(FeedScreenController(myUser.obs));
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        FeedTopView(controller: controller),
        Expanded(
            child: MyRefreshIndicator(
          refreshKey: controller.refreshKey,
          onRefresh: controller.onRefresh,
          shouldRefresh: true,
          child: Stack(
            children: [
              Obx(() {
                if (!controller.isLoading.value && controller.posts.isEmpty) {
                  return Stack(
                    children: [
                      NoDataView(
                          safeAreaTop: false,
                          title: LKey.noUserPostsTitle.tr,
                          description: LKey.noUserPostsDescription.tr),
                      SingleChildScrollView(
                        child: SizedBox(width: double.infinity, height: Get.height),
                      ),
                    ],
                  );
                }
                if (controller.isLoading.value && controller.posts.isEmpty) {
                  return const LoaderWidget();
                }
                return const SizedBox();
              }),
              SingleChildScrollView(
                controller: controller.postScrollController,
                physics: const AlwaysScrollableScrollPhysics(),
                // Allows bouncing on edge

                child: Column(
                  children: [
                    StoryView(controller: controller),
                    PostList(posts: controller.posts, isLoading: false.obs, shrinkWrap: true, showNoData: false),
                    Obx(() {
                      if (!controller.hasMoreDiscoverPosts.value && controller.posts.isNotEmpty) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 40.0),
                          child: Column(
                            children: [
                              Icon(Icons.check_circle_outline, size: 60, color: themeAccentSolid(context)),
                              const SizedBox(height: 15),
                              Text("You're all caught up", style: TextStyleCustom.outFitBold700(fontSize: 20)),
                              const SizedBox(height: 5),
                              Text("You've seen all new posts.", style: TextStyleCustom.outFitLight300(fontSize: 14)),
                            ]
                          )
                        );
                      }
                      return const SizedBox();
                    })
                  ],
                ),
              ),
            ],
          ),
        ))
      ],
    );
  }
}
