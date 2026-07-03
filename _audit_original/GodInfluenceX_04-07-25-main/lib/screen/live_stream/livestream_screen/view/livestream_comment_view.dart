import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shortzz/common/extensions/string_extension.dart';
import 'package:shortzz/common/widget/custom_image.dart';
import 'package:shortzz/common/widget/full_name_with_blue_tick.dart';
import 'package:shortzz/languages/languages_keys.dart';
import 'package:shortzz/model/livestream/livestream_comment.dart';
import 'package:shortzz/screen/live_stream/livestream_screen/livestream_screen_controller.dart';
import 'package:shortzz/utilities/text_style_custom.dart';
import 'package:shortzz/utilities/theme_res.dart';

class LiveStreamCommentView extends StatelessWidget {
  final LivestreamScreenController controller;

  const LiveStreamCommentView({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return ShaderMask(
      shaderCallback: (Rect bounds) {
        return LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [
          blackPure(context),
          blackPure(context).withValues(alpha: .6),
          blackPure(context).withValues(alpha: .1),
        ], stops: const [
          .0,
          .3,
          .5
        ]).createShader(bounds);
      },
      blendMode: BlendMode.dstOut,
      child: Obx(() {
        return ListView.builder(
          padding: const EdgeInsets.only(top: 70),
          itemCount: controller.comments.length,
          reverse: true,
          shrinkWrap: true,
          primary: false,
          physics: const BouncingScrollPhysics(),
          itemBuilder: (context, index) {
            LivestreamComment comment = controller.comments[index];
            // Hide gift comments from the comments section
            if (comment.commentType == LivestreamCommentType.gift) {
              return const SizedBox.shrink();
            }
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 3.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CustomImage(
                    size: const Size(38, 38),
                    image: comment.senderUser?.profile?.addBaseURL(),
                    fullName: comment.senderUser?.fullname,
                    strokeWidth: 2,
                    strokeColor: whitePure(context).withValues(alpha: .5),
                    isStokeOutSide: true,
                  ),
                  const SizedBox(width: 5),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      spacing: 3,
                      children: [
                        FullNameWithBlueTick(
                          username: comment.senderUser?.username,
                          isVerify: comment.senderUser?.isVerify,
                          fontColor: whitePure(context),
                          opacity: 0.7,
                          fontSize: 12,
                          iconSize: 18,
                        ),
                        _buildCommentContent(context, comment)
                      ],
                    ),
                  )
                ],
              ),
            );
          },
        );
      }),
    );
  }

  Widget _buildCommentContent(BuildContext context, LivestreamComment comment) {
    switch (comment.commentType) {
      case null:
        return const SizedBox();
      case LivestreamCommentType.request:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              LKey.requestingToJoinTheStream.tr,
              style: TextStyleCustom.outFitRegular400(color: whitePure(context).withValues(alpha: .80)),
            ),
            const SizedBox(height: 5),
            Row(
              children: [
                InkWell(
                  onTap: () {
                    controller.handleRequestResponse(user: comment.senderUser, isRefused: true, comment: comment);
                  },
                  child: Container(
                    height: 26,
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    decoration: BoxDecoration(
                        color: whitePure(context).withValues(alpha: .2), borderRadius: BorderRadius.circular(30)),
                    alignment: Alignment.center,
                    child: Text(LKey.refuse.tr,
                        style: TextStyleCustom.outFitRegular400(fontSize: 13, color: bgGrey(context))),
                  ),
                ),
                const SizedBox(width: 5),
                InkWell(
                  onTap: () {
                    controller.handleRequestResponse(user: comment.senderUser, isRefused: false, comment: comment);
                  },
                  child: Container(
                    height: 26,
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(30),
                      color: whitePure(context),
                    ),
                    alignment: Alignment.center,
                    child: Text(LKey.accept.tr,
                        style: TextStyleCustom.outFitRegular400(fontSize: 13, color: textDarkGrey(context))),
                  ),
                ),
              ],
            ),
          ],
        );
      case LivestreamCommentType.text:
        return Text(comment.comment?.tr ?? '',
            style: TextStyleCustom.outFitRegular400(color: whitePure(context).withValues(alpha: .80)));
      case LivestreamCommentType.gift:
        // Gifts are not displayed in the comments section
        return const SizedBox();
      case LivestreamCommentType.joined:
        return Text(LKey.joinedTheStream.tr,
            style: TextStyleCustom.outFitRegular400(color: whitePure(context).withValues(alpha: .80)));
      case LivestreamCommentType.joinedCoHost:
        return Text(LKey.joinedAsACoHost.tr,
            style: TextStyleCustom.outFitRegular400(color: whitePure(context).withValues(alpha: .80)));
    }
  }
}
