import 'package:get/get.dart';
import 'package:shortzz/common/controller/base_controller.dart';
import 'package:shortzz/common/manager/logger.dart';
import 'package:shortzz/common/service/api/post_service.dart';
import 'package:shortzz/model/post_story/post/explore_page_model.dart';
import 'package:shortzz/model/post_story/post_model.dart';
import 'package:shortzz/screen/hashtag_screen/hashtag_screen.dart';
import 'package:shortzz/screen/post_screen/single_post_screen.dart';
import 'package:shortzz/screen/reels_screen/reels_screen.dart';
import 'package:shortzz/screen/scan_qr_code_screen/scan_qr_code_screen.dart';
import 'package:shortzz/screen/search_screen/search_screen.dart';
import 'package:shortzz/screen/video_player_screen/video_player_screen.dart';

class ExploreScreenController extends BaseController {
  Rx<ExplorePageData?> explorePageData = Rx(null);

  @override
  void onInit() {
    super.onInit();
    fetchExplorePageData();
  }

  Future<void> fetchExplorePageData() async {
    isLoading.value = true;
    explorePageData.value = await PostService.instance.fetchExplorePageData();
    isLoading.value = false;
  }

  void onExploreTap(String? hashtag) {
    Get.to(() => HashtagScreen(hashtag: hashtag ?? '', index: 0),
        preventDuplicates: false);
  }

  void onPostTap(Post post) {
    switch (post.postType) {
      case PostType.reel:
        Get.to(() => ReelsScreen(
            reels: [post].obs, position: 0, hasMoreData: false.obs));
        break;
      case PostType.image:
        Get.to(() => SinglePostScreen(post: post, isFromNotification: false));
        break;
      case PostType.video:
      case PostType.podcast: // Treat podcast same as video
        Get.to(() => VideoPlayerScreen(post: post));
        break;
      case PostType.text:
        break;
      case PostType.none:
        Loggers.error('Post Type none');
        break;
    }
  }

  void openSearch() {
    Get.to(() => const SearchScreen());
  }

  void openPodcasts() async {
    final posts = await PostService.instance.fetchPostsDiscover(
      type: '${PostType.podcast.type}',
      page: 1,
    );

    if (posts.isNotEmpty) {
      Get.to(() => ReelsScreen(
            reels: posts.obs,
            position: 0,
            hasMoreData: false.obs,
          ));
    } else {
      Get.to(() => const SearchScreen());
    }
  }

  void onScanQrCode() {
    Get.to(() => const ScanQrCodeScreen());
  }
}
