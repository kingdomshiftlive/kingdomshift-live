// File: widget/audio_live_stream_user_info_sheet.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shortzz/common/extensions/string_extension.dart';
import 'package:shortzz/common/widget/custom_image.dart';
import 'package:shortzz/common/widget/full_name_with_blue_tick.dart';
import 'package:shortzz/model/livestream/app_user.dart';
import 'package:shortzz/utilities/text_style_custom.dart';
import 'package:shortzz/utilities/theme_res.dart';

import '../../languages/languages_keys.dart';
import 'audio_live_stream_controller.dart';

class AudioLiveStreamUserInfoSheet extends StatelessWidget {
  final bool isAudience;
  final AppUser liveUser;
  final AudioLiveStreamController controller;

  const AudioLiveStreamUserInfoSheet({
    super.key,
    required this.isAudience,
    required this.liveUser,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: blackPure(context),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CustomImage(
            size: const Size(80, 80),
            image: liveUser.profile?.addBaseURL(),
            fullName: liveUser.fullname,
            strokeWidth: 2,
          ),
          const SizedBox(height: 10),
          FullNameWithBlueTick(
            username: liveUser.username,
            fontColor: whitePure(context),
            fontSize: 16,
            isVerify: liveUser.isVerify,
          ),
          Text(
            liveUser.fullname ?? '',
            style: TextStyleCustom.outFitRegular400(
              fontSize: 14,
              color: textLightGrey(context),
            ),
          ),
          const SizedBox(height: 20),
          if (!isAudience)
            ElevatedButton(
              onPressed: () => Get.back(),
              child: Text(LKey.stop.tr),
            ),
        ],
      ),
    );
  }
}
