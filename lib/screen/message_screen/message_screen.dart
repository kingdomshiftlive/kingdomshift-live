import 'package:flutter/material.dart';
import 'package:get/get.dart';
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
          _buildStoryRow(),
          _buildPinned(),
          Expanded(child: _buildMessageList()),
        ]),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF7B2FF7),
        onPressed: () {},
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
    final tabs = ['Primary', 'Groups', 'Requests 3', 'Archived'];
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

  Widget _buildStoryRow() {
    final stories = [
      {'label': 'New Message', 'emoji': '+', 'isNew': true},
      {'label': 'Your Note', 'emoji': '📝', 'online': true},
      {'label': 'Sarah J.', 'emoji': '👩🏽', 'online': true},
      {'label': 'Justin M.', 'emoji': '👨🏾', 'online': true},
      {'label': 'KE Group', 'emoji': 'KE'},
      {'label': 'Bible Study', 'emoji': '📖'},
    ];
    return SizedBox(
      height: 90,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: stories.length,
        itemBuilder: (_, i) {
          final s = stories[i];
          final isNew = s['isNew'] == true;
          return Container(
            width: 70,
            margin: const EdgeInsets.only(right: 12),
            child: Column(children: [
              Stack(children: [
                Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: isNew
                          ? null
                          : const LinearGradient(
                              colors: [Color(0xFF7B2FF7), Color(0xFFFF006E)]),
                      color: isNew ? const Color(0xFF1A1A2E) : null,
                      border: isNew ? Border.all(color: Colors.white24) : null,
                    ),
                    child: Center(
                        child: Text(s['emoji'] as String,
                            style: TextStyle(
                                fontSize: isNew ? 24 : 22,
                                color: Colors.white)))),
                if (s['online'] == true)
                  Positioned(
                      bottom: 2,
                      right: 2,
                      child: Container(
                          width: 12,
                          height: 12,
                          decoration: BoxDecoration(
                              color: Colors.green,
                              shape: BoxShape.circle,
                              border: Border.all(
                                  color: const Color(0xFF0A0A0F), width: 2)))),
              ]),
              const SizedBox(height: 4),
              Text(s['label'] as String,
                  style: const TextStyle(color: Colors.white70, fontSize: 10),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis),
            ]),
          );
        },
      ),
    );
  }

  Widget _buildPinned() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          const Row(children: [
            Icon(Icons.push_pin, color: Color(0xFFFFB800), size: 16),
            SizedBox(width: 6),
            Text('Pinned',
                style: TextStyle(
                    color: Color(0xFFFFB800), fontWeight: FontWeight.bold)),
          ]),
          GestureDetector(
              onTap: () {},
              child: const Text('View All',
                  style: TextStyle(color: Color(0xFFFFB800), fontSize: 13))),
        ]),
        const SizedBox(height: 8),
        _msgTile('👨🏾', 'Pastor David Wilson',
            "Let's connect about the conference next month.", '10:30 AM',
            tag: 'MINISTRY', pinned: true, unread: 1),
        _msgTile('👩🏾', 'Tasha Entrepreneur', '🎤 Voice message', 'Yesterday',
            tag: 'BUSINESS', pinned: true, unread: 2),
        _msgTile('👑', 'WealthShift Community',
            "Robert: Don't forget our call tonight at 8pm EST!", 'Yesterday',
            tag: 'GROUP', pinned: true),
      ]),
    );
  }

  Widget _buildMessageList() {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 80),
      children: [
        _msgTile('👨🏿', 'Marcus Johnson',
            'Thanks for the resource! It helped a lot. 🔥', '9:45 AM',
            unread: 1),
        _msgTile('👨👩👧', 'Kingdom Creators',
            "Lisa: Here's the content calendar for this week.", '8:15 AM',
            tag: 'GROUP', unread: 5),
        _msgTile('👩🏽', 'Brittany Love',
            'Can\'t wait to see what God does! 🙌', 'Yesterday'),
        _msgTile(
            '🛡️',
            'KingdomShift Team',
            'System Update: Live stream was completed successfully.',
            'Yesterday',
            tag: 'OFFICIAL',
            unread: 2),
        _msgTile('👨🏾', 'Jonathan Wright',
            'Appreciate the collaboration brother!', 'Mon'),
      ],
    );
  }

  Widget _msgTile(String avatar, String name, String preview, String time,
      {String? tag, bool pinned = false, int? unread}) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 0, vertical: 4),
      leading: Stack(children: [
        CircleAvatar(
            radius: 26,
            backgroundColor: const Color(0xFF1A1A2E),
            child: Text(avatar, style: const TextStyle(fontSize: 22))),
        Positioned(
            bottom: 0,
            left: 0,
            child: Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                    color: Colors.green,
                    shape: BoxShape.circle,
                    border:
                        Border.all(color: const Color(0xFF0A0A0F), width: 2)))),
      ]),
      title: Row(children: [
        Text(name,
            style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 14)),
        if (tag != null) ...[
          const SizedBox(width: 6),
          Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                  color: const Color(0xFF7B2FF7).withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(
                      color: const Color(0xFF7B2FF7).withValues(alpha: 0.5))),
              child: Text(tag,
                  style: const TextStyle(
                      color: Color(0xFF7B2FF7),
                      fontSize: 10,
                      fontWeight: FontWeight.bold))),
        ],
      ]),
      subtitle: Text(preview,
          style: const TextStyle(color: Colors.white54, fontSize: 13),
          maxLines: 1,
          overflow: TextOverflow.ellipsis),
      trailing: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(time,
              style: const TextStyle(color: Colors.white54, fontSize: 12)),
          const SizedBox(height: 4),
          Row(mainAxisSize: MainAxisSize.min, children: [
            if (pinned)
              const Icon(Icons.push_pin, color: Color(0xFFFFB800), size: 14),
            if (unread != null) ...[
              const SizedBox(width: 4),
              Container(
                  width: 20,
                  height: 20,
                  decoration: const BoxDecoration(
                      color: Color(0xFF7B2FF7), shape: BoxShape.circle),
                  child: Center(
                      child: Text('$unread',
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.bold)))),
            ],
          ]),
        ],
      ),
      onTap: () {},
    );
  }
}
