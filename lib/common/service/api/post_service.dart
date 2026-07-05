import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:image_picker/image_picker.dart';
import 'package:shortzz/common/controller/base_controller.dart';
import 'package:shortzz/common/manager/logger.dart';
import 'package:shortzz/common/manager/session_manager.dart';
import 'package:shortzz/common/service/api/api_service.dart';
import 'package:shortzz/common/service/utils/params.dart';
import 'package:shortzz/common/service/utils/web_service.dart';
import 'package:shortzz/model/general/status_model.dart';
import 'package:shortzz/model/post_story/comment/add_comment_model.dart';
import 'package:shortzz/model/post_story/comment/fetch_comment_model.dart';
import 'package:shortzz/model/post_story/comment/reply_comment_model.dart';
import 'package:shortzz/model/post_story/music/music_model.dart';
import 'package:shortzz/model/post_story/music/musics_model.dart';
import 'package:shortzz/model/post_story/post/explore_page_model.dart';
import 'package:shortzz/model/post_story/post/hashtag_post_model.dart';
import 'package:shortzz/model/post_story/post/posts_model.dart';
import 'package:shortzz/model/post_story/post_by_id.dart';
import 'package:shortzz/model/post_story/post_model.dart';
import 'package:shortzz/model/post_story/story/stories_model.dart';
import 'package:shortzz/model/post_story/story/story_model.dart';
import 'package:shortzz/model/post_story/user_post_model.dart';
import 'package:shortzz/model/user_model/user_model.dart';
import 'package:shortzz/utilities/app_res.dart';
import 'package:shortzz/screen/comment_sheet/helper/comment_helper.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as supabase;

enum PostType {
  reel,
  image,
  video,
  text,
  podcast,
  none;

  int get type {
    switch (this) {
      case PostType.reel:
        return 1;
      case PostType.image:
        return 2;
      case PostType.video:
        return 3;
      case PostType.text:
        return 4;
      case PostType.podcast:
        return 5;
      case PostType.none:
        return 0;
    }
  }

  static String get posts =>
      '${PostType.image.type},${PostType.video.type},${PostType.text.type},${PostType.podcast.type}';

  static String get reels => '${PostType.reel.type}';

  static PostType fromString(int value) {
    return PostType.values.firstWhere(
      (e) => e.type == value,
      orElse: () => throw ArgumentError('Invalid MessageType: $value'),
    );
  }
}

class PostService {
  PostService._();

  static final PostService instance = PostService._();


  Future<Map<String, dynamic>> getSupabaseVideoSocialState(String supabaseId) async {
    try {
      final userKey = firebase_auth.FirebaseAuth.instance.currentUser?.uid ??
          SessionManager.instance.getUserID().toString();

      final likes = await supabase.Supabase.instance.client
          .from('video_likes')
          .select('id')
          .eq('video_id', supabaseId);

      final saves = await supabase.Supabase.instance.client
          .from('video_saves')
          .select('id')
          .eq('video_id', supabaseId);

      final myLike = await supabase.Supabase.instance.client
          .from('video_likes')
          .select('id')
          .eq('video_id', supabaseId)
          .eq('user_key', userKey)
          .maybeSingle();

      final mySave = await supabase.Supabase.instance.client
          .from('video_saves')
          .select('id')
          .eq('video_id', supabaseId)
          .eq('user_key', userKey)
          .maybeSingle();

      return {
        'likes': (likes as List).length,
        'saves': (saves as List).length,
        'isLiked': myLike != null,
        'isSaved': mySave != null,
      };
    } catch (e) {
      Loggers.error('Supabase social state failed: $e');
      return {};
    }
  }

