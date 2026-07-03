// File: audio_live_stream_screen.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:keyboard_avoider/keyboard_avoider.dart';
import 'package:shortzz/common/extensions/string_extension.dart';
import 'package:shortzz/model/livestream/livestream.dart';
import 'package:shortzz/screen/live_stream/livestream_screen/widget/live_stream_background_blur_image.dart';
import 'package:shortzz/utilities/theme_res.dart';

import '../../common/widget/custom_image.dart';
import '../../common/widget/full_name_with_blue_tick.dart';
import 'audio_live_stream_bottom_view.dart';
import 'audio_live_stream_controller.dart';
import 'audio_live_stream_top_view.dart';
import 'audio_live_stream_view.dart';

class AudioLiveStreamScreen extends StatelessWidget {
  final Livestream liveData;
  final bool isHost;

  const AudioLiveStreamScreen({
    super.key,
    required this.isHost,
    required this.liveData,
  });

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(AudioLiveStreamController(liveData.obs, isHost));

    return Scaffold(
      backgroundColor: blackPure(context),
      resizeToAvoidBottomInset: false,
      body: PopScope(
        canPop: false,
        child: Stack(
          children: [
            const LiveStreamBlurBackgroundImage(),
            const Center(child: Text('Audio Live Stream', style: TextStyle(color: Colors.white, fontSize: 18))),
            AudioLiveStreamView(
              controller: controller,
            ),
            Positioned(
              top: 115,
              left: 10,
              width: 200,
              height: 250,
              child: Obx(() => ListView.builder(
                    itemCount: controller.audienceList.length,
                    itemBuilder: (context, index) {
                      final user = controller.audienceList[index];
                      if (user.userId.toString() == liveData.roomID) {
                        return const SizedBox.shrink();
                      }
                      return ListTile(
                        contentPadding: EdgeInsets.zero,
                        horizontalTitleGap: 2,
                        leading: CustomImage(
                          size: Size(Get.width * 0.1, Get.width * 0.1),
                          image: user.user?.profile?.addBaseURL(),
                          fullName: user.user?.fullname,
                          strokeWidth: 3,
                        ),
                        title: FullNameWithBlueTick(
                          username: user.user?.username ?? 'No Name',
                          fontColor: whitePure(context),
                          fontSize: 13,
                          isVerify: user.user?.isVerify,
                          // onTap: () => _showUserActionSheet(hostUser, hostState),
                        ),
                      );
                    },
                  )),
            ),
            KeyboardAvoider(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  AudioLiveStreamTopView(
                    isAudience: !isHost,
                    controller: controller,
                  ),
                  AudioLiveStreamBottomView(
                    controller: controller,
                    liveData: liveData,
                  ),
                ],
              ),
            ),
            // Animation overlay for gift animations
            Obx(() {
              if (controller.isPlayingAnimation.value && controller.mediaPlayerWidget != null) {
                return Positioned.fill(
                  child: InkWell(
                    onTap: () {
                      controller.stopAnim();
                      controller.isPlayingAnimation.value = false;
                    },
                    child: Container(
                      color: Colors.transparent,
                      child: FittedBox(
                        fit: BoxFit.contain,
                        child: SizedBox(
                          width: Get.width,
                          height: Get.height,
                          child: controller.mediaPlayerWidget,
                        ),
                      ),
                    ),
                  ),
                );
              } else {
                return const SizedBox.shrink();
              }
            }),
          ],
        ),
      ),
    );
  }
}
