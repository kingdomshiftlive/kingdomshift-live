import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../services/api_service.dart';
import '../theme/ks_theme.dart';

class CommentsSheet extends StatefulWidget {
  final dynamic postId;
  final Function(int newCount)? onCommentAdded;

  const CommentsSheet({super.key, required this.postId, this.onCommentAdded});

  @override
  State<CommentsSheet> createState() => _CommentsSheetState();
}

class _CommentsSheetState extends State<CommentsSheet> {
  List<dynamic> comments = [];
  bool isLoading = true;
  bool isSending = false;
  final TextEditingController _controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadComments();
  }

  Future<void> _loadComments() async {
    setState(() => isLoading = true);
    final res = await ApiService.fetchPostComments(widget.postId);
    setState(() {
      if (res['status'] == true) {
        comments = (res['data']?['commentList'] as List? ?? []);
      }
      isLoading = false;
    });
  }

  Future<void> _sendComment() async {
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    setState(() => isSending = true);
    final res = await ApiService.addPostComment(widget.postId, text);
    if (res['status'] == true) {
      _controller.clear();
      await _loadComments();
      widget.onCommentAdded?.call(comments.length);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error sending comment'), backgroundColor: Colors.red),
        );
      }
    }
    if (mounted) setState(() => isSending = false);
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.6,
      minChildSize: 0.4,
      maxChildSize: 0.9,
      builder: (context, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: KSTheme.bgCard,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              const SizedBox(height: 8),
              Container(
                width: 40, height: 4,
                decoration: BoxDecoration(color: KSTheme.divider, borderRadius: BorderRadius.circular(2)),
              ),
              const Padding(
                padding: EdgeInsets.all(12),
                child: Text('Comments', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
              ),
              const Divider(color: KSTheme.divider, height: 1),
              Expanded(
                child: isLoading
                    ? const Center(child: CircularProgressIndicator(color: KSTheme.teal))
                    : comments.isEmpty
                        ? const Center(child: Text('No comments yet. Be the first!', style: TextStyle(color: KSTheme.textSecondary)))
                        : ListView.builder(
                            controller: scrollController,
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            itemCount: comments.length,
                            itemBuilder: (context, index) {
                              final c = comments[index];
                              final user = c['user'];
                              return Padding(
                                padding: const EdgeInsets.symmetric(vertical: 8),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    CircleAvatar(
                                      radius: 18,
                                      backgroundColor: KSTheme.bgCardLight,
                                      backgroundImage: (user?['profilePhoto']?.isNotEmpty == true)
                                          ? CachedNetworkImageProvider(user['profilePhoto'])
                                          : null,
                                      child: (user?['profilePhoto']?.isEmpty != false)
                                          ? Text(
                                              (user?['fullname']?.isNotEmpty == true) ? user['fullname'][0] : '?',
                                              style: const TextStyle(color: Colors.white, fontSize: 12))
                                          : null,
                                    ),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Row(children: [
                                            Text(user?['username'] ?? '',
                                                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
                                            const SizedBox(width: 4),
                                            const Icon(Icons.verified, color: KSTheme.teal, size: 11),
                                          ]),
                                          const SizedBox(height: 2),
                                          Text(c['comment'] ?? '',
                                              style: const TextStyle(color: Colors.white70, fontSize: 13)),
                                        ],
                                      ),
                                    ),
                                    const Icon(Icons.favorite_border, color: KSTheme.textSecondary, size: 16),
                                  ],
                                ),
                              );
                            },
                          ),
              ),
              const Divider(color: KSTheme.divider, height: 1),
              Padding(
                padding: EdgeInsets.only(
                  left: 12, right: 12, top: 8,
                  bottom: 8 + MediaQuery.of(context).viewInsets.bottom,
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _controller,
                        style: const TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          hintText: 'Add a comment...',
                          hintStyle: const TextStyle(color: KSTheme.textSecondary),
                          filled: true,
                          fillColor: KSTheme.bgCardLight,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(24),
                            borderSide: BorderSide.none,
                          ),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                        ),
                        onSubmitted: (_) => _sendComment(),
                      ),
                    ),
                    const SizedBox(width: 8),
                    isSending
                        ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2, color: KSTheme.gold))
                        : GestureDetector(
                            onTap: _sendComment,
                            child: Container(
                              width: 44, height: 44,
                              decoration: const BoxDecoration(shape: BoxShape.circle, gradient: KSTheme.goldGradient),
                              child: const Icon(Icons.send_rounded, color: Colors.white, size: 20),
                            ),
                          ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
