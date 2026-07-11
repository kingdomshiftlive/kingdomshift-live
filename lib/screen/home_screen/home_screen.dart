import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:shortzz/screen/home_screen/home_screen_controller.dart';
import 'package:shortzz/screen/dashboard_screen/dashboard_screen_controller.dart';
import 'package:shortzz/screen/reels_screen/reels_screen.dart';
import 'package:shortzz/screen/search_screen/search_screen.dart';
import 'package:shortzz/common/widget/custom_image.dart';
import 'package:shortzz/screen/live_stream/live_stream_search_screen/live_stream_search_screen_controller.dart';

const kBgPrimary = Color(0xFF08141F);
const kTeal = Color(0xFF005574);
const kTealLight = Color(0xFF00D4C7);
const kGold = Color(0xFFD4AF37);
const kPink = Color(0xFFFF4FA3);
const kLivePink = Color(0xFFFF2D8D);
const kTextPrimary = Color(0xFFFFFFFF);
const kTextSecondary = Color(0xFFA7B7CC);

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});
  @override
  Widget build(BuildContext context) {
    final controller = Get.put(HomeScreenController());
    return Scaffold(
      backgroundColor: kBgPrimary,
      body: Stack(children: [
        ReelsScreen(
          isHomePage: true,
          reels: controller.reels,
          position: 0,
          isLoading: controller.isLoading,
          onFetchMoreData: () => controller.onRefreshPage(reset: false),
          widget: _KSHomeOverlay(controller: controller),
          onRefresh: controller.onRefreshPage,
          hasMoreData: kDebugMode ? false.obs : controller.hasMoreData,
        ),
        Obx(() => Visibility(
              visible: controller.isLoading.value,
              child: const Center(
                  child: CircularProgressIndicator(color: kTealLight)),
            )),
      ]),
    );
  }
}

class _KSHomeOverlay extends StatefulWidget {
  final HomeScreenController controller;
  const _KSHomeOverlay({required this.controller});
  @override
  State<_KSHomeOverlay> createState() => _KSHomeOverlayState();
}

class _KSHomeOverlayState extends State<_KSHomeOverlay> {
  int _selectedTab = 0;
  final _tabs = [
    'Creator Network',
    'Following',
    'Live Groups',
    'Marketplace',
  ];

  late final LiveStreamSearchScreenController _liveController;