  Future<List<Post>> fetchPostsDiscover(
      {required String type, int page = 1, CancelToken? cancelToken}) async {
    try {
      print('QUERYING SUPABASE VIDEOS TABLE...');
      final response = await supabase.Supabase.instance.client
          .from('videos')
          .select('*, app_profiles(id, full_name, username, avatar_url)')
          .order('created_at', ascending: false)
          .limit(AppRes.paginationLimit);
      print('RAW VIDEO RESPONSE: $response');
      final responseList = response as List;
      final validVideos = responseList.where((item) {
        final videoUrl = (item['video_url'] ?? '').toString().trim();
        return videoUrl.isNotEmpty;
      }).toList();

      List<Post> posts = [];
      for (final item in validVideos) {
        final social = await getSupabaseVideoSocialState(item['id'].toString());
        posts.add(Post(
          id: item['id'].hashCode,
          supabaseId: item['id']?.toString(),
          userId: item['creator_id']?.toString().hashCode,
          metadata: item['creator_id']?.toString(),
          description: item['title'] ?? '',
          video: item['video_url'] ?? '',
          thumbnail: item['thumbnail_url'] ?? '',
          likes: social['likes'] ?? item['likes_count'] ?? 0,
          saves: social['saves'] ?? 0,
          isLiked: social['isLiked'] ?? false,
          isSaved: social['isSaved'] ?? false,
          comments: item['comments_count'] ?? 0,
          views: item['views_count'] ?? 0,
          shares: item['shares_count'] ?? 0,
          postType: PostType.reel,
          createdAt: item['created_at'] ?? '',
          user: item['app_profiles'] != null
              ? User(
                  id: item['creator_id']?.toString().hashCode,
                  fullname: item['app_profiles']['full_name'] ?? '',
                  username: item['app_profiles']['username'] ?? '',
                  profilePhoto: item['app_profiles']['avatar_url'] ?? '',
                )
              : null,
        ));
      }
      print('MAPPED ${posts.length} POSTS, FILTERED OUT ${responseList.length - validVideos.length} BAD VIDEO ROWS');
      return posts;
    } catch (e) {
      print('FETCH POSTS ERROR: $e');
      return [];
    }
  }

  Future<List<Post>> fetchPostsFollowing(
      {required String type, CancelToken? cancelToken}) async {
    try {
      final response = await supabase.Supabase.instance.client
          .from('videos')
          .select('*, app_profiles(id, full_name, username, avatar_url)')
          .order('created_at', ascending: false)
          .limit(AppRes.paginationLimit);
      List<Post> posts = (response as List).map((item) {
        return Post(
          id: item['id'].hashCode,
          supabaseId: item['id']?.toString(),
          userId: item['creator_id']?.toString().hashCode,
          metadata: item['creator_id']?.toString(),
          description: item['title'] ?? '',
          video: item['video_url'] ?? '',
          thumbnail: item['thumbnail_url'] ?? '',
          likes: item['likes_count'] ?? 0,
          comments: item['comments_count'] ?? 0,
          views: item['views_count'] ?? 0,
          shares: item['shares_count'] ?? 0,
          postType: PostType.reel,
          createdAt: item['created_at'] ?? '',
          user: User(
            id: item['creator_id']?.toString().hashCode,
            username: 'creator',
            fullname: 'Creator',
            isFollowing: false,
          ),
        );
      }).toList();
      return posts;
    } catch (e) {
      return [];
    }
  }

  Future<PostByIdModel> fetchPostById(
      {required int postId, int? commentId, int? replyId}) async {
    if (postId == -1) return PostByIdModel();
    PostByIdModel model = await ApiService.instance.call(
        url: WebService.post.fetchPostById,
        param: {
          Params.postId: postId,
          if (commentId != null) Params.commentId: commentId,
          if (replyId != null) Params.replyId: replyId
        },
        fromJson: PostByIdModel.fromJson);
    return model;
  }

  Future<List<Post>> fetchPostsNearBy(
      {required String type,
      required double placeLat,
      required double placeLon,
      CancelToken? cancelToken}) async {
    PostsModel model = await ApiService.instance.call(
        url: WebService.post.fetchPostsNearBy,
        param: {
          Params.placeLat: placeLat,
          Params.placeLon: placeLon,
          Params.types: type
        },
        fromJson: PostsModel.fromJson,
        cancelToken: cancelToken);
    return model.data ?? [];
  }

  Future<List<Post>> fetchReelPostsByMusic(
      {int? musicId, int? lastItemId}) async {
    PostsModel model = await ApiService.instance.call(
        url: WebService.post.fetchReelPostsByMusic,
        param: {
          Params.limit: AppRes.paginationLimit,
          Params.lastItemId: lastItemId,
          Params.musicId: musicId
        },
        fromJson: PostsModel.fromJson);
    return model.data ?? [];
  }

