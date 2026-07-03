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
      backgroundColor: themeColor(context),
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
              child: const Center(child: CircularProgressIndicator()),
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
      child: Obx(
        () => SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: TabType.values.map((tabType) {
              final isSelected =
                  controller.selectedReelCategory.value == tabType;
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: InkWell(
                  onTap: () => controller.onTabTypeChanged(tabType),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        tabType.title.toUpperCase(),
                        style: isSelected
                            ? TextStyleCustom.unboundedBold700(
                                color: whitePure(context), fontSize: 13)
                            : TextStyleCustom.unboundedRegular400(
                                color:
                                    whitePure(context).withValues(alpha: 0.7),
                                fontSize: 13),
                      ),
                      const SizedBox(height: 4),
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        height: 2,
                        width: isSelected ? 20 : 0,
                        decoration: BoxDecoration(
                          color: whitePure(context),
                          borderRadius: BorderRadius.circular(1),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ),
    );
  }
}

class TrianglePainter extends CustomPainter {
  final Color strokeColor;
  final PaintingStyle paintingStyle;
  final double strokeWidth;

  TrianglePainter(
      {this.strokeColor = Colors.black,
      this.strokeWidth = 3,
      this.paintingStyle = PaintingStyle.stroke});

  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = Paint()
      ..color = strokeColor
      ..strokeWidth = strokeWidth
      ..style = paintingStyle;

    canvas.drawPath(getTrianglePath(size.width, size.height), paint);
  }

  Path getTrianglePath(double x, double y) {
    return Path()
      ..moveTo(0, y)
      ..lineTo(x / 2, 0)
      ..lineTo(x, y)
      ..lineTo(0, y);
  }

  @override
  bool shouldRepaint(TrianglePainter oldDelegate) {
    return oldDelegate.strokeColor != strokeColor ||
        oldDelegate.paintingStyle != paintingStyle ||
        oldDelegate.strokeWidth != strokeWidth;
  }
}
