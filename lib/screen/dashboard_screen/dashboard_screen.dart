import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:shortzz/common/widget/kingdom_reveal/kingdom_reveal_overlay.dart';
import 'package:get/get.dart';
import 'package:proste_indexed_stack/proste_indexed_stack.dart';
import 'package:shortzz/common/service/subscription/subscription_manager.dart';
import 'package:shortzz/common/widget/banner_ads_custom.dart';
import 'package:shortzz/model/user_model/user_model.dart';
import 'package:shortzz/screen/dashboard_screen/dashboard_screen_controller.dart';
import 'package:shortzz/screen/explore_screen/explore_screen.dart';
import 'package:shortzz/screen/feed_screen/feed_screen.dart';
import 'package:shortzz/screen/home_screen/home_screen.dart';
import 'package:shortzz/screen/live_stream/live_dashboard_screen.dart';
import 'package:shortzz/screen/message_screen/message_screen.dart';
import 'package:shortzz/screen/notification_screen/notification_screen.dart';
import 'package:shortzz/screen/profile_screen/profile_screen.dart';
import 'package:shortzz/screen/kingdom_ai_screen/kingdom_ai_screen.dart';
import 'package:shortzz/screen/brain_battle_screen/brain_battle_screen.dart';
import 'package:shortzz/screen/camera_screen/camera_screen.dart';
import 'package:shortzz/screen/wealth_shift_screen/wealth_shift_screen.dart';
import 'package:shortzz/screen/ministries_screen/ministries_screen.dart';
import 'package:shortzz/screen/shop_screen/shop_screen.dart';
import 'package:shortzz/screen/podcast_screen/podcast_screen.dart';
import 'package:shortzz/utilities/style_res.dart';
import 'package:shortzz/utilities/text_style_custom.dart';

class DashboardScreen extends StatefulWidget {
  final User? myUser;
  final int? index;

