import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:keyboard_avoider/keyboard_avoider.dart';
import 'package:shortzz/model/livestream/livestream.dart';
import 'package:shortzz/screen/live_stream/livestream_screen/audience/widget/livestream_audience_top_view.dart';
import 'package:shortzz/screen/live_stream/livestream_screen/livestream_screen_controller.dart';
import 'package:shortzz/screen/live_stream/livestream_screen/view/battle_view.dart';
import 'package:shortzz/screen/live_stream/livestream_screen/view/live_stream_bottom_view.dart';
import 'package:shortzz/screen/live_stream/livestream_screen/view/live_video_player.dart';
import 'package:shortzz/screen/live_stream/livestream_screen/view/livestream_view.dart';
import 'package:shortzz/screen/live_stream/livestream_screen/widget/battle_start_countdown_overlay.dart';
import 'package:shortzz/screen/live_stream/livestream_screen/widget/live_stream_background_blur_image.dart';
import 'package:shortzz/utilities/theme_res.dart';

class LiveStreamAudienceScreen extends StatelessWidget {
  final Livestream livestream;
  final bool isHost;

  const LiveStreamAudienceScreen(
      {super.key, required this.livestream, required this.isHost});

  @override
  Widget build(BuildContext context) {
    final controller =
        Get.put(LivestreamScreenController(livestream.obs, isHost));

    return Scaffold(
      backgroundColor: blackPure(context),
      resizeToAvoidBottomInset: false,
      body: PopScope(
        canPop: false,
        child: Stack(
          children: [
            const LiveStreamBlurBackgroundImage(),

            /// Live StreamView
            Obx(() {
              switch (controller.liveData.value.type) {
                case null:
                case LivestreamType.livestream:
                case LivestreamType.audioLivestream:
                  return LivestreamView(
                    streamViews: controller.streamViews,
                    controller: controller,
                  );
                case LivestreamType.battle:
                  return BattleView(
                    isAudience: true,
                    controller: controller,
                    margin: const EdgeInsets.only(top: 100),
                  );
                case LivestreamType.dummy:
                  return LivestreamVideoPlayer(
                      controller: controller.videoPlayerController);
              }
            }),

            KeyboardAvoider(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  LiveStreamAudienceTopView(
                      isAudience: true, controller: controller),
                  LiveStreamBottomView(
                      isAudience: true, controller: controller),
                ],
              ),
            ),

            Obx(
              () {
                Livestream stream = controller.liveData.value;
                bool isBattle = stream.battleType == BattleType.waiting;
                if (isBattle) {
                  return BattleStartCountdownOverlay(
                      isHost: isHost, stream: stream);
                }
                return const SizedBox();
              },
            ),

            Obx(() {
              if (controller.isPlayingAnimation.value &&
                  controller.mediaPlayerWidget != null) {
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
                          width: Get.width, // Use screen width
                          height: Get.height, // Use screen height
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

            // screen share show
            Obx(
              () => controller.isScreenSharing.value
                  ? Positioned(
                      top: 90,
                      left: 10,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.green,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.screen_share,
                                color: Colors.white, size: 16),
                            SizedBox(width: 4),
                            Text(
                              'Host is sharing screen',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  : const SizedBox(),
            ),
          ],
        ),
      ),
    );
  }
}
