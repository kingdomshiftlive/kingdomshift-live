import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shortzz/common/extensions/string_extension.dart';
import 'package:shortzz/common/extensions/list_extension.dart';
import 'package:shortzz/common/extensions/user_extension.dart';
import 'package:shortzz/common/manager/session_manager.dart';
import 'package:shortzz/common/service/api/user_service.dart';
import 'package:shortzz/common/widget/custom_image.dart';
import 'package:shortzz/model/chat/chat_thread.dart';
import 'package:shortzz/model/user_model/user_model.dart';
import 'package:shortzz/screen/chat_screen/chat_screen.dart';

class NewMessageSheet extends StatefulWidget {
  const NewMessageSheet({super.key});

  @override
  State<NewMessageSheet> createState() => _NewMessageSheetState();
}

class _NewMessageSheetState extends State<NewMessageSheet> {
  final TextEditingController _searchController = TextEditingController();
  List<User> _results = [];
  bool _isLoading = false;

  Future<void> _search(String keyword) async {
    setState(() => _isLoading = true);
    final results = await UserService.instance
        .searchUsers(keyWord: keyword, limit: 20);
    setState(() {
      _results = results;
      _isLoading = false;
    });
  }

  void _startChat(User user) {
    ChatThread conversation = ChatThread(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        lastMsg: '',
        msgCount: 0,
        isDeleted: false,
        deletedId: 0,
        iAmBlocked: false,
        iBlocked: user.isBlock ?? false,
        requestType: 'accept',
        chatType: user.isFollowing ?? false
            ? ChatType.approved
            : ChatType.request,
        conversationId: [SessionManager.instance.getUserID(), user.id]
            .conversationId,
        userId: user.id);
    conversation.chatUser = user.appUser;
    Get.back();
    Get.to(() => ChatScreen(conversationUser: conversation, user: user));
  }

  @override
  void initState() {
    super.initState();
    _search('');
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.75,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: const BoxDecoration(
        color: Color(0xFF0A0A0F),
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('New Message',
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          TextField(
            controller: _searchController,
            style: const TextStyle(color: Colors.white),
            onChanged: _search,
            decoration: InputDecoration(
              hintText: 'Search people',
              hintStyle: const TextStyle(color: Colors.white38),
              prefixIcon: const Icon(Icons.search, color: Colors.white38),
              filled: true,
              fillColor: const Color(0xFF1A1A2E),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
            ),
          ),
          const SizedBox(height: 12),
          Expanded(
            child: _isLoading
                ? const Center(
                    child:
                        CircularProgressIndicator(color: Color(0xFF7B2FF7)))
                : _results.isEmpty
                    ? const Center(
                        child: Text('No users found',
                            style: TextStyle(color: Colors.white54)))
                    : ListView.builder(
                        itemCount: _results.length,
                        itemBuilder: (_, i) {
                          final user = _results[i];
                          return ListTile(
                            leading: CircleAvatar(
                              radius: 22,
                              backgroundColor: const Color(0xFF1A1A2E),
                              child: ClipOval(
                                child: CustomImage(
                                  size: const Size(44, 44),
                                  image: user.profilePhoto?.addBaseURL(),
                                  fullName: user.fullname,
                                ),
                              ),
                            ),
                            title: Text(user.fullname ?? user.username ?? '',
                                style: const TextStyle(color: Colors.white)),
                            subtitle: Text('@${user.username ?? ''}',
                                style:
                                    const TextStyle(color: Colors.white54)),
                            onTap: () => _startChat(user),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }
}
