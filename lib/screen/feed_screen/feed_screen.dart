import 'package:flutter/material.dart';

// ─── Brand Colors ───────────────────────────────────────────────
const kBgPrimary = Color(0xFF08141F);
const kBgSecondary = Color(0xFF0A1A2A);
const kCardBg = Color(0xFF0D2035);
const kTeal = Color(0xFF005574);
const kAqua = Color(0xFF005574);
const kBlue = Color(0xFF2D7FF9);
const kGold = Color(0xFFD4AF37);
const kGoldAccent = Color(0xFFB8960C);
const kPink = Color(0xFFFF4FA3);
const kLivePink = Color(0xFFFF2D8D);
const kTextPrimary = Color(0xFFFFFFFF);
const kTextSecondary = Color(0xFFA7B7CC);

// ─── Reusable Teal Active Tab Indicator ─────────────────────────
class KSTabs extends StatefulWidget {
  final List<String> tabs;
  final int initialIndex;
  final ValueChanged<int>? onChanged;
  final bool usePill;
  const KSTabs(
      {super.key,
      required this.tabs,
      this.initialIndex = 0,
      this.onChanged,
      this.usePill = false});
  @override
  State<KSTabs> createState() => _KSTabsState();
}

class _KSTabsState extends State<KSTabs> {
  late int _selected;
  @override
  void initState() {
    super.initState();
    _selected = widget.initialIndex;
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 42,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        itemCount: widget.tabs.length,
        itemBuilder: (_, i) {
          final isActive = _selected == i;
          return GestureDetector(
            onTap: () {
              setState(() => _selected = i);
              widget.onChanged?.call(i);
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: const EdgeInsets.only(right: 6, top: 6, bottom: 6),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              decoration: BoxDecoration(
                color: isActive
                    ? kTeal.withValues(alpha: 0.15)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isActive ? kTeal : Colors.transparent,
                  width: 1.5,
                ),
                boxShadow: isActive
                    ? [
                        BoxShadow(
                            color: kTeal.withValues(alpha: 0.3),
                            blurRadius: 8,
                            spreadRadius: 1)
                      ]
                    : [],
              ),
              child: Text(widget.tabs[i],
                  style: TextStyle(
                    color: isActive ? kTeal : kTextSecondary,
                    fontSize: 13,
                    fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
                  )),
            ),
          );
        },
      ),
    );
  }
}

// ─── Feed Screen ────────────────────────────────────────────────
class FeedScreen extends StatefulWidget {
  final dynamic myUser;
  const FeedScreen({super.key, this.myUser});
  @override
  State<FeedScreen> createState() => _FeedScreenState();
}

