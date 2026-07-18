import "package:flutter/material.dart";
import "package:firebase_auth/firebase_auth.dart";
import "package:supabase_flutter/supabase_flutter.dart" as sb;
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
  List<Map> _activeGifts = [];
  int _userCoins = 0;
  int _likeCount = 0;
  String _duration = "00:00";
  int _seconds = 0;
  bool _liveStarted = false;

  @override
  void initState() {
    super.initState();
    _loadCoins();
    _startTimer();
  }

  void _startTimer() {
    Future.doWhile(() async {
      await Future.delayed(const Duration(seconds: 1));
      if (!mounted) return false;
      if (_liveStarted) {
        setState(() {
          _seconds++;
          final m = (_seconds ~/ 60).toString().padLeft(2, '0');
          final s = (_seconds % 60).toString().padLeft(2, '0');
          _duration = "$m:$s";
        });
      }
      return true;
    });
  }

  Future<void> _loadCoins() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    try {
      final res = await sb.Supabase.instance.client
          .from("user_coins").select("balance").eq("user_id", user.uid).maybeSingle();
      if (mounted) setState(() => _userCoins = res?["balance"] ?? 0);
    } catch (e) {}
  }

  void _sendGift(String emoji, String name, int coins) {
    setState(() {
      _activeGifts.add({"emoji": emoji, "name": name});
      _userCoins = (_userCoins - coins).clamp(0, 999999);
    });
    Future.delayed(const Duration(seconds: 4), () {
      if (mounted) setState(() => _activeGifts.clear());
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
            onPressed: () async {
              Navigator.pop(ctx);
              final u = FirebaseAuth.instance.currentUser;
              if (u != null) await sb.Supabase.instance.client
                  .from("live_streams").update({"status": "ended"}).eq("creator_id", u.uid);
              if (mounted) Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
            child: const Text("End Live", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final u = FirebaseAuth.instance.currentUser;
    final userID = u?.uid ?? "guest";

    final hostConfig = ZegoUIKitPrebuiltLiveStreamingConfig.host()
      ..maxCoHostCount = 10
      ..bottomMenuBar.hostButtons = [
        ZegoLiveStreamingMenuBarButtonName.toggleCameraButton,
        ZegoLiveStreamingMenuBarButtonName.toggleMicrophoneButton,
        ZegoLiveStreamingMenuBarButtonName.switchCameraButton,
        ZegoLiveStreamingMenuBarButtonName.coHostControlButton,
      ];

    final audienceConfig = ZegoUIKitPrebuiltLiveStreamingConfig.audience()
      ..bottomMenuBar.audienceButtons = [
        ZegoLiveStreamingMenuBarButtonName.coHostControlButton,
      ];

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Zego full screen
          Positioned.fill(
            child: ZegoUIKitPrebuiltLiveStreaming(
              appID: LiveStreamScreen.zegoAppID,
              appSign: LiveStreamScreen.zegoAppSign,
              userID: userID,
              userName: widget.userName,
              liveID: widget.roomID,
              events: ZegoUIKitPrebuiltLiveStreamingEvents(
                onLiveStreamingStateUpdate: (state) {
                  if (mounted) {
                    setState(() {
                      _liveStarted = state == ZegoLiveStreamingState.living;
                    });
                  }
                },
              ),
              config: widget.isHost ? hostConfig : audienceConfig,
            ),
          ),

          // Only show our custom overlay AFTER live has started
          if (_liveStarted) ...[
            // Top gradient
            Positioned(
              top: 0, left: 0, right: 0, height: 140,
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Colors.black.withOpacity(0.8), Colors.transparent],
                  ),
                ),
              ),
            ),

            // Bottom gradient
            Positioned(
              bottom: 0, left: 0, right: 0, height: 180,
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                    colors: [Colors.black.withOpacity(0.85), Colors.transparent],
                  ),
                ),
              ),
            ),

            // Top bar
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(12, 8, 12, 0),
                child: Row(
                  children: [
                    Container(
                      width: 36, height: 36,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: KSTheme.gold, width: 2),
                        color: KSTheme.bgCard,
                      ),
                      child: const Icon(Icons.person, color: Colors.white, size: 18),
                    ),
                    const SizedBox(width: 8),
                    Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Row(children: [
                        Text(widget.userName, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
                        const SizedBox(width: 4),
                        const Icon(Icons.verified, color: KSTheme.teal, size: 13),
                      ]),
                      Row(children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(color: Colors.red, borderRadius: BorderRadius.circular(4)),
                          child: const Text("LIVE", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 9)),
                        ),
                        const SizedBox(width: 6),
                        Text(_duration, style: const TextStyle(color: Colors.white70, fontSize: 11)),
                      ]),
                    ]),
                    const Spacer(),
                    if (!widget.isHost)
                      GestureDetector(
                        onTap: () {},
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            border: Border.all(color: KSTheme.gold),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Text("+ Follow", style: TextStyle(color: KSTheme.gold, fontSize: 12, fontWeight: FontWeight.bold)),
                        ),
                      ),
                    const SizedBox(width: 8),
                    GestureDetector(
                      onTap: widget.isHost ? _endLive : () => Navigator.pop(context),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                        decoration: BoxDecoration(
                          color: widget.isHost ? Colors.red : Colors.black54,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          widget.isHost ? "End Live" : "Leave",
                          style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Right side buttons
            Positioned(
              right: 12,
              bottom: 120,
              child: Column(
                children: [
                  _SideBtn(
                    icon: Icons.favorite,
                    color: KSTheme.teal,
                    count: _likeCount > 0 ? "$_likeCount" : "",
                    onTap: () => setState(() => _likeCount++),
                  ),
                  const SizedBox(height: 16),
                  _SideBtn(
                    icon: Icons.card_giftcard_rounded,
                    color: KSTheme.gold,
                    onTap: () => showModalBottomSheet(
                      context: context,
                      backgroundColor: Colors.transparent,
                      isScrollControlled: true,
                      builder: (_) => GiftPanel(
                        roomId: widget.roomID,
                        hostId: widget.roomID.replaceFirst("live_", ""),
                        onGiftSent: _sendGift,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  _SideBtn(
                    icon: Icons.monetization_on_outlined,
                    color: KSTheme.gold,
                    count: "$_userCoins",
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const CoinsStoreScreen())),
                  ),
                ],
              ),
            ),

            // Gift animations
            if (_activeGifts.isNotEmpty)
              Positioned(
                left: 12, bottom: 120,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: _activeGifts.map((g) => Container(
                    margin: const EdgeInsets.only(bottom: 6),
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: KSTheme.bgCard.withOpacity(0.85),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: KSTheme.gold.withOpacity(0.4)),
                    ),
                    child: Row(mainAxisSize: MainAxisSize.min, children: [
                      const Icon(Icons.person, color: Colors.white, size: 14),
                      const SizedBox(width: 4),
                      Text(g["emoji"] as String, style: const TextStyle(fontSize: 20)),
                      const SizedBox(width: 4),
                      Text("sent ${g["name"]}", style: const TextStyle(color: KSTheme.gold, fontSize: 11)),
                    ]),
                  )).toList(),
                ),
              ),
          ],
        ],
      ),
    );
  }
}

class _SideBtn extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String? count;
  final VoidCallback onTap;
  const _SideBtn({required this.icon, required this.color, this.count, required this.onTap});
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(children: [
        Container(
          width: 48, height: 48,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.black54,
            border: Border.all(color: color.withOpacity(0.6), width: 1.5),
          ),
          child: Icon(icon, color: color, size: 22),
        ),
        if (count != null && count!.isNotEmpty) ...[
          const SizedBox(height: 3),
          Text(count!, style: const TextStyle(
            color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold,
            shadows: [Shadow(blurRadius: 4, color: Colors.black87)],
          )),
        ],
      ]),
    );
  }
}
