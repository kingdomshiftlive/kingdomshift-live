import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shortzz/screen/shop_screen/shop_controller.dart';

/// Drop this into your live-viewing screen (wherever viewers actually watch
/// a ZegoCloud broadcast) to show a floating row of products the host has
/// pinned, updating in real time. Example:
///
///   Stack(children: [
///     YourZegoVideoView(),
///     Positioned(bottom: 90, left: 0, right: 0,
///         child: LiveShopOverlay(liveStreamId: stream.id)),
///   ])
class LiveShopOverlay extends StatefulWidget {
  final String liveStreamId;
  const LiveShopOverlay({super.key, required this.liveStreamId});

  @override
  State<LiveShopOverlay> createState() => _LiveShopOverlayState();
}

class _LiveShopOverlayState extends State<LiveShopOverlay> {
  late final ShopController controller;

  @override
  void initState() {
    super.initState();
    controller = Get.isRegistered<ShopController>()
        ? Get.find<ShopController>()
        : Get.put(ShopController());
    controller.watchLiveFeaturedProducts(widget.liveStreamId);
  }

  @override
  void dispose() {
    controller.stopWatchingLiveProducts();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (controller.liveFeatured.isEmpty) return const SizedBox.shrink();

      return SizedBox(
        height: 84,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          itemCount: controller.liveFeatured.length,
          itemBuilder: (_, i) {
            final featured = controller.liveFeatured[i];
            final product = featured.product;
            if (product == null) return const SizedBox.shrink();

            return GestureDetector(
              onTap: () {
                controller.addToCart(product);
                Get.snackbar('Added to cart', product.name,
                    backgroundColor: const Color(0xFF12121E),
                    colorText: Colors.white,
                    snackPosition: SnackPosition.TOP,
                    duration: const Duration(seconds: 2));
              },
              child: Container(
                width: 220,
                margin: const EdgeInsets.only(right: 10),
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.7),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: const Color(0xFFFFB800).withValues(alpha: 0.5)),
                ),
                child: Row(children: [
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      color: const Color(0xFF1A1A2E),
                      borderRadius: BorderRadius.circular(10),
                      image: product.imageUrl != null
                          ? DecorationImage(image: NetworkImage(product.imageUrl!), fit: BoxFit.cover)
                          : null,
                    ),
                    child: product.imageUrl == null
                        ? const Icon(Icons.shopping_bag_outlined, color: Colors.white38, size: 24)
                        : null,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(product.name,
                            style: const TextStyle(
                                color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis),
                        const SizedBox(height: 2),
                        Text('\$${product.price.toStringAsFixed(2)}',
                            style: const TextStyle(
                                color: Color(0xFFFFB800), fontWeight: FontWeight.bold, fontSize: 13)),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: const BoxDecoration(color: Color(0xFFFFB800), shape: BoxShape.circle),
                    child: const Icon(Icons.add_shopping_cart, color: Colors.black, size: 14),
                  ),
                ]),
              ),
            );
          },
        ),
      );
    });
  }
}
