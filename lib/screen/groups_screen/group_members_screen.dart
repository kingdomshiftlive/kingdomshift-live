import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shortzz/screen/groups_screen/groups_controller.dart';

class GroupMembersScreen extends StatelessWidget {
  const GroupMembersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<GroupsController>();

    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0F),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0A0A0F),
        elevation: 0,
        title: const Text('Members',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SafeArea(
        child: Obx(() => ListView(
              padding: const EdgeInsets.all(16),
              children: [
                if (controller.pendingMembers.isNotEmpty) ...[
                  const Text('Pending Requests',
                      style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 14)),
                  const SizedBox(height: 10),
                  ...controller.pendingMembers.map((m) => _buildPendingTile(controller, m)),
                  const SizedBox(height: 24),
                ],
                Text('Members (${controller.members.length})',
                    style: const TextStyle(
                        color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
                const SizedBox(height: 10),
                ...controller.members.map((m) => _buildMemberTile(m)),
              ],
            )),
      ),
    );
  }

  Widget _buildPendingTile(GroupsController controller, GroupMemberModel member) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF12121E),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFFF006E).withValues(alpha: 0.25)),
      ),
      child: Row(children: [
        CircleAvatar(
          radius: 18,
          backgroundColor: const Color(0xFF1A1A2E),
          backgroundImage:
              member.profileImage != null ? NetworkImage(member.profileImage!) : null,
          child: member.profileImage == null
              ? const Icon(Icons.person, color: Colors.white38)
              : null,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(member.fullname ?? member.username ?? 'Member',
              style: const TextStyle(color: Colors.white, fontSize: 13),
              maxLines: 1,
              overflow: TextOverflow.ellipsis),
        ),
        GestureDetector(
          onTap: () => controller.approveMember(member),
          child: Container(
            padding: const EdgeInsets.all(8),
            decoration: const BoxDecoration(
                color: Color(0xFF7B2FF7), shape: BoxShape.circle),
            child: const Icon(Icons.check, color: Colors.white, size: 16),
          ),
        ),
        const SizedBox(width: 8),
        GestureDetector(
          onTap: () => controller.rejectMember(member),
          child: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.08), shape: BoxShape.circle),
            child: const Icon(Icons.close, color: Colors.white54, size: 16),
          ),
        ),
      ]),
    );
  }

  Widget _buildMemberTile(GroupMemberModel member) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF12121E),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white12),
      ),
      child: Row(children: [
        CircleAvatar(
          radius: 18,
          backgroundColor: const Color(0xFF1A1A2E),
          backgroundImage:
              member.profileImage != null ? NetworkImage(member.profileImage!) : null,
          child: member.profileImage == null
              ? const Icon(Icons.person, color: Colors.white38)
              : null,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(member.fullname ?? member.username ?? 'Member',
              style: const TextStyle(color: Colors.white, fontSize: 13),
              maxLines: 1,
              overflow: TextOverflow.ellipsis),
        ),
        if (member.role == 'admin')
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
                color: const Color(0xFF7B2FF7).withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(10)),
            child: const Text('Admin',
                style: TextStyle(color: Color(0xFF7B2FF7), fontSize: 10)),
          ),
      ]),
    );
  }
}
