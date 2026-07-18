import 'dart:math';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as sb;
import 'package:firebase_auth/firebase_auth.dart';
import '../../theme/ks_theme.dart';
import 'coins_store_screen.dart';

class GiftPanel extends StatefulWidget {
  final String roomId;
  final String hostId;
  final Function(String emoji, String giftName, int coins)? onGiftSent;
  const GiftPanel({super.key, required this.roomId, required this.hostId, this.onGiftSent});

  @override
  State<GiftPanel> createState() => _GiftPanelState();
}

class _GiftPanelState extends State<GiftPanel> {
  List<Map> gifts = [];
  int userBalance = 0;
  bool isLoading = true;
  String? selectedGiftId;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    try {
      final giftsRes = await sb.Supabase.instance.client.from('gifts').select().eq('is_active', true).order('sort_order');
      final coinsRes = await sb.Supabase.instance.client.from('user_coins').select('balance').eq('user_id', user.uid).maybeSingle();
      if (mounted) setState(() {
        gifts = (giftsRes as List).cast<Map>();
        userBalance = coinsRes?['balance'] ?? 0;
        isLoading = false;
      });
    } catch (e) {
      if (mounted) setState(() => isLoading = false);
    }
  }

  Future<void> _sendGift(Map gift) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    final cost = gift['coin_price'] as int;
    if (userBalance < cost) {
      Navigator.pop(context);
      Navigator.push(context, MaterialPageRoute(builder: (_) => const CoinsStoreScreen()));
      return;
    }
    try {
      // Deduct coins from sender
      await sb.Supabase.instance.client.from('user_coins').upsert({'user_id': user.uid, 'balance': userBalance - cost, 'total_spent': cost});
      // Add coins to receiver
      final hostCoins = await sb.Supabase.instance.client.from('user_coins').select('balance, total_earned').eq('user_id', widget.hostId).maybeSingle();
      final hostBalance = hostCoins?['balance'] ?? 0;
      final hostEarned = hostCoins?['total_earned'] ?? 0;
      await sb.Supabase.instance.client.from('user_coins').upsert({'user_id': widget.hostId, 'balance': hostBalance + cost, 'total_earned': hostEarned + cost});
      // Record transaction
      await sb.Supabase.instance.client.from('gift_transactions').insert({
        'sender_id': user.uid,
        'receiver_id': widget.hostId,
        'gift_id': gift['id'],
        'coin_amount': cost,
        'live_room_id': widget.roomId,
      });
      setState(() => userBalance -= cost);
      widget.onGiftSent?.call(gift['emoji'] as String, gift['name'] as String, cost);
      Navigator.pop(context);
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 340,
      decoration: const BoxDecoration(
        color: KSTheme.bgCard,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          // Handle
          Container(margin: const EdgeInsets.only(top: 10), width: 40, height: 4, decoration: BoxDecoration(color: KSTheme.divider, borderRadius: BorderRadius.circular(2))),
          // Header
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: Row(children: [
              const Text('🎁 Send a Gift', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
              const Spacer(),
              GestureDetector(
                onTap: () { Navigator.pop(context); Navigator.push(context, MaterialPageRoute(builder: (_) => const CoinsStoreScreen())); },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(color: KSTheme.bgCardLight, borderRadius: BorderRadius.circular(20), border: Border.all(color: KSTheme.gold)),
                  child: Row(children: [
                    const Text('🪙', style: TextStyle(fontSize: 14)),
                    const SizedBox(width: 4),
                    Text('$userBalance', style: const TextStyle(color: KSTheme.gold, fontWeight: FontWeight.bold)),
                    const SizedBox(width: 4),
                    Text('+', style: TextStyle(color: KSTheme.teal, fontWeight: FontWeight.bold)),
                  ]),
                ),
              ),
            ]),
          ),
          const Divider(color: KSTheme.divider, height: 1),
          // Gifts grid
          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator(color: KSTheme.teal))
                : gifts.isEmpty
                    ? Center(child: Text('No gifts available', style: TextStyle(color: KSTheme.textSecondary)))
                    : GridView.builder(
                        padding: const EdgeInsets.all(12),
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 4, crossAxisSpacing: 8, mainAxisSpacing: 8, childAspectRatio: 0.85),
                        itemCount: gifts.length,
                        itemBuilder: (_, i) {
                          final gift = gifts[i];
                          final isSelected = selectedGiftId == gift['id'];
                          return GestureDetector(
                            onTap: () => setState(() => selectedGiftId == gift['id'] ? selectedGiftId = null : selectedGiftId = gift['id'] as String),
                            onDoubleTap: () => _sendGift(gift),
                            child: Container(
                              decoration: BoxDecoration(
                                color: isSelected ? KSTheme.teal.withValues(alpha: 0.2) : KSTheme.bgCardLight,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: isSelected ? KSTheme.teal : KSTheme.divider, width: isSelected ? 2 : 1),
                              ),
                              child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                                Text(gift['emoji'] as String, style: const TextStyle(fontSize: 28)),
                                const SizedBox(height: 2),
                                Text(gift['name'] as String, style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w600), textAlign: TextAlign.center),
                                Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                                  const Text('🪙', style: TextStyle(fontSize: 9)),
                                  const SizedBox(width: 2),
                                  Text('${gift['coin_price']}', style: TextStyle(color: KSTheme.gold, fontSize: 10, fontWeight: FontWeight.bold)),
                                ]),
                              ]),
                            ),
                          );
                        },
                      ),
          ),
          // Send button
          if (selectedGiftId != null)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    final gift = gifts.firstWhere((g) => g['id'] == selectedGiftId);
                    _sendGift(gift);
                  },
                  style: ElevatedButton.styleFrom(backgroundColor: KSTheme.teal, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)), padding: const EdgeInsets.symmetric(vertical: 14)),
                  child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                    Text(gifts.firstWhere((g) => g['id'] == selectedGiftId, orElse: () => {'emoji': '🎁'})['emoji'] as String, style: const TextStyle(fontSize: 18)),
                    const SizedBox(width: 8),
                    const Text('Send Gift', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                  ]),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// Gift animation overlay widget