  const DashboardScreen({super.key, this.myUser, this.index});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  @override
  void initState() {
    super.initState();
    if (widget.index != null) {
      SchedulerBinding.instance.addPostFrameCallback((v) {
        final controller = Get.put(DashboardScreenController());
        controller.selectedPageIndex.value = widget.index!;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(DashboardScreenController());
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0F),
      resizeToAvoidBottomInset: true,
      body: Obx(() {
        return Column(
          children: [
            Expanded(
              child: ProsteIndexedStack(
                index: controller.selectedPageIndex.value,
                children: [
                  // 0 - Home
                  IndexedStackChild(child: const HomeScreen(), preload: true),
                  // 1 - Feed
                  IndexedStackChild(
                      child: FeedScreen(myUser: widget.myUser), preload: true),
                  // 2 - Live
                  IndexedStackChild(
                      child: LiveDashboardScreen(), preload: false),
                  // 3 - Explore
                  IndexedStackChild(
                      child: const ExploreScreen(), preload: true),
                  // 4 - Messages
                  IndexedStackChild(
                      child: const MessageScreen(), preload: true),
                  // 5 - Notifications
                  IndexedStackChild(
                      child: const NotificationScreen(), preload: false),
                  // 6 - Profile
                  IndexedStackChild(
                    child: ProfileScreen(
                        isDashBoard: true,
                        user: widget.myUser,
                        isTopBarVisible: false),
                    preload: true,
                  ),
                  // 7 - KingdomAI
                  IndexedStackChild(
                      child: const KingdomAIScreen(), preload: false),
                  // 8 - Brain Battle
                  IndexedStackChild(
                      child: const BrainBattleScreen(), preload: false),
                  // 9 - WealthShift
                  IndexedStackChild(
                      child: const WealthShiftScreen(), preload: false),
                  // 10 - Ministries
                  IndexedStackChild(
                      child: const MinistriesScreen(), preload: false),
                  // 11 - Shop
                  IndexedStackChild(child: const ShopScreen(), preload: false),
                  // 12 - Podcasts
                  IndexedStackChild(
                      child: const PodcastScreen(), preload: false),
                ],
              ),
            ),
            if (controller.selectedPageIndex.value == 2 && !isSubscribe.value)
              const BannerAdsCustom(),
          ],
        );
      }),
      bottomNavigationBar: _buildBottomNav(context, controller),
    );
  }

  Widget _buildBottomNav(
      BuildContext context, DashboardScreenController controller) {
    return Obx(() {
      PostUploadingProgress postUpload = controller.postProgress.value;
      bool isPostUploading =
          postUpload.uploadType == UploadType.none ? false : true;

      return AnimatedContainer(
        duration: const Duration(milliseconds: 100),
        color: const Color(0xFF0D0D16),
        padding: const EdgeInsets.only(top: 4),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Top quick-access secondary nav (scrollable)
            _buildSecondaryNav(controller),
            const SizedBox(height: 4),
            // Main bottom nav bar
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _navItem(context, controller, 0, Icons.home_rounded, 'Home',
                    isPostUploading),
                _navItem(context, controller, 1, Icons.dynamic_feed_rounded,
                    'Feed', isPostUploading),
                _navItem(context, controller, -1, Icons.add_circle_rounded,
                    'Create', isPostUploading,
                    isCreate: true),
                _navItem(context, controller, 4,
                    Icons.chat_bubble_outline_rounded, 'Inbox', isPostUploading,
                    badgeIndex: 4),
                _navItem(context, controller, 6, Icons.person_outline_rounded,
                    'Profile', isPostUploading),
              ],
            ),
            AnimatedContainer(
              duration: const Duration(milliseconds: 100),
              height: isPostUploading ? 30 : 0,
              margin: Platform.isAndroid || !isPostUploading
                  ? EdgeInsets.zero
                  : const EdgeInsets.only(bottom: 20, top: 5),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Container(
                      height: 30,
                      decoration:
                          BoxDecoration(gradient: StyleRes.themeGradient)),
                  Align(
                    alignment: AlignmentDirectional.centerEnd,
                    child: LayoutBuilder(builder: (context, constraints) {
                      double progress =
                          (constraints.maxWidth * postUpload.progress) / 100;
                      return AnimatedContainer(
                        height: 30,
                        width: constraints.maxWidth - progress,
                        duration: const Duration(milliseconds: 250),
                        decoration:
                            BoxDecoration(color: const Color(0xFF1A1A2E)),
                      );
                    }),
                  ),
                  Align(
                    alignment: Alignment.center,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if (postUpload.uploadType != UploadType.error)
                          Text('${postUpload.progress.toInt()}%',
                              style: TextStyleCustom.outFitMedium500(
                                  color: Colors.white, fontSize: 16)),
                        Text(' ${postUpload.uploadType.title(postUpload.type)}',
                            style: TextStyleCustom.outFitLight300(
                                color: Colors.white, fontSize: 14)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    });
  }

  // Scrollable secondary nav for extra screens
  Widget _buildSecondaryNav(DashboardScreenController controller) {
    final items = [
      {'index': 3, 'icon': Icons.explore_outlined, 'label': 'Explore'},
      {'index': 5, 'icon': Icons.notifications_outlined, 'label': 'Alerts'},
      {'index': 7, 'icon': Icons.auto_awesome, 'label': 'KingdomAI'},
      {'index': 8, 'icon': Icons.psychology_outlined, 'label': 'Brain Battle'},
      {'index': 9, 'icon': Icons.trending_up_rounded, 'label': 'WealthShift'},
      {'index': 2, 'icon': Icons.radio_button_checked, 'label': 'Live'},
      {'index': 10, 'icon': Icons.groups_rounded, 'label': 'Groups'},
      {
        'index': 11,
        'icon': Icons.shopping_bag_outlined,
        'label': 'AuthorityShop'
      },
      {'index': 12, 'icon': Icons.mic_none_rounded, 'label': 'Podcasts'},
    ];

    return Obx(() {
      final sel = controller.selectedPageIndex.value;
      return SizedBox(
        height: 36,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          itemCount: items.length,
          itemBuilder: (_, i) {
            final item = items[i];
            final idx = item['index'] as int;
            final isSelected = sel == idx;
            return GestureDetector(
              onTap: () => controller.selectedPageIndex.value = idx,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                margin: const EdgeInsets.only(right: 8),
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: isSelected
                      ? const Color(0xFF7B2FF7)
                      : const Color(0xFF12121E),
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(
                    color:
                        isSelected ? const Color(0xFF7B2FF7) : Colors.white12,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(item['icon'] as IconData,
                        size: 14,
                        color: isSelected ? Colors.white : Colors.white54),
                    const SizedBox(width: 4),
                    Text(item['label'] as String,
                        style: TextStyle(
                          color: isSelected ? Colors.white : Colors.white54,
                          fontSize: 11,
                          fontWeight:
                              isSelected ? FontWeight.bold : FontWeight.normal,
                        )),
                  ],
                ),
              ),
            );
          },
        ),
      );
    });
  }