class _FeedScreenState extends State<FeedScreen> {
  final _navTabs = ['Feed', 'Following', 'Live', 'Groups', 'Marketplace'];
  final _filterTabs = ['For You', 'Trending', 'New', 'Saved', 'All Topics'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBgPrimary,
      body: SafeArea(
          child: Column(children: [
        _buildHeader(),
        KSTabs(tabs: _navTabs, initialIndex: 0),
        const Divider(color: Color(0xFF1A2A3A), height: 1),
        KSTabs(tabs: _filterTabs, initialIndex: 0, usePill: true),
        const Divider(color: Color(0xFF1A2A3A), height: 1),
        Expanded(
            child: ListView(
          padding: const EdgeInsets.only(top: 8),
          children: [
            _VideoPostCard(
              name: 'Aaliyah Grace',
              handle: '@aaliyahgrace',
              role: 'Entrepreneur • Speaker • Author',
              time: '2h ago',
              text:
                  'Purpose fuels passion.\nAction creates legacy.\nWhat are you building today?',
              hashtag: '#KingdomMindset #MadeForMore',
              likes: '12.4K',
              comments: '342',
              shares: '1.2K',
              saves: '870',
            ),
            _ProductPostCard(
              name: 'Minister Jay',
              handle: '@ministerjay',
              role: 'Faith Leader • Author • Coach',
              time: '4h ago',
              productName: 'Kingdom Mindset Devotional Journal',
              productDesc:
                  'Daily scriptures, powerful prayers, and kingdom strategies to help you grow spiritually and financially.',
              price: '\$24.99',
              likes: '3.2K',
              comments: '128',
              shares: '512',
            ),
            _PodcastPostCard(
              name: 'Faith & Finance Live',
              handle: '@faithfinance',
              role: 'Podcast • Business • Wealth Building',
              time: '6h ago',
              episodeTitle: 'Building Wealth with Kingdom Principles',
              duration: '28:45',
              likes: '2.1K',
              comments: '96',
              shares: '388',
              isLive: true,
            ),
            _VideoPostCard(
              name: 'David Baker',
              handle: '@dbaker',
              role: 'Business Owner • Coach',
              time: '8h ago',
              text:
                  'Kingdom principles work in every area of life. Business, family, health — all of it.',
              hashtag: '#KingdomBusiness #Marketplace',
              likes: '5.1K',
              comments: '127',
              shares: '432',
              saves: '210',
            ),
          ],
        )),
      ])),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 6),
      child: Row(children: [
        Image.asset("assets/images/ks_logo.png", width: 44, height: 44),
        const SizedBox(width: 8),
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          RichText(
              text: const TextSpan(children: [
            TextSpan(
                text: 'KINGDOMSHIFT',
                style: TextStyle(
                    color: kGold,
                    fontSize: 14,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0.5)),
            TextSpan(
                text: '.LIVE',
                style: TextStyle(
                    color: kPink, fontSize: 14, fontWeight: FontWeight.w900)),
          ])),
          RichText(
              text: const TextSpan(
                  style: TextStyle(fontSize: 9, letterSpacing: 0.3),
                  children: [
                TextSpan(
                    text: 'CREATE • CONNECT • ',
                    style: TextStyle(color: kTextSecondary)),
                TextSpan(text: 'GROW', style: TextStyle(color: kTeal)),
                TextSpan(text: ' • MONETIZE', style: TextStyle(color: kPink)),
              ])),
        ]),
        const Spacer(),
        _hBtn(Icons.search_rounded, () {}),
        const SizedBox(width: 6),
        _hBtn(Icons.shopping_bag_outlined, () {}),
        const SizedBox(width: 6),
        Stack(children: [
          _hBtn(Icons.notifications_outlined, () {}),
          Positioned(
              top: 2,
              right: 2,
              child: Container(
                  width: 14,
                  height: 14,
                  decoration: const BoxDecoration(
                      color: kLivePink, shape: BoxShape.circle),
                  child: const Center(
                      child: Text('3',
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 8,
                              fontWeight: FontWeight.bold))))),
        ]),
        const SizedBox(width: 6),
        Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: kCardBg,
                border: Border.all(
                    color: kTeal.withValues(alpha: 0.4), width: 1.5)),
            child: const Icon(Icons.person_rounded,
                color: kTextSecondary, size: 20)),
      ]),
    );
  }

  Widget _hBtn(IconData icon, VoidCallback onTap) {
    return GestureDetector(
        onTap: onTap,
        child: Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
                color: kBgSecondary,
                shape: BoxShape.circle,
                border: Border.all(color: kTeal.withValues(alpha: 0.2))),
            child: Icon(icon, color: kTextPrimary, size: 18)));
  }
}

// ─── Video Post Card ────────────────────────────────────────────
class _VideoPostCard extends StatefulWidget {
  final String name,
      handle,
      role,
      time,
      text,
      hashtag,
      likes,
      comments,
      shares,
      saves;
  const _VideoPostCard(
      {required this.name,
      required this.handle,
      required this.role,
      required this.time,
      required this.text,
      required this.hashtag,
      required this.likes,
      required this.comments,
      required this.shares,
      required this.saves});
  @override
  State<_VideoPostCard> createState() => _VideoPostCardState();
}

