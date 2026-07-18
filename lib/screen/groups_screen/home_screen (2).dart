import 'package:share_plus/share_plus.dart';
import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as sb;
import '../../services/api_service.dart';
import '../../models/app_post.dart';
import '../../theme/ks_theme.dart';
import '../profile/profile_screen.dart';
import '../story/story_viewer_screen.dart';
import '../../widgets/feed_video_player.dart';
import '../../widgets/comments_sheet.dart';
import '../post/create_post_screen.dart';
import '../search/search_screen.dart';
import '../notifications/notifications_screen.dart';
import '../live/live_list_screen.dart';
import '../battle/brain_battles_screen.dart';
import '../shop/authority_shop_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  late TabController _tabController;
  List<AppPost> posts = [];
  List<AppPost> followingPosts = [];
  bool followingLoaded = false;
  List<AppStoryGroup> storyGroups = [];
  Set<dynamic> liveUserNumericIds = {};
  bool isLoading = true;
  bool isUploadingStory = false;
  Set<dynamic> likedPosts = {};
  Map<dynamic, int> likeCounts = {};
  Map<dynamic, int> commentCounts = {};
  Set<dynamic> savedPosts = {};
  Timer? _breakTimer;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _tabController.addListener(() {
      if (_tabController.index == 1 && !followingLoaded) _loadFollowing();
    });
    _loadData();
    _breakTimer = Timer(const Duration(minutes: 30), _showBreakReminder);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _breakTimer?.cancel();
    super.dispose();
  }

  void _showBreakReminder() {
    if (!mounted) return;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        backgroundColor: KSTheme.bgCard,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(mainAxisAlignment: MainAxisAlignment.end, children: [
                GestureDetector(
                  onTap: () { Navigator.pop(context); _breakTimer = Timer(const Duration(minutes: 30), _showBreakReminder); },
                  child: const Icon(Icons.close, color: Colors.white),
                ),
              ]),
              const Icon(Icons.self_improvement, color: KSTheme.teal, size: 48),
              const SizedBox(height: 16),
              const Text("Time for a Break?", style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold), textAlign: TextAlign.center),
              const SizedBox(height: 8),
              const Text("You've been scrolling for a while. Take a moment to rest, pray, or stretch.", style: TextStyle(color: KSTheme.textSecondary), textAlign: TextAlign.center),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () { Navigator.pop(context); _breakTimer = Timer(const Duration(minutes: 30), _showBreakReminder); },
                  style: KSTheme.tealButton,
                  child: const Text('Continue Scrolling'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _loadFollowing() async {
    final res = await ApiService.fetchPostsFollowing();
    setState(() {
      if (res['status'] == true) {
        final list = (res['data']?['postList'] as List? ?? []);
        followingPosts = list.map((p) => AppPost.fromJson(p)).toList();
      }
      followingLoaded = true;
    });
  }

  Future<void> _loadData() async {
    setState(() => isLoading = true);
    final postsRes = await ApiService.fetchPostsDiscover();
    final storiesRes = await ApiService.fetchStory();
    setState(() {
      if (postsRes['status'] == true) {
        final list = (postsRes['data']?['postList'] as List? ?? []);
        posts = list.map((p) => AppPost.fromJson(p)).toList();
      }
      if (storiesRes['status'] == true) {
        final list = (storiesRes['data'] as List? ?? []);
        storyGroups = list.map((s) => AppStoryGroup.fromJson(s)).toList();
      }
      isLoading = false;
    });
    try {
      final liveData = await sb.Supabase.instance.client.from('live_streams').select('creator_id').eq('status', 'live');
      final creatorIds = (liveData as List).map((l) => l['creator_id']).toList();
      if (creatorIds.isNotEmpty) {
        final profiles = await sb.Supabase.instance.client.from('app_profiles').select('numeric_id').inFilter('id', creatorIds);
        if (mounted) setState(() { liveUserNumericIds = (profiles as List).map((p) => p['numeric_id']).toSet(); });
      }
    } catch (e) {}
  }

  Future<void> _toggleSave(AppPost post) async {
    final wasSaved = savedPosts.contains(post.id);
    setState(() { wasSaved ? savedPosts.remove(post.id) : savedPosts.add(post.id); });
    final res = wasSaved ? await ApiService.unSavePost(post.id) : await ApiService.savePost(post.id);
    if (res['status'] != true) setState(() { wasSaved ? savedPosts.add(post.id) : savedPosts.remove(post.id); });
  }

  void _openComments(AppPost post) {
    showModalBottomSheet(
      context: context, isScrollControlled: true, backgroundColor: Colors.transparent,
      builder: (context) => CommentsSheet(postId: post.id, onCommentAdded: (n) => setState(() => commentCounts[post.id] = n)),
    );
  }

  Future<void> _toggleLike(AppPost post) async {
    final wasLiked = likedPosts.contains(post.id);
    setState(() {
      wasLiked ? likedPosts.remove(post.id) : likedPosts.add(post.id);
      likeCounts[post.id] = (likeCounts[post.id] ?? post.likes) + (wasLiked ? -1 : 1);
    });
    final res = wasLiked ? await ApiService.disLikePost(post.id) : await ApiService.likePost(post.id);
    if (res['status'] != true) {
      setState(() {
        wasLiked ? likedPosts.add(post.id) : likedPosts.remove(post.id);
        likeCounts[post.id] = (likeCounts[post.id] ?? post.likes) + (wasLiked ? 1 : -1);
      });
    }
  }

  Future<void> _uploadStory() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery, imageQuality: 70);
    if (picked == null) return;
    final firebaseUser = FirebaseAuth.instance.currentUser;
    if (firebaseUser == null) return;
    setState(() => isUploadingStory = true);
    try {
      final file = File(picked.path);
      final ext = picked.path.split('.').last.toLowerCase();
      final fileName = '${firebaseUser.uid}/story_${DateTime.now().millisecondsSinceEpoch}.$ext';
      await sb.Supabase.instance.client.storage.from('thumbnails').upload(fileName, file, fileOptions: const sb.FileOptions(upsert: true));
      final url = sb.Supabase.instance.client.storage.from('thumbnails').getPublicUrl(fileName);
      final res = await ApiService.createStory(contentUrl: url, thumbnailUrl: url, type: 0, duration: 5);
      if (res['status'] == true) await _loadData();
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    } finally {
      setState(() => isUploadingStory = false);
    }
  }

  void _sharePost(AppPost post) {
    SharePlus.instance.share(ShareParams(text: 'Check out this post by @${post.user?.username ?? 'someone'} on KingdomShift.Live!\nhttps://kingdomshift.live/post/${post.id}'));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: KSTheme.bgDark,
      appBar: AppBar(
        backgroundColor: KSTheme.bgDark,
        elevation: 0,
        titleSpacing: 16,
        title: Row(
          children: [
            Container(
              width: 38, height: 38,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: KSTheme.tealGradient,
                border: Border.all(color: KSTheme.gold, width: 1.5),
              ),
              child: const Center(child: Text('KS', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13))),
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('KingdomShift', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: -0.3)),
                Text('MEDIA', style: TextStyle(color: KSTheme.teal, fontSize: 10, fontWeight: FontWeight.w600, letterSpacing: 2)),
              ],
            ),
          ],
        ),
        actions: [
          IconButton(icon: const Icon(Icons.search, color: Colors.white, size: 22), onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SearchScreen()))),
          IconButton(icon: const Icon(Icons.notifications_outlined, color: Colors.white, size: 22), onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const NotificationsScreen()))),
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: GestureDetector(
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ProfileScreen())),
              child: const CircleAvatar(radius: 16, backgroundColor: KSTheme.bgCardLight, child: Icon(Icons.person, color: Colors.white, size: 18)),
            ),
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: KSTheme.teal,
          indicatorWeight: 2,
          labelColor: KSTheme.teal,
          unselectedLabelColor: KSTheme.textSecondary,
          labelStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
          isScrollable: true,
          tabs: const [
            Tab(text: 'For You'),
            Tab(text: 'Following'),
            Tab(text: 'Kingdom'),
            Tab(text: 'Ministries'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildFeedTab(posts, _loadData),
          _buildFollowingTab(),
          _buildFeedTab(posts, _loadData), // placeholder
          _buildFeedTab(posts, _loadData), // placeholder
        ],
      ),
    );
  }

  Widget _buildFeedTab(List<AppPost> feedPosts, Future<void> Function() onRefresh) {
    return RefreshIndicator(
      onRefresh: onRefresh,
      color: KSTheme.teal,
      child: isLoading
          ? const Center(child: CircularProgressIndicator(color: KSTheme.teal))
          : ListView(
              children: [
                _buildStoriesRow(),
                const Divider(color: KSTheme.divider, height: 1),
                ...feedPosts.map((post) => _buildPostCard(post)),
                _buildEndOfFeedFooter(),
              ],
            ),
    );
  }

  Widget _buildFollowingTab() {
    return RefreshIndicator(
      onRefresh: _loadFollowing,
      color: KSTheme.teal,
      child: !followingLoaded
          ? const Center(child: CircularProgressIndicator(color: KSTheme.teal))
          : followingPosts.isEmpty
              ? const Center(child: Text('No posts from people you follow yet', style: TextStyle(color: KSTheme.textSecondary)))
              : ListView(children: [...followingPosts.map((post) => _buildPostCard(post)), _buildEndOfFeedFooter()]),
    );
  }

  Widget _buildStoriesRow() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Stories', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
              Text('See All >', style: TextStyle(color: KSTheme.teal, fontSize: 13, fontWeight: FontWeight.w600)),
            ],
          ),
        ),
        SizedBox(
          height: 100,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            children: [
              _buildAddStoryItem(),
              ...storyGroups.asMap().entries.map((entry) => _buildStoryItem(entry.value, entry.key)),
            ],
          ),
        ),
        const SizedBox(height: 8),
      ],
    );
  }

  Widget _buildAddStoryItem() {
    return GestureDetector(
      onTap: isUploadingStory ? null : _uploadStory,
      child: Padding(
        padding: const EdgeInsets.only(right: 12),
        child: Column(
          children: [
            Container(
              width: 64, height: 64,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: KSTheme.bgCard,
                border: Border.all(color: KSTheme.teal, width: 2),
              ),
              child: isUploadingStory
                  ? const Padding(padding: EdgeInsets.all(18), child: CircularProgressIndicator(strokeWidth: 2, color: KSTheme.teal))
                  : Stack(alignment: Alignment.center, children: [
                      const Icon(Icons.person, color: KSTheme.textSecondary, size: 28),
                      Positioned(bottom: 2, right: 2, child: Container(
                        width: 20, height: 20,
                        decoration: const BoxDecoration(color: KSTheme.teal, shape: BoxShape.circle),
                        child: const Icon(Icons.add, color: Colors.white, size: 14),
                      )),
                    ]),
            ),
            const SizedBox(height: 4),
            const Text('Your Story', style: TextStyle(color: Colors.white, fontSize: 10), overflow: TextOverflow.ellipsis),
          ],
        ),
      ),
    );
  }

  Widget _buildStoryItem(AppStoryGroup group, int idx) {
    final isLive = liveUserNumericIds.contains(group.id);
    final ringColors = [
      [const Color(0xFF00C9C8), const Color(0xFF0095A8)],
      [const Color(0xFFC9A227), const Color(0xFFE8C547)],
      [const Color(0xFF9B59B6), const Color(0xFF6C3483)],
      [const Color(0xFFFF2D9B), const Color(0xFFFF6B9D)],
    ];
    final colors = isLive ? [KSTheme.teal, const Color(0xFF0095A8)] : ringColors[idx % ringColors.length];
    return GestureDetector(
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => StoryViewerScreen(storyGroups: storyGroups, initialGroupIndex: idx))),
      child: Padding(
        padding: const EdgeInsets.only(right: 10),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(2.5),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(colors: colors),
              ),
              child: Container(
                padding: const EdgeInsets.all(2),
                decoration: const BoxDecoration(shape: BoxShape.circle, color: KSTheme.bgDark),
                child: CircleAvatar(
                  radius: 30,
                  backgroundColor: KSTheme.bgCard,
                  backgroundImage: group.profilePhoto.isNotEmpty ? CachedNetworkImageProvider(group.profilePhoto) : null,
                  child: group.profilePhoto.isEmpty ? Text(group.fullname.isNotEmpty ? group.fullname[0] : '?', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)) : null,
                ),
              ),
            ),
            const SizedBox(height: 4),
            SizedBox(width: 68, child: Text(group.username, style: const TextStyle(color: Colors.white, fontSize: 10), overflow: TextOverflow.ellipsis, textAlign: TextAlign.center)),
            if (isLive)
              Container(
                margin: const EdgeInsets.only(top: 2),
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                decoration: BoxDecoration(color: KSTheme.teal, borderRadius: BorderRadius.circular(6)),
                child: const Text('LIVE', style: TextStyle(color: Colors.white, fontSize: 8, fontWeight: FontWeight.bold)),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildPostCard(AppPost post) {
    return Container(
      margin: const EdgeInsets.only(bottom: 1),
      color: KSTheme.bgDark,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 8),
            child: Row(
              children: [
                GestureDetector(
                  onTap: () { if (post.user != null) Navigator.push(context, MaterialPageRoute(builder: (_) => ProfileScreen(userId: post.user!.id))); },
                  child: Container(
                    decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: KSTheme.teal, width: 1.5)),
                    child: CircleAvatar(
                      radius: 20,
                      backgroundColor: KSTheme.bgCard,
                      backgroundImage: post.user?.profilePhoto.isNotEmpty == true ? CachedNetworkImageProvider(post.user!.profilePhoto) : null,
                      child: post.user?.profilePhoto.isEmpty != false ? Text(post.user?.fullname.isNotEmpty == true ? post.user!.fullname[0] : '?', style: const TextStyle(color: Colors.white, fontSize: 12)) : null,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(children: [
                        Text(post.user?.fullname ?? '', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 14)),
                        const SizedBox(width: 4),
                        const Icon(Icons.verified, color: KSTheme.teal, size: 14),
                      ]),
                      Text('@${post.user?.username ?? ''} · 2h', style: const TextStyle(color: KSTheme.textSecondary, fontSize: 12)),
                    ],
                  ),
                ),
                const Icon(Icons.more_horiz, color: KSTheme.textSecondary),
              ],
            ),
          ),
          // Description
          if (post.description.isNotEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 0, 12, 8),
              child: RichText(
                text: TextSpan(
                  children: post.description.split(' ').map((word) => TextSpan(
                    text: '$word ',
                    style: TextStyle(color: word.startsWith('#') ? KSTheme.teal : Colors.white, fontSize: 14),
                  )).toList(),
                ),
              ),
            ),
          // Media
          if (post.video.isNotEmpty)
            ClipRRect(
              borderRadius: BorderRadius.zero,
              child: FeedVideoPlayer(videoUrl: post.video, thumbnailUrl: post.thumbnail),
            )
          else if (post.thumbnail.isNotEmpty)
            CachedNetworkImage(imageUrl: post.thumbnail, width: double.infinity, fit: BoxFit.cover,
              placeholder: (_, __) => Container(height: 200, color: KSTheme.bgCard),
              errorWidget: (_, __, ___) => Container(height: 200, color: KSTheme.bgCard)),
          // Actions
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
            child: Row(
              children: [
                _actionBtn(likedPosts.contains(post.id) ? Icons.favorite : Icons.favorite_border,
                  '${likeCounts[post.id] ?? post.likes}', likedPosts.contains(post.id) ? Colors.red : Colors.white,
                  () => _toggleLike(post)),
                const SizedBox(width: 20),
                _actionBtn(Icons.chat_bubble_outline, '${commentCounts[post.id] ?? post.comments}', Colors.white, () => _openComments(post)),
                const SizedBox(width: 20),
                _actionBtn(Icons.repeat_rounded, '32', Colors.white, () {}),
                const Spacer(),
                GestureDetector(onTap: () => _toggleSave(post), child: Icon(
                  savedPosts.contains(post.id) ? Icons.bookmark : Icons.bookmark_border,
                  color: savedPosts.contains(post.id) ? KSTheme.teal : Colors.white, size: 22)),
                const SizedBox(width: 16),
                GestureDetector(onTap: () => _sharePost(post), child: const Icon(Icons.ios_share, color: Colors.white, size: 20)),
              ],
            ),
          ),
          const Divider(color: KSTheme.divider, height: 1),
        ],
      ),
    );
  }

  Widget _actionBtn(IconData icon, String count, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Row(children: [
        Icon(icon, color: color, size: 22),
        const SizedBox(width: 4),
        Text(count, style: const TextStyle(color: Colors.white, fontSize: 13)),
      ]),
    );
  }

  Widget _buildEndOfFeedFooter() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 32),
      child: Column(children: [
        const Icon(Icons.check_circle_outline, color: KSTheme.textSecondary, size: 28),
        const SizedBox(height: 8),
        const Text("You're all caught up!", style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold)),
        const SizedBox(height: 4),
        const Text("You've seen all new posts", style: TextStyle(color: KSTheme.textSecondary, fontSize: 12)),
      ]),
    );
  }
}
