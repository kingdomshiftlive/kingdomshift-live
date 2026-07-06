import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shortzz/common/extensions/string_extension.dart';
import 'package:shortzz/common/widget/custom_image.dart';
import 'package:shortzz/model/chat/chat_thread.dart';
import 'package:shortzz/model/livestream/app_user.dart';
import 'package:shortzz/screen/chat_screen/chat_screen.dart';
import 'widget/new_message_sheet.dart';
import 'message_screen_controller.dart';

class MessageScreen extends StatelessWidget {
  const MessageScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final c = Get.put(MessageScreenController());
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0F),
      body: SafeArea(
        child: Column(children: [
          _buildHeader(c),
          _buildTabs(c),
          Expanded(child: _buildMessageList(c)),
        ]),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF7B2FF7),
        onPressed: () {
          Get.bottomSheet(const NewMessageSheet(), isScrollControlled: true);
        },
        child: const Icon(Icons.edit, color: Colors.white),
      ),
    );
  }

  Widget _buildHeader(MessageScreenController c) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      child: Row(children: [
        Container(
            width: 48,
            height: 48,
            decoration: const BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                    colors: [Color(0xFF7B2FF7), Color(0xFFFF006E)])),
            child: const Icon(Icons.chat_bubble_outline,
                color: Colors.white, size: 22)),
        const SizedBox(width: 12),
        const Expanded(
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Messages',
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.bold)),
          Text('Connect, collaborate, and impact together.',
              style: TextStyle(color: Colors.white54, fontSize: 12)),
        ])),
        Container(
          decoration: BoxDecoration(
              color: const Color(0xFF1A1A2E),
              borderRadius: BorderRadius.circular(12)),
          child: Row(children: [
            IconButton(
                icon: const Icon(Icons.search, color: Colors.white70),
                onPressed: () {}),
            IconButton(
                icon: const Icon(Icons.tune, color: Colors.white70),
                onPressed: () {}),
          ]),
        ),
      ]),
    );
  }

  Widget _buildTabs(MessageScreenController c) {
    final tabs = ['Primary', 'Groups', 'Requests', 'Archived'];
    return Obx(() => Row(
          children: List.generate(tabs.length, (i) {
            final sel = c.selectedTab.value == i;
            return GestureDetector(
              onTap: () => c.selectedTab.value = i,
              child: Container(
                margin: const EdgeInsets.only(left: 16, bottom: 8),
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  border: Border(
                      bottom: BorderSide(
                          color: sel
                              ? const Color(0xFFFFB800)
                              : Colors.transparent,
                          width: 2)),
                ),
                child: Text(tabs[i],
                    style: TextStyle(
                      color: sel ? const Color(0xFFFFB800) : Colors.white54,
                      fontWeight: sel ? FontWeight.bold : FontWeight.normal,
                      fontSize: 14,
                    )),
              ),
            );
          }),
        ));
  }

  Widget _buildMessageList(MessageScreenController c) {
    return Obx(() {
      if (c.isLoading.value) {
        return const Center(
            child: CircularProgressIndicator(color: Color(0xFF7B2FF7)));
      }
      if (c.threads.isEmpty) {
        return const Center(
          child: Text('No conversations yet',
              style: TextStyle(color: Colors.white54, fontSize: 14)),
        );
      }
      final filtered = c.selectedTab.value == 2
          ? c.threads.where((t) => t.chatType == ChatType.request).toList()
          : c.threads.where((t) => t.chatType != ChatType.request).toList();
      if (filtered.isEmpty) {
        return const Center(
          child: Text('No conversations yet',
              style: TextStyle(color: Colors.white54, fontSize: 14)),
        );
      }
      return ListView.builder(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 80),
        itemCount: filtered.length,
        itemBuilder: (_, i) => _msgTile(filtered[i]),
      );
    });
  }

  Widget _msgTile(ChatThread thread) {
    final AppUser? user = thread.chatUser;
    final String name = user?.fullname ?? user?.username ?? 'Unknown';
    final String? photo = user?.profile;
    final int unread = thread.msgCount ?? 0;

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 0, vertical: 4),
      leading: CircleAvatar(
        radius: 26,
        backgroundColor: const Color(0xFF1A1A2E),
        child: ClipOval(
          child: CustomImage(
            size: const Size(52, 52),
            image: photo?.addBaseURL(),
            fullName: name,
          ),
        ),
      ),
      title: Text(name,
          style: const TextStyle(
              color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
      subtitle: Text(thread.lastMsg ?? '',
          style: const TextStyle(color: Colors.white54, fontSize: 13),
          maxLines: 1,
          overflow: TextOverflow.ellipsis),
      trailing: unread > 0
          ? Container(
              width: 20,
              height: 20,
              decoration: const BoxDecoration(
                  color: Color(0xFF7B2FF7), shape: BoxShape.circle),
              child: Center(
                  child: Text('$unread',
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.bold))))
          : null,
      onTap: () {
        Get.to(() => ChatScreen(conversationUser: thread));
      },
    );
  }
}
