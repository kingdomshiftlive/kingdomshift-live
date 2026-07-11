import 'package:flutter/material.dart';
import 'package:shortzz/screen/live_stream/livestream_screen/widget/brain_battle_live_overlay.dart';
import 'package:get/get.dart';
import 'package:keyboard_avoider/keyboard_avoider.dart';
import 'package:shortzz/model/livestream/livestream.dart';
import 'package:shortzz/screen/live_stream/livestream_screen/host/widget/live_stream_host_top_view.dart';
import 'package:shortzz/screen/live_stream/livestream_screen/livestream_screen_controller.dart';
import 'package:shortzz/screen/live_stream/livestream_screen/view/battle_view.dart';
import 'package:shortzz/screen/live_stream/livestream_screen/view/live_stream_bottom_view.dart';
import 'package:shortzz/screen/live_stream/livestream_screen/view/live_video_player.dart';
import 'package:shortzz/screen/live_stream/livestream_screen/view/livestream_view.dart';
import 'package:shortzz/screen/live_stream/livestream_screen/widget/battle_start_countdown_overlay.dart';
import 'package:shortzz/screen/live_stream/livestream_screen/widget/live_stream_background_blur_image.dart';
import 'package:shortzz/utilities/theme_res.dart';

class LivestreamHostScreen extends StatelessWidget {
  final Livestream livestream;
  final Widget? hostPreview;
  final bool isHost;

  const LivestreamHostScreen({super.key, this.hostPreview, required this.livestream, required this.isHost});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(LivestreamScreenController(livestream.obs, isHost, hostPreview: hostPreview));

    return Scaffold(
      backgroundColor: blackPure(context),
      resizeToAvoidBottomInset: false,
      body: PopScope(
        canPop: false,
        child: Stack(
          children: [
            // Background blur image view
            const LiveStreamBlurBackgroundImage(),

            /// HOST screen
            Obx(
              () {
                switch (controller.liveData.value.type) {
                  case null:
                    return const Center(child: Text('No One Can live'));
                  case LivestreamType.livestream:
                  case LivestreamType.audioLivestream:
                    return LivestreamView(streamViews: controller.streamViews, controller: controller);
                  case LivestreamType.battle:
                    return BattleView(
                        isAudience: false, controller: controller, margin: const EdgeInsets.only(top: 60));
                  case LivestreamType.dummy:
                    return LivestreamVideoPlayer(controller: controller.videoPlayerController);
                }
              },
            ),

            // Add screen sharing indicator
            Obx(
              () => controller.isScreenSharing.value
                  ? Positioned(
                      top: 90,
                      left: 16,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.red,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.screen_share, color: Colors.white, size: 16),
                            SizedBox(width: 4),
                            Text(
                              'Screen Sharing',
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

            Obx(() => controller.isScreenSharing.value
                ? const Positioned(
                    bottom: 100,
                    left: 0,
                    right: 0,
                    child: Text(
                      'You are sharing your screen. Switch to other apps to share content.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.white, fontSize: 14),
                    ),
                  )
                : const SizedBox()),
            KeyboardAvoider(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  LiveStreamHostTopView(controller: controller),
                  LiveStreamBottomView(controller: controller),
                ],
              ),
            ),

            Obx(
              () {
                Livestream stream = controller.liveData.value;
                bool isBattleWaiting = stream.battleType == BattleType.waiting;
                if (isBattleWaiting) {
                  return BattleStartCountdownOverlay(isHost: isHost, stream: stream);
                }
                return const SizedBox();
              },
            ),
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
            BrainBattleLiveOverlay(controller: controller),
          ],
        ),
      ),
    );
  }
}
