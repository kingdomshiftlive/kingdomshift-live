import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shortzz/screen/shop_screen/shop_controller.dart';
import 'package:shortzz/screen/shop_screen/add_product_screen.dart';

class ShopScreen extends StatelessWidget {
  const ShopScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.isRegistered<ShopController>()
        ? Get.find<ShopController>()
        : Get.put(ShopController());
    final cats = ['All', 'Books', 'Courses', 'Merch', 'Digital', 'Templates'];

    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0F),
      body: SafeArea(
        child: Column(children: [
          _buildHeader(controller),
          _buildBanner(),
          _buildCategories(controller, cats),
          Expanded(child: _buildProducts(controller)),
        ]),
      ),
    );
  }

  Widget _buildHeader(ShopController controller) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      child: Row(children: [
        const Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Shop. Support. Succeed.',
              style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
          Text('Kingdom creators marketplace',
              style: TextStyle(color: Colors.white54, fontSize: 12)),
        ])),
        IconButton(
          icon: const Icon(Icons.add_box_outlined, color: Colors.white70),
          onPressed: () => Get.to(() => const AddProductScreen()),
        ),
        Stack(children: [
          IconButton(
              icon: const Icon(Icons.shopping_bag_outlined, color: Colors.white70),
              onPressed: () => _showCartSheet(controller)),
          Obx(() => controller.cart.length > 0
              ? Positioned(
                  top: 6,
                  right: 6,
                  child: Container(
                      width: 14,
                      height: 14,
                      decoration: const BoxDecoration(
                          color: Color(0xFF7B2FF7), shape: BoxShape.circle),
                      child: Center(
                          child: Text('${controller.cartCount}',
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 9,
                                  fontWeight: FontWeight.bold)))))
              : const SizedBox.shrink()),
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
        gradient: const LinearGradient(colors: [Color(0xFF0D1B3E), Color(0xFF1A2C5B)]),
        border: Border.all(color: const Color(0xFFFFB800).withValues(alpha: 0.3)),
      ),
      child: Stack(children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                      color: const Color(0xFFFFB800).withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(6)),
                  child: const Text('NEW ARRIVALS',
                      style: TextStyle(
                          color: Color(0xFFFFB800), fontSize: 11, fontWeight: FontWeight.bold))),
              const SizedBox(height: 6),
              const Text('Kingdom Creator Merchandise',
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
            ],
          ),
        ),
        const Positioned(
            right: 16, top: 0, bottom: 0, child: Center(child: Text('👑', style: TextStyle(fontSize: 60)))),
      ]),
    );
  }

  Widget _buildCategories(ShopController controller, List<String> cats) {
    return SizedBox(
      height: 40,
      child: Obx(() {
        final currentCategory = controller.selectedCategory.value;
        return ListView.builder(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          itemCount: cats.length,
          itemBuilder: (_, i) {
            final sel = currentCategory == cats[i];
            return GestureDetector(
              onTap: () => controller.fetchProducts(category: cats[i]),
              child: Container(
                margin: const EdgeInsets.only(right: 8),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: sel ? const Color(0xFFFFB800) : const Color(0xFF12121E),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: sel ? const Color(0xFFFFB800) : Colors.white12),
                ),
                child: Text(cats[i],
                    style: TextStyle(
                        color: sel ? Colors.black : Colors.white54,
                        fontWeight: sel ? FontWeight.bold : FontWeight.normal,
                        fontSize: 13)),
              ),
            );
          },
        );
      }),
    );
  }

  Widget _buildProducts(ShopController controller) {
    return Obx(() {
      if (controller.isLoading.value && controller.products.isEmpty) {
        return const Center(child: CircularProgressIndicator(color: Color(0xFFFFB800)));
      }
      if (controller.products.isEmpty) {
        return Center(
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            const Icon(Icons.storefront_outlined, color: Colors.white24, size: 56),
            const SizedBox(height: 12),
            const Text('No products yet', style: TextStyle(color: Colors.white54)),
            const SizedBox(height: 12),
            TextButton(
              onPressed: () => Get.to(() => const AddProductScreen()),
              child: const Text('+ Add your first product',
                  style: TextStyle(color: Color(0xFFFFB800))),
            ),
          ]),
        );
      }
      return RefreshIndicator(
        color: const Color(0xFFFFB800),
        backgroundColor: const Color(0xFF12121E),
        onRefresh: () => controller.fetchProducts(),
        child: GridView.builder(
          padding: const EdgeInsets.all(16),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2, crossAxisSpacing: 12, mainAxisSpacing: 12, childAspectRatio: 0.72),
          itemCount: controller.products.length,
          itemBuilder: (_, i) {
            final p = controller.products[i];
            return Container(
              decoration: BoxDecoration(
                  color: const Color(0xFF12121E),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: Colors.white12)),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Expanded(
                  child: Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                        color: const Color(0xFF1A1A2E),
                        borderRadius: const BorderRadius.vertical(top: Radius.circular(14)),
                        image: p.imageUrl != null
                            ? DecorationImage(image: NetworkImage(p.imageUrl!), fit: BoxFit.cover)
                            : null),
                    child: p.imageUrl == null
                        ? const Center(child: Icon(Icons.shopping_bag_outlined, color: Colors.white24, size: 40))
                        : null,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(10),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(p.name,
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis),
                    const SizedBox(height: 6),
                    Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                      Text('\$${p.price.toStringAsFixed(2)}',
                          style: const TextStyle(
                              color: Color(0xFFFFB800), fontWeight: FontWeight.bold, fontSize: 14)),
                      GestureDetector(
                        onTap: () => controller.addToCart(p),
                        child: Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                                color: const Color(0xFF7B2FF7), borderRadius: BorderRadius.circular(8)),
                            child: const Icon(Icons.add_shopping_cart, color: Colors.white, size: 14)),
                      ),
                    ]),
                  ]),
                ),
              ]),
            );
          },
        ),
      );
    });
  }

  void _showCartSheet(ShopController controller) {
    Get.bottomSheet(
      Container(
        constraints: BoxConstraints(maxHeight: Get.height * 0.75),
        decoration: const BoxDecoration(
            color: Color(0xFF12121E), borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
        padding: const EdgeInsets.all(16),
        child: Obx(() => Column(mainAxisSize: MainAxisSize.min, children: [
              const Text('Your Cart',
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
              const SizedBox(height: 12),
              if (controller.cart.isEmpty)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 30),
                  child: Text('Cart is empty', style: TextStyle(color: Colors.white38)),
                )
              else ...[
                Flexible(
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: controller.cart.length,
                    itemBuilder: (_, i) {
                      final item = controller.cart[i];
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 6),
                        child: Row(children: [
                          Expanded(
                            child: Text(item.product.name,
                                style: const TextStyle(color: Colors.white, fontSize: 13),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis),
                          ),
                          IconButton(
                              icon: const Icon(Icons.remove_circle_outline,
                                  color: Colors.white54, size: 18),
                              onPressed: () => controller.updateQuantity(
                                  item.product.id, item.quantity - 1)),
                          Text('${item.quantity}', style: const TextStyle(color: Colors.white)),
                          IconButton(
                              icon: const Icon(Icons.add_circle_outline,
                                  color: Colors.white54, size: 18),
                              onPressed: () => controller.updateQuantity(
                                  item.product.id, item.quantity + 1)),
                          Text('\$${item.subtotal.toStringAsFixed(2)}',
                              style: const TextStyle(
                                  color: Color(0xFFFFB800), fontWeight: FontWeight.bold, fontSize: 13)),
                        ]),
                      );
                    },
                  ),
                ),
                const Divider(color: Colors.white12),
                Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                  const Text('Total', style: TextStyle(color: Colors.white70, fontSize: 14)),
                  Text('\$${controller.cartTotal.toStringAsFixed(2)}',
                      style: const TextStyle(
                          color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                ]),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: GestureDetector(
                    onTap: controller.isCheckingOut.value
                        ? null
                        : () async {
                            final ok = await controller.checkout();
                            if (ok) Get.back();
                          },
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      decoration: BoxDecoration(
                          color: const Color(0xFFFFB800), borderRadius: BorderRadius.circular(12)),
                      child: Center(
                        child: controller.isCheckingOut.value
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(color: Colors.black, strokeWidth: 2))
                            : const Text('Checkout',
                                style: TextStyle(
                                    color: Colors.black, fontWeight: FontWeight.bold, fontSize: 14)),
                      ),
                    ),
                  ),
                ),
              ],
            ])),
      ),
    );
  }
}