class _VideoPostCardState extends State<_VideoPostCard> {
  bool _liked = false;
  bool _saved = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(12, 0, 12, 12),
      decoration: BoxDecoration(
          color: kCardBg,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: kTeal.withValues(alpha: 0.12), width: 1),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withValues(alpha: 0.3), blurRadius: 10)
          ]),
      child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.max,
          children: [
            Expanded(
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                  // Header
                  Padding(
                      padding: const EdgeInsets.all(12),
                      child: Row(children: [
                        Container(
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: kBgSecondary,
                                border: Border.all(
                                    color: kTeal.withValues(alpha: 0.3),
                                    width: 1.5)),
                            child: const Icon(Icons.person_rounded,
                                color: kTextSecondary, size: 22)),
                        const SizedBox(width: 8),
                        Expanded(
                            child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                              Row(children: [
                                Text(widget.name,
                                    style: const TextStyle(
                                        color: kTextPrimary,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14)),
                                const SizedBox(width: 4),
                                const Icon(Icons.verified,
                                    color: kBlue, size: 14),
                                const SizedBox(width: 2),
                                const Icon(Icons.workspace_premium_rounded,
                                    color: kGold, size: 14),
                              ]),
                              Text(widget.role,
                                  style: const TextStyle(
                                      color: kTextSecondary, fontSize: 11)),
                              Row(children: [
                                Text(widget.time,
                                    style: const TextStyle(
                                        color: kTextSecondary, fontSize: 11)),
                                const SizedBox(width: 4),
                                const Icon(Icons.public,
                                    color: kTextSecondary, size: 11),
                              ]),
                            ])),
                        Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 5),
                            decoration: BoxDecoration(
                                border: Border.all(color: kTeal, width: 1.5),
                                borderRadius: BorderRadius.circular(20),
                                boxShadow: [
                                  BoxShadow(
                                      color: kTeal.withValues(alpha: 0.2),
                                      blurRadius: 6)
                                ]),
                            child: const Text('Follow',
                                style: TextStyle(
                                    color: kTeal,
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold))),
                        const SizedBox(width: 6),
                        const Icon(Icons.more_horiz,
                            color: kTextSecondary, size: 20),
                      ])),
                  // Text
                  Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(widget.text,
                                style: const TextStyle(
                                    color: kTextPrimary,
                                    fontSize: 14,
                                    height: 1.5)),
                            const SizedBox(height: 4),
                            Text(widget.hashtag,
                                style: const TextStyle(
                                    color: kTeal,
                                    fontSize: 13,
                                    fontWeight: FontWeight.w500)),
                          ])),
                  const SizedBox(height: 10),
                  // Video
                  Stack(children: [
                    Container(
                        margin: const EdgeInsets.symmetric(horizontal: 12),
                        height: 200,
                        decoration: BoxDecoration(
                            color: kBgSecondary,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                                color: kTeal.withValues(alpha: 0.1))),
                        child: Center(
                            child: Container(
                                width: 52,
                                height: 52,
                                decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: kTeal.withValues(alpha: 0.15),
                                    border: Border.all(color: kTeal, width: 2)),
                                child: const Icon(Icons.play_arrow_rounded,
                                    color: kTeal, size: 30)))),
                    Positioned(
                        bottom: 8,
                        left: 20,
                        child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                                color: Colors.black54,
                                borderRadius: BorderRadius.circular(4)),
                            child: const Text('01:32',
                                style: TextStyle(
                                    color: Colors.white, fontSize: 11)))),
                  ]),
                  const SizedBox(height: 10),
                  // Bottom actions
                  Padding(
                      padding: const EdgeInsets.fromLTRB(12, 0, 8, 12),
                      child: Row(children: [
                        GestureDetector(
                            onTap: () => setState(() {
                                  _liked = _liked ? false : true;
                                }),
                            child: Row(children: [
                              Icon(Icons.favorite,
                                  color: _liked ? kLivePink : kTextSecondary,
                                  size: 20),
                              const SizedBox(width: 3),
                              Text(widget.likes,
                                  style: TextStyle(
                                      color:
                                          _liked ? kLivePink : kTextSecondary,
                                      fontSize: 12)),
                            ])),
                        const SizedBox(width: 14),
                        Row(children: [
                          const Icon(Icons.chat_bubble_outline,
                              color: kTextSecondary, size: 18),
                          const SizedBox(width: 3),
                          Text(widget.comments,
                              style: const TextStyle(
                                  color: kTextSecondary, fontSize: 12)),
                        ]),
                        const SizedBox(width: 14),
                        Row(children: [
                          const Icon(Icons.reply_outlined,
                              color: kTextSecondary, size: 18),
                          const SizedBox(width: 3),
                          Text(widget.shares,
                              style: const TextStyle(
                                  color: kTextSecondary, fontSize: 12)),
                        ]),
                        const Spacer(),
                        GestureDetector(
                            onTap: () => setState(() {
                                  _saved = _saved ? false : true;
                                }),
                            child: Row(children: [
                              Icon(Icons.bookmark,
                                  color: _saved ? kGold : kTextSecondary,
                                  size: 18),
                              const SizedBox(width: 3),
                              Text(widget.saves,
                                  style: TextStyle(
                                      color: _saved ? kGold : kTextSecondary,
                                      fontSize: 12)),
                            ])),
                      ])),
                ])),
            // Right side actions
            Padding(
                padding: const EdgeInsets.only(top: 60, right: 8, bottom: 12),
                child: Column(children: [
                  _sideAction(Icons.person_add_rounded, '', kTeal),
                  const SizedBox(height: 16),
                  _sideAction(Icons.favorite, widget.likes, kLivePink),
                  const SizedBox(height: 16),
                  _sideAction(Icons.chat_bubble_outline, widget.comments,
                      kTextSecondary),
                  const SizedBox(height: 16),
                  _sideAction(
                      Icons.reply_outlined, widget.shares, kTextSecondary),
                  const SizedBox(height: 16),
                  _sideAction(
                      Icons.bookmark_border, widget.saves, kTextSecondary),
                  const SizedBox(height: 16),
                  _sideAction(Icons.shopping_bag_rounded, 'Shop', kGold),
                ])),
          ]),
    );
  }

  Widget _sideAction(IconData icon, String label, Color color) {
    return Column(children: [
      Icon(icon, color: color, size: 22),
      if (label.isNotEmpty) ...[
        const SizedBox(height: 2),
        Text(label,
            style: TextStyle(
                color: color, fontSize: 10, fontWeight: FontWeight.w500)),
      ],
    ]);
  }
}

