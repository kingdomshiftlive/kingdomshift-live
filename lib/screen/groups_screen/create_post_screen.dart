import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as sb;
import '../../theme/ks_theme.dart';
import '../../services/api_service.dart';
import '../live/live_list_screen.dart';

class CreatePostScreen extends StatefulWidget {
  const CreatePostScreen({super.key});
  @override
  State<CreatePostScreen> createState() => _CreatePostScreenState();
}

class _CreatePostScreenState extends State<CreatePostScreen> {
  final TextEditingController _controller = TextEditingController();
  File? _mediaFile;
  bool _isVideo = false;
  bool _isPosting = false;
  String _audience = 'Public';
  String _selectedTab = 'Post';
  int _selectedTemplate = 0;

  final templates = [
    {'label': 'KS', 'isLogo': true},
    {'label': 'TRUST IN\nHIS PLAN', 'color': 0xFF1A2A3A},
    {'label': 'FAITH\nOVER\nFEAR', 'color': 0xFF2A1A0A},
    {'label': 'WALK BY\nFAITH', 'color': 0xFF0A1A2A},
    {'label': '+\nMore', 'color': 0xFF1A1A1A},
  ];

  Future<void> _pickMedia(bool isVideo) async {
    final picker = ImagePicker();
    final picked = isVideo
        ? await picker.pickVideo(source: ImageSource.gallery)
        : await picker.pickImage(source: ImageSource.gallery, imageQuality: 80);
    if (picked != null) {
      setState(() { _mediaFile = File(picked.path); _isVideo = isVideo; });
    }
  }

