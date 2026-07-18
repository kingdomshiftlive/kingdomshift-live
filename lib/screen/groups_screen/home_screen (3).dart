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
import '../grow/grow_screen.dart';
import '../following/following_screen.dart';
import '../ministries/ministries_screen.dart';
import '../live/live_list_screen.dart';
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

  // Tabs: Creator Network, Following, Live, Grow, Ministries, Shop
  final List<String> _tabs = ['Creator Network', 'Following', 'Live', 'Grow', 'Ministries', 'Shop'];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _tabs.length, vsync: this);
    _tabController.addListener(() {
      final i = _tabController.index;
      if (i == 1) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _tabController.animateTo(0);
          Navigator.push(context, MaterialPageRoute(builder: (_) => const FollowingScreen()));
        });
      } else if (i == 2) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _tabController.animateTo(0);
          Navigator.push(context, MaterialPageRoute(builder: (_) => const LiveListScreen()));
        });
      } else if (i == 3) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _tabController.animateTo(0);
          Navigator.push(context, MaterialPageRoute(builder: (_) => const GrowScreen()));
        });
      } else if (i == 4) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _tabController.animateTo(0);
          Navigator.push(context, MaterialPageRoute(builder: (_) => const MinistriesScreen()));
        });
      } else if (i == 5) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _tabController.animateTo(0);
          Navigator.push(context, MaterialPageRoute(builder: (_) => const AuthorityShopScreen()));
        });
      }
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
          child: Column(mainAxisSize: MainAxisSize.min, children: [
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
            SizedBox(width: double.infinity, child: ElevatedButton(
              onPressed: () { Navigator.pop(context); _breakTimer = Timer(const Duration(minutes: 30), _showBreakReminder); },
              style: KSTheme.tealButton,
              child: const Text('Continue Scrolling'),
            )),
          ]),
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
        title: Row(children: [
          ClipOval(child: Image.asset('assets/images/ks_logo.png', width: 40, height: 40, fit: BoxFit.cover)),
          const SizedBox(width: 10),
          const Text('KingdomShift', style: TextStyle(color: KSTheme.gold, fontSize: 16, fontWeight: FontWeight.bold)),
          const Text('.Live', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
        ]),
        actions: [
          IconButton(icon: const Icon(Icons.search, color: Colors.white, size: 22), onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SearchScreen()))),
          Stack(children: [
            IconButton(icon: const Icon(Icons.notifications_outlined, color: Colors.white, size: 22), onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const NotificationsScreen()))),
            Positioned(top: 8, right: 8, child: Container(width: 8, height: 8, decoration: const BoxDecoration(color: KSTheme.teal, shape: BoxShape.circle))),
          ]),
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
          tabs: _tabs.asMap().entries.map((e) {
            // Add red dot to Live tab
            if (e.key == 2) {
              return Tab(child: Row(mainAxisSize: MainAxisSize.min, children: [
                const Text('Live'),
                const SizedBox(width: 4),
                Container(width: 7, height: 7, decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle)),
              ]));
            }
            return Tab(text: e.value);
          }).toList(),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: List.generate(_tabs.length, (i) => _buildFeedTab(posts, _loadData)),
      ),
    );
  }

  Widget _buildFeedTab(List<AppPost> feedPosts, Future<void> Function() onRefresh) {
    return RefreshIndicator(
      onRefresh: onRefresh,
      color: KSTheme.teal,
      child: isLoading
          ? const Center(child: CircularProgressIndicator(color: KSTheme.teal))
          : ListView(children: [
              _buildStoriesRow(),
              const Divider(color: KSTheme.divider, height: 1),
              ...feedPosts.map((post) => _buildPostCard(post)),
              _buildEndOfFeedFooter(),
            ]),
    );
  }

  Widget _buildStoriesRow() {
    return SizedBox(
      height: 110,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        children: [
          _buildAddStoryItem(),
          ...storyGroups.asMap().entries.map((entry) => _buildStoryItem(entry.value, entry.key)),
        ],
      ),
    );
  }

  Widget _buildAddStoryItem() {
    return GestureDetector(
      onTap: isUploadingStory ? null : _uploadStory,
      child: Padding(
        padding: const EdgeInsets.only(right: 12),
        child: Column(children: [
          Container(
            width: 64, height: 64,
            decoration: BoxDecoration(shape: BoxShape.circle, color: KSTheme.bgCard, border: Border.all(color: KSTheme.teal, width: 2)),
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
        ]),
      ),
    );
  }

  Widget _buildStoryItem(AppStoryGroup group, int idx) {
    final isLive = liveUserNumericIds.contains(group.id);
    return GestureDetector(
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => StoryViewerScreen(storyGroups: storyGroups, initialGroupIndex: idx))),
      child: Padding(
        padding: const EdgeInsets.only(right: 12),
        child: Column(children: [
          Stack(children: [
            Container(
              padding: const EdgeInsets.all(2),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: isLive ? KSTheme.tealGradient : KSTheme.goldGradient,
              ),
              child: Container(
                padding: const EdgeInsets.all(2),
                decoration: const BoxDecoration(shape: BoxShape.circle, color: KSTheme.bgDark),
                child: CircleAvatar(
                  radius: 28,
                  backgroundColor: KSTheme.bgCard,
                  backgroundImage: group.profilePhoto.isNotEmpty ? CachedNetworkImageProvider(group.profilePhoto) : null,
                  child: group.profilePhoto.isEmpty ? Text(group.fullname.isNotEmpty ? group.fullname[0] : '?', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)) : null,
                ),
              ),
            ),
            if (isLive)
              Positioned(bottom: 0, left: 0, right: 0, child: Center(child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                decoration: BoxDecoration(color: Colors.red, borderRadius: BorderRadius.circular(6)),
                child: const Text('LIVE', style: TextStyle(color: Colors.white, fontSize: 8, fontWeight: FontWeight.bold)),
              ))),
          ]),
          const SizedBox(height: 4),
          SizedBox(width: 64, child: Text(group.username, style: const TextStyle(color: Colors.white, fontSize: 10), overflow: TextOverflow.ellipsis, textAlign: TextAlign.center)),
        ]),
      ),
    );
  }

  Widget _buildPostCard(AppPost post) {
    final isLiked = likedPosts.contains(post.id);
    final isSaved = savedPosts.contains(post.id);
    final likeCount = likeCounts[post.id] ?? post.likes;
    final commentCount = commentCounts[post.id] ?? post.comments;

    return Container(
      margin: const EdgeInsets.only(bottom: 1),
      color: KSTheme.bgDark,
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        // ── Header ──────────────────────────────────────────────────
        Padding(
          padding: const EdgeInsets.fromLTRB(12, 12, 12, 6),
          child: Row(children: [
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
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                Text(post.user?.fullname ?? '', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 14)),
                const SizedBox(width: 4),
                const Icon(Icons.verified, color: KSTheme.teal, size: 14),
              ]),
              Text('@${post.user?.username ?? ''} · 2h', style: const TextStyle(color: KSTheme.textSecondary, fontSize: 12)),
            ])),
            // Follow button
            GestureDetector(
              onTap: () {},
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
                decoration: BoxDecoration(border: Border.all(color: KSTheme.teal), borderRadius: BorderRadius.circular(20)),
                child: const Text('Follow', style: TextStyle(color: KSTheme.teal, fontSize: 12, fontWeight: FontWeight.w600)),
              ),
            ),
            const SizedBox(width: 8),
            const Icon(Icons.more_horiz, color: KSTheme.textSecondary),
          ]),
        ),

        // ── Tags ────────────────────────────────────────────────────
        if (post.description.isNotEmpty)
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 0, 12, 6),
            child: Wrap(spacing: 6, children: [
              _tag('✝ Faith', KSTheme.teal),
              _tag('❤ Inspiration', Colors.red),
              _tag('👑 Testimony', KSTheme.gold),
            ]),
          ),

        // ── Media + right side buttons ───────────────────────────────
        Stack(children: [
          // Media
          if (post.video.isNotEmpty)
            FeedVideoPlayer(videoUrl: post.video, thumbnailUrl: post.thumbnail)
          else if (post.thumbnail.isNotEmpty)
            CachedNetworkImage(
              imageUrl: post.thumbnail,
              width: double.infinity,
              fit: BoxFit.cover,
              placeholder: (_, __) => Container(height: 300, color: KSTheme.bgCard),
              errorWidget: (_, __, ___) => Container(height: 300, color: KSTheme.bgCard),
            )
          else
            Container(height: 300, color: KSTheme.bgCard),

          // Description overlay bottom left
          if (post.description.isNotEmpty)
            Positioned(
              bottom: 60, left: 12, right: 80,
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.6),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(
                    post.description.length > 60 ? '${post.description.substring(0, 60)}...' : post.description,
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14, height: 1.4),
                  ),
                  if (post.thumbnail.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                      decoration: BoxDecoration(color: KSTheme.bgCard.withOpacity(0.9), borderRadius: BorderRadius.circular(8)),
                      child: Row(children: [
                        const Icon(Icons.shopping_bag_outlined, color: KSTheme.gold, size: 14),
                        const SizedBox(width: 6),
                        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          const Text('KingdomShift Shop', style: TextStyle(color: KSTheme.gold, fontSize: 10, fontWeight: FontWeight.bold)),
                        ])),
                        const Icon(Icons.chevron_right, color: KSTheme.textSecondary, size: 14),
                      ]),
                    ),
                  ],
                ]),
              ),
            ),

          // Right side action buttons
          Positioned(
            right: 8, bottom: 12,
            child: Column(children: [
              // Support (crown)
              _sideBtn('👑', 'Support', () {}),
              const SizedBox(height: 14),
              // Like
              _sideBtnIcon(
                isLiked ? Icons.favorite : Icons.favorite_border,
                '$likeCount',
                isLiked ? Colors.red : Colors.white,
                () => _toggleLike(post),
              ),
              const SizedBox(height: 14),
              // Comments
              _sideBtnIcon(Icons.chat_bubble_outline, '$commentCount', Colors.white, () => _openComments(post)),
              const SizedBox(height: 14),
              // Share
              _sideBtnIcon(Icons.reply, '512', Colors.white, () => _sharePost(post)),
              const SizedBox(height: 14),
              // Shop
              _sideBtnIcon(Icons.shopping_bag_outlined, 'Shop', Colors.white, () {}),
              const SizedBox(height: 14),
              // Gift
              _sideBtnIcon(Icons.card_giftcard_rounded, 'Gift', KSTheme.gold, () {}),
              const SizedBox(height: 14),
              // Save
              _sideBtnIcon(
                isSaved ? Icons.bookmark : Icons.bookmark_outline,
                'Save',
                isSaved ? KSTheme.teal : Colors.white,
                () => _toggleSave(post),
              ),
              const SizedBox(height: 14),
              // Prayer
              _sideBtn('🙏', 'Prayer', () {}),
            ]),
          ),
        ]),

        // ── Post title + bottom actions ────────────────────────────
        Padding(
          padding: const EdgeInsets.fromLTRB(12, 8, 12, 4),
          child: Text(
            post.description.isNotEmpty ? post.description : 'Walking in Purpose: Trusting God\'s Plan 👑',
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
            maxLines: 2, overflow: TextOverflow.ellipsis,
          ),
        ),

        // ── Bottom action bar ────────────────────────────────────
        Padding(
          padding: const EdgeInsets.fromLTRB(12, 4, 12, 12),
          child: Row(children: [
            _actionChip('✝', 'Faith', KSTheme.teal),
            const SizedBox(width: 8),
            _actionChip('❤', '$likeCount', Colors.red),
            const SizedBox(width: 8),
            _actionChip('💬', '$commentCount', Colors.white),
            const SizedBox(width: 8),
            _actionChip('↗', '512', Colors.white),
            const Spacer(),
            const Icon(Icons.more_horiz, color: KSTheme.textSecondary, size: 20),
          ]),
        ),
        const Divider(color: KSTheme.divider, height: 1),
      ]),
    );
  }

  Widget _tag(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(label, style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.w600)),
    );
  }

  Widget _sideBtn(String emoji, String label, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Column(children: [
        Container(
          width: 44, height: 44,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.black.withOpacity(0.5),
            border: Border.all(color: Colors.white.withOpacity(0.2)),
          ),
          child: Center(child: Text(emoji, style: const TextStyle(fontSize: 20))),
        ),
        const SizedBox(height: 3),
        Text(label, style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w500,
          shadows: [Shadow(blurRadius: 4, color: Colors.black87)])),
      ]),
    );
  }

  Widget _sideBtnIcon(IconData icon, String label, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Column(children: [
        Container(
          width: 44, height: 44,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.black.withOpacity(0.5),
            border: Border.all(color: color.withOpacity(0.3)),
          ),
          child: Icon(icon, color: color, size: 22),
        ),
        const SizedBox(height: 3),
        Text(label, style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.w500,
          shadows: const [Shadow(blurRadius: 4, color: Colors.black87)])),
      ]),
    );
  }

  Widget _actionChip(String emoji, String label, Color color) {
    return Row(children: [
      Text(emoji, style: TextStyle(color: color, fontSize: 13)),
      const SizedBox(width: 3),
      Text(label, style: TextStyle(color: color, fontSize: 13, fontWeight: FontWeight.w500)),
    ]);
  }

  Widget _buildEndOfFeedFooter() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 32),
      child: Column(children: [
        const Icon(Icons.check_circle_outline, color: KSTheme.textSecondary, size: 28),
        const SizedBox(height: 8),
        const Text("You're all caught up!", style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold)),
        const SizedBox(height: 4),
        const Text("You've seen all new posts from your Creator Network", style: TextStyle(color: KSTheme.textSecondary, fontSize: 12)),
      ]),
    );
  }
}
