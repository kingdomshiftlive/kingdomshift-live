import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:get/get.dart';
import 'package:shortzz/common/controller/base_controller.dart';
import 'package:shortzz/common/functions/media_picker_helper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as supabase;

class GroupModel {
  final String id;
  final String name;
  final String? description;
  final String? coverImageUrl;
  final String creatorId;
  final bool isPrivate;
  final int memberCount;

  GroupModel({
    required this.id,
    required this.name,
    this.description,
    this.coverImageUrl,
    required this.creatorId,
    required this.isPrivate,
    required this.memberCount,
  });

  factory GroupModel.fromJson(Map<String, dynamic> json) {
    return GroupModel(
      id: json['id'].toString(),
      name: json['name'] ?? '',
      description: json['description'],
      coverImageUrl: json['cover_image_url'],
      creatorId: json['creator_id'] ?? '',
      isPrivate: json['is_private'] ?? false,
      memberCount: json['member_count'] ?? 1,
    );
  }
}

class GroupMemberModel {
  final String id;
  final String groupId;
  final String userId;
  final String role; // 'admin' | 'member'
  final String status; // 'approved' | 'pending'
  final String? fullname;
  final String? username;
  final String? profileImage;

  GroupMemberModel({
    required this.id,
    required this.groupId,
    required this.userId,
    required this.role,
    required this.status,
    this.fullname,
    this.username,
    this.profileImage,
  });

  factory GroupMemberModel.fromJson(Map<String, dynamic> json) {
    final user = json['user'] as Map<String, dynamic>?;
    return GroupMemberModel(
      id: json['id'].toString(),
      groupId: json['group_id'].toString(),
      userId: json['user_id'] ?? '',
      role: json['role'] ?? 'member',
      status: json['status'] ?? 'pending',
      fullname: user?['fullname'],
      username: user?['username'],
      profileImage: user?['profile_image'],
    );
  }
}

class GroupPostModel {
  final String id;
  final String groupId;
  final String userId;
  final String? content;
  final String? imageUrl;
  final DateTime? createdAt;
  final String? fullname;
  final String? username;
  final String? profileImage;

  GroupPostModel({
    required this.id,
    required this.groupId,
    required this.userId,
    this.content,
    this.imageUrl,
    this.createdAt,
    this.fullname,
    this.username,
    this.profileImage,
  });

  factory GroupPostModel.fromJson(Map<String, dynamic> json) {
    final user = json['user'] as Map<String, dynamic>?;
    return GroupPostModel(
      id: json['id'].toString(),
      groupId: json['group_id'].toString(),
      userId: json['user_id'] ?? '',
      content: json['content'],
      imageUrl: json['image_url'],
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'].toString())
          : null,
      fullname: user?['fullname'],
      username: user?['username'],
      profileImage: user?['profile_image'],
    );
  }
}

class GroupsController extends BaseController {
  RxList<GroupModel> groups = <GroupModel>[].obs;
  RxBool isCreating = false.obs;

  // Detail-screen state
  Rx<GroupModel?> selectedGroup = Rx<GroupModel?>(null);
  RxList<GroupMemberModel> members = <GroupMemberModel>[].obs;
  RxList<GroupMemberModel> pendingMembers = <GroupMemberModel>[].obs;
  RxList<GroupPostModel> posts = <GroupPostModel>[].obs;
  RxString myStatus = ''.obs; // '', 'pending', 'approved'
  RxString myRole = ''.obs; // '', 'member', 'admin'
  RxBool isPosting = false.obs;
  RxBool isJoining = false.obs;

  String? get _userId => firebase_auth.FirebaseAuth.instance.currentUser?.uid;

  /// Public accessor so UI layers can check post/comment ownership.
  String? get currentUserId => _userId;

  @override
  void onInit() {
    super.onInit();
    fetchGroups();
  }

