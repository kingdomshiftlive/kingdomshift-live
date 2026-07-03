import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shortzz/common/manager/session_manager.dart';

import 'package:shortzz/screen/feed_screen/feed_screen_controller.dart';
import 'package:shortzz/screen/notification_screen/notification_screen.dart';
import 'package:shortzz/utilities/asset_res.dart';

import 'package:shortzz/utilities/text_style_custom.dart';
import 'package:shortzz/utilities/theme_res.dart';

class FeedTopView extends StatelessWidget {
  final FeedScreenController controller;

  const FeedTopView({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: scaffoldBackgroundColor(context),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      child: SafeArea(
        bottom: false,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Obx(
                () => SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: PostCategory.values.map((category) {
                      final isSelected =
                          controller.selectedPostCategory.value == category;
                      return Padding(
                        padding: const EdgeInsets.only(right: 16),
                        child: InkWell(
                          onTap: () => controller.onChangeCategory(category),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                category.title.toUpperCase(),
                                style: isSelected
                                    ? TextStyleCustom.unboundedBold700(
                                        color: textDarkGrey(context),
                                        fontSize: 13)
                                    : TextStyleCustom.unboundedRegular400(
                                        color: textLightGrey(context),
                                        fontSize: 13),
                              ),
                              const SizedBox(height: 4),
                              AnimatedContainer(
                                duration: const Duration(milliseconds: 200),
                                height: 2,
                                width: isSelected ? 20 : 0,
                                decoration: BoxDecoration(
                                  color: textDarkGrey(context),
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
            ),
            InkWell(
              onTap: () {
                Get.to(() => const NotificationScreen());
                int count = SessionManager.instance.notifyCount.value;
                SessionManager.instance.setNotifyCount(-count);
                SessionManager.instance.notifyCount.value = 0;
              },
              child: SizedBox(
                width: 32,
                height: 32,
                child: Stack(
                  alignment: Alignment.bottomCenter,
                  children: [
                    Image.asset(AssetRes.icNotification, width: 24, height: 24),
                    Obx(() {
                      int notifyCount =
                          SessionManager.instance.notifyCount.value;
                      if (notifyCount <= 0) {
                        return const SizedBox();
                      }
                      return Align(
                        alignment: Alignment.topRight,
                        child: Container(
                          height: 19,
                          width: 19,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                              color: themeAccentSolid(context),
                              shape: BoxShape.circle),
                          child: Text(
                            '$notifyCount',
                            style: TextStyleCustom.outFitRegular400(
                                color: whitePure(context), fontSize: 12),
                          ),
                        ),
                      );
                    })
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