  Future<List<Post>> fetchPostsByLocation(
      {required String type,
      required double placeLat,
      required double placeLon,
      int? lastItemId}) async {
    PostsModel model = await ApiService.instance.call(
        url: WebService.post.fetchPostsByLocation,
        param: {
          Params.limit: AppRes.paginationLimit,
          Params.lastItemId: lastItemId,
          Params.types: type,
          Params.placeLat: placeLat,
          Params.placeLon: placeLon
        },
        fromJson: PostsModel.fromJson);
    return model.data ?? [];
  }

  Future<UserPostData?> fetchUserPosts(
      {required String type,
      required int? userId,
      required int? lastItemId}) async {
    try {
      final firebaseUser = firebase_auth.FirebaseAuth.instance.currentUser;
      if (firebaseUser == null) return null;

      final response = await supabase.Supabase.instance.client
          .from('videos')
          .select()
          .eq('creator_id', firebaseUser.uid)
          .eq('status', 'published')
          .order('created_at', ascending: false)
          .limit(AppRes.paginationLimit);

      List<Post> posts = (response as List).map((item) {
        return Post(
          id: item['id'].hashCode,
          supabaseId: item['id']?.toString(),
          userId: item['creator_id']?.toString().hashCode,
          metadata: item['creator_id']?.toString(),
          description: item['title'] ?? '',
          video: item['video_url'] ?? '',
          thumbnail: item['thumbnail_url'] ?? '',
          likes: item['likes_count'] ?? 0,
          comments: item['comments_count'] ?? 0,
          views: item['views_count'] ?? 0,
          shares: item['shares_count'] ?? 0,
          postType: PostType.reel,
          createdAt: item['created_at'] ?? '',
          user: User(
            id: item['creator_id']?.toString().hashCode,
            username: 'creator',
            fullname: 'Creator',
            isFollowing: false,
          ),
        );
      }).toList();

      return UserPostData(posts: posts, pinnedPostList: []);
    } catch (e) {
      Loggers.error('fetchUserPosts error: $e');
      return null;
    }
  }

  Future<HashtagPostData?> fetchPostsByHashtag(
      {required String type,
      required String hashTag,
      required int? lastItemId}) async {
    HashtagPostModel model = await ApiService.instance.call(
        url: WebService.post.fetchPostsByHashtag,
        param: {
          Params.limit: AppRes.paginationLimit,
          Params.hashtag: hashTag,
          Params.types: type,
          Params.lastItemId: lastItemId
        },
        fromJson: HashtagPostModel.fromJson);
    return model.data;
  }

  Future<List<Post>> fetchSavedPosts(
      {required String type, required int? lastItemId}) async {
    PostsModel model = await ApiService.instance.call(
        url: WebService.post.fetchSavedPosts,
        param: {
          Params.types: type,
          Params.limit: AppRes.paginationLimit,
          Params.lastItemId: lastItemId
        },
        fromJson: PostsModel.fromJson);
    return model.data ?? [];
  }


  Future<bool> deleteSupabaseVideo({required String supabaseId}) async {
    try {
      await supabase.Supabase.instance.client
          .from('videos')
          .delete()
          .eq('id', supabaseId);
      return true;
    } catch (e) {
      Loggers.error('Supabase video delete failed: $e');
      return false;
    }
  }


  Future<List<Comment>> fetchSupabaseVideoComments({
    required String supabaseId,
  }) async {
    try {
      final response = await supabase.Supabase.instance.client
          .from('video_comments')
          .select()
          .eq('video_id', supabaseId)
          .order('created_at', ascending: true);

      return (response as List).map((item) {
        return Comment(
          id: item['id'].toString().hashCode,
          postId: supabaseId.hashCode,
          comment: item['comment']?.toString() ?? '',
          likes: 0,
          repliesCount: 0,
          isPinned: 0,
          type: (item['type'] == 1) ? CommentType.image : CommentType.text,
          createdAt: item['created_at']?.toString(),
          user: null,
        );
      }).toList();
    } catch (e) {
      Loggers.error('Supabase comments fetch failed: $e');
      return [];
    }
  }

