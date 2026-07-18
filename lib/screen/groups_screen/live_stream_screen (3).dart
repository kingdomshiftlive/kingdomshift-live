import "package:flutter/material.dart";
import "package:firebase_auth/firebase_auth.dart";
import "package:supabase_flutter/supabase_flutter.dart" as sb;
import "package:share_plus/share_plus.dart";
import "package:zego_uikit_prebuilt_live_streaming/zego_uikit_prebuilt_live_streaming.dart";
import "../../theme/ks_theme.dart";
import "../coins/gift_panel.dart";
import "../coins/coins_store_screen.dart";

class LiveStreamScreen extends StatefulWidget {
  final String roomID;
  final bool isHost;
  final String userName;
  const LiveStreamScreen({super.key, required this.roomID, required this.isHost, required this.userName});
  static const int zegoAppID = 1974018811;
  static const String zegoAppSign = "b8fcc1eede562f781a1310a6c1fc38696d43f8c854a3f9534c509eb7fba4fa9b";
  @override
  State<LiveStreamScreen> createState() => _LiveStreamScreenState();
}

class _LiveStreamScreenState extends State<LiveStreamScreen> {
  final TextEditingController _chatController = TextEditingController();
  List<Map> _chatMessages = [];
  List<Map> _activeGifts = [];
  int _userCoins = 0;
  int _viewerCount = 0;
  int _activeTab = 0; // 0=chat, 1=guests
  bool _showGiftPanel = false;

  final List<Map> _topGifters = [
    {'name': 'Jessica M.', 'coins': 3250},
    {'name': 'David K.', 'coins': 2150},
    {'name': 'Lisa R.', 'coins': 1250},
  ];

  final List<Map> _demoChats = [
    {'name': 'Pastor James', 'isHost': true, 'msg': 'Welcome to KingdomShift.Live! We\'re so glad you\'re here.\nLet\'s build FAITH. Gain KNOWLEDGE. Walk in VICTORY! 🙌', 'time': '9:20 AM', 'pinned': true},
    {'name': 'Jessica M.', 'isHost': false, 'msg': 'This word is powerful! 🔥', 'time': '9:20 AM', 'pinned': false},
    {'name': 'David K.', 'isHost': false, 'msg': 'Amen! Let\'s go! 💪', 'time': '9:21 AM', 'pinned': false},
    {'name': 'Lisa R.', 'isHost': false, 'msg': 'Thank you Pastor! 🙏', 'time': '9:21 AM', 'pinned': false},
    {'name': 'Michael T.', 'isHost': false, 'msg': 'God is moving mightily today! 🙌', 'time': '9:22 AM', 'pinned': false},
    {'name': 'Angela B.', 'isHost': false, 'msg': 'Received this word! ❤️', 'time': '9:22 AM', 'pinned': false},
    {'name': 'John D.', 'isHost': false, 'msg': 'Where can I watch the replay?', 'time': '9:23 AM', 'pinned': false},
  ];

  @override
  void initState() {
    super.initState();
    _chatMessages = List.from(_demoChats);
    _loadCoins();
  }

