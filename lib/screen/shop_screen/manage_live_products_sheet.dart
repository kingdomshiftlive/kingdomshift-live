import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shortzz/screen/shop_screen/shop_controller.dart';

/// Call this from the host's live-streaming controls to let them pick which
/// products are featured/pinned for the current stream:
///
///   showManageLiveProductsSheet(liveStreamId: stream.id);
void showManageLiveProductsSheet({required String liveStreamId}) {
  final controller = Get.isRegistered<ShopController>()
      ? Get.find<ShopController>()
      : Get.put(ShopController());

  if (controller.products.isEmpty) {
    controller.fetchProducts();
  }
  controller.watchLiveFeaturedProducts(liveStreamId);

  Get.bottomSheet(
    Container(
      constraints: BoxConstraints(maxHeight: Get.height * 0.75),
      decoration: const BoxDecoration(
          color: Color(0xFF12121E), borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      padding: const EdgeInsets.all(16),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        const Text('Feature Products',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 4),
        const Text('Tap to pin or unpin a product for viewers to see live',
            style: TextStyle(color: Colors.white38, fontSize: 12)),
        const SizedBox(height: 16),
        Flexible(
          child: Obx(() {
            final pinnedList = controller.liveFeatured;
            if (controller.products.isEmpty) {
              return const Padding(
                padding: EdgeInsets.symmetric(vertical: 30),
                child: Text('No products yet. Add one from the Shop tab first.',
                    style: TextStyle(color: Colors.white38), textAlign: TextAlign.center),
              );
            }
            return ListView.builder(
              shrinkWrap: true,
              itemCount: controller.products.length,
              itemBuilder: (_, i) {
                final product = controller.products[i];
                final featured = pinnedList
                    .firstWhereOrNull((f) => f.productId == product.id);
                final isPinned = featured != null;

                return Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0D0D16),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                        color: isPinned ? const Color(0xFFFFB800) : Colors.white12),
                  ),
                  child: Row(children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: const Color(0xFF1A1A2E),
                        borderRadius: BorderRadius.circular(8),
                        image: product.imageUrl != null
                            ? DecorationImage(image: NetworkImage(product.imageUrl!), fit: BoxFit.cover)
                            : null,
                      ),
                      child: product.imageUrl == null
                          ? const Icon(Icons.shopping_bag_outlined, color: Colors.white38, size: 20)
                          : null,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(product.name,
                              style: const TextStyle(color: Colors.white, fontSize: 13),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis),
                          Text('\$${product.price.toStringAsFixed(2)}',
                              style: const TextStyle(color: Color(0xFFFFB800), fontSize: 12)),
                        ],
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        if (isPinned) {
                          controller.unpinLiveProduct(featured.id);
                        } else {
                          controller.pinProductToLive(
                              liveStreamId: liveStreamId, product: product);
                        }
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                        decoration: BoxDecoration(
                          color: isPinned ? const Color(0xFFFFB800) : Colors.white.withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Text(isPinned ? 'Pinned' : 'Pin',
                            style: TextStyle(
                                color: isPinned ? Colors.black : Colors.white70,
                                fontWeight: FontWeight.bold,
                                fontSize: 12)),
                      ),
                    ),
                  ]),
                );
              },
            );
          }),
        ),
      ]),
    ),
  );
}
