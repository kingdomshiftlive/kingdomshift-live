import 'package:figma_squircle_updated/figma_squircle.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shortzz/common/extensions/common_extension.dart';
import 'package:shortzz/common/manager/haptic_manager.dart';
import 'package:shortzz/common/manager/branch_io_manager.dart';
import 'package:shortzz/common/widget/text_button_custom.dart';
import 'package:shortzz/languages/languages_keys.dart';
import 'package:shortzz/model/livestream/livestream.dart';
import 'package:shortzz/model/livestream/livestream_user_state.dart';
import 'package:shortzz/screen/live_stream/livestream_screen/livestream_screen_controller.dart';
import 'package:shortzz/screen/live_stream/livestream_screen/widget/members_sheet.dart';
import 'package:shortzz/utilities/asset_res.dart';
import 'package:shortzz/utilities/text_style_custom.dart';
import 'package:shortzz/utilities/theme_res.dart';

const kLiveTeal = Color(0xFF005574);
const kLiveGold = Color(0xFFD4AF37);
const kLivePink = Color(0xFFFF2D8D);

class LiveStreamHostTopView extends StatelessWidget {
  final LivestreamScreenController controller;
  const LiveStreamHostTopView({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: AlignmentDirectional.topStart,
      child: SafeArea(
        bottom: false,
        minimum: EdgeInsets.only(top: AppBar().preferredSize.height * 0.3),
        child: Obx(() {
          Livestream stream = controller.liveData.value;
          LivestreamUserState? userState = controller.liveUsersStates
              .firstWhereOrNull((e) => e.userId == stream.hostId);
          int watchingCount = (stream.watchingCount ?? 0).clamp(0, 999999);
          bool isVisible = controller.isViewVisible.value;
          int totalCoins = userState?.totalCoin ?? 0;

          return AnimatedOpacity(
            duration: const Duration(milliseconds: 100),
            opacity: isVisible ? 1 : 0,
            child: IgnorePointer(
              ignoring: !isVisible,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // ── Row 1: Profile + Live timer | viewers | Top10 | screenshot | more ──
                    Row(
                      children: [
                        // X close button
                        GestureDetector(
                          onTap: controller.onStopButtonTap,
                          child: Container(
                              width: 32,
                              height: 32,
                              decoration: BoxDecoration(
                                  color: Colors.black45,
                                  shape: BoxShape.circle,
                                  border: Border.all(color: Colors.white24)),
                              child: const Icon(Icons.close,
                                  color: Colors.white, size: 18)),
                        ),
                        const SizedBox(width: 8),
                        // Profile pill
                        Container(
                          padding: const EdgeInsets.fromLTRB(4, 4, 10, 4),
                          decoration: BoxDecoration(
                              color: Colors.black45,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: Colors.white24)),
                          child: Row(mainAxisSize: MainAxisSize.min, children: [
                            Container(
                                width: 24,
                                height: 24,
                                decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: kLiveTeal,
                                    border: Border.all(
                                        color: Colors.white, width: 1)),
                                child: ClipOval(
                                    child:
                                        controller.liveData.value.hostId != null
                                            ? const Icon(Icons.person,
                                                color: Colors.white, size: 16)
                                            : const Icon(Icons.person,
                                                color: Colors.white,
                                                size: 16))),
                            const SizedBox(width: 6),
                            Obx(() => Text('KingdomShift.Live',
                                style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold))),
                            const SizedBox(width: 6),
                            Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                    color: kLivePink,
                                    borderRadius: BorderRadius.circular(4)),
                                child: const Text('LIVE',
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 9,
                                        fontWeight: FontWeight.bold))),
                            const SizedBox(width: 6),
                            Obx(() => _LiveTimer(controller: controller)),
                          ]),
                        ),
                        const SizedBox(width: 6),
                        // Viewer count
                        Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 6),
                            decoration: BoxDecoration(
                                color: Colors.black45,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(color: Colors.white24)),
                            child:
                                Row(mainAxisSize: MainAxisSize.min, children: [
                              const Icon(Icons.remove_red_eye_outlined,
                                  color: Colors.white, size: 14),
                              const SizedBox(width: 4),
                              Text(watchingCount.numberFormat,
                                  style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600)),
                            ])),
                        const SizedBox(width: 6),
                        // Top 10 badge
                        Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 6),
                            decoration: BoxDecoration(
                                color: Colors.black45,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                    color: kLiveGold.withValues(alpha: 0.5))),
                            child:
                                Row(mainAxisSize: MainAxisSize.min, children: [
                              Icon(Icons.workspace_premium_rounded,
                                  color: kLiveGold, size: 14),
                              const SizedBox(width: 4),
                              const Text('Top 10',
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600)),
                            ])),
                        const Spacer(),
                        // Screenshot
                        LiveStreamCircleBorderButton(
                          image: AssetRes.icPostShare,
                          size: const Size(32, 32),
                          iconSize: 16,
                          iconColor: whitePure(context),
                          onTap: () => BranchIoManager.instance.shareContent(
                              type: ShareBranchType.liveStream,
                              livestream: controller.liveData.value),
                        ),
                        const SizedBox(width: 6),
                        // More
                        LiveStreamCircleBorderButton(
                          image: AssetRes.icAudience,
                          size: const Size(32, 32),
                          iconSize: 16,
                          iconColor: whitePure(context),
                          onTap: () => Get.bottomSheet(
                              const MembersSheet(isHost: true),
                              isScrollControlled: true),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    // ── Row 2: Weekly Ranking | Live Goal ──
                    Row(
                      children: [
                        // Weekly Ranking button
                        GestureDetector(
                          onTap: () {},
                          child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                  color: Colors.black45,
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(color: Colors.white24)),
                              child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(Icons.local_fire_department,
                                        color: Colors.orange, size: 14),
                                    const SizedBox(width: 4),
                                    const Text('Weekly Ranking',
                                        style: TextStyle(
                                            color: Colors.white, fontSize: 11)),
                                    const SizedBox(width: 4),
                                    const Icon(Icons.chevron_right,
                                        color: Colors.white54, size: 14),
                                  ])),
                        ),
                        const Spacer(),
                        // Live Goal tracker
                        Container(
                            padding: const EdgeInsets.fromLTRB(8, 6, 12, 6),
                            decoration: BoxDecoration(
                                color: Colors.black45,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                    color: kLivePink.withValues(alpha: 0.4))),
                            child:
                                Row(mainAxisSize: MainAxisSize.min, children: [
                              Container(
                                  width: 28,
                                  height: 28,
                                  decoration: BoxDecoration(
                                      color: kLivePink.withValues(alpha: 0.2),
                                      borderRadius: BorderRadius.circular(8)),
                                  child: Icon(Icons.card_giftcard_rounded,
                                      color: kLivePink, size: 16)),
                              const SizedBox(width: 8),
                              Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text('Live Goal',
                                        style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 10,
                                            fontWeight: FontWeight.bold)),
                                    const SizedBox(height: 2),
                                    Row(children: [
                                      Container(
                                        width: 60,
                                        height: 4,
                                        decoration: BoxDecoration(
                                            color: Colors.white24,
                                            borderRadius:
                                                BorderRadius.circular(2)),
                                        child: FractionallySizedBox(
                                          widthFactor:
                                              (totalCoins / 50).clamp(0.0, 1.0),
                                          alignment: Alignment.centerLeft,
                                          child: Container(
                                              decoration: BoxDecoration(
                                                  color: kLivePink,
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          2))),
                                        ),
                                      ),
                                      const SizedBox(width: 6),
                                      Text('$totalCoins/50',
                                          style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 10)),
                                    ]),
                                  ]),
                              const SizedBox(width: 6),
                              const Icon(Icons.chevron_right,
                                  color: Colors.white54, size: 14),
                            ])),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}

