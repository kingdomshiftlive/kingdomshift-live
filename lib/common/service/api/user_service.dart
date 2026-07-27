import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:supabase_flutter/supabase_flutter.dart' as supabase;
import 'package:shortzz/common/manager/logger.dart';
import 'package:shortzz/common/manager/session_manager.dart';
import 'package:shortzz/common/service/api/api_service.dart';
import 'package:shortzz/common/service/utils/params.dart';
import 'package:shortzz/common/service/utils/web_service.dart';
import 'package:shortzz/model/general/status_model.dart';
import 'package:shortzz/model/user_model/block_user_model.dart';
import 'package:shortzz/model/user_model/follower_model.dart';
import 'package:shortzz/model/user_model/following_model.dart';
import 'package:shortzz/model/user_model/links_model.dart';
import 'package:shortzz/model/user_model/user_model.dart';
import 'package:shortzz/model/user_model/users_model.dart';
import 'package:shortzz/screen/edit_profile_screen/widget/add_edit_link_sheet.dart';
import 'package:shortzz/utilities/app_res.dart';
import 'package:image_picker/image_picker.dart';

enum LoginMethod {
  email,
  google,
  apple;

  String title() {
    switch (this) {
      case LoginMethod.email:
        return 'email';
      case LoginMethod.google:
        return 'google';
      case LoginMethod.apple:
        return 'apple';
    }
  }
}

class UserService {
  UserService._();

  static final UserService instance = UserService._();

  Future<User?> logInUser({
    String? fullName,
    required String identity,
    String? deviceToken,
    required LoginMethod loginMethod,
  }) async {
    final firebaseUser = firebase_auth.FirebaseAuth.instance.currentUser;
    if (firebaseUser == null) {
      Loggers.error("logInUser: no Firebase user");
      return null;
    }

    try {
      await supabase.Supabase.instance.client.auth.signInAnonymously();
      Loggers.success("Supabase anonymous auth done");
    } catch (e) {
      Loggers.error("Supabase auth error: $e");
    }

    Map<String, dynamic>? profile;
    try {
      await supabase.Supabase.instance.client.from('app_profiles').upsert({
        'id': firebaseUser.uid,
        'email': identity,
        'username': identity.split('@')[0],
        'full_name': fullName ?? identity.split('@')[0],
        'role': 'creator',
        'login_method': loginMethod.title(),
        'device_token': deviceToken,
      }).timeout(const Duration(seconds: 10));

      profile = await supabase.Supabase.instance.client
          .from('app_profiles')
          .select()
          .eq('id', firebaseUser.uid)
          .maybeSingle()
          .timeout(const Duration(seconds: 10));

      Loggers.success("Supabase profile upserted: $profile");
    } catch (e) {
      Loggers.error("Supabase logInUser error (continuing anyway): $e");
    }

    final appUser = User(
      id: 100,
      identity: identity,
      fullname: profile?['full_name'] ?? fullName ?? identity.split('@')[0],
      username: profile?['username'] ?? identity.split('@')[0],
      userEmail: identity,
      loginMethod: loginMethod.title(),
      device: Platform.isAndroid ? 0 : 1,
      deviceToken: deviceToken,
      isVerify: 0,
      coinWallet: 0,
      followerCount: 0,
      followingCount: 0,
      totalPostLikesCount: 0,
      isFreez: 0,
      isModerator: 0,
      newRegister: false,
    );

    SessionManager.instance.setUser(appUser);
    return appUser;
  }

  Future<StatusModel> deleteMyAccount() async {
    StatusModel response = await ApiService.instance.call(
        url: WebService.user.deleteMyAccount, fromJson: StatusModel.fromJson);
    return response;
  }

  Future<StatusModel> logoutUser() async {
    try {
      await firebase_auth.FirebaseAuth.instance.signOut();
      return StatusModel(status: true, message: 'Logged out');
    } catch (e) {
      return StatusModel(status: false, message: '$e');
    }
  }