  Future<void> fetchGroups() async {
    isLoading.value = true;
    try {
      final response = await supabase.Supabase.instance.client
          .from('groups')
          .select()
          .order('created_at', ascending: false);
      groups.value = (response as List).map((e) => GroupModel.fromJson(e)).toList();
    } catch (e) {
      showSnackBar('Failed to load groups: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> createGroup({
    required String name,
    required String description,
    required bool isPrivate,
    String? coverImagePath,
  }) async {
    final userId = _userId;
    if (userId == null) {
      showSnackBar('Please sign in to create a group.');
      return false;
    }
    if (name.trim().isEmpty) {
      showSnackBar('Please enter a group name.');
      return false;
    }

    isCreating.value = true;
    try {
      String? coverUrl;
      if (coverImagePath != null) {
        final file = File(coverImagePath);
        final fileName = '$userId/group_cover_${DateTime.now().millisecondsSinceEpoch}.jpg';
        await supabase.Supabase.instance.client.storage.from('thumbnails').upload(
            fileName, file,
            fileOptions: const supabase.FileOptions(upsert: true));
        coverUrl = supabase.Supabase.instance.client.storage
            .from('thumbnails')
            .getPublicUrl(fileName);
      }

      final inserted = await supabase.Supabase.instance.client
          .from('groups')
          .insert({
            'name': name.trim(),
            'description': description.trim(),
            'cover_image_url': coverUrl,
            'creator_id': userId,
            'is_private': isPrivate,
          })
          .select()
          .single();

      // Creator automatically becomes an approved admin member
      await supabase.Supabase.instance.client.from('group_members').insert({
        'group_id': inserted['id'],
        'user_id': userId,
        'role': 'admin',
        'status': 'approved',
      });

      isCreating.value = false;
      await fetchGroups();
      return true;
    } catch (e) {
      isCreating.value = false;
      showSnackBar('Failed to create group: $e');
      return false;
    }
  }

  Future<String?> pickCoverImage() async {
    final XFile? picked = await MediaPickerHelper.shared.pickImage(source: ImageSource.gallery);
    return picked?.path;
  }

  // ---------------- Group detail ----------------

  Future<void> openGroup(GroupModel group) async {
    selectedGroup.value = group;
    members.clear();
    pendingMembers.clear();
    posts.clear();
    myStatus.value = '';
    myRole.value = '';
    await Future.wait([
      fetchMembers(group.id),
      fetchPosts(group.id),
    ]);
  }

  Future<void> fetchMembers(String groupId) async {
    try {
      final memberRows = await supabase.Supabase.instance.client
          .from('group_members')
          .select()
          .eq('group_id', groupId);

      final rows = (memberRows as List).cast<Map<String, dynamic>>();
      final userIds = rows.map((r) => r['user_id'] as String).toSet().toList();

      Map<String, Map<String, dynamic>> profilesById = {};
      if (userIds.isNotEmpty) {
        final profiles = await supabase.Supabase.instance.client
            .from('app_profiles')
            .select('id, full_name, username, avatar_url')
            .inFilter('id', userIds);
        for (final p in (profiles as List).cast<Map<String, dynamic>>()) {
          profilesById[p['id'] as String] = p;
        }
      }

      final all = rows.map((r) {
        final profile = profilesById[r['user_id']];
        return GroupMemberModel.fromJson({
          ...r,
          'user': profile == null
              ? null
              : {
                  'fullname': profile['full_name'],
                  'username': profile['username'],
                  'profile_image': profile['avatar_url'],
                },
        });
      }).toList();

      members.value = all.where((m) => m.status == 'approved').toList();
      pendingMembers.value = all.where((m) => m.status == 'pending').toList();

      final me = all.where((m) => m.userId == _userId).toList();
      if (me.isNotEmpty) {
        myStatus.value = me.first.status;
        myRole.value = me.first.role;
      } else {
        myStatus.value = '';
        myRole.value = '';
      }
    } catch (e) {
      showSnackBar('Failed to load members: $e');
    }
  }

  Future<void> fetchPosts(String groupId) async {
    try {
      final postRows = await supabase.Supabase.instance.client
          .from('group_posts')
          .select()
          .eq('group_id', groupId)
          .order('created_at', ascending: false);

      final rows = (postRows as List).cast<Map<String, dynamic>>();
      final userIds = rows.map((r) => r['user_id'] as String).toSet().toList();

      Map<String, Map<String, dynamic>> profilesById = {};
      if (userIds.isNotEmpty) {
        final profiles = await supabase.Supabase.instance.client
            .from('app_profiles')
            .select('id, full_name, username, avatar_url')
            .inFilter('id', userIds);
        for (final p in (profiles as List).cast<Map<String, dynamic>>()) {
          profilesById[p['id'] as String] = p;
        }
      }

      posts.value = rows.map((r) {
        final profile = profilesById[r['user_id']];
        return GroupPostModel.fromJson({
          ...r,
          'user': profile == null
              ? null
              : {
                  'fullname': profile['full_name'],
                  'username': profile['username'],
                  'profile_image': profile['avatar_url'],
                },
        });
      }).toList();
    } catch (e) {
      showSnackBar('Failed to load posts: $e');
    }
  }

  bool get canPost => myStatus.value == 'approved';
  bool get isAdmin => myRole.value == 'admin';
  bool get isPending => myStatus.value == 'pending';

  Future<void> joinGroup(GroupModel group) async {
    final userId = _userId;
    if (userId == null) {
      showSnackBar('Please sign in to join groups.');
      return;
    }
    isJoining.value = true;
    try {
      final status = group.isPrivate ? 'pending' : 'approved';
      await supabase.Supabase.instance.client.from('group_members').insert({
        'group_id': group.id,
        'user_id': userId,
        'role': 'member',
        'status': status,
      });
      myStatus.value = status;
      myRole.value = 'member';
      if (status == 'approved') {
        await fetchMembers(group.id);
        showSnackBar('You joined ${group.name}');
      } else {
        showSnackBar('Request sent — waiting for admin approval');
      }
    } catch (e) {
      showSnackBar('Failed to join group: $e');
    } finally {
      isJoining.value = false;
    }
  }

  Future<void> leaveGroup(GroupModel group) async {
    final userId = _userId;
    if (userId == null) return;
    try {
      await supabase.Supabase.instance.client
          .from('group_members')
          .delete()
          .eq('group_id', group.id)
          .eq('user_id', userId);
      myStatus.value = '';
      myRole.value = '';
      await fetchMembers(group.id);
      showSnackBar('You left ${group.name}');
    } catch (e) {
      showSnackBar('Failed to leave group: $e');
    }
  }

  Future<void> approveMember(GroupMemberModel member) async {
    try {
      await supabase.Supabase.instance.client
          .from('group_members')
          .update({'status': 'approved'})
          .eq('id', member.id);
      if (selectedGroup.value != null) {
        await fetchMembers(selectedGroup.value!.id);
      }
      showSnackBar('Approved ${member.fullname ?? member.username ?? 'member'}');
    } catch (e) {
      showSnackBar('Failed to approve member: $e');
    }
  }

  Future<void> rejectMember(GroupMemberModel member) async {
    try {
      await supabase.Supabase.instance.client
          .from('group_members')
          .delete()
          .eq('id', member.id);
      if (selectedGroup.value != null) {
        await fetchMembers(selectedGroup.value!.id);
      }
    } catch (e) {
      showSnackBar('Failed to reject member: $e');
    }
  }

  Future<void> createPost({required String content, String? imagePath}) async {
    final userId = _userId;
    final group = selectedGroup.value;
    if (userId == null || group == null) return;
    if (content.trim().isEmpty && imagePath == null) return;

    isPosting.value = true;
    try {
      String? imageUrl;
      if (imagePath != null) {
        final file = File(imagePath);
        final fileName = '$userId/group_post_${DateTime.now().millisecondsSinceEpoch}.jpg';
        await supabase.Supabase.instance.client.storage.from('thumbnails').upload(
            fileName, file,
            fileOptions: const supabase.FileOptions(upsert: true));
        imageUrl = supabase.Supabase.instance.client.storage
            .from('thumbnails')
            .getPublicUrl(fileName);
      }

      await supabase.Supabase.instance.client.from('group_posts').insert({
        'group_id': group.id,
        'user_id': userId,
        'content': content.trim(),
        'image_url': imageUrl,
      });

      await fetchPosts(group.id);
    } catch (e) {
      showSnackBar('Failed to post: $e');
    } finally {
      isPosting.value = false;
    }
  }

  Future<String?> pickPostImage() async {
    final XFile? picked = await MediaPickerHelper.shared.pickImage(source: ImageSource.gallery);
    return picked?.path;
  }

  Future<void> deletePost(GroupPostModel post) async {
    try {
      await supabase.Supabase.instance.client
          .from('group_posts')
          .delete()
          .eq('id', post.id);
      posts.removeWhere((p) => p.id == post.id);
    } catch (e) {
      showSnackBar('Failed to delete post: $e');
    }
  }
}
