import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as sb;
import '../../theme/ks_theme.dart';
import '../../services/api_service.dart';
import 'my_shop_screen.dart';
import 'my_orders_screen.dart';

class AuthorityShopScreen extends StatefulWidget {
  const AuthorityShopScreen({super.key});
  @override
  State<AuthorityShopScreen> createState() => _AuthorityShopScreenState();
}

class _AuthorityShopScreenState extends State<AuthorityShopScreen> {
  List<Map> products = [];
  bool isLoading = true;
  int cartCount = 2;
  String selectedCategory = 'All';

  final categories = [
    {'icon': Icons.star_outline, 'label': 'New Arrivals'},
    {'icon': Icons.workspace_premium_outlined, 'label': 'Best Sellers'},
    {'icon': Icons.menu_book_outlined, 'label': 'Books'},
    {'icon': Icons.checkroom_outlined, 'label': 'Apparel'},
    {'icon': Icons.coffee_outlined, 'label': 'Drinkware'},
    {'icon': Icons.shopping_bag_outlined, 'label': 'Accessories'},
  ];

  final collections = [
    {'title': 'Kingdom Mindset', 'subtitle': 'Renew your mind.', 'color': 0xFF0A1A2A},
    {'title': 'Faith Wear', 'subtitle': 'Wear your faith.\nInspire the world.', 'color': 0xFF1A0A1A},
    {'title': 'Daily Inspiration', 'subtitle': 'Start your day\nwith purpose.', 'color': 0xFF0A1A1A},
  ];

  final bestSellers = [
    {'name': 'Kingdom Mindset', 'type': 'Book', 'price': '\$19.99', 'rating': '4.9', 'reviews': '1.2K', 'color': 0xFF0A1A2A},
    {'name': 'Faith Over Fear', 'type': 'Hoodie', 'price': '\$39.99', 'rating': '4.8', 'reviews': '856', 'color': 0xFF1A0A0A},
    {'name': 'Walk by Faith', 'type': 'Ceramic Mug', 'price': '\$24.99', 'rating': '4.9', 'reviews': '642', 'color': 0xFF0A1A1A},
    {'name': 'Kingdom Authority', 'type': 'Journal', 'price': '\$16.99', 'rating': '4.8', 'reviews': '523', 'color': 0xFF1A1A0A},
  ];

  @override
  void initState() {
    super.initState();
    _loadProducts();
  }