  /// Fetches ANY user's public profile by their Firebase UID, without
  /// touching the local session (unlike fetchUserDetails, which is only
  /// safe for refreshing the CURRENTLY LOGGED IN user's own data).
  Future<User?> fetchUserProfileByUid(String targetUid) async {
    try {
      final profile = await supabase.Supabase.instance.client
          .from('app_profiles')
          .select()
          .eq('id', targetUid)
          .maybeSingle();

      if (profile == null) return null;

      return User(
        id: targetUid.hashCode,
        identity: profile['email'] ?? '',
        fullname: profile['full_name'] ?? '',
        username: profile['username'] ?? '',
        firebaseUid: targetUid,
        profilePhoto: profile['avatar_url'] ?? '',
        isVerify: profile['is_verify'] ?? 0,
        followerCount: profile['follower_count'] ?? 0,
        followingCount: profile['following_count'] ?? 0,
        totalPostLikesCount: 0,
        isFreez: profile['is_freez'] ?? 0,
        isModerator: profile['is_moderator'] ?? 0,
        bio: profile['bio'] ?? '',
        newRegister: false,
      );
    } catch (e) {
      return null;
    }
  }
  Future<User?> fetchUserDetails({int? userId, Function()? onError}) async {
    try {
      final firebaseUser = firebase_auth.FirebaseAuth.instance.currentUser;
      if (firebaseUser == null) return null;

      final profile = await supabase.Supabase.instance.client
          .from('app_profiles')
          .select()
          .eq('id', firebaseUser.uid)
          .maybeSingle();

      if (profile == null) return null;
      final appUser = User(
        id: firebaseUser.uid.hashCode,
        firebaseUid: firebaseUser.uid,
        identity: profile['email'] ?? '',
        fullname: profile['full_name'] ?? '',
        username: profile['username'] ?? '',
        userEmail: profile['email'] ?? '',
        loginMethod: profile['login_method'] ?? 'email',
        profilePhoto: profile['avatar_url'] ?? '',
        device: Platform.isAndroid ? 0 : 1,
        isVerify: profile['is_verify'] ?? 0,
        coinWallet: profile['coin_wallet'] ?? 0,
        followerCount: profile['follower_count'] ?? 0,
        followingCount: profile['following_count'] ?? 0,
        totalPostLikesCount: 0,
        isFreez: profile['is_freez'] ?? 0,
        isModerator: profile['is_moderator'] ?? 0,
        bio: profile['bio'] ?? '',
        whoCanViewPost: profile['who_can_view_post'] ?? 0,
        showMyFollowing: (profile['show_my_following'] == true) ? 1 : 0,
        receiveMessage: (profile['receive_message'] == true) ? 1 : 0,
        notifyPostLike: (profile['notify_post_like'] == true) ? 1 : 0,
        notifyPostComment: (profile['notify_post_comment'] == true) ? 1 : 0,
        notifyFollow: (profile['notify_follow'] == true) ? 1 : 0,
        notifyMention: (profile['notify_mention'] == true) ? 1 : 0,
        notifyGiftReceived: (profile['notify_gift_received'] == true) ? 1 : 0,
        notifyChat: (profile['notify_chat'] == true) ? 1 : 0,
        newRegister: false,
      );

      SessionManager.instance.setUser(appUser);
      return appUser;
    } catch (e) {
      Loggers.error('fetchUserDetails error: $e');
      return null;
    }
  }

  Future<User?> updateUserDetails(
      {XFile? profilePhoto,
      String? fullname,
      String? userName,
      String? bio,
      String? email,
      String? phoneNumber,
      int? mobileCountryCode,
      String? countryCode,
      String? country,
      String? appLanguage,
      bool? showMyFollowing,
      bool? receiveMessage,
      bool? notifyPostLike,
      bool? notifyPostComment,
      bool? notifyFollow,
      bool? notifyMention,
      bool? notifyGiftReceived,
      bool? notifyChat,
      List<int>? savedMusicIds,
      double? lat,
      double? lon,
      String? whoCanSeePost,
      String? appLastUsed,
      String? region,
      String? regionName,
      String? timezone,
      int? isVerify}) async {
    try {
      final firebaseUser = firebase_auth.FirebaseAuth.instance.currentUser;
      if (firebaseUser == null) return null;

      String? photoUrl;
      if (profilePhoto != null) {
        final avatarFileName = '${firebaseUser.uid}/avatar.jpg';
        await supabase.Supabase.instance.client.storage
            .from('thumbnails')
            .upload(
              avatarFileName,
              File(profilePhoto.path),
              fileOptions: const supabase.FileOptions(upsert: true),
            );
        photoUrl = supabase.Supabase.instance.client.storage
            .from('thumbnails')
            .getPublicUrl(avatarFileName);
      }

      final updates = <String, dynamic>{};
      if (fullname != null) updates['full_name'] = fullname;
      if (userName != null) updates['username'] = userName;
      if (bio != null) updates['bio'] = bio;
      if (email != null) updates['email'] = email;
      if (photoUrl != null) updates['avatar_url'] = photoUrl;
      if (appLanguage != null) updates['app_language'] = appLanguage;
      if (showMyFollowing != null)
        updates['show_my_following'] = showMyFollowing;
      if (receiveMessage != null) updates['receive_message'] = receiveMessage;
      if (notifyPostLike != null) updates['notify_post_like'] = notifyPostLike;
      if (notifyPostComment != null)
        updates['notify_post_comment'] = notifyPostComment;
      if (notifyFollow != null) updates['notify_follow'] = notifyFollow;
      if (notifyMention != null) updates['notify_mention'] = notifyMention;
      if (notifyGiftReceived != null)
        updates['notify_gift_received'] = notifyGiftReceived;
      if (notifyChat != null) updates['notify_chat'] = notifyChat;
      if (whoCanSeePost != null)
        updates['who_can_view_post'] = int.tryParse(whoCanSeePost) ?? 0;

      if (updates.isNotEmpty) {
        await supabase.Supabase.instance.client
            .from('app_profiles')
            .update(updates)
            .eq('id', firebaseUser.uid);
      }

      return await fetchUserDetails();
    } catch (e) {
      Loggers.error('updateUserDetails error: $e');
      return null;
    }
  }