class _LiveTimer extends StatelessWidget {
  final LivestreamScreenController controller;
  const _LiveTimer({required this.controller});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: Stream.periodic(const Duration(seconds: 1)),
      builder: (context, _) {
        final start = controller.liveData.value.createdAt;
        if (start == null)
          return const Text('00:00',
              style: TextStyle(color: Colors.white70, fontSize: 11));
        final diff = DateTime.now()
            .difference(DateTime.fromMillisecondsSinceEpoch(start));
        final mm = diff.inMinutes.toString().padLeft(2, '0');
        final ss = (diff.inSeconds % 60).toString().padLeft(2, '0');
        return Text('$mm:$ss',
            style: const TextStyle(color: Colors.white70, fontSize: 11));
      },
    );
  }
}

class StopLiveStreamSheet extends StatelessWidget {
  final VoidCallback onTap;
  final String? title;
  final String? description;
  final String? positiveText;

  const StopLiveStreamSheet(
      {super.key,
      required this.onTap,
      this.title,
      this.description,
      this.positiveText});

  @override
  Widget build(BuildContext context) {
    return Wrap(children: [
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 30),
        width: double.infinity,
        decoration: ShapeDecoration(
            color: whitePure(context),
            shape: const SmoothRectangleBorder(
                borderRadius: SmoothBorderRadius.vertical(
                    top: SmoothRadius(cornerRadius: 40, cornerSmoothing: 1)))),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const SizedBox(height: 5),
          Align(
              alignment: Alignment.center,
              child: Container(
                  height: .5, color: textLightGrey(context), width: 100)),
          const SizedBox(height: 30),
          Text(title ?? LKey.endStreamTitle.tr,
              style: TextStyleCustom.unboundedRegular400(
                  fontSize: 15, color: textDarkGrey(context))),
          Text(description ?? LKey.endStreamMessage.tr,
              style: TextStyleCustom.outFitLight300(
                  fontSize: 17, color: textLightGrey(context))),
          const SizedBox(height: 40),
          Row(children: [
            Expanded(
                child: TextButtonCustom(
                    onTap: Get.back,
                    title: LKey.cancel.tr,
                    backgroundColor: bgMediumGrey(context))),
            Expanded(
                child: TextButtonCustom(
                    onTap: () {
                      Get.back();
                      onTap();
                    },
                    title: positiveText ?? LKey.yes.tr,
                    backgroundColor: themeAccentSolid(context),
                    titleColor: whitePure(context),
                    horizontalMargin: 5)),
          ]),
          SizedBox(height: AppBar().preferredSize.height),
        ]),
      ),
    ]);
  }
}

