import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:supabase_flutter/supabase_flutter.dart' as supabase;

import 'package:shortzz/common/manager/logger.dart';
import 'package:shortzz/common/manager/session_manager.dart';
import 'package:shortzz/common/service/api/post_service.dart';
import 'package:shortzz/model/post_story/hashtag_model.dart';
import 'package:shortzz/model/post_story/post_model.dart';
import 'package:shortzz/model/user_model/user_model.dart';
import 'package:shortzz/utilities/app_res.dart';

class SearchService {
  SearchService._();

  static final SearchService instance = SearchService._();

  Future<Map<String, dynamic>> _socialState(String supabaseId) async {
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
      Loggers.error('Search social state failed: $e');
      return {};
    }
  }

  Future<List<Post>> searchPost({
    String? keyword,
    required String type,
    num? lastItemId,
  }) async {
    try {
      final query = (keyword ?? '').trim().toLowerCase();

      var request = supabase.Supabase.instance.client
          .from('videos')
          .select('*, app_profiles(id, full_name, username, avatar_url)')
          .order('created_at', ascending: false)
          .limit(AppRes.paginationLimit);

      final response = await request;
      final rows = (response as List).where((item) {
        final videoUrl = (item['video_url'] ?? '').toString().trim();
        if (videoUrl.isEmpty) return false;

        if (query.isEmpty) return true;

        final title = (item['title'] ?? '').toString().toLowerCase();
        final description =
            (item['description'] ?? '').toString().toLowerCase();
        final username =
            (item['app_profiles']?['username'] ?? '').toString().toLowerCase();
        final fullname =
            (item['app_profiles']?['full_name'] ?? '').toString().toLowerCase();

        return title.contains(query) ||
            description.contains(query) ||
            username.contains(query) ||
            fullname.contains(query);
      }).toList();

      final posts = <Post>[];

      for (final item in rows) {
        final social = await _socialState(item['id'].toString());
        posts.add(Post(
          id: item['id'].toString().hashCode,
          supabaseId: item['id']?.toString(),
          userId: item['creator_id']?.toString().hashCode,
          metadata: item['creator_id']?.toString(),
          description: item['title'] ?? item['description'] ?? '',
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
              : User(
                  id: item['creator_id']?.toString().hashCode,
                  fullname: 'Creator',
                  username: 'creator',
                ),
        ));
      }

      return posts;
    } catch (e) {
      Loggers.error('Supabase searchPost failed: $e');
      return [];
    }
  }

  Future<List<User>> searchUsers({String? keyword, num? lastItemId}) async {
    try {
      final query = (keyword ?? '').trim().toLowerCase();

      final response = await supabase.Supabase.instance.client
          .from('app_profiles')
          .select()
          .limit(AppRes.paginationLimit);

      final rows = (response as List).where((item) {
        if (query.isEmpty) return true;

        final username = (item['username'] ?? '').toString().toLowerCase();
        final fullname = (item['full_name'] ?? '').toString().toLowerCase();
        final bio = (item['bio'] ?? '').toString().toLowerCase();

        return username.contains(query) ||
            fullname.contains(query) ||
            bio.contains(query);
      }).toList();

      return rows.map((item) {
        return User(
          id: item['id']?.toString().hashCode,
          fullname: item['full_name'] ?? '',
          username: item['username'] ?? '',
          firebaseUid: item['id']?.toString(),
          profilePhoto: item['avatar_url'] ?? '',
          bio: item['bio'] ?? '',
          isVerify: 0,
        );
      }).toList();
    } catch (e) {
      Loggers.error('Supabase searchUsers failed: $e');
      return [];
    }
  }

  Future<List<Hashtag>> searchHashtags({
    required String keyword,
    int? lastItemId,
  }) async {
    try {
      final query = keyword.trim().toLowerCase();

      final response = await supabase.Supabase.instance.client
          .from('videos')
          .select('title, description')
          .limit(100);

      final counts = <String, int>{};

      for (final item in response as List) {
        final text =
            '${item['title'] ?? ''} ${item['description'] ?? ''}'.toLowerCase();

        final matches = RegExp(r'#([a-zA-Z0-9_]+)').allMatches(text);
        for (final match in matches) {
          final tag = match.group(1);
          if (tag == null || tag.isEmpty) continue;
          if (query.isNotEmpty && !tag.contains(query.replaceAll('#', ''))) {
            continue;
          }
          counts[tag] = (counts[tag] ?? 0) + 1;
        }
      }

      final sorted = counts.entries.toList()
        ..sort((a, b) => b.value.compareTo(a.value));

      return sorted.take(AppRes.paginationLimit).map((entry) {
        return Hashtag(
          id: entry.key.hashCode,
          hashtag: entry.key,
          postCount: entry.value,
        );
      }).toList();
    } catch (e) {
      Loggers.error('Supabase searchHashtags failed: $e');
      return [];
    }
  }
}
