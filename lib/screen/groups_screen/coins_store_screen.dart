import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as sb;
import 'package:firebase_auth/firebase_auth.dart';
import '../../theme/ks_theme.dart';

class CoinsStoreScreen extends StatefulWidget {
  const CoinsStoreScreen({super.key});
  @override
  State<CoinsStoreScreen> createState() => _CoinsStoreScreenState();
}

class _CoinsStoreScreenState extends State<CoinsStoreScreen> {
  int userBalance = 0;
  bool isLoading = true;

  final coinPacks = [
    {'coins': 100, 'price': '\$0.99', 'bonus': '', 'popular': false, 'color': 0xFF1A2A3A},
    {'coins': 500, 'price': '\$3.99', 'bonus': '+50 FREE', 'popular': false, 'color': 0xFF1A2A3A},
    {'coins': 1200, 'price': '\$8.99', 'bonus': '+200 FREE', 'popular': true, 'color': 0xFF0A2A2A},
    {'coins': 2500, 'price': '\$17.99', 'bonus': '+500 FREE', 'popular': false, 'color': 0xFF1A2A3A},
    {'coins': 5000, 'price': '\$32.99', 'bonus': '+1000 FREE', 'popular': false, 'color': 0xFF1A1A2A},
    {'coins': 10000, 'price': '\$59.99', 'bonus': '+3000 FREE', 'popular': false, 'color': 0xFF2A1A0A},
  ];

  @override
  void initState() {
    super.initState();
    _loadBalance();
  }

  Future<void> _loadBalance() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    try {
      final res = await sb.Supabase.instance.client
          .from('user_coins').select('balance').eq('user_id', user.uid).maybeSingle();
      if (mounted) setState(() { userBalance = res?['balance'] ?? 0; isLoading = false; });
    } catch (e) {
      if (mounted) setState(() => isLoading = false);
    }
  }

  Future<void> _purchaseCoins(Map pack) async {
    // Show purchase confirmation
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: KSTheme.bgCard,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Purchase Coins', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        content: Column(mainAxisSize: MainAxisSize.min, children: [
          const Text('🪙', style: TextStyle(fontSize: 48)),
          const SizedBox(height: 8),
          Text('${pack['coins']} Coins${pack['bonus'] != '' ? ' + ${pack['bonus']}' : ''}',
            style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text(pack['price'] as String, style: TextStyle(color: KSTheme.teal, fontSize: 24, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text('In-app purchases will be available soon via RevenueCat', style: TextStyle(color: KSTheme.textSecondary, fontSize: 12), textAlign: TextAlign.center),
        ]),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text('Cancel', style: TextStyle(color: KSTheme.textSecondary))),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              // TODO: RevenueCat purchase
              // For now add coins directly for testing
              final user = FirebaseAuth.instance.currentUser;
              if (user == null) return;
              final coins = pack['coins'] as int;
              await sb.Supabase.instance.client.from('user_coins').upsert({
                'user_id': user.uid,
                'balance': userBalance + coins,
                'total_earned': userBalance + coins,
              });
              setState(() => userBalance += coins);
              if (mounted) ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('$coins coins added! (Test mode)'), backgroundColor: KSTheme.teal),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: KSTheme.teal, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
            child: const Text('Purchase', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: KSTheme.bgDark,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
              child: Row(children: [
                GestureDetector(onTap: () => Navigator.pop(context), child: const Icon(Icons.arrow_back, color: Colors.white)),
                const SizedBox(width: 12),
                const Text('Coins Store', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(color: KSTheme.bgCard, borderRadius: BorderRadius.circular(20), border: Border.all(color: KSTheme.gold)),
                  child: Row(children: [
                    const Text('🪙', style: TextStyle(fontSize: 16)),
                    const SizedBox(width: 6),
                    Text('$userBalance', style: const TextStyle(color: KSTheme.gold, fontWeight: FontWeight.bold, fontSize: 16)),
                  ]),
                ),
              ]),
            ),
            const SizedBox(height: 16),
            // Banner
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(colors: [Color(0xFF0D2137), Color(0xFF0A1628)]),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: KSTheme.gold.withValues(alpha: 0.3)),
                ),
                child: Row(children: [
                  const Text('🪙', style: TextStyle(fontSize: 48)),
                  const SizedBox(width: 16),
                  Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    const Text('Kingdom Coins', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                    Text('Send gifts during live streams\nand support your favorite creators!', style: TextStyle(color: KSTheme.textSecondary, fontSize: 13)),
                  ])),
                ]),
              ),
            ),
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(children: [
                const Text('Choose a Pack', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                const Spacer(),
                Text('Best value = more coins!', style: TextStyle(color: KSTheme.textSecondary, fontSize: 12)),
              ]),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: GridView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, crossAxisSpacing: 12, mainAxisSpacing: 12, childAspectRatio: 1.4),
                itemCount: coinPacks.length,
                itemBuilder: (_, i) {
                  final pack = coinPacks[i];
                  final isPopular = pack['popular'] as bool;
                  return GestureDetector(
                    onTap: () => _purchaseCoins(pack),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Color(pack['color'] as int),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: isPopular ? KSTheme.gold : KSTheme.divider, width: isPopular ? 2 : 1),
                      ),
                      child: Stack(
                        children: [
                          if (isPopular)
                            Positioned(top: 8, right: 8, child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(color: KSTheme.gold, borderRadius: BorderRadius.circular(10)),
                              child: const Text('POPULAR', style: TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold)),
                            )),
                          Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Text('🪙', style: TextStyle(fontSize: 28)),
                                const SizedBox(height: 4),
                                Text('${pack['coins']} Coins', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                                if (pack['bonus'] != '')
                                  Text(pack['bonus'] as String, style: TextStyle(color: KSTheme.teal, fontSize: 12, fontWeight: FontWeight.w600)),
                                const SizedBox(height: 4),
                                Text(pack['price'] as String, style: TextStyle(color: KSTheme.gold, fontWeight: FontWeight.bold, fontSize: 18)),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            // Footer note
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text('Coins are non-refundable. Prices may vary by region.', style: TextStyle(color: KSTheme.textSecondary, fontSize: 11), textAlign: TextAlign.center),
            ),
          ],
        ),
      ),
    );
  }
}
