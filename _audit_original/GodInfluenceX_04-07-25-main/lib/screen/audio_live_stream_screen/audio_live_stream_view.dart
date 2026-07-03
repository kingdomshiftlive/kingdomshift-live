// File: audio_live_stream_view.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shortzz/common/extensions/duration_extension.dart';
import 'package:shortzz/common/extensions/string_extension.dart';
import 'package:shortzz/common/widget/custom_image.dart';
import 'package:shortzz/common/widget/full_name_with_blue_tick.dart';
import 'package:shortzz/model/livestream/app_user.dart';
import 'package:shortzz/model/livestream/livestream_user_state.dart';
import 'package:shortzz/utilities/asset_res.dart';
import 'package:shortzz/utilities/text_style_custom.dart';
import 'package:shortzz/utilities/theme_res.dart';

import '../../model/livestream/livestream.dart';
import 'audio_live_stream_controller.dart';

class AudioLiveStreamView extends StatelessWidget {
  final AudioLiveStreamController controller;

  const AudioLiveStreamView({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      Livestream stream = controller.liveData.value;
      final hostId = stream.hostId.toString();
      AppUser? hostUser =
          controller.firestoreController.users.firstWhereOrNull((user) => user.userId == int.parse(hostId));
      LivestreamUserState? hostState =
          controller.liveUsersStates.firstWhereOrNull((state) => state.userId == int.parse(hostId));

      if (hostUser == null || hostState == null) {
        return _buildEmptyView();
      }

      return Stack(
        children: [
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // CustomImage(
                //   size: Size(Get.width * 0.5, Get.width * 0.5),
                //   image: hostUser.profile?.addBaseURL(),
                //   fullName: hostUser.fullname,
                //   strokeWidth: 3,
                // ),
                const SizedBox(height: 10),
                // FullNameWithBlueTick(
                //   username: hostUser.username,
                //   fontColor: whitePure(context),
                //   fontSize: 16,
                //   isVerify: hostUser.isVerify,
                //   onTap: () => _showUserActionSheet(hostUser, hostState),
                // ),
                if (hostState.audioStatus == VideoAudioStatus.offByHost)
                  Padding(
                    padding: const EdgeInsets.only(top: 10),
                    child: Image.asset(
                      AssetRes.icMicOff,
                      height: 25,
                      width: 25,
                      color: whitePure(context).withValues(alpha: 0.6),
                    ),
                  )
                // else
                //   Padding(
                //     padding: const EdgeInsets.only(top: 10),
                //     child: Image.asset(
                //       AssetRes.icMicrophone,
                //       height: 25,
                //       width: 25,
                //       color: whitePure(context).withValues(alpha: 0.6),
                //     ),
                //   )
              ],
            ),
          ),
          if (controller.isHost || hostUser.userId != controller.myUserId) _buildMuteButton(context, controller),

          Positioned(
            top: 90,
            right: 65,
            child: Obx(() {
              Duration duration = Duration(seconds: controller.elapsedSeconds.value);
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: whitePure(context),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  duration.printDuration,
                  style: TextStyleCustom.unboundedMedium500(
                    color: themeAccentSolid(context),
                    fontSize: 13,
                  ),
                ),
              );
            }),
          ),
          // comment display section
          Positioned(
            bottom: 80,
            left: 10,
            right: 10,
            child: SizedBox(
              height: 250, // Adjust height as needed
              child: Obx(() => ListView.builder(
                    reverse: true, // Newest comments at the bottom
                    itemCount: controller.comments.length,
                    itemBuilder: (context, index) {
                      final comment = controller.comments[index];
                      final commenter = controller.firestoreController.users.firstWhereOrNull(
                        (user) => user.userId == comment.senderId,
                      );
                      if (comment.comment?.isEmpty ?? true) {
                        return const SizedBox.shrink();
                      }
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            CustomImage(
                              size: const Size(30, 30),
                              image: commenter?.profile?.addBaseURL(),
                              fullName: commenter?.fullname,
                              strokeWidth: 1,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  FullNameWithBlueTick(
                                    username: commenter?.username ?? 'Unknown',
                                    fontColor: whitePure(context),
                                    fontSize: 12,
                                    isVerify: commenter?.isVerify,
                                  ),
                                  Text(
                                    comment.comment ?? '',
                                    style: TextStyleCustom.unboundedRegular400(
                                      color: whitePure(context).withValues(alpha: 0.8),
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  )),
            ),
          ),
        ],
      );
    });
  }

  Widget _buildEmptyView() {
    return Center(
      child: Text(
        'No host in audio stream',
        style: TextStyleCustom.unboundedMedium500(color: Colors.white),
      ),
    );
  }

  Widget _buildMuteButton(BuildContext context, AudioLiveStreamController controller) {
    return Positioned(
      top: 80,
      left: 10,
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Obx(() {
          // Get the current user's state from liveUsersStates
          final userState =
              controller.liveUsersStates.firstWhereOrNull((element) => element.userId == controller.myUserId);
          // Determine if audio is muted (offByMe or offByHost)
          final isMute = (userState?.audioStatus != VideoAudioStatus.on).obs;
          return MuteUnMuteButton(
            isMute: isMute,
            onTap: () => controller.toggleAudioMute(),
          );
        }),
      ),
    );
  }

// void _showUserActionSheet(AppUser user, LivestreamUserState state) {
//   Get.bottomSheet(
//     AudioLiveStreamUserInfoSheet(
//       isAudience: !controller.isHost,
//       liveUser: user,
//       controller: controller,
//     ),
//     isScrollControlled: true,
//   );
// }
}

class MuteUnMuteButton extends StatelessWidget {
  final RxBool isMute;
  final VoidCallback? onTap;

  const MuteUnMuteButton({super.key, required this.isMute, this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Obx(
        () => Image.asset(
          isMute.value ? AssetRes.icSpeakerMute : AssetRes.icSpeaker,
          width: 24,
          height: 24,
          color: Colors.white,
        ),
      ),
    );
  }
}
