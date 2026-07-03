import 'package:flutter/material.dart';

class ShopScreen extends StatefulWidget {
  const ShopScreen({super.key});
  @override
  State<ShopScreen> createState() => _ShopScreenState();
}

class _ShopScreenState extends State<ShopScreen> {
  int _selectedCat = 0;
  final List<String> cats = [
    'All',
    'Books',
    'Courses',
    'Merch',
    'Digital',
    'Templates'
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0F),
      body: SafeArea(
          child: Column(children: [
        _buildHeader(),
        _buildBanner(),
        _buildCategories(),
        Expanded(child: _buildProducts()),
      ])),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      child: Row(children: [
        const Expanded(
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Shop. Support. Succeed.',
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold)),
          Text('Kingdom creators marketplace',
              style: TextStyle(color: Colors.white54, fontSize: 12)),
        ])),
        IconButton(
            icon: const Icon(Icons.search, color: Colors.white70),
            onPressed: () {}),
        Stack(children: [
          IconButton(
              icon: const Icon(Icons.shopping_bag_outlined,
                  color: Colors.white70),
              onPressed: () {}),
          Positioned(
              top: 6,
              right: 6,
              child: Container(
                  width: 14,
                  height: 14,
                  decoration: const BoxDecoration(
                      color: Color(0xFF7B2FF7), shape: BoxShape.circle),
                  child: const Center(
                      child: Text('3',
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 9,
                              fontWeight: FontWeight.bold))))),
        ]),
      ]),
    );
  }

  Widget _buildBanner() {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      height: 120,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: const LinearGradient(
            colors: [Color(0xFF0D1B3E), Color(0xFF1A2C5B)]),
        border:
            Border.all(color: const Color(0xFFFFB800).withValues(alpha: 0.3)),
      ),
      child: Stack(children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                      color: const Color(0xFFFFB800).withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(6)),
                  child: const Text('NEW ARRIVALS',
                      style: TextStyle(
                          color: Color(0xFFFFB800),
                          fontSize: 11,
                          fontWeight: FontWeight.bold))),
              const SizedBox(height: 6),
              const Text('Kingdom Creator Merchandise',
                  style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16)),
              const SizedBox(height: 8),
              Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                      color: const Color(0xFFFFB800),
                      borderRadius: BorderRadius.circular(8)),
                  child: const Text('Shop Now',
                      style: TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                          fontSize: 12))),
            ],
          ),
        ),
        const Positioned(
            right: 16,
            top: 0,
            bottom: 0,
            child: Center(child: Text('👑', style: TextStyle(fontSize: 60)))),
      ]),
    );
  }

  Widget _buildCategories() {
    return SizedBox(
      height: 40,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: cats.length,
        itemBuilder: (_, i) {
          final sel = _selectedCat == i;
          return GestureDetector(
            onTap: () => setState(() => _selectedCat = i),
            child: Container(
              margin: const EdgeInsets.only(right: 8),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: sel ? const Color(0xFFFFB800) : const Color(0xFF12121E),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                    color: sel ? const Color(0xFFFFB800) : Colors.white12),
              ),
              child: Text(cats[i],
                  style: TextStyle(
                      color: sel ? Colors.black : Colors.white54,
                      fontWeight: sel ? FontWeight.bold : FontWeight.normal,
                      fontSize: 13)),
            ),
          );
        },
      ),
    );
  }

  Widget _buildProducts() {
    final List<Map<String, String>> products = [
      {
        'title': 'God In You',
        'author': 'Char Orcino',
        'price': r'$19.99',
        'emoji': '📖',
        'tag': 'Bestseller'
      },
      {
        'title': 'Kingdom Blueprint',
        'author': 'KingdomShift',
        'price': r'$24.99',
        'emoji': '🏛️',
        'tag': 'New'
      },
      {
        'title': 'KS Classic Hoodie',
        'author': 'KS Merch',
        'price': r'$49.99',
        'emoji': '👕',
        'tag': ''
      },
      {
        'title': 'Wealth Academy',
        'author': 'WealthShift',
        'price': r'$99.00',
        'emoji': '🎓',
        'tag': 'Popular'
      },
      {
        'title': 'Purpose Carry Bag',
        'author': 'Promise and Purpose',
        'price': r'$65.00',
        'emoji': '👜',
        'tag': 'Featured'
      },
      {
        'title': 'Daily Decree Bundle',
        'author': 'Prophetess Char',
        'price': r'$12.99',
        'emoji': '📜',
        'tag': ''
      },
    ];
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 0.75),
      itemCount: products.length,
      itemBuilder: (_, i) {
        final p = products[i];
        return Container(
          decoration: BoxDecoration(
              color: const Color(0xFF12121E),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: Colors.white12)),
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Expanded(
                child: Stack(children: [
              Container(
                  width: double.infinity,
                  decoration: const BoxDecoration(
                      color: Color(0xFF1A1A2E),
                      borderRadius:
                          BorderRadius.vertical(top: Radius.circular(14))),
                  child: Center(
                      child: Text(p['emoji']!,
                          style: const TextStyle(fontSize: 52)))),
              if (p['tag']!.isNotEmpty)
                Positioned(
                    top: 8,
                    left: 8,
                    child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                            color: const Color(0xFFFFB800),
                            borderRadius: BorderRadius.circular(6)),
                        child: Text(p['tag']!,
                            style: const TextStyle(
                                color: Colors.black,
                                fontSize: 10,
                                fontWeight: FontWeight.bold)))),
              Positioned(
                  top: 8,
                  right: 8,
                  child: Container(
                      width: 28,
                      height: 28,
                      decoration: const BoxDecoration(
                          color: Colors.black54, shape: BoxShape.circle),
                      child: const Icon(Icons.favorite_border,
                          color: Colors.white70, size: 16))),
            ])),
            Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(p['title']!,
                        style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 13)),
                    Text(p['author']!,
                        style: const TextStyle(
                            color: Colors.white54, fontSize: 11)),
                    const SizedBox(height: 6),
                    Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(p['price']!,
                              style: const TextStyle(
                                  color: Color(0xFFFFB800),
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14)),
                          Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                  color: const Color(0xFF7B2FF7),
                                  borderRadius: BorderRadius.circular(8)),
                              child: const Icon(Icons.add_shopping_cart,
                                  color: Colors.white, size: 14)),
                        ]),
                  ]),
            ),
          ]),
        );
      },
    );
  }
}