  Future<Comment?> addSupabaseVideoComment({
    required String supabaseId,
    required String comment,
    int type = 0,
  }) async {
    print('USING SUPABASE COMMENT -> video_id=$supabaseId comment=$comment');
    try {
      final firebaseUser = firebase_auth.FirebaseAuth.instance.currentUser;
      if (firebaseUser == null) return null;

      final item = await supabase.Supabase.instance.client
          .from('video_comments')
          .insert({
            'video_id': supabaseId,
            'creator_id': firebaseUser.uid,
            'comment': comment,
            'type': type,
          })
          .select()
          .single();

      print('COMMENT INSERTED -> $item');

      return Comment(
        id: item['id'].toString().hashCode,
        postId: supabaseId.hashCode,
        userId: SessionManager.instance.getUserID(),
        comment: item['comment']?.toString() ?? '',
        likes: 0,
        repliesCount: 0,
        isPinned: 0,
        type: (item['type'] == 1) ? CommentType.image : CommentType.text,
        createdAt: item['created_at']?.toString(),
        user: SessionManager.instance.getUser(),
      );
    } catch (e) {
      print('COMMENT ERROR: $e');
      Loggers.error('Supabase comment add failed: $e');
      return null;
    }
  }

  Future<StatusModel> deletePost({int? postId}) async {
    return await ApiService.instance.call(
        url: WebService.post.deletePost,
        param: {Params.postId: postId},
        fromJson: StatusModel.fromJson);
  }

  Future<StatusModel> deleteComment({int? commentId}) async {
    return await ApiService.instance.call(
        url: WebService.post.deleteComment,
        param: {Params.commentId: commentId},
        fromJson: StatusModel.fromJson);
  }

  Future<StatusModel> deleteCommentReply({int? replyId}) async {
    return await ApiService.instance.call(
        url: WebService.post.deleteCommentReply,
        param: {Params.replyId: replyId},
        fromJson: StatusModel.fromJson);
  }


  Future<bool> increaseSupabaseShareCount({
    required String supabaseId,
  }) async {
    try {
      final response = await supabase.Supabase.instance.client
          .from('videos')
          .select('shares_count')
          .eq('id', supabaseId)
          .maybeSingle();

      final current = response == null ? 0 : (response['shares_count'] ?? 0) as int;

      await supabase.Supabase.instance.client
          .from('videos')
          .update({'shares_count': current + 1})
          .eq('id', supabaseId);

      return true;
    } catch (e) {
      Loggers.error('Supabase share count failed: $e');
      return false;
    }
  }

  Future<StatusModel> increaseShareCount({int? postId}) async {
    return await ApiService.instance.call(
        url: WebService.post.increaseShareCount,
        param: {Params.postId: postId},
        fromJson: StatusModel.fromJson);
  }

  Future<StatusModel> increaseViewsCount({int? postId}) async {
    return await ApiService.instance.call(
        url: WebService.post.increaseViewsCount,
        param: {Params.postId: postId},
        fromJson: StatusModel.fromJson);
  }

  Future<StatusModel> likeComment({int? commentId}) async {
    return await ApiService.instance.call(
        url: WebService.post.likeComment,
        param: {Params.commentId: commentId},
        fromJson: StatusModel.fromJson);
  }


  Future<bool> setSupabaseVideoLike({
    required String supabaseId,
    required bool isLiked,
  }) async {
    try {
      final userKey = firebase_auth.FirebaseAuth.instance.currentUser?.uid ??
          SessionManager.instance.getUserID().toString();

      if (isLiked) {
        await supabase.Supabase.instance.client.from('video_likes').upsert({
          'video_id': supabaseId,
          'user_key': userKey,
        });
      } else {
        await supabase.Supabase.instance.client
            .from('video_likes')
            .delete()
            .eq('video_id', supabaseId)
            .eq('user_key', userKey);
      }
      return true;
    } catch (e) {
      Loggers.error('Supabase like failed: $e');
      return false;
    }
  }

  Future<bool> setSupabaseVideoSave({
    required String supabaseId,
    required bool isSaved,
  }) async {
    try {
      final userKey = firebase_auth.FirebaseAuth.instance.currentUser?.uid ??
          SessionManager.instance.getUserID().toString();

      if (isSaved) {
        await supabase.Supabase.instance.client.from('video_saves').upsert({
          'video_id': supabaseId,
          'user_key': userKey,
        });
      } else {
        await supabase.Supabase.instance.client
            .from('video_saves')
            .delete()
            .eq('video_id', supabaseId)
            .eq('user_key', userKey);
      }
      return true;
    } catch (e) {
      Loggers.error('Supabase save failed: $e');
      return false;
    }
  }