// ─── Product Post Card ──────────────────────────────────────────
class _ProductPostCard extends StatelessWidget {
  final String name,
      handle,
      role,
      time,
      productName,
      productDesc,
      price,
      likes,
      comments,
      shares;
  const _ProductPostCard(
      {required this.name,
      required this.handle,
      required this.role,
      required this.time,
      required this.productName,
      required this.productDesc,
      required this.price,
      required this.likes,
      required this.comments,
      required this.shares});
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(12, 0, 12, 12),
      decoration: BoxDecoration(
          color: kCardBg,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: kGold.withValues(alpha: 0.2), width: 1),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withValues(alpha: 0.3), blurRadius: 10)
          ]),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Padding(
            padding: const EdgeInsets.all(12),
            child: Row(children: [
              Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: kBgSecondary,
                      border: Border.all(
                          color: kGold.withValues(alpha: 0.4), width: 1.5)),
                  child: const Icon(Icons.workspace_premium_rounded,
                      color: kGold, size: 22)),
              const SizedBox(width: 8),
              Expanded(
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                    Row(children: [
                      Text(name,
                          style: const TextStyle(
                              color: kTextPrimary,
                              fontWeight: FontWeight.bold,
                              fontSize: 14)),
                      const SizedBox(width: 4),
                      const Icon(Icons.verified, color: kBlue, size: 14),
                      const SizedBox(width: 2),
                      const Icon(Icons.workspace_premium_rounded,
                          color: kGold, size: 14),
                    ]),
                    Text(role,
                        style: const TextStyle(
                            color: kTextSecondary, fontSize: 11)),
                    Text(time,
                        style: const TextStyle(
                            color: kTextSecondary, fontSize: 11)),
                  ])),
              Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                  decoration: BoxDecoration(
                      border: Border.all(color: kTeal, width: 1.5),
                      borderRadius: BorderRadius.circular(20)),
                  child: const Text('Follow',
                      style: TextStyle(
                          color: kTeal,
                          fontSize: 12,
                          fontWeight: FontWeight.bold))),
              const SizedBox(width: 6),
              const Icon(Icons.more_horiz, color: kTextSecondary, size: 20),
            ])),
        Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Row(children: [
              Container(
                  width: 100,
                  height: 110,
                  decoration: BoxDecoration(
                      color: kBgSecondary,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: kGold.withValues(alpha: 0.2))),
                  child: const Center(
                      child: Icon(Icons.menu_book_rounded,
                          color: kGold, size: 40))),
              const SizedBox(width: 12),
              Expanded(
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                    Text(productName,
                        style: const TextStyle(
                            color: kTextPrimary,
                            fontWeight: FontWeight.bold,
                            fontSize: 14)),
                    const SizedBox(height: 6),
                    Text(productDesc,
                        style: const TextStyle(
                            color: kTextSecondary, fontSize: 12, height: 1.4)),
                    const SizedBox(height: 8),
                    Text(price,
                        style: const TextStyle(
                            color: kGold,
                            fontWeight: FontWeight.bold,
                            fontSize: 16)),
                    const SizedBox(height: 8),
                    Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 6),
                        decoration: BoxDecoration(
                            border: Border.all(color: kTeal, width: 1.5),
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                  color: kTeal.withValues(alpha: 0.2),
                                  blurRadius: 6)
                            ]),
                        child: const Text('Shop Now',
                            style: TextStyle(
                                color: kTeal,
                                fontSize: 12,
                                fontWeight: FontWeight.bold))),
                  ])),
              Column(children: [
                const Icon(Icons.favorite_border, color: kLivePink, size: 20),
                Text(likes,
                    style:
                        const TextStyle(color: kTextSecondary, fontSize: 10)),
                const SizedBox(height: 12),
                const Icon(Icons.chat_bubble_outline,
                    color: kTextSecondary, size: 18),
                Text(comments,
                    style:
                        const TextStyle(color: kTextSecondary, fontSize: 10)),
                const SizedBox(height: 12),
                const Icon(Icons.reply_outlined,
                    color: kTextSecondary, size: 18),
                Text(shares,
                    style:
                        const TextStyle(color: kTextSecondary, fontSize: 10)),
                const SizedBox(height: 12),
                const Icon(Icons.shopping_bag_rounded, color: kGold, size: 20),
              ]),
            ])),
        const SizedBox(height: 12),
      ]),
    );
  }
}