class LiveStreamBorderButton extends StatelessWidget {
  final Color? backgroundColor;
  final String title;
  final String imageIcon;
  final Color? imageColor;
  final VoidCallback? onTap;
  final List<BoxShadow>? shadow;

  const LiveStreamBorderButton(
      {super.key,
      this.backgroundColor,
      required this.title,
      this.imageIcon = '',
      this.imageColor,
      this.onTap,
      this.shadow});

  @override
  Widget build(BuildContext context) {
    double width = Get.width / 5.5;
    return InkWell(
      onTap: onTap,
      child: Container(
        height: 30,
        width: width,
        alignment: Alignment.center,
        decoration: ShapeDecoration(
            shape: SmoothRectangleBorder(
                borderRadius: SmoothBorderRadius(cornerRadius: 30),
                side: BorderSide(
                    color: whitePure(context).withValues(alpha: .3))),
            shadows: shadow,
            color: backgroundColor ?? blackPure(context).withValues(alpha: .1)),
        child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            spacing: 3,
            children: [
              if (imageIcon.isNotEmpty)
                Image.asset(imageIcon,
                    height: 16, width: 16, color: imageColor),
              Text(title,
                  style: TextStyleCustom.outFitRegular400(
                      color: whitePure(context))),
            ]),
      ),
    );
  }
}

class LiveStreamCircleBorderButton extends StatelessWidget {
  final String image;
  final EdgeInsets? margin;
  final VoidCallback? onTap;
  final Size? size;
  final Color? iconColor;
  final Color? borderColor;
  final Color? bgColor;
  final double? iconSize;

  const LiveStreamCircleBorderButton(
      {super.key,
      required this.image,
      this.margin,
      this.onTap,
      this.size,
      this.iconColor,
      this.borderColor,
      this.iconSize,
      this.bgColor});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        HapticManager.shared.light();
        onTap?.call();
      },
      child: Container(
        height: size?.height ?? 32,
        width: size?.width ?? 32,
        margin: margin,
        alignment: Alignment.center,
        decoration: ShapeDecoration(
            shape: SmoothRectangleBorder(
                borderRadius: SmoothBorderRadius(cornerRadius: 30),
                side: BorderSide(
                    color: borderColor ??
                        whitePure(context).withValues(alpha: .3))),
            color: (bgColor ?? blackPure(context)).withValues(alpha: .1)),
        child: Image.asset(image,
            height: iconSize ?? 20,
            width: iconSize ?? 20,
            color: iconColor ?? whitePure(context).withValues(alpha: .3)),
      ),
    );
  }
}

final livestreamShadow = [
  BoxShadow(
      color: Colors.black.withValues(alpha: .15),
      offset: const Offset(0, 2),
      blurRadius: 5),
];
