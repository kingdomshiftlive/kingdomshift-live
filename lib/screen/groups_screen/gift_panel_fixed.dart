import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as sb;
import 'package:firebase_auth/firebase_auth.dart';
import '../../theme/ks_theme.dart';
import 'coins_store_screen.dart';

class GiftPanel extends StatefulWidget {
  final String roomId;
  final String hostId;
  final Function(String emoji, String giftName, int coins)? onGiftSent;

  const GiftPanel({
    super.key,
    required this.roomId,
    required this.hostId,
    this.onGiftSent,
  });

  @override
  State<GiftPanel> createState() => _GiftPanelState();
}

class _GiftPanelState extends State<GiftPanel> {
  List<Map> gifts = [];
  int userBalance = 0;
  int userTotalSpent = 0;
  bool isLoading = true;
  String? selectedGiftId;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  int _safeInt(dynamic value) {
    return int.tryParse(value?.toString() ?? '0') ?? 0;
  }

  String _safeString(dynamic value, {String fallback = ''}) {
    final text = value?.toString() ?? fallback;
    return text.isEmpty ? fallback : text;
  }

  int _giftCost(Map gift) {
    return _safeInt(gift['coin_price'] ?? gift['coins'] ?? gift['price']);
  }

  Future<void> _loadData() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      if (mounted) setState(() => isLoading = false);
      return;
    }

    try {
      final giftsRes = await sb.Supabase.instance.client
          .from('virtual_gifts')
          .select()
          .eq('is_active', true)
          .order('coins');

      final coinsRes = await sb.Supabase.instance.client
          .from('user_coins')
          .select('balance, total_spent')
          .eq('user_id', user.uid)
          .maybeSingle();

      if (!mounted) return;

      setState(() {
        gifts = (giftsRes as List).cast<Map>();
        userBalance = _safeInt(coinsRes?['balance']);
        userTotalSpent = _safeInt(coinsRes?['total_spent']);
        isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() => isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading gifts: $e')),
      );
    }
  }

  Future<void> _sendGift(Map gift) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final int cost = _giftCost(gift);
    final String giftId = _safeString(gift['id']);
    final String emoji = _safeString(gift['emoji'], fallback: '🎁');
    final String giftName = _safeString(gift['name'], fallback: 'Gift');

    if (cost <= 0 || giftId.isEmpty) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Gift is missing price or ID')),
      );
      return;
    }

    if (userBalance < cost) {
      if (!mounted) return;
      Navigator.pop(context);
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const CoinsStoreScreen()),
      );
      return;
    }

    try {
      await sb.Supabase.instance.client.from('user_coins').upsert({
        'user_id': user.uid,
        'balance': userBalance - cost,
        'total_spent': userTotalSpent + cost,
      }, onConflict: 'user_id');

      final hostCoins = await sb.Supabase.instance.client
          .from('user_coins')
          .select('balance, total_earned')
          .eq('user_id', widget.hostId)
          .maybeSingle();

      final int hostBalance = _safeInt(hostCoins?['balance']);
      final int hostEarned = _safeInt(hostCoins?['total_earned']);

      await sb.Supabase.instance.client.from('user_coins').upsert({
        'user_id': widget.hostId,
        'balance': hostBalance + cost,
        'total_earned': hostEarned + cost,
      }, onConflict: 'user_id');

      await sb.Supabase.instance.client.from('gift_transactions').insert({
        'sender_id': user.uid,
        'receiver_id': widget.hostId,
        'gift_id': giftId,
        'coin_amount': cost,
        'live_room_id': widget.roomId,
      });

      if (!mounted) return;

      setState(() {
        userBalance -= cost;
        userTotalSpent += cost;
        selectedGiftId = null;
      });

      widget.onGiftSent?.call(emoji, giftName, cost);
      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error sending gift: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 360,
      decoration: const BoxDecoration(
        color: KSTheme.bgCard,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          Container(
            margin: const EdgeInsets.only(top: 10),
            width: 42,
            height: 4,
            decoration: BoxDecoration(
              color: KSTheme.divider,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 8),
            child: Row(
              children: [
                const Text(
                  '🎁 Send a Gift',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                GestureDetector(
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const CoinsStoreScreen(),
                      ),
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 7,
                    ),
                    decoration: BoxDecoration(
                      color: KSTheme.bgCardLight,
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: KSTheme.gold),
                    ),
                    child: Row(
                      children: [
                        const Text('🪙', style: TextStyle(fontSize: 14)),
                        const SizedBox(width: 5),
                        Text(
                          '$userBalance',
                          style: const TextStyle(
                            color: KSTheme.gold,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(width: 4),
                        const Text(
                          '+',
                          style: TextStyle(
                            color: KSTheme.teal,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          const Divider(color: KSTheme.divider, height: 1),
          Expanded(
            child: isLoading
                ? const Center(
                    child: CircularProgressIndicator(color: KSTheme.teal),
                  )
                : gifts.isEmpty
                    ? Center(
                        child: Text(
                          'No gifts available',
                          style: TextStyle(color: KSTheme.textSecondary),
                        ),
                      )
                    : GridView.builder(
                        padding: const EdgeInsets.all(12),
                        itemCount: gifts.length,
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 4,
                          crossAxisSpacing: 8,
                          mainAxisSpacing: 8,
                          childAspectRatio: 0.85,
                        ),
                        itemBuilder: (_, i) {
                          final gift = gifts[i];
                          final giftId = _safeString(gift['id']);
                          final emoji =
                              _safeString(gift['emoji'], fallback: '🎁');
                          final name =
                              _safeString(gift['name'], fallback: 'Gift');
                          final imageUrl = _safeString(gift['image_url']);
                          final price = _giftCost(gift);
                          final isSelected = selectedGiftId == giftId;

                          return GestureDetector(
                            onTap: () {
                              if (giftId.isEmpty) return;
                              setState(() {
                                selectedGiftId =
                                    selectedGiftId == giftId ? null : giftId;
                              });
                            },
                            onDoubleTap: () => _sendGift(gift),
                            child: Container(
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? KSTheme.teal.withValues(alpha: 0.18)
                                    : KSTheme.bgCardLight,
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(
                                  color: isSelected
                                      ? KSTheme.teal
                                      : KSTheme.divider,
                                  width: isSelected ? 2 : 1,
                                ),
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  imageUrl.isNotEmpty
                                      ? ClipRRect(
                                          borderRadius:
                                              BorderRadius.circular(8),
                                          child: Image.network(
                                            imageUrl,
                                            width: 48,
                                            height: 48,
                                            fit: BoxFit.contain,
                                            errorBuilder: (_, __, ___) => Text(
                                              emoji,
                                              style: const TextStyle(
                                                fontSize: 28,
                                              ),
                                            ),
                                          ),
                                        )
                                      : Text(
                                          emoji,
                                          style:
                                              const TextStyle(fontSize: 28),
                                        ),
                                  const SizedBox(height: 3),
                                  Text(
                                    name,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 10,
                                      fontWeight: FontWeight.w600,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                  const SizedBox(height: 2),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      const Text(
                                        '🪙',
                                        style: TextStyle(fontSize: 9),
                                      ),
                                      const SizedBox(width: 2),
                                      Text(
                                        '$price',
                                        style: const TextStyle(
                                          color: KSTheme.gold,
                                          fontSize: 10,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
          ),
          if (selectedGiftId != null)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    final gift = gifts.firstWhere(
                      (g) => _safeString(g['id']) == selectedGiftId,
                      orElse: () => {},
                    );

                    if (gift.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Gift not found')),
                      );
                      return;
                    }

                    _sendGift(gift);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: KSTheme.teal,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: const Text(
                    'Send Gift',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class GiftAnimationOverlay extends StatefulWidget {
  final String emoji;
  final String giftName;
  final String senderName;

  const GiftAnimationOverlay({
    super.key,
    required this.emoji,
    required this.giftName,
    required this.senderName,
  });

  @override
  State<GiftAnimationOverlay> createState() => _GiftAnimationOverlayState();
}

class _GiftAnimationOverlayState extends State<GiftAnimationOverlay>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnim;
  late Animation<double> _opacityAnim;
  late Animation<Offset> _slideAnim;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2500),
    );

    _scaleAnim = Tween<double>(begin: 0.5, end: 1.2).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0, 0.3, curve: Curves.elasticOut),
      ),
    );

    _opacityAnim = Tween<double>(begin: 1, end: 0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.7, 1.0),
      ),
    );

    _slideAnim = Tween<Offset>(
      begin: Offset.zero,
      end: const Offset(0, -2),
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.3, 1.0, curve: Curves.easeInOut),
      ),
    );

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
                border: Border.all(
                  color: KSTheme.gold.withValues(alpha: 0.5),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(widget.emoji, style: const TextStyle(fontSize: 32)),
                  const SizedBox(width: 8),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.senderName,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                      Text(
                        'sent ${widget.giftName}',
                        style: const TextStyle(
                          color: KSTheme.gold,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