  Future<StatusModel> checkUsernameAvailability(
      {required String userName}) async {
    return await ApiService.instance.call(
        url: WebService.user.checkUsernameAvailability,
        param: {Params.username: userName},
        fromJson: StatusModel.fromJson);
  }

  Future<LinksModel> addEditDeleteUserLink(
      {String? title,
      String? urlLink,
      int? linkId,
      required LinkType linkType}) async {
    String url;
    switch (linkType) {
      case LinkType.add:
        url = WebService.user.addUserLink;
      case LinkType.edit:
        url = WebService.user.editeUserLink;
      case LinkType.delete:
        url = WebService.user.deleteUserLink;
    }
    LinksModel model = await ApiService.instance.call(
        url: url,
        fromJson: LinksModel.fromJson,
        param: {
          Params.linkId: linkId,
          Params.title: title,
          Params.url: urlLink
        });
    return model;
  }

  Future<List<User>> searchUsers(
      {int? lastItemId, String keyWord = '', required int limit}) async {
    UsersModel model = await ApiService.instance.call(
        url: WebService.user.searchUsers,
        param: {
          if (lastItemId != null) Params.lastItemId: lastItemId,
          Params.limit: limit,
          if (keyWord.isNotEmpty) Params.keyword: keyWord,
        },
        fromJson: UsersModel.fromJson);
    return model.data ?? [];
  }

  Future<List<Follower>> fetchMyFollowers(
      {required int lastItemId, required int? userId}) async {
    bool isMe = userId == SessionManager.instance.getUserID();
    String url = isMe
        ? WebService.user.fetchMyFollowers
        : WebService.user.fetchUserFollowers;
    FollowerModel model = await ApiService.instance.call(
        url: url,
        param: {
          Params.limit: AppRes.paginationLimit,
          if (lastItemId != -1) Params.lastItemId: lastItemId,
          if (!isMe) Params.userId: userId,
        },
        fromJson: FollowerModel.fromJson);
    return model.data ?? [];
  }

  Future<List<Following>> fetchMyFollowing(
      {required int lastItemId, required int? userId}) async {
    bool isMe = userId == SessionManager.instance.getUserID();
    String url = isMe
        ? WebService.user.fetchMyFollowings
        : WebService.user.fetchUserFollowings;
    FollowingModel model = await ApiService.instance.call(
        url: url,
        param: {
          Params.limit: AppRes.paginationLimit,
          if (lastItemId != -1) Params.lastItemId: lastItemId,
          if (!isMe) Params.userId: userId,
        },
        fromJson: FollowingModel.fromJson);
    return model.data ?? [];
  }


  Future<bool> setSupabaseFollow({
    required String followingKey,
    required bool isFollowing,
  }) async {
    try {
      final followerKey = firebase_auth.FirebaseAuth.instance.currentUser?.uid ??
          SessionManager.instance.getUserID().toString();

      if (isFollowing) {
        await supabase.Supabase.instance.client.from('user_follows').upsert({
          'follower_key': followerKey,
          'following_key': followingKey,
        }, onConflict: 'follower_key,following_key');
      } else {
        await supabase.Supabase.instance.client
            .from('user_follows')
            .delete()
            .eq('follower_key', followerKey)
            .eq('following_key', followingKey);
      }
      return true;
    } catch (e) {
      Loggers.error('Supabase follow failed: $e');
      return false;
    }
  }

  Future<StatusModel> followUser({required int userId}) async {
    StatusModel model = await ApiService.instance.call(
      url: WebService.user.followUser,
      param: {Params.userId: userId},
      fromJson: StatusModel.fromJson,
    );
    return model;
  }

  Future<StatusModel> unFollowUser({required int userId}) async {
    StatusModel model = await ApiService.instance.call(
      url: WebService.user.unFollowUser,
      param: {Params.userId: userId},
      fromJson: StatusModel.fromJson,
    );
    return model;
  }

  Future<StatusModel> unBlockUser({required int userId}) async {
    StatusModel model = await ApiService.instance.call(
        url: WebService.user.unBlockUser,
        param: {Params.userId: userId},
        fromJson: StatusModel.fromJson);
    return model;
  }

  Future<StatusModel> blockUser({required int userId}) async {
    StatusModel model = await ApiService.instance.call(
        url: WebService.user.blockUser,
        param: {Params.userId: userId},
        fromJson: StatusModel.fromJson);
    return model;
  }

  Future<StatusModel> reportPost(
      {required int userId,
      required String reason,
      required String description}) async {
    StatusModel model = await ApiService.instance.call(
        url: WebService.user.reportUser,
        param: {
          Params.userId: userId,
          Params.reason: reason,
          Params.description: description,
        },
        fromJson: StatusModel.fromJson);
    return model;
  }

  Future<List<BlockUsers>> fetchMyBlockedUsers() async {
    BlockUserModel response = await ApiService.instance.call(
      url: WebService.user.fetchMyBlockedUsers,
      fromJson: BlockUserModel.fromJson,
    );
    return response.data ?? [];
  }

  Future<void> updateLastUsedAt() async {}
}