  Future<StatusModel> disLikeComment({int? commentId}) async {
    return await ApiService.instance.call(
        url: WebService.post.disLikeComment,
        param: {Params.commentId: commentId},
        fromJson: StatusModel.fromJson);
  }

  Future<StatusModel> likePost({required int postId}) async {
    return await ApiService.instance.call(
        url: WebService.post.likePost,
        param: {Params.postId: postId},
        fromJson: StatusModel.fromJson);
  }

  Future<StatusModel> pinPost({required int postId}) async {
    return await ApiService.instance.call(
        url: WebService.post.pinPost,
        param: {Params.postId: postId},
        fromJson: StatusModel.fromJson);
  }

  Future<StatusModel> unpinPost({required int postId}) async {
    return await ApiService.instance.call(
        url: WebService.post.unpinPost,
        param: {Params.postId: postId},
        fromJson: StatusModel.fromJson);
  }

  Future<StatusModel> pinComment({required int commentId}) async {
    return await ApiService.instance.call(
        url: WebService.post.pinComment,
        param: {Params.commentId: commentId},
        fromJson: StatusModel.fromJson);
  }

  Future<StatusModel> unPinComment({required int commentId}) async {
    return await ApiService.instance.call(
        url: WebService.post.unPinComment,
        param: {Params.commentId: commentId},
        fromJson: StatusModel.fromJson);
  }

  Future<StatusModel> disLikePost({required int postId}) async {
    return await ApiService.instance.call(
        url: WebService.post.disLikePost,
        param: {Params.postId: postId},
        fromJson: StatusModel.fromJson);
  }

  Future<StatusModel> savePost({required int postId}) async {
    return await ApiService.instance.call(
        url: WebService.post.savePost,
        param: {Params.postId: postId},
        fromJson: StatusModel.fromJson);
  }

  Future<StatusModel> unSavePost({required int postId}) async {
    return await ApiService.instance.call(
        url: WebService.post.unSavePost,
        param: {Params.postId: postId},
        fromJson: StatusModel.fromJson);
  }

  Future<CommentData?> fetchPostComments(
      {required int postId, int? lastItemId}) async {
    FetchCommentModel model = await ApiService.instance.call(
        url: WebService.post.fetchPostComments,
        param: {
          Params.postId: postId,
          Params.limit: AppRes.paginationLimit,
          Params.lastItemId: lastItemId
        },
        fromJson: FetchCommentModel.fromJson);
    return model.data;
  }

  Future<List<Comment>> fetchPostCommentReplies(
      {required int commentId, int? lastItemId}) async {
    ReplyCommentModel model = await ApiService.instance.call(
        url: WebService.post.fetchPostCommentReplies,
        param: {
          Params.commentId: commentId,
          Params.limit: AppRes.paginationLimit,
          if (lastItemId != null) Params.lastItemId: lastItemId
        },
        fromJson: ReplyCommentModel.fromJson);
    return model.data ?? [];
  }

  Future<Comment?> addComment(
      {required int postId,
      int? type,
      required String comment,
      String? mentionUserIds}) async {
    AddCommentModel model = await ApiService.instance.call(
        url: WebService.post.addPostComment,
        param: {
          Params.postId: postId,
          Params.type: type,
          Params.comment: comment,
          Params.mentionedUserIds: mentionUserIds
        },
        fromJson: AddCommentModel.fromJson);
    if (model.status == false) BaseController.share.showSnackBar(model.message);
    return model.data;
  }

  Future<Comment?> replyToComment(
      {required int commentId,
      required String reply,
      String? mentionUserIds}) async {
    AddCommentModel model = await ApiService.instance.call(
        url: WebService.post.replyToComment,
        param: {
          Params.commentId: commentId,
          Params.reply: reply,
          Params.mentionedUserIds: mentionUserIds
        },
        fromJson: AddCommentModel.fromJson);
    if (model.status == false) BaseController.share.showSnackBar(model.message);
    return model.data;
  }

  Future<StatusModel> reportPost(
      {required int postId,
      required String reason,
      required String description}) async {
    return await ApiService.instance.call(
        url: WebService.post.reportPost,
        param: {
          Params.postId: postId,
          Params.reason: reason,
          Params.description: description
        },
        fromJson: StatusModel.fromJson);
  }