// ─── Podcast Post Card ──────────────────────────────────────────
class _PodcastPostCard extends StatelessWidget {
  final String name,
      handle,
      role,
      time,
      episodeTitle,
      duration,
      likes,
      comments,
      shares;
  final bool isLive;
  const _PodcastPostCard(
      {required this.name,
      required this.handle,
      required this.role,
      required this.time,
      required this.episodeTitle,
      required this.duration,
      required this.likes,
      required this.comments,
      required this.shares,
      this.isLive = false});
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(12, 0, 12, 12),
      decoration: BoxDecoration(
          color: kCardBg,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
              color: isLive
                  ? kLivePink.withValues(alpha: 0.3)
                  : kTeal.withValues(alpha: 0.12),
              width: 1),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withValues(alpha: 0.3), blurRadius: 10)
          ]),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Padding(
            padding: const EdgeInsets.all(12),
            child: Row(children: [
              Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: kBgSecondary,
                      border: Border.all(
                          color: kTeal.withValues(alpha: 0.3), width: 1.5)),
                  child: const Icon(Icons.podcasts_rounded,
                      color: kTeal, size: 22)),
              const SizedBox(width: 8),
              Expanded(
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                    Row(children: [
                      Text(name,
                          style: const TextStyle(
                              color: kTextPrimary,
                              fontWeight: FontWeight.bold,
                              fontSize: 14)),
                      const SizedBox(width: 4),
                      const Icon(Icons.verified, color: kBlue, size: 14),
                      if (isLive) ...[
                        const SizedBox(width: 6),
                        Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                                color: kLivePink,
                                borderRadius: BorderRadius.circular(4)),
                            child: const Text('LIVE',
                                style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 9,
                                    fontWeight: FontWeight.bold))),
                      ],
                    ]),
                    Text(role,
                        style: const TextStyle(
                            color: kTextSecondary, fontSize: 11)),
                    Text(time,
                        style: const TextStyle(
                            color: kTextSecondary, fontSize: 11)),
                  ])),
              const Icon(Icons.more_horiz, color: kTextSecondary, size: 20),
            ])),
        Padding(
            padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                  color: kBgSecondary,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: kTeal.withValues(alpha: 0.1))),
              child: Row(children: [
                Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8), color: kCardBg),
                    child: const Icon(Icons.music_note_rounded,
                        color: kTeal, size: 26)),
                const SizedBox(width: 10),
                Expanded(
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                      Text(episodeTitle,
                          style: const TextStyle(
                              color: kTextPrimary,
                              fontSize: 13,
                              fontWeight: FontWeight.w600)),
                      const SizedBox(height: 6),
                      Row(
                          children: List.generate(
                              20,
                              (i) => Expanded(
                                      child: Container(
                                    height: i % 3 == 0
                                        ? 16
                                        : i % 2 == 0
                                            ? 10
                                            : 6,
                                    margin: const EdgeInsets.symmetric(
                                        horizontal: 1),
                                    decoration: BoxDecoration(
                                        color: kTeal.withValues(alpha: 0.6),
                                        borderRadius: BorderRadius.circular(2)),
                                  )))),
                    ])),
                const SizedBox(width: 10),
                Column(children: [
                  Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: kTeal.withValues(alpha: 0.2),
                          border: Border.all(color: kTeal, width: 1.5)),
                      child: const Icon(Icons.play_arrow_rounded,
                          color: kTeal, size: 20)),
                  const SizedBox(height: 4),
                  Text(duration,
                      style:
                          const TextStyle(color: kTextSecondary, fontSize: 10)),
                ]),
              ]),
            )),
        Padding(
            padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
            child: Row(children: [
              const Icon(Icons.favorite_border, color: kLivePink, size: 18),
              const SizedBox(width: 3),
              Text(likes,
                  style: const TextStyle(color: kTextSecondary, fontSize: 12)),
              const SizedBox(width: 14),
              const Icon(Icons.chat_bubble_outline,
                  color: kTextSecondary, size: 16),
              const SizedBox(width: 3),
              Text(comments,
                  style: const TextStyle(color: kTextSecondary, fontSize: 12)),
              const SizedBox(width: 14),
              const Icon(Icons.reply_outlined, color: kTextSecondary, size: 16),
              const SizedBox(width: 3),
              Text(shares,
                  style: const TextStyle(color: kTextSecondary, fontSize: 12)),
            ])),
      ]),
    );
  }
}
