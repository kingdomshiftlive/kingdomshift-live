import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shortzz/model/livestream/app_user.dart';
import 'package:shortzz/model/livestream/livestream.dart';
import 'package:shortzz/screen/audio_live_stream_screen/audio_live_stream_controller.dart';
import 'package:shortzz/utilities/asset_res.dart';
import 'package:shortzz/utilities/style_res.dart';
import 'package:shortzz/utilities/theme_res.dart';

class AudioLiveStreamBottomView extends StatelessWidget {
  final Livestream liveData;
  final AudioLiveStreamController controller;

  const AudioLiveStreamBottomView({
    super.key,
    required this.liveData,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.5),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
      ),
      child: Row(
        children: [
          Expanded(
            // child: Obx(() => ,),
            child: TextField(
              controller: controller.textCommentController,
              decoration: InputDecoration(
                hintText: 'Write comment',
                hintStyle: const TextStyle(color: Colors.white70),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: const BorderSide(color: Colors.white),
                ),
                filled: true,
                fillColor: Colors.white.withValues(alpha: 0.1),
              ),
              style: const TextStyle(color: Colors.white),
              onChanged: (value) {
                controller.isTextEmpty.value = value.trim().isEmpty;
              },
            ),
          ),
          const SizedBox(width: 8),
          Obx(() {
            // Show gift icon when text is empty (for audience members)
            // Show send button when text is not empty or for host
            if (controller.isTextEmpty.value && !controller.isHost) {
              // Get users from audience list for gift selection
              List<AppUser> users = controller.liveUsersStates
                  .map((state) => state.user)
                  .whereType<AppUser>()
                  .toList();

              // Add host user if available
              if (controller.liveData.value.hostId != null) {
                final hostUser = controller.firestoreController.users
                    .firstWhereOrNull((user) =>
                        user.userId == controller.liveData.value.hostId);
                if (hostUser != null &&
                    !users.any((u) => u.userId == hostUser.userId)) {
                  users.insert(0, hostUser);
                }
              }

              return InkWell(
                onTap: () => controller.onGiftTap(users: users),
                child: Container(
                  height: 40,
                  width: 40,
                  decoration: BoxDecoration(
                    gradient: StyleRes.themeGradient,
                    shape: BoxShape.circle,
                  ),
                  alignment: Alignment.center,
                  child: Image.asset(
                    AssetRes.icGift,
                    height: 20,
                    width: 20,
                    color: whitePure(context),
                  ),
                ),
              );
            } else {
              return IconButton(
                icon: const Icon(Icons.send, color: Colors.white),
                onPressed: controller.isTextEmpty.value
                    ? null
                    : controller.onTextCommentSend,
              );
            }
          }),
        ],
      ),
    );
  }
}
