// File: widget/audio_live_stream_top_view.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shortzz/common/widget/full_name_with_blue_tick.dart';
import 'package:shortzz/languages/languages_keys.dart';
import 'package:shortzz/utilities/text_style_custom.dart';
import 'package:shortzz/utilities/theme_res.dart';

import 'audio_live_stream_controller.dart';

class AudioLiveStreamTopView extends StatelessWidget {
  final bool isAudience;
  final AudioLiveStreamController controller;

  const AudioLiveStreamTopView({
    super.key,
    required this.isAudience,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Obx(() {
                final host = controller.firestoreController.users
                    .firstWhereOrNull((user) => user.userId == controller.liveData.value.hostId);
                return FullNameWithBlueTick(
                  username: host?.username ?? '',
                  fontColor: whitePure(context),
                  fontSize: 14,
                  isVerify: host?.isVerify,
                );
              }),
            ),
            Obx(() => Text(
                  '${controller.liveData.value.coHostUsers == null ? '0' : controller.liveData.value.coHostUsers!.length - 1} ${LKey.viewers.tr}',
                  style: TextStyleCustom.outFitRegular400(
                    color: whitePure(context),
                    fontSize: 12,
                  ),
                )),
            const SizedBox(width: 10),
            InkWell(
              onTap: () => controller.endStream(),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: whitePure(context).withValues(alpha: 0.3),
                    width: 1,
                  ),
                ),
                child: Text(
                  LKey.stop.tr,
                  style: TextStyleCustom.outFitRegular400(
                    color: whitePure(context),
                    fontSize: 12,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
