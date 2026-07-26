import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shortzz/screen/profile_screen/profile_screen_controller.dart';
import 'package:shortzz/utilities/asset_res.dart';
import 'package:shortzz/utilities/theme_res.dart';
import 'package:flutter_svg/flutter_svg.dart';

class ProfileTabs extends StatelessWidget {
  final ProfileScreenController controller;

  final bool isMe;
  const ProfileTabs({super.key, required this.controller, this.isMe = false});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Obx(
          () => Stack(
            children: [
              Container(height: .5, color: textLightGrey(context)),
              AnimatedAlign(
                alignment: controller.selectedTabIndex.value == 1
                    ? AlignmentDirectional.centerEnd
                    : AlignmentDirectional.centerStart,
                duration: const Duration(milliseconds: 300),
                child: Container(
                  height: 1,
                  width: (MediaQuery.of(context).size.width / (isMe ? 5 : 3) - 40)
                    .clamp(20.0, double.infinity),
                  color: themeAccentSolid(context),
                  margin: const EdgeInsets.symmetric(horizontal: 20),
                ),
              ),
            ],
          ),
        ),
        TabBar(
            onTap: (value) {
              controller.userData.value?.checkIsBlocked(() {
                controller.onTabChanged(value);
                controller.pageController.animateToPage(value,
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.linear);
              });
            },
            indicatorColor: Colors.transparent,
            tabs: List.generate(isMe ? 5 : 3, (index) {
              if (isMe && index == 3) {
                return Obx(() {
                  final color = controller.selectedTabIndex.value == index
                      ? themeAccentSolid(context)
                      : disableGrey(context);
                  return Container(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    child: Icon(Icons.video_camera_back_rounded,
                        size: 26, color: color),
                  );
                });
              }
              if (isMe && index == 4) {
                return Obx(() {
                  final color = controller.selectedTabIndex.value == index
                      ? themeAccentSolid(context)
                      : disableGrey(context);
                  return Container(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    child: Icon(Icons.videocam_rounded,
                        size: 26, color: color),
                  );
                });
              }
              final icon = index == 0
                  ? AssetRes.icReel
                  : index == 1
                      ? AssetRes.icPost
                      : AssetRes.icPodcast;
              return Obx(() {
                final color = controller.selectedTabIndex.value == index
                    ? themeAccentSolid(context)
                    : disableGrey(context);
                if (index == 2) {
                  return Container(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    child: SvgPicture.asset(icon,
                        height: 26,
                        width: 26,
                        colorFilter: ColorFilter.mode(color, BlendMode.srcIn)),
                  );
                }
                return Image.asset(icon, height: 32, width: 24, color: color);
              });
            })),
        Container(height: .5, color: textLightGrey(context)),
      ],
    );
  }
}