  Widget _navItem(
    BuildContext context,
    DashboardScreenController controller,
    int index,
    IconData icon,
    String label,
    bool isPostUploading, {
    bool isLive = false,
    bool isCreate = false,
    int? badgeIndex,
  }) {
    return Obx(() {
      final isSelected = controller.selectedPageIndex.value == index;
      return SafeArea(
        bottom: isPostUploading ? false : true,
        child: GestureDetector(
          onTap: () {
            if (isCreate) {
              KingdomRevealOverlay.pauseForModal();
              Get.to(() => const CameraScreen(cameraType: CameraScreenType.post))?.then((_) {
                KingdomRevealOverlay.resumeAfterModal();
              });
              return;
            }
            controller.onChanged(index);
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
            decoration: BoxDecoration(
              color: isSelected
                  ? const Color(0xFF7B2FF7).withValues(alpha: 0.15)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Stack(
                  clipBehavior: Clip.none,
                  children: [
                    isLive
                        ? Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              gradient: isSelected
                                  ? const LinearGradient(colors: [
                                      Color(0xFFFF0055),
                                      Color(0xFFFF6B00)
                                    ])
                                  : null,
                              color:
                                  isSelected ? null : const Color(0xFF1A1A2E),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                  color: isSelected
                                      ? Colors.transparent
                                      : Colors.white24),
                            ),
                            child:
                                Row(mainAxisSize: MainAxisSize.min, children: [
                              Container(
                                  width: 6,
                                  height: 6,
                                  decoration: const BoxDecoration(
                                      color: Colors.red,
                                      shape: BoxShape.circle)),
                              const SizedBox(width: 4),
                              Text('LIVE',
                                  style: TextStyle(
                                    color: isSelected
                                        ? Colors.white
                                        : Colors.white54,
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                  )),
                            ]),
                          )
                        : Icon(icon,
                            size: 26,
                            color: isSelected
                                ? const Color(0xFF7B2FF7)
                                : Colors.white54),
                    if (badgeIndex != null)
                      Obx(() {
                        final count = controller.unReadCount.value;
                        return count > 0
                            ? Positioned(
                                top: -4,
                                right: -4,
                                child: Container(
                                  width: 16,
                                  height: 16,
                                  decoration: const BoxDecoration(
                                      color: Color(0xFF7B2FF7),
                                      shape: BoxShape.circle),
                                  child: Center(
                                    child: Text(count > 9 ? '9+' : '$count',
                                        style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 9,
                                            fontWeight: FontWeight.bold)),
                                  ),
                                ),
                              )
                            : const SizedBox();
                      }),
                  ],
                ),
                const SizedBox(height: 2),
                Text(label,
                    style: TextStyle(
                      color:
                          isSelected ? const Color(0xFF7B2FF7) : Colors.white38,
                      fontSize: 10,
                      fontWeight:
                          isSelected ? FontWeight.bold : FontWeight.normal,
                    )),
              ],
            ),
          ),
        ),
      );
    });
  }
}
