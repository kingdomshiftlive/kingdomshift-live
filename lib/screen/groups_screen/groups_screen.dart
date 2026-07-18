import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shortzz/screen/groups_screen/groups_controller.dart';
import 'package:shortzz/screen/groups_screen/create_group_screen.dart';
import 'package:shortzz/screen/groups_screen/group_detail_screen.dart';

class GroupsScreen extends StatelessWidget {
  const GroupsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.isRegistered<GroupsController>()
        ? Get.find<GroupsController>()
        : Get.put(GroupsController());

    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0F),
      body: SafeArea(
        child: Column(children: [
          _buildHeader(controller),
          Expanded(child: _buildGroupsList(controller)),
        ]),
      ),
    );
  }

  Widget _buildHeader(GroupsController controller) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      child: Row(children: [
        Container(
          width: 48,
          height: 48,
          decoration: const BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                  colors: [Color(0xFF7B2FF7), Color(0xFFFF006E)])),
          child: const Icon(Icons.groups_rounded, color: Colors.white, size: 22),
        ),
        const SizedBox(width: 12),
        const Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Kingdom Groups',
              style: TextStyle(
                  color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
          Text('Find your people, build together',
              style: TextStyle(color: Colors.white54, fontSize: 12)),
        ])),
        GestureDetector(
          onTap: () => Get.to(() => const CreateGroupScreen()),
          child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                  gradient: const LinearGradient(
                      colors: [Color(0xFF7B2FF7), Color(0xFF00C6FF)]),
                  borderRadius: BorderRadius.circular(20)),
              child: const Text('+ Create',
                  style: TextStyle(
                      color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12))),
        ),
      ]),
    );
  }

  Widget _buildGroupsList(GroupsController controller) {
    return Obx(() {
      if (controller.isLoading.value && controller.groups.isEmpty) {
        return const Center(
            child: CircularProgressIndicator(color: Color(0xFF7B2FF7)));
      }
      if (controller.groups.isEmpty) {
        return Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.groups_outlined, color: Colors.white24, size: 56),
              const SizedBox(height: 12),
              const Text('No groups yet',
                  style: TextStyle(color: Colors.white54, fontSize: 14)),
              const SizedBox(height: 4),
              const Text('Be the first to start one',
                  style: TextStyle(color: Colors.white24, fontSize: 12)),
            ],
          ),
        );
      }
      return RefreshIndicator(
        color: const Color(0xFF7B2FF7),
        backgroundColor: const Color(0xFF12121E),
        onRefresh: controller.fetchGroups,
        child: ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: controller.groups.length,
          itemBuilder: (_, i) {
            final group = controller.groups[i];
            return GestureDetector(
              onTap: () async {
                await controller.openGroup(group);
                Get.to(() => const GroupDetailScreen());
              },
              child: Container(
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: const Color(0xFF12121E),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.white12),
                ),
                child: Row(children: [
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      color: const Color(0xFF1A1A2E),
                      borderRadius: BorderRadius.circular(10),
                      image: group.coverImageUrl != null
                          ? DecorationImage(
                              image: NetworkImage(group.coverImageUrl!),
                              fit: BoxFit.cover)
                          : null,
                    ),
                    child: group.coverImageUrl == null
                        ? const Center(
                            child: Text('⛪', style: TextStyle(fontSize: 26)))
                        : null,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(children: [
                          Flexible(
                            child: Text(group.name,
                                style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis),
                          ),
                          if (group.isPrivate) ...[
                            const SizedBox(width: 6),
                            const Icon(Icons.lock, color: Colors.white38, size: 12),
                          ],
                        ]),
                        if ((group.description ?? '').isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(top: 2),
                            child: Text(group.description!,
                                style: const TextStyle(
                                    color: Colors.white54, fontSize: 12),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis),
                          ),
                        const SizedBox(height: 4),
                        Text(
                            '${group.memberCount} member${group.memberCount == 1 ? '' : 's'}',
                            style: const TextStyle(
                                color: Color(0xFF7B2FF7), fontSize: 11)),
                      ],
                    ),
                  ),
                  const Icon(Icons.chevron_right, color: Colors.white24),
                ]),
              ),
            );
          },
        ),
      );
    });
  }
}