  Future<void> _post() async {
    if (_controller.text.trim().isEmpty && _mediaFile == null) return;
    setState(() => _isPosting = true);
    try {
      final firebaseUser = FirebaseAuth.instance.currentUser;
      if (firebaseUser == null) return;

      String videoPath = '';
      String thumbnailPath = '';

      if (_mediaFile != null) {
        final ext = _mediaFile!.path.split('.').last;
        final fileName = '${firebaseUser.uid}/${DateTime.now().millisecondsSinceEpoch}.$ext';
        final bucket = _isVideo ? 'videos' : 'thumbnails';
        await sb.Supabase.instance.client.storage.from(bucket).upload(fileName, _mediaFile!, fileOptions: const sb.FileOptions(upsert: true));
        final url = sb.Supabase.instance.client.storage.from(bucket).getPublicUrl(fileName);
        if (_isVideo) videoPath = url; else thumbnailPath = url;
      }

      final res = await ApiService.createPost(
        description: _controller.text.trim(),
        videoPath: videoPath,
        thumbnailPath: thumbnailPath,
      );

      if (res['status'] == true && mounted) {
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    } finally {
      if (mounted) setState(() => _isPosting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: KSTheme.bgDark,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
              child: Row(
                children: [
                  GestureDetector(onTap: () => Navigator.pop(context), child: const Icon(Icons.close, color: Colors.white, size: 24)),
                  const Expanded(
                    child: Column(children: [
                      Text('Create Post', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                      Text('Share truth. Inspire change. Build the Kingdom.', style: TextStyle(color: KSTheme.textSecondary, fontSize: 11), textAlign: TextAlign.center),
                    ]),
                  ),
                  GestureDetector(
                    onTap: _isPosting ? null : _post,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                      decoration: BoxDecoration(gradient: KSTheme.tealGradient, borderRadius: BorderRadius.circular(12)),
                      child: _isPosting
                          ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                          : const Row(children: [
                              Text('Post', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                              SizedBox(width: 6),
                              Icon(Icons.send_rounded, color: Colors.white, size: 16),
                            ]),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            // Scrollable content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Text input
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(color: KSTheme.bgCard, borderRadius: BorderRadius.circular(14), border: Border.all(color: KSTheme.divider)),
                      child: Column(
                        children: [
                          TextField(
                            controller: _controller,
                            maxLines: 5,
                            maxLength: 1000,
                            style: const TextStyle(color: Colors.white, fontSize: 15),
                            decoration: const InputDecoration(
                              hintText: "What's on your heart?",
                              hintStyle: TextStyle(color: KSTheme.textSecondary, fontSize: 15),
                              border: InputBorder.none,
                              counterStyle: TextStyle(color: KSTheme.textSecondary),
                            ),
                            onChanged: (_) => setState(() {}),
                          ),
                          if (_mediaFile != null)
                            ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.file(_mediaFile!, height: 120, width: double.infinity, fit: BoxFit.cover),
                            ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Media type buttons
                    Row(
                      children: [
                        _mediaBtn(Icons.image_outlined, 'Photo', KSTheme.teal, () => _pickMedia(false)),
                        const SizedBox(width: 8),
                        _mediaBtn(Icons.videocam_outlined, 'Video', KSTheme.teal, () => _pickMedia(true)),
                        const SizedBox(width: 8),
                        _mediaBtn(Icons.sensors, 'Live', KSTheme.gold, () => Navigator.push(context, MaterialPageRoute(builder: (_) => const LiveListScreen()))),
                        const SizedBox(width: 8),
                        _mediaBtn(Icons.mic_outlined, 'Podcast', KSTheme.teal, () {}),
                        const SizedBox(width: 8),
                        _mediaBtn(Icons.menu_book_outlined, 'Bible Verse', KSTheme.gold, () {}),
                      ],
                    ),
                    const SizedBox(height: 16),
                    // Options list
                    Container(
                      decoration: BoxDecoration(color: KSTheme.bgCard, borderRadius: BorderRadius.circular(14), border: Border.all(color: KSTheme.divider)),
                      child: Column(
                        children: [
                          _optionRow(Icons.people_outline, 'Tag People', 'Invite others to see your post'),
                          _divider(),
                          _optionRow(Icons.location_on_outlined, 'Add Location', 'Let others know where you are'),
                          _divider(),
                          _optionRow(Icons.tag, 'Add Topic', 'Help others find your post'),
                          _divider(),
                          _optionRow(Icons.groups_outlined, 'Add to Group', 'Share with your community'),
                          _divider(),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                            child: Row(
                              children: [
                                const Icon(Icons.security_outlined, color: KSTheme.gold, size: 22),
                                const SizedBox(width: 14),
                                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                                  const Text('Audience', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
                                  Text('Choose who can see this post', style: TextStyle(color: KSTheme.textSecondary, fontSize: 12)),
                                ]),
                                const Spacer(),
                                Text(_audience, style: TextStyle(color: KSTheme.teal, fontWeight: FontWeight.w600)),
                                const Icon(Icons.keyboard_arrow_down, color: KSTheme.teal),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Inspiration section
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(color: KSTheme.bgCard, borderRadius: BorderRadius.circular(14), border: Border.all(color: KSTheme.divider)),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Container(
                                width: 36, height: 36,
                                decoration: const BoxDecoration(shape: BoxShape.circle, color: KSTheme.bgCardLight),
                                child: const Icon(Icons.auto_awesome, color: KSTheme.gold, size: 18),
                              ),
                              const SizedBox(width: 12),
                              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                                const Text('Inspiration for today', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
                                Text('You are called for such a time as this.', style: TextStyle(color: KSTheme.teal, fontSize: 12)),
                              ]),
                              const Spacer(),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                decoration: BoxDecoration(color: KSTheme.bgCardLight, borderRadius: BorderRadius.circular(8), border: Border.all(color: KSTheme.teal)),
                                child: const Row(children: [
                                  Icon(Icons.menu_book_outlined, color: KSTheme.teal, size: 14),
                                  SizedBox(width: 4),
                                  Text('Add Verse', style: TextStyle(color: KSTheme.teal, fontSize: 11, fontWeight: FontWeight.w600)),
                                ]),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          SizedBox(
                            height: 80,
                            child: ListView.separated(
                              scrollDirection: Axis.horizontal,
                              itemCount: templates.length,
                              separatorBuilder: (_, __) => const SizedBox(width: 8),
                              itemBuilder: (_, i) {
                                final t = templates[i];
                                final isSelected = _selectedTemplate == i;
                                return GestureDetector(
                                  onTap: () => setState(() => _selectedTemplate = i),
                                  child: Container(
                                    width: 80,
                                    decoration: BoxDecoration(
                                      color: Color(t['color'] as int? ?? 0xFF1A2A3A),
                                      borderRadius: BorderRadius.circular(10),
                                      border: Border.all(color: isSelected ? KSTheme.teal : Colors.transparent, width: 2),
                                    ),
                                    child: Stack(
                                      alignment: Alignment.center,
                                      children: [
                                        Text(t['label'] as String, style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold), textAlign: TextAlign.center),
                                        if (isSelected)
                                          Positioned(bottom: 4, right: 4, child: Container(
                                            width: 18, height: 18,
                                            decoration: const BoxDecoration(color: KSTheme.teal, shape: BoxShape.circle),
                                            child: const Icon(Icons.check, color: Colors.white, size: 12),
                                          )),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Post/Reel/LiveStream tabs
                    Container(
                      decoration: BoxDecoration(color: KSTheme.bgCard, borderRadius: BorderRadius.circular(14), border: Border.all(color: KSTheme.divider)),
                      child: Row(
                        children: [
                          _tabBtn(Icons.article_outlined, 'Post'),
                          _tabBtn(Icons.video_collection_outlined, 'Reel'),
                          _tabBtn(Icons.sensors, 'Live Stream'),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _mediaBtn(IconData icon, String label, Color color, VoidCallback onTap) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(color: KSTheme.bgCard, borderRadius: BorderRadius.circular(12), border: Border.all(color: KSTheme.divider)),
          child: Column(children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 4),
            Text(label, style: const TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.w500), textAlign: TextAlign.center),
          ]),
        ),
      ),
    );
  }

  Widget _optionRow(IconData icon, String title, String subtitle) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(children: [
        Icon(icon, color: KSTheme.teal, size: 22),
        const SizedBox(width: 14),
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
          Text(subtitle, style: const TextStyle(color: KSTheme.textSecondary, fontSize: 12)),
        ]),
        const Spacer(),
        const Icon(Icons.chevron_right, color: KSTheme.textSecondary),
      ]),
    );
  }

  Widget _divider() => const Divider(color: KSTheme.divider, height: 1, indent: 52);

  Widget _tabBtn(IconData icon, String label) {
    final isSelected = _selectedTab == label;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedTab = label),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            border: Border(bottom: BorderSide(color: isSelected ? KSTheme.teal : Colors.transparent, width: 2)),
          ),
          child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            Icon(icon, color: isSelected ? KSTheme.teal : KSTheme.textSecondary, size: 18),
            const SizedBox(width: 6),
            Text(label, style: TextStyle(color: isSelected ? KSTheme.teal : KSTheme.textSecondary, fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal, fontSize: 13)),
          ]),
        ),
      ),
    );
  }
}
