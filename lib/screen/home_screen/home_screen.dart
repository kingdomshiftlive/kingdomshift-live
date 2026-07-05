import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:shortzz/screen/home_screen/home_screen_controller.dart';
import 'package:shortzz/screen/dashboard_screen/dashboard_screen_controller.dart';
import 'package:shortzz/screen/reels_screen/reels_screen.dart';
import 'package:shortzz/screen/search_screen/search_screen.dart';

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
    'Live',
    'Groups',
    'Marketplace'
  ];

  @override
  Widget build(BuildContext context) {
    return Column(mainAxisSize: MainAxisSize.min, children: [
      _buildHeader(),
      _buildTabBar(),
    ]);
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 2, 12, 0),
      child: Row(children: [
        // Compact text logo like TikTok
        RichText(
            text: const TextSpan(children: [
          TextSpan(
              text: 'Kingdom',
              style: TextStyle(
                  color: kGold, fontSize: 18, fontWeight: FontWeight.w800)),
          TextSpan(
              text: 'Shift',
              style: TextStyle(
                  color: kTealLight,
                  fontSize: 18,
                  fontWeight: FontWeight.w800)),
          TextSpan(
              text: '.Live',
              style: TextStyle(
                  color: kPink, fontSize: 18, fontWeight: FontWeight.w800)),
        ])),
        const Spacer(),
        // Search - navigates to search screen
        GestureDetector(
            onTap: () => Get.to(() => const SearchScreen()),
            child: Container(
                width: 38,
                height: 42,
                decoration: BoxDecoration(
                    color: Colors.black38,
                    shape: BoxShape.circle,
                    border:
                        Border.all(color: kTealLight.withValues(alpha: 0.25))),
                child: const Icon(Icons.search_rounded,
                    color: kTextPrimary, size: 21))),
        const SizedBox(width: 6),
        GestureDetector(
            onTap: () {
              if (Get.isRegistered<DashboardScreenController>()) {
                Get.find<DashboardScreenController>().onChanged(5);
              }
            },
            child: Stack(children: [
              Container(
                  width: 34,
                  height: 34,
                  decoration: BoxDecoration(
                      color: Colors.black38,
                      shape: BoxShape.circle,
                      border: Border.all(
                          color: kTealLight.withValues(alpha: 0.25))),
                  child: const Icon(Icons.notifications_outlined,
                      color: kTextPrimary, size: 21)),
              Positioned(
                  top: 2,
                  right: 2,
                  child: Container(
                      width: 13,
                      height: 13,
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

  Widget _buildTabBar() {
    return SizedBox(
      height: 42,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
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
              if (i == 2) dash.onChanged(2); // Live
              if (i == 3) dash.onChanged(10); // Groups / Ministries
              if (i == 4) dash.onChanged(11); // Marketplace / Shop
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: const EdgeInsets.only(right: 8),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 7),
              decoration: BoxDecoration(
                color: isSelected ? null : Colors.black.withValues(alpha: 0.38),
                gradient: isSelected
                    ? const LinearGradient(colors: [kTealLight, kTeal])
                    : null,
                borderRadius: BorderRadius.circular(22),
                border: Border.all(
                    color: isSelected ? kTealLight : Colors.white24, width: 1),
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                            color: kTealLight.withValues(alpha: 0.45), blurRadius: 14)
                      ]
                    : [],
              ),
              child: Text(_tabs[i],
                  style: TextStyle(
                    color: isSelected ? Colors.black : kTextSecondary,
                    fontSize: 12,
                    fontWeight:
                        isSelected ? FontWeight.bold : FontWeight.normal,
                  )),
            ),
          );
        },
      ),
    );
  }
}
