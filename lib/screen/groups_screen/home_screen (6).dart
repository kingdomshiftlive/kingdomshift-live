import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:share_plus/share_plus.dart';
import 'package:video_player/video_player.dart';
import '../../common/services/auth_service.dart';
import '../../common/services/post_service.dart';
import '../../common/services/user_service.dart';
import '../../common/widgets/ks_avatar.dart';
import '../../models/post_model.dart';
import '../../utils/colors.dart';
import '../profile/other_profile_screen.dart';
import 'comments_sheet.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with AutomaticKeepAliveClientMixin {
  final PageController _pageController = PageController();
  List<KPost> _posts = [];
  bool _loading = true;
  int _currentIndex = 0;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _loadPosts();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _loadPosts({bool refresh = false}) async {
    if (!refresh && _posts.isNotEmpty) return;
    setState(() => _loading = true);
    final posts = await PostService.to.fetchFeedPosts(page: 1, type: 'reel');
    setState(() { _posts = posts; _loading = false; });
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
      backgroundColor: KColors.background,
      extendBodyBehindAppBar: false,
      appBar: AppBar(
        backgroundColor: KColors.background,
        elevation: 0,
        titleSpacing: 0,
        title: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(children: [
            Image.asset('assets/images/ks_logo.png', width: 32, height: 32),
            const SizedBox(width: 8),
            RichText(text: const TextSpan(children: [
              TextSpan(text: 'Kingdom', style: TextStyle(color: KColors.blue, fontSize: 16, fontWeight: FontWeight.bold)),
              TextSpan(text: 'Shift', style: TextStyle(color: KColors.gold, fontSize: 16, fontWeight: FontWeight.bold)),
              TextSpan(text: '.Live', style: TextStyle(color: KColors.white, fontSize: 16, fontWeight: FontWeight.bold)),
            ])),
          ]),
        ),
        actions: [
          IconButton(icon: const Icon(Icons.search, color: KColors.white), onPressed: () {}),
          IconButton(icon: const Icon(Icons.notifications_none, color: KColors.white), onPressed: () {}),
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: KSAvatar(url: AuthService.to.currentUser.value?.avatarUrl, size: 30, fallbackText: AuthService.to.currentUser.value?.username),
          ),
        ],
      ),
      body: Column(children: [
        _TabBar(),
        _StoriesRow(),
        // Feed
        Expanded(
          child: _loading
              ? const Center(child: CircularProgressIndicator(color: KColors.gold))
              : _posts.isEmpty
                  ? _EmptyFeed(onRefresh: () => _loadPosts(refresh: true))
                  : PageView.builder(
                      controller: _pageController,
                      scrollDirection: Axis.vertical,
                      itemCount: _posts.length + 1,
                      onPageChanged: (i) => setState(() => _currentIndex = i),
                      itemBuilder: (context, i) {
                        if (i == _posts.length) {
                          return _AllCaughtUp(onRefresh: () {
                            _pageController.animateToPage(0,
                              duration: const Duration(milliseconds: 500), curve: Curves.easeOut);
                          });
                        }
                        return _ReelCard(post: _posts[i], isActive: i == _currentIndex);
                      },
                    ),
        ),
      ]),
    );
  }
}

class _TabBar extends StatefulWidget {
  @override
  State<_TabBar> createState() => _TabBarState();
}

