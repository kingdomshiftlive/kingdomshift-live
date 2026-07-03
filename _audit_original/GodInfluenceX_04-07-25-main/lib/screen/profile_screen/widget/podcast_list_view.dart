import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shortzz/common/extensions/common_extension.dart';
import 'package:shortzz/common/extensions/string_extension.dart';
import 'package:shortzz/common/widget/custom_image.dart';
import 'package:shortzz/common/widget/load_more_widget.dart';
import 'package:shortzz/common/widget/loader_widget.dart';
import 'package:shortzz/common/widget/no_data_widget.dart';
import 'package:shortzz/common/widget/reel_list.dart';
import 'package:shortzz/languages/languages_keys.dart';
import 'package:shortzz/model/post_story/post_model.dart';
import 'package:shortzz/screen/profile_screen/podcast_detail_screen.dart';
import 'package:shortzz/utilities/asset_res.dart';
import 'package:shortzz/utilities/text_style_custom.dart';
import 'package:super_context_menu/super_context_menu.dart';

class PodcastListView extends StatelessWidget {
  final RxList<Post> podcasts;
  final ScrollController? controller;
  final RxBool isLoading;
  final VoidCallback? onLoadMore;
  final bool isPinShow;
  final List<ContextMenuElement>? menus;
  final Future<void> Function() onFetchMoreData;
  final Function(dynamic)? onBackResponse;
  final bool shrinkWrap;
  final Widget? widget;

  const PodcastListView({
    super.key,
    required this.podcasts,
    this.controller,
    required this.isLoading,
    this.onLoadMore,
    this.isPinShow = false,
    this.menus,
    required this.onFetchMoreData,
    this.shrinkWrap = false,
    this.onBackResponse,
    this.widget,
  });

  @override
  Widget build(BuildContext context) {
    return LoadMoreWidget(
      loadMore: () async => onLoadMore?.call(),
      child: Obx(
        () => isLoading.value && podcasts.isEmpty
            ? const LoaderWidget()
            : NoDataView(
                title: LKey.noUserPodcastsTitle.tr,
                description: LKey.noUserPodcastsDescription.tr,
                showShow: !isLoading.value && podcasts.isEmpty,
                child: ListView.separated(
                  primary: !shrinkWrap,
                  shrinkWrap: shrinkWrap,
                  controller: controller,
                  padding: EdgeInsets.only(bottom: AppBar().preferredSize.height),
                  itemCount: podcasts.length,
                  separatorBuilder: (context, index) => const SizedBox(height: 15),
                  itemBuilder: (context, index) {
                    Post post = podcasts[index];
                    return PodcastListItem(
                      post: post,
                      onTap: () {
                        Get.to(() => PodcastDetailScreen(post: post), preventDuplicates: false)?.then((value) {
                          onBackResponse?.call(value);
                        });
                      },
                      isPinShow: isPinShow,
                      menus: menus,
                    );
                  },
                ),
              ),
      ),
    );
  }
}

class PodcastListItem extends StatelessWidget {
  final Post post;
  final VoidCallback? onTap;
  final bool isPinShow;
  final List<ContextMenuElement>? menus;

  const PodcastListItem({
    super.key,
    required this.post,
    this.onTap,
    this.isPinShow = false,
    this.menus,
  });

  @override
  Widget build(BuildContext context) {
    return ContextMenuWidget(
      child: InkWell(
        onTap: onTap,
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 15),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Thumbnail
              Stack(
                children: [
                  AspectRatio(
                    aspectRatio: 16 / 9,
                    child: CustomImage(
                      image: post.thumbnail?.addBaseURL(),
                      fit: BoxFit.cover,
                      isShowPlaceHolder: true,
                      size: const Size(double.infinity, double.infinity),
                      radius: 10,
                    ),
                  ),
                  // Pinned Icon
                  if (post.isPinned == 1 && isPinShow)
                    Positioned(
                      top: 8,
                      right: 8,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration:
                            BoxDecoration(color: Colors.black.withOpacity(0.5), borderRadius: BorderRadius.circular(4)),
                        child: Image.asset(AssetRes.icPinned, width: 16, height: 16),
                      ),
                    ),
                  // Play Icon Overlay
                  Positioned.fill(
                    child: Center(
                      child: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.3),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.play_arrow_rounded, color: Colors.white, size: 40),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              // Title and Details
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          post.description ?? '',
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyleCustom.outFitSemiBold600(
                              fontSize: 16, color: Theme.of(context).textTheme.bodyLarge?.color),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Text(
                              '${(post.views ?? 0).numberFormat} ${LKey.views.tr}',
                              style: TextStyleCustom.outFitRegular400(fontSize: 12, color: Colors.grey),
                            ),
                            const SizedBox(width: 4),
                            const Text('•', style: TextStyle(color: Colors.grey, fontSize: 12)),
                            const SizedBox(width: 4),
                            Expanded(
                                child: Text(
                              (post.createdAt != null && post.createdAt!.isNotEmpty) ? post.createdAt!.timeAgo : '',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyleCustom.outFitRegular400(fontSize: 12, color: Colors.grey),
                            )),
                          ],
                        ),
                      ],
                    ),
                  ),
                  if (menus != null)
                    PopupMenuButton<ContextMenuElement>(
                      icon: const Icon(Icons.more_vert),
                      color: Theme.of(context).cardColor,
                      onSelected: (item) => item.onTap?.call(post),
                      itemBuilder: (context) => menus!
                          .map((e) => PopupMenuItem(
                                value: e,
                                child: Text(e.title,
                                    style: TextStyleCustom.outFitRegular400(
                                        fontSize: 14, color: Theme.of(context).textTheme.bodyLarge?.color)),
                              ))
                          .toList(),
                    )
                ],
              ),
            ],
          ),
        ),
      ),
      menuProvider: (_) {
        return Menu(
            children:
                menus?.map((e) => MenuAction(title: e.title, callback: () => e.onTap?.call(post))).toList() ?? []);
      },
    );
  }
}
