import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as sb;
import 'package:share_plus/share_plus.dart';
import 'package:zego_uikit_prebuilt_live_streaming/zego_uikit_prebuilt_live_streaming.dart';

class LiveStreamScreen extends StatefulWidget {
  final String roomID;
  final bool isHost;
  final String userName;
  const LiveStreamScreen({super.key, required this.roomID, required this.isHost, required this.userName});
  static const int zegoAppID = 1974018811;
  static const String zegoAppSign = 'b8fcc1eede562f781a1310a6c1fc38696d43f8c854a3f9534c509eb7fba4fa9b';
  @override
  State<LiveStreamScreen> createState() => _LiveStreamScreenState();
}

class _LiveStreamScreenState extends State<LiveStreamScreen> {
  @override
  void dispose() {
    if (widget.isHost) {
      final u = FirebaseAuth.instance.currentUser;
      if (u != null) {
        sb.Supabase.instance.client.from('live_streams')
            .update({'status': 'ended'}).eq('creator_id', u.uid)
            .then((_) {}).catchError((_) {});
      }
    }
    super.dispose();
  }

  void _endLive() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A2E),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('End Live Stream?', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        content: const Text('Your viewers will be disconnected.', style: TextStyle(color: Colors.grey)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () { Navigator.pop(ctx); Navigator.pop(context); },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
            child: const Text('End Live', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final u = FirebaseAuth.instance.currentUser;
    final userID = u?.uid ?? 'guest_${DateTime.now().millisecondsSinceEpoch}';

    return Stack(
      children: [
        ZegoUIKitPrebuiltLiveStreaming(
          appID: LiveStreamScreen.zegoAppID,
          appSign: LiveStreamScreen.zegoAppSign,
          userID: userID,
          userName: widget.userName,
          liveID: widget.roomID,
          config: widget.isHost
              ? ZegoUIKitPrebuiltLiveStreamingConfig.host()
              : ZegoUIKitPrebuiltLiveStreamingConfig.audience(),
        ),
        // Top overlay bar
        Positioned(
          top: 0, left: 0, right: 0,
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // End Live button (host only)
                  if (widget.isHost)
                    GestureDetector(
                      onTap: _endLive,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(colors: [Color(0xFFFF416C), Color(0xFFFF4B2B)]),
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [BoxShadow(color: Colors.red.withOpacity(0.4), blurRadius: 8, spreadRadius: 1)],
                        ),
                        child: const Row(
                          children: [
                            Icon(Icons.stop_circle_outlined, color: Colors.white, size: 16),
                            SizedBox(width: 6),
                            Text('End Live', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
                          ],
                        ),
                      ),
                    )
                  else
                    const SizedBox.shrink(),
                  // Share button
                  GestureDetector(
                    onTap: () => SharePlus.instance.share(ShareParams(
                      text: 'Join this live on KingdomShift.Live!\nhttps://kingdomshift.live/live/${widget.roomID}',
                    )),
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.5),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.white.withOpacity(0.2)),
                      ),
                      child: const Icon(Icons.share_outlined, color: Colors.white, size: 18),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