class GiftAnimationOverlay extends StatefulWidget {
  final String emoji;
  final String giftName;
  final String senderName;
  const GiftAnimationOverlay({super.key, required this.emoji, required this.giftName, required this.senderName});
  @override
  State<GiftAnimationOverlay> createState() => _GiftAnimationOverlayState();
}

class _GiftAnimationOverlayState extends State<GiftAnimationOverlay> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnim;
  late Animation<double> _opacityAnim;
  late Animation<Offset> _slideAnim;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 2500));
    _scaleAnim = Tween<double>(begin: 0.5, end: 1.2).animate(CurvedAnimation(parent: _controller, curve: const Interval(0, 0.3, curve: Curves.elasticOut)));
    _opacityAnim = Tween<double>(begin: 1, end: 0).animate(CurvedAnimation(parent: _controller, curve: const Interval(0.7, 1.0)));
    _slideAnim = Tween<Offset>(begin: Offset.zero, end: const Offset(0, -2)).animate(CurvedAnimation(parent: _controller, curve: const Interval(0.3, 1.0, curve: Curves.easeInOut)));
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (_, __) => SlideTransition(
        position: _slideAnim,
        child: FadeTransition(
          opacity: _opacityAnim,
          child: ScaleTransition(
            scale: _scaleAnim,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.black54,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: KSTheme.gold.withValues(alpha: 0.5)),
              ),
              child: Row(mainAxisSize: MainAxisSize.min, children: [
                Text(widget.emoji, style: const TextStyle(fontSize: 32)),
                const SizedBox(width: 8),
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(widget.senderName, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
                  Text('sent ${widget.giftName}', style: TextStyle(color: KSTheme.gold, fontSize: 11)),
                ]),
              ]),
            ),
          ),
        ),
      ),
    );
  }
}
