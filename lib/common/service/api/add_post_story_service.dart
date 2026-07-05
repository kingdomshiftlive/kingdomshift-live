import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:supabase_flutter/supabase_flutter.dart' as supabase;
import 'package:shortzz/model/post_story/post_model.dart';

class AddPostStoryService {
  AddPostStoryService._();
  static final AddPostStoryService instance = AddPostStoryService._();

  Future<PostModel> addPostFeedVideo(
      {required Map<String, dynamic> param}) async {
    return await _saveToSupabase(param: param, type: 'video');
  }

  Future<PostModel> addPostReel({required Map<String, dynamic> param}) async {
    return await _saveToSupabase(param: param, type: 'reel');
  }

  Future<PostModel> addPostFeedText(
      {required Map<String, dynamic> param}) async {
    return await _saveToSupabase(param: param, type: 'text');
  }

  Future<PostModel> addPostFeedImage(
      {required Map<String, dynamic> param}) async {
    return await _saveToSupabase(param: param, type: 'image');
  }

  Future<PostModel> addPostFeedPodcast(
      {required Map<String, dynamic> param}) async {
    return await _saveToSupabase(param: param, type: 'podcast');
  }

  Future<PostModel> _saveToSupabase(
      {required Map<String, dynamic> param, required String type}) async {
    try {
      final firebaseUser = firebase_auth.FirebaseAuth.instance.currentUser;
      if (firebaseUser == null) {
        print('SAVE FAILED: No Firebase user');
        return PostModel();
      }
      print('ALL PARAMS: $param');
      String videoUrl = '';
      String thumbnailUrl = '';
      for (var key in param.keys) {
        final val = param[key]?.toString() ?? '';
        if (val.contains('supabase') && val.contains('mp4')) {
          videoUrl = val;
        }
        if (val.contains('supabase') &&
            (val.contains('jpg') ||
                val.contains('jpeg') ||
                val.contains('png'))) {
          thumbnailUrl = val;
        }
      }
      if (videoUrl.isEmpty) videoUrl = param['video']?.toString() ?? '';
      if (thumbnailUrl.isEmpty)
        thumbnailUrl = param['thumbnail']?.toString() ?? '';
      print('FINAL VIDEO URL: $videoUrl');

      // Bug #8 fix: never write a row with an empty video_url. This was the
      // source of the bad Supabase row that broke feed scrolling before.
      if (videoUrl.isEmpty) {
        print('SAVE ABORTED: video_url resolved empty, refusing to insert');
        return PostModel(status: false, message: 'Video upload did not return a valid URL');
      }

      final inserted = await supabase.Supabase.instance.client.from('videos').insert({
        'creator_id': firebaseUser.uid,
        'title': param['description'] ?? param['caption'] ?? '',
        'description': param['description'] ?? param['caption'] ?? '',
        'video_url': videoUrl,
        'thumbnail_url': thumbnailUrl,
        'category': param['category'] ?? 'Faith',
        'status': 'published',
      }).select().single().timeout(const Duration(seconds: 15));
      print('SAVED TO VIDEOS TABLE SUCCESS: $inserted');
      return PostModel(
        status: true,
        message: 'Post uploaded successfully',
        data: Post(
          id: inserted['id'].toString().hashCode,
          supabaseId: inserted['id']?.toString(),
          userId: inserted['creator_id']?.toString().hashCode,
          metadata: inserted['creator_id']?.toString(),
          description: inserted['title'] ?? '',
          video: inserted['video_url'] ?? '',
          thumbnail: inserted['thumbnail_url'] ?? '',
          likes: 0,
          comments: 0,
          views: 0,
          shares: 0,
          saves: 0,
          isLiked: false,
          isSaved: false,
          createdAt: inserted['created_at'] ?? '',
        ),
      );
    } catch (e) {
      print('SAVE ERROR: $e');
      return PostModel();
    }
  }
}
