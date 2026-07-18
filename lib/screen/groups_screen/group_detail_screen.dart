import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shortzz/screen/groups_screen/groups_controller.dart';
import 'package:shortzz/screen/groups_screen/group_members_screen.dart';

class GroupDetailScreen extends StatelessWidget {
  const GroupDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<GroupsController>();
    final postController = TextEditingController();
    final RxString postImagePath = ''.obs;

    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0F),
      body: SafeArea(
        child: Obx(() {
          final group = controller.selectedGroup.value;
          if (group == null) {
            return const Center(
                child: CircularProgressIndicator(color: Color(0xFF7B2FF7)));
          }
          return Column(children: [
            _buildAppBar(controller, group),
            Expanded(
              child: RefreshIndicator(
                color: const Color(0xFF7B2FF7),
                backgroundColor: const Color(0xFF12121E),
                onRefresh: () => controller.openGroup(group),
                child: ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    _buildJoinBanner(controller, group),
                    if (controller.isAdmin && controller.pendingMembers.isNotEmpty)
                      _buildPendingBanner(controller),
                    if (controller.canPost) ...[
                      _buildComposer(controller, postController, postImagePath),
                      const SizedBox(height: 16),
                    ],
                    ..._buildPosts(controller),
                  ],
                ),
              ),
            ),
          ]);
        }),
      ),
    );
  }

  Widget _buildAppBar(GroupsController controller, GroupModel group) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 8, 16, 8),
      child: Row(children: [
        IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Get.back(),
        ),
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: const Color(0xFF1A1A2E),
            borderRadius: BorderRadius.circular(10),
            image: group.coverImageUrl != null
                ? DecorationImage(
                    image: NetworkImage(group.coverImageUrl!), fit: BoxFit.cover)
                : null,
          ),
          child: group.coverImageUrl == null
              ? const Center(child: Text('⛪', style: TextStyle(fontSize: 20)))
              : null,
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(group.name,
                  style: const TextStyle(
                      color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis),
              Obx(() => Text('${controller.members.length} members',
                  style: const TextStyle(color: Colors.white54, fontSize: 11))),
            ],
          ),
        ),
        if (controller.isAdmin)
          IconButton(
            icon: const Icon(Icons.people_outline, color: Colors.white70),
            onPressed: () => Get.to(() => const GroupMembersScreen()),
          ),
      ]),
    );
  }

  Widget _buildJoinBanner(GroupsController controller, GroupModel group) {
    if (controller.myStatus.value == 'approved') return const SizedBox.shrink();

    if (controller.isPending) {
      return Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: const Color(0xFF12121E),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white12),
        ),
        child: const Row(children: [
          Icon(Icons.hourglass_top, color: Colors.white54, size: 18),
          SizedBox(width: 10),
          Expanded(
            child: Text('Your request to join is pending admin approval',
                style: TextStyle(color: Colors.white70, fontSize: 13)),
          ),
        ]),
      );
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [
          const Color(0xFF7B2FF7).withValues(alpha: 0.25),
          const Color(0xFF12121E)
        ]),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF7B2FF7).withValues(alpha: 0.3)),
      ),
      child: Row(children: [
        Expanded(
          child: Text(
              group.isPrivate
                  ? 'This is a private group. Request to join to see and share posts.'
                  : 'Join this group to post and connect with members.',
              style: const TextStyle(color: Colors.white70, fontSize: 13)),
        ),
        const SizedBox(width: 10),
        GestureDetector(
          onTap: controller.isJoining.value ? null : () => controller.joinGroup(group),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                  colors: [Color(0xFF7B2FF7), Color(0xFF00C6FF)]),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(group.isPrivate ? 'Request' : 'Join',
                style: const TextStyle(
                    color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
          ),
        ),
      ]),
    );
  }

  Widget _buildPendingBanner(GroupsController controller) {
    return GestureDetector(
      onTap: () => Get.to(() => const GroupMembersScreen()),
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: const Color(0xFFFF006E).withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFFF006E).withValues(alpha: 0.3)),
        ),
        child: Row(children: [
          const Icon(Icons.notifications_active_outlined,
              color: Color(0xFFFF006E), size: 18),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
                '${controller.pendingMembers.length} join request${controller.pendingMembers.length == 1 ? '' : 's'} waiting for approval',
                style: const TextStyle(color: Colors.white, fontSize: 13)),
          ),
          const Icon(Icons.chevron_right, color: Colors.white38),
        ]),
      ),
    );
  }

  Widget _buildComposer(GroupsController controller,
      TextEditingController postController, RxString postImagePath) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF12121E),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white12),
      ),
      child: Column(children: [
        TextField(
          controller: postController,
          maxLines: 3,
          style: const TextStyle(color: Colors.white, fontSize: 14),
          decoration: const InputDecoration(
            hintText: 'Share something with the group...',
            hintStyle: TextStyle(color: Colors.white24, fontSize: 13),
            border: InputBorder.none,
          ),
        ),
        Obx(() => postImagePath.value.isNotEmpty
            ? Padding(
                padding: const EdgeInsets.only(top: 8),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Image.file(File(postImagePath.value),
                      height: 140, width: double.infinity, fit: BoxFit.cover),
                ),
              )
            : const SizedBox.shrink()),
        Row(children: [
          IconButton(
            icon: const Icon(Icons.image_outlined, color: Colors.white54),
            onPressed: () async {
              final path = await controller.pickPostImage();
              if (path != null) postImagePath.value = path;
            },
          ),
          const Spacer(),
          Obx(() => GestureDetector(
                onTap: controller.isPosting.value
                    ? null
                    : () async {
                        await controller.createPost(
                          content: postController.text,
                          imagePath: postImagePath.value.isEmpty
                              ? null
                              : postImagePath.value,
                        );
                        postController.clear();
                        postImagePath.value = '';
                      },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                        colors: [Color(0xFF7B2FF7), Color(0xFF00C6FF)]),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: controller.isPosting.value
                      ? const SizedBox(
                          width: 14,
                          height: 14,
                          child: CircularProgressIndicator(
                              color: Colors.white, strokeWidth: 2))
                      : const Text('Post',
                          style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 12)),
                ),
              )),
        ]),
      ]),
    );
  }

  List<Widget> _buildPosts(GroupsController controller) {
    if (controller.posts.isEmpty) {
      return [
        const Padding(
          padding: EdgeInsets.only(top: 40),
          child: Center(
            child: Text('No posts yet', style: TextStyle(color: Colors.white38)),
          ),
        ),
      ];
    }
    return controller.posts.map((post) {
      final canDelete = controller.isAdmin || post.userId == controller.currentUserId;
      return Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: const Color(0xFF12121E),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [
              CircleAvatar(
                radius: 16,
                backgroundColor: const Color(0xFF1A1A2E),
                backgroundImage: post.profileImage != null
                    ? NetworkImage(post.profileImage!)
                    : null,
                child: post.profileImage == null
                    ? const Icon(Icons.person, color: Colors.white38, size: 16)
                    : null,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(post.fullname ?? post.username ?? 'Member',
                    style: const TextStyle(
                        color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
              ),
              if (canDelete)
                GestureDetector(
                  onTap: () => controller.deletePost(post),
                  child: const Icon(Icons.close, color: Colors.white24, size: 16),
                ),
            ]),
            if ((post.content ?? '').isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 10),
                child: Text(post.content!,
                    style: const TextStyle(color: Colors.white70, fontSize: 13)),
              ),
            if (post.imageUrl != null)
              Padding(
                padding: const EdgeInsets.only(top: 10),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Image.network(post.imageUrl!,
                      height: 180, width: double.infinity, fit: BoxFit.cover),
                ),
              ),
          ],
        ),
      );
    }).toList();
  }
}

