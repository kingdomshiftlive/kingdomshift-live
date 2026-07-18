import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:shortzz/screen/home_screen/home_screen_controller.dart';
import 'package:shortzz/screen/reels_screen/reels_screen.dart';
import 'package:shortzz/utilities/app_res.dart';
import 'package:shortzz/utilities/text_style_custom.dart';
import 'package:shortzz/utilities/theme_res.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(HomeScreenController());
    return Scaffold(
      backgroundColor: const Color(0xFF0A0E1A),
      body: Stack(
        children: [
          ReelsScreen(
            isHomePage: true,
            reels: controller.reels,
            position: 0,
            isLoading: controller.isLoading,
            onFetchMoreData: () => controller.onRefreshPage(reset: false),
            widget: HomeTopCenterWidget(controller: controller),
            onRefresh: controller.onRefreshPage,
            hasMoreData: kDebugMode ? false.obs : controller.hasMoreData,
          ),
          Obx(
            () => Visibility(
              visible: controller.isLoading.value,
              child: const Center(child: CircularProgressIndicator(color: Color(0xFF00D4C8))),
            ),
          ),
        ],
      ),
    );
  }
}

class HomeTopCenterWidget extends StatelessWidget {
  final HomeScreenController controller;

  const HomeTopCenterWidget({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: Column(
        children: [
          // Custom KingdomShift Header
          _KSHeader(),
          const SizedBox(height: 8),
          // Stories Row
          _KSStoriesRow(),
          const SizedBox(height: 8),
          // Tab Bar
          Obx(
            () => SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: TabType.values.map((tabType) {
                  final isSelected =
                      controller.selectedReelCategory.value == tabType;
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: GestureDetector(
                      onTap: () => controller.onTabChange(tabType),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          border: Border(
                            bottom: BorderSide(
                              color: isSelected ? const Color(0xFF00D4C8) : Colors.transparent,
                              width: 2.5,
                            ),
                          ),
                        ),
                        child: Text(
                          tabType.name,
                          style: TextStyle(
                            color: isSelected ? const Color(0xFF00D4C8) : Colors.white60,
                            fontSize: 13,
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _KSHeader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(children: [
        Row(children: [
          const Icon(Icons.workspace_premium_rounded, color: Color(0xFFC9A84C), size: 30),
          const SizedBox(width: 6),
          RichText(text: const TextSpan(children: [
            TextSpan(text: 'KINGDOM\n', style: TextStyle(color: Color(0xFFC9A84C), fontSize: 12, fontWeight: FontWeight.w900, height: 1.1)),
            TextSpan(text: 'SHIFT', style: TextStyle(color: Color(0xFF00D4C8), fontSize: 12, fontWeight: FontWeight.w900)),
            TextSpan(text: '.LIVE', style: TextStyle(color: Color(0xFFFF1493), fontSize: 12, fontWeight: FontWeight.w900)),
          ])),
        ]),
        const Spacer(),
        IconButton(icon: const Icon(Icons.search, color: Colors.white, size: 22), onPressed: () {}),
        Stack(children: [
          IconButton(icon: const Icon(Icons.notifications_outlined, color: Colors.white, size: 22), onPressed: () {}),
          Positioned(top: 8, right: 8, child: Container(
            width: 14, height: 14,
            decoration: const BoxDecoration(color: Color(0xFFFF1493), shape: BoxShape.circle),
            child: const Center(child: Text('3', style: TextStyle(color: Colors.white, fontSize: 8, fontWeight: FontWeight.bold))),
          )),
        ]),
        Container(
          width: 32, height: 32,
          decoration: const BoxDecoration(color: Color(0xFFC9A84C), shape: BoxShape.circle),
          child: const Icon(Icons.workspace_premium_rounded, color: Colors.white, size: 18),
        ),
      ]),
    );
  }
}

class _KSStoriesRow extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final stories = ['KS Live', '@ministerjay', '@iamfaith', '@dbaker', '@chri'];
    return SizedBox(
      height: 88,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        children: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: Column(children: [
              Stack(children: [
                Container(width: 56, height: 56,
                  decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: const Color(0xFF00D4C8), width: 2), color: const Color(0xFF1A2035)),
                  child: const Icon(Icons.person, color: Colors.white54, size: 28)),
                Positioned(bottom: 0, right: 0, child: Container(
                  width: 18, height: 18,
                  decoration: BoxDecoration(color: const Color(0xFF00D4C8), shape: BoxShape.circle, border: Border.all(color: const Color(0xFF0A0E1A), width: 2)),
                  child: const Icon(Icons.add, color: Colors.white, size: 10))),
              ]),
              const SizedBox(height: 4),
              const Text('Your Story', style: TextStyle(color: Colors.white70, fontSize: 9)),
            ]),
          ),
          ...stories.asMap().entries.map((e) => Padding(
            padding: const EdgeInsets.only(right: 12),
            child: Column(children: [
              Stack(children: [
                Container(
                  padding: const EdgeInsets.all(2),
                  decoration: BoxDecoration(shape: BoxShape.circle,
                    gradient: LinearGradient(colors: e.key == 0
                        ? [const Color(0xFFFF1493), const Color(0xFFC9A84C)]
                        : [const Color(0xFF00D4C8), const Color(0xFF1A6BFF)])),
                  child: Container(padding: const EdgeInsets.all(2),
                    decoration: const BoxDecoration(color: Color(0xFF0A0E1A), shape: BoxShape.circle),
                    child: Container(width: 48, height: 48,
                      decoration: const BoxDecoration(color: Color(0xFF1A2035), shape: BoxShape.circle),
                      child: e.key == 0
                          ? const Icon(Icons.workspace_premium_rounded, color: Color(0xFFC9A84C), size: 24)
                          : const Icon(Icons.person, color: Colors.white54, size: 22)))),
                if (e.key == 0) Positioned(bottom: 2, left: 0, right: 0, child: Center(child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 3, vertical: 1),
                  decoration: BoxDecoration(color: const Color(0xFFFF1493), borderRadius: BorderRadius.circular(3)),
                  child: const Text('LIVE', style: TextStyle(color: Colors.white, fontSize: 6, fontWeight: FontWeight.bold))))),
              ]),
              const SizedBox(height: 4),
              Text(e.value.length > 8 ? e.value.substring(0, 8) : e.value, style: const TextStyle(color: Colors.white70, fontSize: 9)),
            ]),
          )),
        ],
      ),
    );
  }
}