class _TabBarState extends State<_TabBar> {
  int _selected = 0;
  final _tabs = ['For You', 'Following', 'Live  ', 'Grow', 'Ministries'];

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Color(0xFF112248), width: 0.5)),
      ),
      height: 44,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        itemCount: _tabs.length,
        itemBuilder: (_, i) {
          final isActive = _selected == i;
          final colors = [
            const Color(0xFF1A6BFF),  // For You - blue
            const Color(0xFF00D4C8),  // Following - aqua
            Colors.red,               // Live - red
            const Color(0xFFC9A84C),  // Grow - gold
            const Color(0xFFFF1493),  // Ministries - pink
          ];
          return GestureDetector(
            onTap: () {
              setState(() => _selected = i);
              if (i == 3) Get.snackbar('Grow', 'KingdomAI Command Center   Coming Soon!',
                backgroundColor: const Color(0xFF0D1B3E), colorText: const Color(0xFFC9A84C),
                snackPosition: SnackPosition.BOTTOM);
              if (i == 4) Get.snackbar('Ministries', 'Coming Soon!',
                backgroundColor: const Color(0xFF0D1B3E), colorText: const Color(0xFFFF1493),
                snackPosition: SnackPosition.BOTTOM);
            },
            child: Container(
              margin: const EdgeInsets.only(right: 4),
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                border: Border(bottom: BorderSide(
                  color: isActive ? colors[i] : Colors.transparent,
                  width: 2.5,
                )),
              ),
              child: Center(
                child: Row(mainAxisSize: MainAxisSize.min, children: [
                  Text(_tabs[i].replaceAll('  ', ''), style: TextStyle(
                    color: isActive ? colors[i] : KColors.greyText,
                    fontSize: 13,
                    fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
                  )),
                  if (i == 2) ...[
                    const SizedBox(width: 4),
                    Container(width: 6, height: 6, decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle)),
                  ],
                ]),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _StoriesRow extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final user = AuthService.to.currentUser.value;
    return SizedBox(
      height: 105,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        children: [
          // Your story
          Column(children: [
            Stack(children: [
              KSAvatar(url: user?.avatarUrl, size: 56, fallbackText: user?.username),
              Positioned(bottom: 0, right: 0, child: Container(
                width: 20, height: 20,
                decoration: BoxDecoration(color: KColors.gold, shape: BoxShape.circle, border: Border.all(color: KColors.background, width: 2)),
                child: const Icon(Icons.add, color: KColors.white, size: 12),
              )),
            ]),
            const SizedBox(height: 4),
            const Text('Your Story', style: TextStyle(color: KColors.greyText, fontSize: 10)),
          ]),
          const SizedBox(width: 12),
          // Placeholder stories
          ...[
            ('charorcino', null, true),
            ('faithbuilder', null, false),
            ('prayerroom', null, true),
            ('kingdomshift', null, true),
          ].map((s) => Padding(
            padding: const EdgeInsets.only(right: 12),
            child: Column(children: [
              Container(
                padding: const EdgeInsets.all(2.5),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: s.$3
                      ? const LinearGradient(
                          colors: [Color(0xFFC9A84C), Color(0xFFFF1493), Color(0xFF00D4C8)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        )
                      : const LinearGradient(colors: [Color(0xFF3A4A6B), Color(0xFF3A4A6B)]),
                ),
                child: Container(
                  padding: const EdgeInsets.all(2),
                  decoration: const BoxDecoration(color: Color(0xFF050A18), shape: BoxShape.circle),
                  child: KSAvatar(url: null, size: 52, fallbackText: s.$1),
                ),
              ),
              const SizedBox(height: 4),
              Text(s.$1.length > 8 ? '${s.$1.substring(0, 8)}...' : s.$1,
                style: const TextStyle(color: KColors.greyText, fontSize: 10)),
            ]),
          )),
        ],
      ),
    );
  }
}

class _EmptyFeed extends StatelessWidget {
  final VoidCallback onRefresh;
  const _EmptyFeed({required this.onRefresh});
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        const Icon(Icons.play_circle_outline, color: KColors.greyText, size: 60),
        const SizedBox(height: 16),
        const Text('No Reels Yet', style: TextStyle(color: KColors.white, fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        const Text('Be the first to post!', style: TextStyle(color: KColors.greyText)),
        const SizedBox(height: 24),
        TextButton(onPressed: onRefresh, child: const Text('Refresh', style: TextStyle(color: KColors.gold))),
      ]),
    );
  }
}

