import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shortzz/common/widget/custom_back_button.dart';
import 'package:shortzz/screen/reels_screen/reels_screen_controller.dart';
import 'package:shortzz/utilities/asset_res.dart';
import 'package:shortzz/utilities/theme_res.dart';

import '../../../model/post_story/post_by_id.dart';
import '../../../model/post_story/post_model.dart';
import '../../../utilities/text_style_custom.dart';
import '../reel/reel_page_controller.dart';

class ReelsTopBar extends StatelessWidget {
  final ReelsScreenController controller;
  final Widget? widget;
  final Post? reelData;
  final bool isFromChat;
  final PostByIdData? postByIdData;

  const ReelsTopBar({
    super.key,
    required this.controller,
    this.widget,
    required this.reelData,
    this.isFromChat = false,
    this.postByIdData,
  });

  @override
  Widget build(BuildContext context) {
    ReelController? reelController;
    if (reelData != null) {
      if (Get.isRegistered<ReelController>(tag: '${reelData?.id}')) {
        reelController = Get.find<ReelController>(tag: '${reelData?.id}');
        // Delay update until after current frame to ensure proper UI update without conflicts
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!isFromChat) {
            reelController?.updateReelData(reel: reelData);
          }
          reelController?.notifyCommentSheet(postByIdData);
        });
      } else {
        reelController = Get.put(ReelController(reelData!.obs), tag: '${reelData?.id}');
        WidgetsBinding.instance.addPostFrameCallback((_) {
          reelController?.notifyCommentSheet(postByIdData);
        });
      }
    }

    return Stack(
      children: [
        SafeArea(
          bottom: false,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Visibility(
                  visible: !controller.isHomePage,
                  replacement: const SizedBox(width: 30),
                  child: CustomBackButton(
                      color: whitePure(context),
                      height: 30,
                      width: 30,
                      padding: EdgeInsets.zero,
                      image: AssetRes.icBackArrow_1),
                ),
                if (widget != null) Flexible(child: widget!),
                // const SizedBox(width: 30, height: 30),
                if (reelController != null)
                  Obx(() {
                    Post? reel = reelController?.reelData.value;
                    num views = reel?.views ?? 0;
                    return Row(
                      children: [
                        if (views > 0)
                          Row(
                            children: [
                              const SizedBox(
                                width: 5,
                              ),
                              Text(
                                '${reel?.views ?? '0'}',
                                style: TextStyleCustom.outFitLight300(color: whitePure(context), fontSize: 11),
                              ),
                              const SizedBox(
                                width: 3,
                              ),
                              Icon(
                                Icons.remove_red_eye_outlined,
                                color: whitePure(context),
                                size: 18,
                              )
                            ],
                          )
                      ],
                    );
                  }),
                // Obx(() {
                //   if (controller.reels.isEmpty) {
                //     return const SizedBox(width: 30, height: 30);
                //   }
                //
                //   bool isVisible = controller.reels[controller.position.value].userId != SessionManager.instance.getUserID();
                //
                //   return Visibility(
                //     visible: isVisible,
                //     replacement: const SizedBox(width: 30, height: 30),
                //     child: InkWell(
                //       onTap: controller.onReportTap,
                //       child: Image.asset(AssetRes.icAlert, width: 30, height: 30),
                //     ),
                //   );
                // })
              ],
            ),
          ),
        ),
      ],
    );
  }
}
