import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as sb;
import 'package:share_plus/share_plus.dart';
import 'package:zego_uikit_prebuilt_live_streaming/zego_uikit_prebuilt_live_streaming.dart';

class LiveStreamScreen extends StatefulWidget {
  final String roomID;
  final bool isHost;
  final String userName;

  const LiveStreamScreen({
    super.key,
    required this.roomID,
    required this.isHost,
    required this.userName,
  });

  static const int zegoAppID = 1974018811;
  static const String zegoAppSign = 'ea178866d109ba1f3da221522a5b60b8a8b990b1ae673e4090b3c401d474e748';

  @override
  State<LiveStreamScreen> createState() => _LiveStreamScreenState();
}

class _LiveStreamScreenState extends State<LiveStreamScreen> {
  @override
  void dispose() {
    if (widget.isHost) {
      final firebaseUser = FirebaseAuth.instance.currentUser;
      if (firebaseUser != null) {
        sb.Supabase.instance.client
            .from('live_streams')
            .update({'status': 'ended'})
            .eq('creator_id', firebaseUser.uid)
            .then((_) {})
            .catchError((_) {});
      }
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final firebaseUser = FirebaseAuth.instance.currentUser;
    final userID = firebaseUser?.uid ?? 'guest_${DateTime.now().millisecondsSinceEpoch}';

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
        Positioned(
          top: 50,
          right: 16,
          child: SafeArea(
            child: GestureDetector(
              onTap: () {
                SharePlus.instance.share(ShareParams(
                  text: 'Join this live on KingdomShift.Live!\nhttps://kingdomshift.live/live/${widget.roomID}',
                ));
              },
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.black54,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Icon(Icons.share, color: Colors.white, size: 20),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