class _AllCaughtUp extends StatelessWidget {
  final VoidCallback onRefresh;
  const _AllCaughtUp({required this.onRefresh});
  @override
  Widget build(BuildContext context) {
    return Container(
      color: KColors.background,
      child: Center(
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(color: KColors.gold.withOpacity(0.1), shape: BoxShape.circle),
            child: const Icon(Icons.check_circle_rounded, size: 80, color: KColors.gold),
          ),
          const SizedBox(height: 30),
          const Text("You're all caught up", style: TextStyle(color: KColors.white, fontSize: 24, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          const Text("You've seen all the latest reels.", style: TextStyle(color: KColors.greyText)),
          const SizedBox(height: 40),
          GestureDetector(
            onTap: onRefresh,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 14),
              decoration: BoxDecoration(color: KColors.gold, borderRadius: BorderRadius.circular(30)),
              child: const Text('Back to Top', style: TextStyle(color: KColors.white, fontWeight: FontWeight.bold)),
            ),
          ),
        ]),
      ),
    );
  }
}

class _ReelCard extends StatefulWidget {
  final KPost post;
  final bool isActive;
  const _ReelCard({required this.post, required this.isActive});
  @override
  State<_ReelCard> createState() => _ReelCardState();
}

class _ReelCardState extends State<_ReelCard> {
  VideoPlayerController? _controller;
  bool _liked = false;
  int _likes = 0;
  int _comments = 0;
  int _shareCount = 0;

  @override
  void initState() {
    super.initState();
    _liked = widget.post.isLiked;
    _likes = widget.post.likes;
    _comments = widget.post.comments;
    _initVideo();
  }

  void _initVideo() {
    if (widget.post.video == null) return;
    _controller = VideoPlayerController.networkUrl(Uri.parse(widget.post.video!))
      ..initialize().then((_) {
        setState(() {});
        if (widget.isActive) { _controller?.play(); _controller?.setLooping(true); }
      });
  }

  @override
  void didUpdateWidget(_ReelCard old) {
    super.didUpdateWidget(old);
    if (widget.isActive && !old.isActive) _controller?.play();
    else if (!widget.isActive && old.isActive) _controller?.pause();
  }

  @override
  void dispose() { _controller?.dispose(); super.dispose(); }

  void _toggleLike() async {
    final newLiked = !_liked;
    setState(() { _liked = newLiked; _likes += newLiked ? 1 : -1; });
    await PostService.to.toggleLike(widget.post.id, !newLiked);
  }