  Future<void> _loadCoins() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    try {
      final res = await sb.Supabase.instance.client.from("user_coins").select("balance").eq("user_id", user.uid).maybeSingle();
      if (mounted) setState(() => _userCoins = res?["balance"] ?? 0);
    } catch (e) {}
  }

  void _sendGift(String emoji, String name, int coins) {
    setState(() {
      _activeGifts.add({"emoji": emoji, "name": name, "id": DateTime.now().millisecondsSinceEpoch, "count": 1});
      _userCoins = (_userCoins - coins).clamp(0, 999999);
    });
    Future.delayed(const Duration(seconds: 4), () {
      if (mounted) setState(() => _activeGifts.removeWhere((g) => g["name"] == name));
    });
  }

  void _endLive() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: KSTheme.bgCard,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text("End Live Stream?", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        content: const Text("Your viewers will be disconnected.", style: TextStyle(color: KSTheme.textSecondary)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Cancel", style: TextStyle(color: KSTheme.textSecondary))),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              final u = FirebaseAuth.instance.currentUser;
              if (u != null) {
                sb.Supabase.instance.client.from("live_streams").update({"status": "ended"}).eq("creator_id", u.uid).then((_) {}).catchError((_) {});
              }
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
            child: const Text("End Live", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _chatController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final u = FirebaseAuth.instance.currentUser;
    final userID = u?.uid ?? "guest";

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Zego live video (full screen background)
          Positioned.fill(
            child: ZegoUIKitPrebuiltLiveStreaming(
              appID: LiveStreamScreen.zegoAppID,
              appSign: LiveStreamScreen.zegoAppSign,
              userID: userID,
              userName: widget.userName,
              liveID: widget.roomID,
              config: widget.isHost
                  ? (ZegoUIKitPrebuiltLiveStreamingConfig.host()
                    ..topMenuBar.buttons = []
                    ..bottomMenuBar.hostButtons = [
                      ZegoLiveStreamingMenuBarButtonName.toggleCameraButton,
                      ZegoLiveStreamingMenuBarButtonName.toggleMicrophoneButton,
                      ZegoLiveStreamingMenuBarButtonName.switchCameraButton,
                    ])
                  : (ZegoUIKitPrebuiltLiveStreamingConfig.audience()
                    ..bottomMenuBar.audienceButtons = []),
            ),
          ),
          // Custom overlay UI
          SafeArea(
            child: Column(
              children: [
                // Top bar
                _buildTopBar(),
                // Rankings bar
                _buildRankingsBar(),
                // Middle area - gift animations
                Expanded(
                  child: Stack(
                    children: [
                      // Gift animations on left side
                      Positioned(
                        left: 12, top: 20, bottom: 100,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.end,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: _activeGifts.map((g) => _buildGiftAnimation(g)).toList(),
                        ),
                      ),
                      // Right side icons
                      Positioned(
                        right: 12, top: 20,
                        child: Column(children: [
                          _iconBtn(Icons.volume_up_outlined, () {}),
                          const SizedBox(height: 12),
                          _iconBtn(Icons.share_outlined, () => SharePlus.instance.share(ShareParams(text: "Join this live!\nhttps://kingdomshift.live/live/${widget.roomID}"))),
                          const SizedBox(height: 12),
                          _iconBtn(Icons.picture_in_picture_outlined, () {}),
                          const SizedBox(height: 12),
                          _iconBtn(Icons.fullscreen, () {}),
                        ]),
                      ),
                    ],
                  ),
                ),
                // Pinned product (host only)
                if (widget.isHost) _buildPinnedProduct(),
                // Chat + Guests area
                _buildChatGuestsArea(),
                // Host controls
                if (widget.isHost) _buildHostControls(),
                // Top gifters
                _buildTopGifters(),
                // Bottom bar
                _buildBottomBar(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 0),
      child: Row(children: [
        CircleAvatar(radius: 18, backgroundColor: KSTheme.bgCard, child: const Icon(Icons.person, color: Colors.white, size: 18)),
        const SizedBox(width: 8),
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Text(widget.userName, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
            const SizedBox(width: 4),
            const Icon(Icons.verified, color: KSTheme.teal, size: 14),
          ]),
          const Text("♥ 12.8K", style: TextStyle(color: Colors.white70, fontSize: 11)),
        ]),
        const SizedBox(width: 10),
        if (!widget.isHost)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(color: Colors.purple, borderRadius: BorderRadius.circular(20)),
            child: const Row(children: [Icon(Icons.add, color: Colors.white, size: 14), SizedBox(width: 4), Text("Follow", style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold))]),
          ),
        const Spacer(),
        // Co-host avatars
        SizedBox(
          width: 60,
          child: Stack(children: [
            CircleAvatar(radius: 16, backgroundColor: KSTheme.bgCard, child: const Icon(Icons.person, color: Colors.white, size: 14)),
            Positioned(left: 20, child: CircleAvatar(radius: 16, backgroundColor: KSTheme.bgCardLight, child: const Icon(Icons.person, color: Colors.white, size: 14))),
          ]),
        ),
        const SizedBox(width: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(color: Colors.black45, borderRadius: BorderRadius.circular(20), border: Border.all(color: Colors.white24)),
          child: Row(children: [const Icon(Icons.visibility_outlined, color: Colors.white, size: 14), const SizedBox(width: 4), Text("$_viewerCount", style: const TextStyle(color: Colors.white, fontSize: 12))]),
        ),
        const SizedBox(width: 8),
        GestureDetector(
          onTap: widget.isHost ? _endLive : () => Navigator.pop(context),
          child: Container(
            width: 32, height: 32,
            decoration: BoxDecoration(color: Colors.black45, borderRadius: BorderRadius.circular(8), border: Border.all(color: Colors.white24)),
            child: const Icon(Icons.close, color: Colors.white, size: 18),
          ),
        ),
      ]),
    );
  }

  Widget _buildRankingsBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 0),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(children: [
          _rankingChip("🔥", "Daily Ranking"),
          const SizedBox(width: 8),
          _rankingChip("💎", "Weekly Ranking"),
          const SizedBox(width: 8),
          _rankingChip("👑", "Top Gifting"),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(color: Colors.black45, borderRadius: BorderRadius.circular(20), border: Border.all(color: Colors.white24)),
            child: const Row(children: [Text("🌐", style: TextStyle(fontSize: 12)), SizedBox(width: 4), Text("Explore >", style: TextStyle(color: Colors.white, fontSize: 12))]),
          ),
        ]),
      ),
    );
  }

  Widget _rankingChip(String emoji, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(color: Colors.black54, borderRadius: BorderRadius.circular(20), border: Border.all(color: Colors.white24)),
      child: Row(children: [Text(emoji, style: const TextStyle(fontSize: 12)), const SizedBox(width: 4), Text(label, style: const TextStyle(color: Colors.white, fontSize: 12))]),
    );
  }

  Widget _buildGiftAnimation(Map g) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(color: Colors.black54, borderRadius: BorderRadius.circular(20)),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        CircleAvatar(radius: 12, backgroundColor: KSTheme.bgCard, child: const Icon(Icons.person, color: Colors.white, size: 12)),
        const SizedBox(width: 6),
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text("sender", style: const TextStyle(color: Colors.white, fontSize: 10)),
          Text("sent ${g["name"]}", style: TextStyle(color: KSTheme.textSecondary, fontSize: 9)),
        ]),
        const SizedBox(width: 8),
        Text(g["emoji"] as String, style: const TextStyle(fontSize: 24)),
        if ((g["count"] as int) > 1) ...[
          const SizedBox(width: 4),
          Text("x ${g["count"]}", style: const TextStyle(color: KSTheme.gold, fontWeight: FontWeight.bold, fontSize: 16)),
        ],
      ]),
    );
  }

  Widget _buildPinnedProduct() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 0, 12, 8),
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(color: Colors.black87, borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.white24)),
        child: Row(children: [
          Container(width: 48, height: 48, decoration: BoxDecoration(color: KSTheme.bgCard, borderRadius: BorderRadius.circular(8)), child: const Icon(Icons.checkroom, color: KSTheme.teal, size: 28)),
          const SizedBox(width: 10),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text("Faith Over Fear Tee", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
            const Text("Wear your faith boldly.", style: TextStyle(color: KSTheme.textSecondary, fontSize: 11)),
            const Text("\$24.99", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ])),
          ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(backgroundColor: Colors.purple, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)), padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8)),
            child: const Text("Buy Now", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
          ),
          const SizedBox(width: 6),
          const Icon(Icons.close, color: Colors.white54, size: 18),
        ]),
      ),
    );
  }

  Widget _buildChatGuestsArea() {
    return SizedBox(
      height: 220,
      child: Row(
        children: [
          // Chat
          Expanded(
            flex: 3,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(12, 0, 6, 0),
              child: Container(
                decoration: BoxDecoration(color: Colors.black54, borderRadius: BorderRadius.circular(12)),
                child: Column(
                  children: [
                    Expanded(
                      child: ListView.builder(
                        padding: const EdgeInsets.all(8),
                        itemCount: _chatMessages.length,
                        itemBuilder: (_, i) {
                          final msg = _chatMessages[i];
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 6),
                            child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                              CircleAvatar(radius: 12, backgroundColor: KSTheme.bgCard, child: const Icon(Icons.person, color: Colors.white, size: 10)),
                              const SizedBox(width: 6),
                              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                                Row(children: [
                                  Text(msg["name"] as String, style: TextStyle(color: msg["isHost"] == true ? Colors.purple : KSTheme.teal, fontWeight: FontWeight.bold, fontSize: 11)),
                                  if (msg["isHost"] == true) ...[const SizedBox(width: 4), Container(padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1), decoration: BoxDecoration(color: Colors.purple, borderRadius: BorderRadius.circular(4)), child: const Text("Host", style: TextStyle(color: Colors.white, fontSize: 8)))],
                                  if (msg["pinned"] == true) ...[const SizedBox(width: 4), const Icon(Icons.push_pin, color: Colors.white54, size: 10)],
                                  const Spacer(),
                                  Text(msg["time"] as String, style: const TextStyle(color: Colors.white38, fontSize: 9)),
                                ]),
                                Text(msg["msg"] as String, style: const TextStyle(color: Colors.white, fontSize: 11), maxLines: 3, overflow: TextOverflow.ellipsis),
                              ])),
                              const SizedBox(width: 4),
                              const Icon(Icons.favorite_outline, color: Colors.white38, size: 14),
                            ]),
                          );
                        },
                      ),
                    ),
                    // Chat input
                    Padding(
                      padding: const EdgeInsets.all(8),
                      child: Row(children: [
                        Expanded(child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(color: Colors.white10, borderRadius: BorderRadius.circular(20)),
                          child: const Text("Type your message...", style: TextStyle(color: Colors.white38, fontSize: 12)),
                        )),
                        const SizedBox(width: 6),
                        const Icon(Icons.sentiment_satisfied_outlined, color: Colors.white54, size: 20),
                        const SizedBox(width: 6),
                        Container(width: 32, height: 32, decoration: BoxDecoration(color: Colors.purple, shape: BoxShape.circle), child: const Icon(Icons.send, color: Colors.white, size: 16)),
                      ]),
                    ),
                  ],
                ),
              ),
            ),
          ),
          // Guests grid
          Expanded(
            flex: 2,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(0, 0, 12, 0),
              child: Container(
                decoration: BoxDecoration(color: Colors.black54, borderRadius: BorderRadius.circular(12)),
                padding: const EdgeInsets.all(8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(children: [
                      const Text("Guests (8/10)", style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold)),
                      const Spacer(),
                      Text("Manage", style: TextStyle(color: KSTheme.teal, fontSize: 10)),
                    ]),
                    const SizedBox(height: 6),
                    Expanded(
                      child: GridView.count(
                        crossAxisCount: 2,
                        crossAxisSpacing: 4,
                        mainAxisSpacing: 4,
                        childAspectRatio: 1.1,
                        physics: const NeverScrollableScrollPhysics(),
                        children: [
                          _guestCell("Host", true, true),
                          _guestCell("Sarah J.", false, true),
                          _guestCell("Marcus T.", false, true),
                          _guestCell("Tiffany R.", false, false),
                          _guestCell("+ Request", false, false, isRequest: true),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _guestCell(String name, bool isHost, bool isMicOn, {bool isRequest = false}) {
    return Container(
      decoration: BoxDecoration(
        color: isHost ? Colors.purple.withValues(alpha: 0.3) : KSTheme.bgCard,
        borderRadius: BorderRadius.circular(8),
        border: isHost ? Border.all(color: Colors.purple, width: 2) : null,
      ),
      child: Stack(children: [
        Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          if (isRequest)
            const Icon(Icons.add, color: KSTheme.teal, size: 20)
          else
            const Icon(Icons.person, color: Colors.white54, size: 20),
          Text(name, style: TextStyle(color: isRequest ? KSTheme.teal : Colors.white, fontSize: 9), textAlign: TextAlign.center),
        ])),
        if (isHost) Positioned(top: 2, left: 2, child: Container(padding: const EdgeInsets.symmetric(horizontal: 3, vertical: 1), decoration: BoxDecoration(color: Colors.purple, borderRadius: BorderRadius.circular(3)), child: const Text("Host", style: TextStyle(color: Colors.white, fontSize: 7)))),
        if (!isRequest) Positioned(bottom: 2, right: 2, child: Icon(isMicOn ? Icons.mic : Icons.mic_off, color: isMicOn ? KSTheme.teal : Colors.red, size: 10)),
      ]),
    );
  }

  Widget _buildHostControls() {
    final controls = [
      {'icon': '🎁', 'label': 'Featured\nGift'},
      {'icon': '📌', 'label': 'Pin\nComment'},
      {'icon': '👤', 'label': 'Invite\nGuest'},
      {'icon': '🔇', 'label': 'Mute\nGuest'},
      {'icon': '🧠', 'label': 'BrainBattle'},
      {'icon': '🛍️', 'label': 'Shop\nProduct'},
      {'icon': '📊', 'label': 'Poll'},
      {'icon': '⚙️', 'label': 'Settings'},
    ];
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 0),
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(color: Colors.black54, borderRadius: BorderRadius.circular(12)),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text("Host Controls", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
          const SizedBox(height: 8),
          Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: controls.map((c) => GestureDetector(
              onTap: () {},
              child: Column(children: [
                Text(c['icon']!, style: const TextStyle(fontSize: 20)),
                Text(c['label']!, style: const TextStyle(color: Colors.white, fontSize: 8), textAlign: TextAlign.center),
              ]),
            )).toList(),
          ),
        ]),
      ),
    );
  }

  Widget _buildTopGifters() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 0),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(color: Colors.black54, borderRadius: BorderRadius.circular(12)),
        child: Row(children: [
          const Text("Top Gifters", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
          const SizedBox(width: 4),
          Text("(This Live)", style: TextStyle(color: KSTheme.textSecondary, fontSize: 10)),
          const Spacer(),
          ..._topGifters.asMap().entries.map((e) => Padding(
            padding: const EdgeInsets.only(left: 8),
            child: Row(children: [
              Text("${e.key + 1}", style: TextStyle(color: KSTheme.gold, fontWeight: FontWeight.bold, fontSize: 11)),
              const SizedBox(width: 4),
              CircleAvatar(radius: 10, backgroundColor: KSTheme.bgCard, child: const Icon(Icons.person, color: Colors.white, size: 10)),
              const SizedBox(width: 4),
              Text(e.value['name'] as String, style: const TextStyle(color: Colors.white, fontSize: 10)),
              const SizedBox(width: 4),
              const Text("👑", style: TextStyle(fontSize: 10)),
              Text("${e.value['coins']}", style: TextStyle(color: KSTheme.gold, fontSize: 10)),
            ]),
          )),
          Text(" View All >", style: TextStyle(color: KSTheme.teal, fontSize: 10)),
        ]),
      ),
    );
  }

  Widget _buildBottomBar() {
    final tabs = [
      {'icon': Icons.chat_bubble_outline, 'label': 'Chat'},
      {'icon': Icons.sentiment_satisfied_outlined, 'label': 'Emoji'},
      {'icon': Icons.people_outline, 'label': 'Guests'},
      {'icon': Icons.card_giftcard, 'label': 'Gifts'},
      {'icon': Icons.share_outlined, 'label': 'Share'},
    ];
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
      child: Row(children: [
        ...tabs.asMap().entries.map((e) {
          final isGift = e.value['label'] == 'Gifts';
          final isActive = _activeTab == e.key;
          return Expanded(
            child: GestureDetector(
              onTap: () {
                setState(() => _activeTab = e.key);
                if (isGift) {
                  showModalBottomSheet(
                    context: context,
                    backgroundColor: Colors.transparent,
                    isScrollControlled: true,
                    builder: (_) => GiftPanel(
                      roomId: widget.roomID,
                      hostId: widget.roomID.replaceFirst("live_", ""),
                      onGiftSent: _sendGift,
                    ),
                  );
                } else if (e.value['label'] == 'Share') {
                  SharePlus.instance.share(ShareParams(text: "Join this live!\nhttps://kingdomshift.live/live/${widget.roomID}"));
                }
              },
              child: Column(children: [
                Icon(e.value['icon'] as IconData, color: isGift ? Colors.purple : (isActive ? KSTheme.teal : Colors.white54), size: isGift ? 26 : 22),
                Text(e.value['label'] as String, style: TextStyle(color: isGift ? Colors.purple : (isActive ? KSTheme.teal : Colors.white54), fontSize: 10, fontWeight: isGift ? FontWeight.bold : FontWeight.normal)),
              ]),
            ),
          );
        }),
        const SizedBox(width: 8),
        GestureDetector(
          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const CoinsStoreScreen())),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(color: Colors.black54, borderRadius: BorderRadius.circular(20), border: Border.all(color: KSTheme.gold)),
            child: Row(children: [
              const Text("🪙", style: TextStyle(fontSize: 14)),
              const SizedBox(width: 4),
              Text("$_userCoins", style: const TextStyle(color: KSTheme.gold, fontWeight: FontWeight.bold, fontSize: 13)),
            ]),
          ),
        ),
        const SizedBox(width: 6),
        Container(
          width: 28, height: 28,
          decoration: BoxDecoration(color: Colors.purple, shape: BoxShape.circle),
          child: const Icon(Icons.add, color: Colors.white, size: 18),
        ),
      ]),
    );
  }

  Widget _iconBtn(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(color: Colors.black45, borderRadius: BorderRadius.circular(8), border: Border.all(color: Colors.white24)),
        child: Icon(icon, color: Colors.white, size: 18),
      ),
    );
  }
}
