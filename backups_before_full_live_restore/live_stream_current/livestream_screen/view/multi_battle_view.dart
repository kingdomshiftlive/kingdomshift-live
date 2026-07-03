import 'package:figma_squircle_updated/figma_squircle.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shortzz/common/extensions/common_extension.dart';
import 'package:shortzz/common/extensions/string_extension.dart';
import 'package:shortzz/common/widget/custom_image.dart';
import 'package:shortzz/model/livestream/app_user.dart';
import 'package:shortzz/model/livestream/livestream_user_state.dart';
import 'package:shortzz/screen/live_stream/livestream_screen/livestream_screen_controller.dart';
import 'package:shortzz/utilities/asset_res.dart';
import 'package:shortzz/utilities/text_style_custom.dart';
import 'package:shortzz/utilities/theme_res.dart';

class MultiBattleView extends StatelessWidget {
  final LivestreamScreenController controller;
  final EdgeInsets? margin;

  const MultiBattleView({super.key, required this.controller, this.margin});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: Container(
        height: 160, // Reduced height as we don't need the full VS overlay
        width: Get.width,
        margin: margin,
        padding: const EdgeInsets.only(top: 10, left: 10, right: 10),
        child: Column(
          children: [
            // Timer is handled in BattleView parent, adding spacing here
            const SizedBox(height: 50),
            Expanded(
              child: Obx(() {
                final participants = _getParticipants();
                participants.sort((a, b) =>
                    b.currentBattleCoin.compareTo(a.currentBattleCoin));

                return ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: participants.length,
                  separatorBuilder: (c, i) => const SizedBox(width: 10),
                  itemBuilder: (context, index) {
                    return _buildParticipantItem(
                        context, participants[index], index);
                  },
                );
              }),
            ),
          ],
        ),
      ),
    );
  }

  List<LivestreamUserState> _getParticipants() {
    return controller.liveUsersStates
        .where((e) =>
            e.type == LivestreamUserType.host ||
            e.type == LivestreamUserType.coHost)
        .toList();
  }

  Widget _buildParticipantItem(
      BuildContext context, LivestreamUserState state, int rank) {
    AppUser? user = state.getUser(controller.firestoreController.users);
    bool isLeader = rank == 0;

    return Container(
      width: 80,
      decoration: ShapeDecoration(
        color: blackPure(context).withValues(alpha: 0.3),
        shape: SmoothRectangleBorder(
          borderRadius: SmoothBorderRadius(cornerRadius: 10),
          side: isLeader
              ? const BorderSide(color: Colors.yellow, width: 2)
              : BorderSide.none,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Rank Indicator
          if (rank < 3)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              margin: const EdgeInsets.only(bottom: 4),
              decoration: BoxDecoration(
                color: _getRankColor(rank),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                '#${rank + 1}',
                style: TextStyleCustom.unboundedBold700(
                    fontSize: 10, color: Colors.white),
              ),
            ),

          // Avatar
          CustomImage(
            size: const Size(40, 40),
            image: user?.profile?.addBaseURL(),
            fullName: user?.fullname,
            strokeColor: _getRankColor(rank),
            strokeWidth: 2,
          ),

          const SizedBox(height: 4),

          // Coins
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Image.asset(AssetRes.icCoin, height: 12, width: 12),
              const SizedBox(width: 2),
              Text(
                state.currentBattleCoin.numberFormat,
                style: TextStyleCustom.outFitBold700(
                    fontSize: 12, color: Colors.white),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Color _getRankColor(int rank) {
    switch (rank) {
      case 0:
        return Colors.yellow; // Gold
      case 1:
        return Colors.grey; // Silver
      case 2:
        return Colors.brown; // Bronze
      default:
        return Colors.white.withValues(alpha: 0.5);
    }
  }
}