  void _openComments() async {
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: KColors.background,
      builder: (_) => CommentsSheet(postId: widget.post.id),
    );
    final fresh = await PostService.to.fetchComments(widget.post.id);
    setState(() => _comments = fresh.length);
  }

  void _share() async {
    Share.share('Check out this video on KingdomShift.Live!');
    setState(() => _shareCount++);
    await PostService.to.incrementShare(widget.post.id);
  }

  @override
  Widget build(BuildContext context) {
    return Stack(fit: StackFit.expand, children: [
      // Video
      if (_controller != null && _controller!.value.isInitialized)
        GestureDetector(
          onTap: () {
            if (_controller!.value.isPlaying) _controller!.pause();
            else _controller!.play();
            setState(() {});
          },
          child: FittedBox(fit: BoxFit.cover, child: SizedBox(
            width: _controller!.value.size.width,
            height: _controller!.value.size.height,
            child: VideoPlayer(_controller!),
          )),
        )
      else if (widget.post.thumbnail != null)
        Image.network(widget.post.thumbnail!, fit: BoxFit.cover)
      else
        Container(color: KColors.background),

      // Gradient overlay
      const DecoratedBox(decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter, end: Alignment.bottomCenter,
          colors: [Colors.transparent, Colors.transparent, Colors.black87],
          stops: [0, 0.5, 1],
        ),
      )),

      // Right actions
      Positioned(
        right: 12, bottom: 20,
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          _ActionBtn(icon: Icons.favorite, label: '$_likes', color: _liked ? Colors.red : KColors.white, onTap: _toggleLike),
          const SizedBox(height: 10),
          _ActionBtn(icon: Icons.chat_bubble_outline, label: '$_comments', onTap: _openComments),
          const SizedBox(height: 10),
          _ActionBtn(icon: Icons.share_outlined, label: '$_shareCount', onTap: _share),
          const SizedBox(height: 10),
          _ActionBtn(icon: Icons.bookmark_border, label: 'Save', color: const Color(0xFF00D4C8), onTap: () {}),
          const SizedBox(height: 10),
          _ActionBtn(icon: Icons.volunteer_activism, label: 'Prayer', color: const Color(0xFFFF1493), onTap: () {
            Get.snackbar('Prayer', 'Praying with you!', backgroundColor: KColors.surface, colorText: KColors.white, snackPosition: SnackPosition.TOP);
          }),
          const SizedBox(height: 10),
          GestureDetector(
            onTap: () => Get.to(() => OtherProfileScreen(userId: widget.post.userId)),
            child: Container(
              decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: KColors.gold, width: 2)),
              child: KSAvatar(url: widget.post.user?.avatarUrl, size: 40, fallbackText: widget.post.user?.username),
            ),
          ),
          const SizedBox(height: 2),
          _FollowButton(userId: widget.post.userId),
        ]),
      ),

      // Bottom info
      Positioned(
        left: 16, right: 80, bottom: 40,
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Text('@${widget.post.user?.username ?? 'user'}',
              style: const TextStyle(color: KColors.white, fontWeight: FontWeight.bold, fontSize: 15,
                shadows: [Shadow(color: Colors.black54, blurRadius: 4)])),
            if (widget.post.user?.isVerified == true) ...[
              const SizedBox(width: 4),
              const Icon(Icons.verified, color: KColors.blue, size: 14),
            ],
          ]),
          if (widget.post.description != null) ...[
            const SizedBox(height: 6),
            Text(widget.post.description!,
              style: const TextStyle(color: KColors.white, fontSize: 13,
                shadows: [Shadow(color: Colors.black54, blurRadius: 4)]),
              maxLines: 2, overflow: TextOverflow.ellipsis),
          ],
          if (widget.post.hashtags != null) ...[
            const SizedBox(height: 4),
            Text(widget.post.hashtags!,
              style: const TextStyle(color: KColors.blue, fontSize: 12,
                shadows: [Shadow(color: Colors.black54, blurRadius: 4)]),
              maxLines: 1, overflow: TextOverflow.ellipsis),
          ],
        ]),
      ),
    ]);
  }
}

class _ActionBtn extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color color;
  const _ActionBtn({required this.icon, required this.label, required this.onTap, this.color = KColors.white});
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(children: [
        Container(
          width: 42, height: 42,
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.4),
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white.withOpacity(0.15), width: 0.5),
          ),
          child: Icon(icon, color: color, size: 20, shadows: const [Shadow(color: Colors.black87, blurRadius: 4)]),
        ),
        const SizedBox(height: 4),
        Text(label, style: const TextStyle(color: KColors.white, fontSize: 11, fontWeight: FontWeight.w500,
          shadows: [Shadow(color: Colors.black87, blurRadius: 4)])),
      ]),
    );
  }
}

class _FollowButton extends StatefulWidget {
  final String userId;
  const _FollowButton({required this.userId});
  @override
  State<_FollowButton> createState() => _FollowButtonState();
}

class _FollowButtonState extends State<_FollowButton> {
  bool _isFollowing = false;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _checkFollow();
  }

  Future<void> _checkFollow() async {
    final following = await UserService.to.isFollowing(widget.userId);
    if (mounted) setState(() { _isFollowing = following; _loading = false; });
  }

  Future<void> _toggleFollow() async {
    if (_loading) return;
    final newState = !_isFollowing;
    setState(() => _isFollowing = newState);
    if (newState) {
      await UserService.to.followUser(widget.userId);
    } else {
      await UserService.to.unfollowUser(widget.userId);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return const SizedBox(height: 18);
    return GestureDetector(
      onTap: _toggleFollow,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
        decoration: BoxDecoration(
          color: _isFollowing ? KColors.surface : KColors.gold,
          borderRadius: BorderRadius.circular(10),
          border: _isFollowing ? Border.all(color: KColors.gold, width: 1) : null,
        ),
        child: Text(
          _isFollowing ? 'Following' : 'Follow',
          style: TextStyle(
            color: _isFollowing ? KColors.gold : KColors.white,
            fontSize: 8,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