  Future<StatusModel> reportComment(
      {required int commentId,
      required String reason,
      required String description}) async {
    return await ApiService.instance.call(
        url: WebService.post.reportComment,
        param: {
          Params.commentId: commentId,
          Params.reason: reason,
          Params.description: description
        },
        fromJson: StatusModel.fromJson);
  }

  Future<StatusModel> reportStory(
      {required int storyId,
      required String reason,
      required String description}) async {
    return await ApiService.instance.call(
        url: WebService.post.reportStory,
        param: {
          Params.storyId: storyId,
          Params.reason: reason,
          Params.description: description
        },
        fromJson: StatusModel.fromJson);
  }

  Future<List<Music>> fetchMusicExplore({int? lastItemId}) async {
    MusicsModel response = await ApiService.instance.call(
        url: WebService.post.fetchMusicExplore,
        param: {
          Params.limit: AppRes.paginationLimit,
          Params.lastItemId: lastItemId
        },
        fromJson: MusicsModel.fromJson);
    return response.status == true ? response.data ?? [] : [];
  }

  Future<List<Music>> fetchMusicByCategories(
      {int? lastItemId, required int categoryId}) async {
    MusicsModel response = await ApiService.instance.call(
        url: WebService.post.fetchMusicByCategories,
        param: {
          Params.limit: AppRes.paginationLimit,
          Params.lastItemId: lastItemId,
          Params.categoryId: categoryId
        },
        fromJson: MusicsModel.fromJson);
    return response.status == true ? response.data ?? [] : [];
  }

  Future<List<Music>> fetchSavedMusics() async {
    MusicsModel response = await ApiService.instance.call(
        url: WebService.post.fetchSavedMusics, fromJson: MusicsModel.fromJson);
    return response.status == true ? response.data ?? [] : [];
  }

  Future<List<Music>> searchMusic(
      {required String keyword, int? lastItemId}) async {
    MusicsModel response = await ApiService.instance.call(
        url: WebService.post.serchMusic,
        param: {
          Params.limit: AppRes.paginationLimit,
          Params.keyword: keyword,
          Params.lastItemId: lastItemId
        },
        fromJson: MusicsModel.fromJson);
    return response.status == true ? response.data ?? [] : [];
  }

  Future<StoryModel> createStory(
      {required Map<String, dynamic> param,
      required Map<String, List<XFile?>> files}) async {
    return await ApiService.instance.multiPartCallApi(
        url: WebService.post.createStory,
        filesMap: files,
        param: param,
        fromJson: StoryModel.fromJson);
  }

  Future<Story?> viewStory({required int storyId}) async {
    StoryModel response = await ApiService.instance.call(
        url: WebService.post.viewStory,
        param: {Params.storyId: storyId},
        fromJson: StoryModel.fromJson);
    return response.status == true ? response.data : null;
  }

  Future<StatusModel> deleteStory({required int storyId}) async {
    return await ApiService.instance.call(
        url: WebService.post.deleteStory,
        param: {Params.storyId: storyId},
        fromJson: StatusModel.fromJson);
  }

  Future<Music?> addUserMusic(
      {required String title,
      required String duration,
      required String artist,
      required XFile? sound,
      required XFile? image}) async {
    MusicModel response = await ApiService.instance.multiPartCallApi(
        url: WebService.post.addUserMusic,
        param: {
          Params.title: title,
          Params.duration: duration,
          Params.artist: artist
        },
        fromJson: MusicModel.fromJson,
        filesMap: {
          Params.sound: [sound],
          if (image != null) Params.image: [image]
        });
    return response.data;
  }

  Future<List<User>> fetchStory() async {
    StoriesModel response = await ApiService.instance
        .call(url: WebService.post.fetchStory, fromJson: StoriesModel.fromJson);
    return response.status == true ? response.data ?? [] : [];
  }

  Future<Story?> fetchStoryByID(int id) async {
    StoryModel response = await ApiService.instance.call(
        url: WebService.post.fetchStoryByID,
        fromJson: StoryModel.fromJsonWithUser,
        param: {Params.storyId: id});
    return response.status == true ? response.data : null;
  }

  Future<ExplorePageData?> fetchExplorePageData() async {
    ExplorePageModel response = await ApiService.instance.call(
        url: WebService.post.fetchExplorePageData,
        fromJson: ExplorePageModel.fromJson);
    return response.status == true ? response.data : null;
  }
}