  @override
  void initState() {
    super.initState();
    // Reuse the existing live search controller/data source rather than
    // creating a new one. Registers it once, globally, if not already present.
    if (Get.isRegistered<LiveStreamSearchScreenController>()) {
      _liveController = Get.find<LiveStreamSearchScreenController>();
    } else {
      _liveController =
          Get.put(LiveStreamSearchScreenController(), permanent: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        _buildHeader(),
        _buildTabBar(),
        _buildLiveCirclesRow(),
      ]),
    );
  }

  // --- 1. Compact corner logo -------------------------------------------
  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(6, 0, 10, 0),
      child: Row(children: [
        // Small corner logo (TikTok-style compact mark)
        RichText(
            text: const TextSpan(children: [
          TextSpan(
              text: 'Kingdom',
              style: TextStyle(
                  color: kGold, fontSize: 13, fontWeight: FontWeight.w800)),
          TextSpan(
              text: 'Shift',
              style: TextStyle(
                  color: kTealLight, fontSize: 13, fontWeight: FontWeight.w800)),
          TextSpan(
              text: '.Live',
              style: TextStyle(
                  color: kPink, fontSize: 11, fontWeight: FontWeight.w700)),
        ])),
        const Spacer(),
        // Search - navigates to search screen
        GestureDetector(
            onTap: () => Get.to(() => const SearchScreen()),
            child: Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                    color: Colors.black38,
                    shape: BoxShape.circle,
                    border:
                        Border.all(color: kTealLight.withValues(alpha: 0.25))),
                child: const Icon(Icons.search_rounded,
                    color: kTextPrimary, size: 18))),
        const SizedBox(width: 6),
        GestureDetector(
            onTap: () {
              if (Get.isRegistered<DashboardScreenController>()) {
                Get.find<DashboardScreenController>().onChanged(5);
              }
            },
            child: Stack(children: [
              Container(
                  width: 30,
                  height: 30,
                  decoration: BoxDecoration(
                      color: Colors.black38,
                      shape: BoxShape.circle,
                      border: Border.all(
                          color: kTealLight.withValues(alpha: 0.25))),
                  child: const Icon(Icons.notifications_outlined,
                      color: kTextPrimary, size: 18)),
              Positioned(
                  top: 1,
                  right: 1,
                  child: Container(
                      width: 12,
                      height: 12,
                      decoration: const BoxDecoration(
                          color: kLivePink, shape: BoxShape.circle),
                      child: const Center(
                          child: Text('3',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 7,
                                  fontWeight: FontWeight.bold))))),
            ])),
      ]),
    );
  }

  // --- 2. Nav tabs, pulled up close under the logo -----------------------
  Widget _buildTabBar() {
    return SizedBox(
      height: 32,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 1),
        itemCount: _tabs.length,
        itemBuilder: (_, i) {
          final isSelected = _selectedTab == i;
          return GestureDetector(
            onTap: () {
              setState(() => _selectedTab = i);
              if (!Get.isRegistered<DashboardScreenController>()) return;
              final dash = Get.find<DashboardScreenController>();
              if (i == 0) dash.onChanged(0); // Creator Network / Home
              if (i == 1) dash.onChanged(1); // Following / Feed
              if (i == 2) dash.onChanged(2); // Live Groups / Live
              if (i == 3) dash.onChanged(11); // Marketplace / Shop
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: const EdgeInsets.only(right: 8),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
              decoration: BoxDecoration(
                color: isSelected ? null : Colors.black.withValues(alpha: 0.38),
                gradient: isSelected
                    ? const LinearGradient(colors: [kTealLight, kTeal])
                    : null,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                    color: isSelected ? kTealLight : Colors.white24, width: 1),
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                            color: kTealLight.withValues(alpha: 0.45), blurRadius: 12)
                      ]
                    : [],
              ),
              child: Text(_tabs[i],
                  style: TextStyle(
                    color: isSelected ? Colors.black : kTextSecondary,
                    fontSize: 10,
                    fontWeight:
                        isSelected ? FontWeight.bold : FontWeight.normal,
                  )),
            ),
          );
        },
      ),
    );
  }

  // --- 3 & 4. Horizontal scrollable live status circles -------------------
  Widget _buildLiveCirclesRow() {
    return Obx(() {
      final streams = _liveController.livestreamFilterList;

      if (streams.isEmpty) {
        return const SizedBox.shrink();
      }

      return Container(
        height: 92,
        margin: const EdgeInsets.only(top: 8),
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          itemCount: streams.length,
          itemBuilder: (_, i) {
            final stream = streams[i];
            final user = stream.hostUser;
            final name = (user?.username?.isNotEmpty ?? false)
                ? user!.username!
                : (user?.fullname ?? 'Live');

            return GestureDetector(
              onTap: () => _liveController.onLiveUserTap(stream),
              child: Container(
                width: 64,
                margin: const EdgeInsets.only(right: 12),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Gradient "live" ring around the avatar
                    Container(
                      padding: const EdgeInsets.all(2.5),
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(
                          colors: [kLivePink, kGold, kTealLight],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                      ),
                      child: Container(
                        padding: const EdgeInsets.all(2),
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: kBgPrimary,
                        ),
                        child: Stack(
                          clipBehavior: Clip.none,
                          children: [
                            CustomImage(
                              size: const Size(52, 52),
                              image: user?.profile,
                              fullName: name,
                              radius: 100,
                              fit: BoxFit.cover,
                            ),
                            // Small live/online status dot
                            Positioned(
                              bottom: 0,
                              right: 0,
                              child: Container(
                                width: 14,
                                height: 14,
                                decoration: BoxDecoration(
                                  color: kLivePink,
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                      color: kBgPrimary, width: 2),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: kTextSecondary,
                        fontSize: 10.5,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      );
    });
  }
}
