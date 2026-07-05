import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shortzz/common/extensions/string_extension.dart';
import 'package:shortzz/common/manager/logger.dart';
import 'package:shortzz/common/service/api/post_service.dart';
import 'package:shortzz/common/service/utils/params.dart';
import 'package:shortzz/model/post_story/post_model.dart';
import 'package:shortzz/model/user_model/user_model.dart';
import 'package:shortzz/screen/share_sheet_widget/share_sheet_widget.dart';
import 'package:shortzz/utilities/app_res.dart';
import 'package:shortzz/model/livestream/livestream.dart';

enum ShareBranchType { post, user, qr, liveStream }

class BranchIoManager {
  BranchIoManager._();

  static final BranchIoManager instance = BranchIoManager._();

  static const String _baseUrl = 'https://kingdomshift.live';

  Future<CustomBranchResponse?> init(
      {required ShareBranchType type,
      User? user,
      Post? post,
      Livestream? livestream,
      VoidCallback? onShareSuccess}) async {
    final BranchShareData shareData = _generateShareData(type,
        user: user, post: post, livestream: livestream);
    final String link = shareData.deepLinkUrl;

    return CustomBranchResponse(link, shareData);
  }

  Future<CustomBranchResponse?> generateLink(
      {required ShareBranchType type,
      User? user,
      Post? post,
      Livestream? livestream}) async {
    return await init(
        type: type, user: user, post: post, livestream: livestream);
  }

  Future<void> shareContent(
      {required ShareBranchType type,
      User? user,
      Post? post,
      Livestream? livestream,
      VoidCallback? onShareSuccess}) async {
    CustomBranchResponse? branchResponse = await init(
        type: type,
        user: user,
        post: post,
        livestream: livestream,
        onShareSuccess: onShareSuccess);
    if (branchResponse == null) {
      Loggers.error('Failed to generate link.');
      return;
    }

    if (type == ShareBranchType.qr) {
      _showNativeShareSheet(
          branchResponse.shareData.title, branchResponse.link);
    } else if (type == ShareBranchType.liveStream) {
      _showNativeShareSheet(
          branchResponse.shareData.title, branchResponse.link);
    } else {
      _showCustomShareSheet(
        link: branchResponse.link,
        type: type,
        user: user,
        post: post,
        title: branchResponse.shareData.title,
        onShareSuccess: onShareSuccess,
      );
    }
  }

  BranchShareData _generateShareData(ShareBranchType type,
      {User? user, Post? post, Livestream? livestream}) {
    switch (type) {
      case ShareBranchType.post:
        final postId = post?.id ?? -1;
        final deepLinkUrl = '$_baseUrl?${Params.postId}=$postId';
        return BranchShareData(
          title:
              '${post?.user?.username ?? ''} on ${AppRes.appName}${(post?.description ?? '').isNotEmpty ? ': ${post?.description}' : ''}',
          imageUrl: post?.getThumbnail.addBaseURL() ?? '',
          metadataKey: Params.postId,
          metadataValue: '$postId',
          deepLinkUrl: deepLinkUrl,
        );
      case ShareBranchType.user:
      case ShareBranchType.qr:
        final userId = user?.id ?? -1;
        final deepLinkUrl = '$_baseUrl?${Params.userId}=$userId';
        return BranchShareData(
          title: getUserTitle(
              fullname: user?.fullname ?? '', username: user?.username ?? ''),
          imageUrl: user?.profilePhoto?.addBaseURL() ?? '',
          metadataKey: Params.userId,
          metadataValue: '$userId',
          deepLinkUrl: deepLinkUrl,
        );
      case ShareBranchType.liveStream:
        final liveStreamId = livestream?.roomID ?? '';
        final deepLinkUrl = '$_baseUrl?${Params.liveStreamId}=$liveStreamId';
        return BranchShareData(
          title:
              '${livestream?.hostUser?.fullname ?? ''} is Live on ${AppRes.appName}',
          imageUrl: livestream?.hostUser?.profile?.addBaseURL() ?? '',
          metadataKey: Params.liveStreamId,
          metadataValue: liveStreamId,
          deepLinkUrl: deepLinkUrl,
        );
    }
  }

  String getUserTitle({required String fullname, required String username}) {
    return '$fullname (@$username) • ${AppRes.appName} profile';
  }

  void _showNativeShareSheet(String title, String link) async {
    try {
      await Share.share(
        link,
        subject: title,
      );
    } catch (e) {
      Loggers.error('Share error: $e');
    }
  }

  void _showCustomShareSheet({
    required String link,
    required ShareBranchType type,
    required User? user,
    required Post? post,
    required String title,
    VoidCallback? onShareSuccess,
  }) {
    Get.bottomSheet(
      ShareSheetWidget(
        onMoreTap: () {
          Get.back();
          _showNativeShareSheet(title, link);
          if (type == ShareBranchType.post && post != null) {
            if ((post.supabaseId ?? '').isNotEmpty) {
              PostService.instance
                  .increaseSupabaseShareCount(supabaseId: post.supabaseId!)
                  .then((ok) {
                if (ok) onShareSuccess?.call();
              });
            } else {
              _increaseShareCount(post.id, onShareSuccess);
            }
          }
        },
        post: post,
        link: link,
        title: type == ShareBranchType.post ? '' : title,
        isDownloadShow:
            type == ShareBranchType.post && post?.postType == PostType.reel,
        type: type,
        onCallBack: onShareSuccess,
      ),
      isScrollControlled: true,
    );
  }

  Future<void> _increaseShareCount(int? postId, VoidCallback? onSuccess) async {
    if (postId == null) return;
    final response =
        await PostService.instance.increaseShareCount(postId: postId);
    if (response.status == true) {
      onSuccess?.call();
    }
  }
}

class BranchShareData {
  final String title;
  final String imageUrl;
  final String metadataKey;
  final String metadataValue;
  final String deepLinkUrl;

  BranchShareData({
    required this.title,
    required this.imageUrl,
    required this.metadataKey,
    required this.metadataValue,
    required this.deepLinkUrl,
  });
}

class CustomBranchResponse {
  final String link;
  final BranchShareData shareData;

  CustomBranchResponse(this.link, this.shareData);
}