  Future<void> _loadProducts() async {
    setState(() => isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: KSTheme.bgDark,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            // Header
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                child: Row(
                  children: [
                    GestureDetector(onTap: () => Navigator.pop(context), child: const Icon(Icons.arrow_back, color: Colors.white)),
                    const SizedBox(width: 12),
                    ClipOval(child: Image.asset('assets/images/ks_logo.png', width: 36, height: 36, fit: BoxFit.cover)),
                    const SizedBox(width: 10),
                    Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      const Text('AuthorityShop', style: TextStyle(color: KSTheme.gold, fontSize: 16, fontWeight: FontWeight.bold)),
                      Text('SHOP', style: TextStyle(color: KSTheme.teal, fontSize: 10, fontWeight: FontWeight.w600, letterSpacing: 2)),
                    ]),
                    const Spacer(),
                    Stack(children: [
                      IconButton(icon: const Icon(Icons.shopping_cart_outlined, color: Colors.white), onPressed: () {}),
                      if (cartCount > 0) Positioned(top: 8, right: 8, child: Container(width: 16, height: 16, decoration: const BoxDecoration(color: KSTheme.teal, shape: BoxShape.circle), child: Center(child: Text('$cartCount', style: const TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold))))),
                    ]),
                    IconButton(icon: const Icon(Icons.search, color: Colors.white), onPressed: () {}),
                    IconButton(icon: const Icon(Icons.more_vert, color: Colors.white), onPressed: () {
                      showModalBottomSheet(
                        context: context,
                        backgroundColor: KSTheme.bgCard,
                        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
                        builder: (_) => Padding(
                          padding: const EdgeInsets.all(20),
                          child: Column(mainAxisSize: MainAxisSize.min, children: [
                            ListTile(leading: const Icon(Icons.store_outlined, color: KSTheme.teal), title: const Text('My Shop', style: TextStyle(color: Colors.white)), onTap: () { Navigator.pop(context); Navigator.push(context, MaterialPageRoute(builder: (_) => const MyShopScreen())); }),
                            ListTile(leading: const Icon(Icons.receipt_outlined, color: KSTheme.teal), title: const Text('My Orders', style: TextStyle(color: Colors.white)), onTap: () { Navigator.pop(context); Navigator.push(context, MaterialPageRoute(builder: (_) => const MyOrdersScreen())); }),
                          ]),
                        ),
                      );
                    }),
                  ],
                ),
              ),
            ),
            // Hero banner
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Container(
                  height: 220,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    gradient: const LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [Color(0xFF0D2137), Color(0xFF0A1628)]),
                    border: Border.all(color: KSTheme.teal.withValues(alpha: 0.3)),
                  ),
                  child: Stack(
                    children: [
                      Positioned(right: 16, top: 16, bottom: 16,
                        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                          Container(width: 120, height: 120, decoration: BoxDecoration(color: KSTheme.bgCardLight, borderRadius: BorderRadius.circular(12)), child: const Center(child: Icon(Icons.checkroom, color: KSTheme.gold, size: 60))),
                        ]),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Equip Your\nPurpose.\nLive With', style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold, height: 1.2)),
                            const Text('Authority.', style: TextStyle(color: KSTheme.teal, fontSize: 22, fontWeight: FontWeight.bold)),
                            const SizedBox(height: 8),
                            const Text('Faith-inspired resources\nto help you grow, lead,\nand walk in your calling.', style: TextStyle(color: Colors.white70, fontSize: 12)),
                            const Spacer(),
                            GestureDetector(
                              onTap: () {},
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                                decoration: BoxDecoration(color: Colors.transparent, borderRadius: BorderRadius.circular(20), border: Border.all(color: Colors.white)),
                                child: const Row(children: [Text('Shop Now', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)), SizedBox(width: 8), Icon(Icons.arrow_forward, color: Colors.white, size: 16)]),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            // Page dots
            SliverToBoxAdapter(
              child: Row(mainAxisAlignment: MainAxisAlignment.center, children: List.generate(5, (i) => Container(
                margin: const EdgeInsets.symmetric(horizontal: 3),
                width: i == 0 ? 16 : 6, height: 6,
                decoration: BoxDecoration(color: i == 0 ? KSTheme.teal : KSTheme.divider, borderRadius: BorderRadius.circular(3)),
              ))),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 16)),
            // Category icons
            SliverToBoxAdapter(
              child: SizedBox(
                height: 80,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: categories.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 10),
                  itemBuilder: (_, i) {
                    final cat = categories[i];
                    return GestureDetector(
                      onTap: () => setState(() => selectedCategory = cat['label'] as String),
                      child: Container(
                        width: 70,
                        decoration: BoxDecoration(color: KSTheme.bgCard, borderRadius: BorderRadius.circular(12), border: Border.all(color: selectedCategory == cat['label'] ? KSTheme.teal : KSTheme.divider)),
                        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                          Icon(cat['icon'] as IconData, color: KSTheme.teal, size: 24),
                          const SizedBox(height: 4),
                          Text(cat['label'] as String, style: const TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.w500), textAlign: TextAlign.center, maxLines: 2),
                        ]),
                      ),
                    );
                  },
                ),
              ),
            ),
            // Featured Collections
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 20, 16, 12),
                child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                  const Text('Featured Collections', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                  Text('See All >', style: TextStyle(color: KSTheme.teal, fontSize: 13, fontWeight: FontWeight.w600)),
                ]),
              ),
            ),
            SliverToBoxAdapter(
              child: SizedBox(
                height: 200,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: collections.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 10),
                  itemBuilder: (_, i) {
                    final col = collections[i];
                    return Container(
                      width: 160,
                      decoration: BoxDecoration(color: Color(col['color'] as int), borderRadius: BorderRadius.circular(14), border: Border.all(color: KSTheme.divider)),
                      child: Stack(
                        children: [
                          Center(child: Icon(Icons.auto_awesome, color: KSTheme.gold.withValues(alpha: 0.2), size: 80)),
                          Padding(
                            padding: const EdgeInsets.all(14),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Spacer(),
                                Text(col['title'] as String, style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold)),
                                Text(col['subtitle'] as String, style: TextStyle(color: KSTheme.textSecondary, fontSize: 11)),
                                const SizedBox(height: 10),
                                Row(children: [
                                  Text('Explore', style: TextStyle(color: KSTheme.teal, fontWeight: FontWeight.w600, fontSize: 13)),
                                  const SizedBox(width: 6),
                                  Container(width: 24, height: 24, decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: KSTheme.teal)), child: const Icon(Icons.arrow_forward, color: KSTheme.teal, size: 14)),
                                ]),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ),
            // Best Sellers
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 20, 16, 12),
                child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                  const Text('Best Sellers', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                  Text('See All >', style: TextStyle(color: KSTheme.teal, fontSize: 13, fontWeight: FontWeight.w600)),
                ]),
              ),
            ),
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (_, i) {
                  final item = bestSellers[i];
                  return Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: KSTheme.cardDecoration,
                      child: Row(children: [
                        Container(width: 56, height: 56, decoration: BoxDecoration(color: Color(item['color'] as int), borderRadius: BorderRadius.circular(10)),
                          child: Center(child: Text((item['name'] as String).split(' ').take(2).join('\n'), style: const TextStyle(color: Colors.white, fontSize: 7, fontWeight: FontWeight.bold), textAlign: TextAlign.center))),
                        const SizedBox(width: 12),
                        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          Text(item['name'] as String, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 14)),
                          Text(item['type'] as String, style: TextStyle(color: KSTheme.textSecondary, fontSize: 12)),
                          const SizedBox(height: 4),
                          Row(children: [
                            const Icon(Icons.star, color: KSTheme.gold, size: 14),
                            const SizedBox(width: 4),
                            Text('${item['rating']} (${item['reviews']})', style: TextStyle(color: KSTheme.textSecondary, fontSize: 11)),
                          ]),
                        ])),
                        Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                          Text(item['price'] as String, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15)),
                          const SizedBox(height: 6),
                          GestureDetector(
                            onTap: () => setState(() => cartCount++),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                              decoration: BoxDecoration(color: KSTheme.bgCardLight, borderRadius: BorderRadius.circular(8), border: Border.all(color: KSTheme.teal)),
                              child: const Row(children: [Icon(Icons.shopping_cart_outlined, color: KSTheme.teal, size: 14), SizedBox(width: 4), Text('Add', style: TextStyle(color: KSTheme.teal, fontSize: 12, fontWeight: FontWeight.w600))]),
                            ),
                          ),
                        ]),
                      ]),
                    ),
                  );
                },
                childCount: bestSellers.length,
              ),
            ),
            // Footer
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: KSTheme.cardDecoration,
                  child: Row(children: [
                    Expanded(child: Row(children: [
                      const Icon(Icons.local_shipping_outlined, color: KSTheme.teal, size: 28),
                      const SizedBox(width: 12),
                      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        const Text('Free Shipping', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
                        Text('On all orders over \$75', style: TextStyle(color: KSTheme.textSecondary, fontSize: 11)),
                      ]),
                    ])),
                    Container(width: 1, height: 40, color: KSTheme.divider),
                    Expanded(child: Row(children: [
                      const SizedBox(width: 12),
                      const Icon(Icons.shield_outlined, color: KSTheme.teal, size: 28),
                      const SizedBox(width: 12),
                      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        const Text('Secure Checkout', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
                        Text('Safe and trusted payments', style: TextStyle(color: KSTheme.textSecondary, fontSize: 11)),
                      ]),
                    ])),
                  ]),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
