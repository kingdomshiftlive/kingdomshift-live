import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:get/get.dart';
import 'package:shortzz/common/controller/base_controller.dart';
import 'package:shortzz/common/functions/media_picker_helper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as supabase;

class ProductModel {
  final String id;
  final String creatorId;
  final String name;
  final String? description;
  final double price;
  final String? imageUrl;
  final String category;
  final int stock;
  final bool isActive;

  ProductModel({
    required this.id,
    required this.creatorId,
    required this.name,
    this.description,
    required this.price,
    this.imageUrl,
    required this.category,
    required this.stock,
    required this.isActive,
  });

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    return ProductModel(
      id: json['id'].toString(),
      creatorId: json['creator_id'] ?? '',
      name: json['name'] ?? '',
      description: json['description'],
      price: (json['price'] as num?)?.toDouble() ?? 0,
      imageUrl: json['image_url'],
      category: json['category'] ?? 'General',
      stock: json['stock'] ?? 0,
      isActive: json['is_active'] ?? true,
    );
  }
}

class CartItem {
  final ProductModel product;
  int quantity;
  CartItem({required this.product, this.quantity = 1});
  double get subtotal => product.price * quantity;
}

class LiveFeaturedProductModel {
  final String id;
  final String liveStreamId;
  final String productId;
  final String hostId;
  final ProductModel? product;

  LiveFeaturedProductModel({
    required this.id,
    required this.liveStreamId,
    required this.productId,
    required this.hostId,
    this.product,
  });

  factory LiveFeaturedProductModel.fromJson(Map<String, dynamic> json) {
    return LiveFeaturedProductModel(
      id: json['id'].toString(),
      liveStreamId: json['live_stream_id'] ?? '',
      productId: json['product_id'].toString(),
      hostId: json['host_id'] ?? '',
      product: json['product'] != null
          ? ProductModel.fromJson(json['product'])
          : null,
    );
  }
}

class ShopController extends BaseController {
  RxList<ProductModel> products = <ProductModel>[].obs;
  RxString selectedCategory = 'All'.obs;
  RxList<CartItem> cart = <CartItem>[].obs;
  RxBool isCreatingProduct = false.obs;
  RxBool isCheckingOut = false.obs;

  // Live-pin state for whichever stream is currently open
  RxList<LiveFeaturedProductModel> liveFeatured = <LiveFeaturedProductModel>[].obs;
  supabase.RealtimeChannel? _liveChannel;

  String? get _userId => firebase_auth.FirebaseAuth.instance.currentUser?.uid;

  double get cartTotal => cart.fold(0, (sum, item) => sum + item.subtotal);
  int get cartCount => cart.fold(0, (sum, item) => sum + item.quantity);

  @override
  void onInit() {
    super.onInit();
    fetchProducts();
  }

  @override
  void onClose() {
    _liveChannel?.unsubscribe();
    super.onClose();
  }

  Future<void> fetchProducts({String? category}) async {
    isLoading.value = true;
    if (category != null) selectedCategory.value = category;
    try {
      var query = supabase.Supabase.instance.client
          .from('products')
          .select()
          .eq('is_active', true);
      if (category != null && category != 'All') {
        query = query.eq('category', category);
      }
      final response = await query.order('created_at', ascending: false);
      products.value =
          (response as List).map((e) => ProductModel.fromJson(e)).toList();
    } catch (e) {
      showSnackBar('Failed to load products: $e');
    } finally {
      isLoading.value = false;
    }
  }

  void addToCart(ProductModel product) {
    final existing = cart.firstWhereOrNull((c) => c.product.id == product.id);
    if (existing != null) {
      existing.quantity++;
      cart.refresh();
    } else {
      cart.add(CartItem(product: product));
    }
  }

  void removeFromCart(String productId) {
    cart.removeWhere((c) => c.product.id == productId);
  }

  void updateQuantity(String productId, int quantity) {
    final item = cart.firstWhereOrNull((c) => c.product.id == productId);
    if (item == null) return;
    if (quantity <= 0) {
      removeFromCart(productId);
    } else {
      item.quantity = quantity;
      cart.refresh();
    }
  }

  void clearCart() => cart.clear();

  /// Creates pending orders for everything in the cart, then hands off to
  /// Stripe checkout via a Supabase Edge Function. The Edge Function itself
  /// (e.g. `create-stripe-checkout`) needs to be deployed separately — this
  /// client call assumes it exists and returns a checkout URL or client
  /// secret, same pattern as the HeyGen/Claude Edge Functions already used
  /// elsewhere in this app.
  Future<bool> checkout({String? liveStreamId}) async {
    final userId = _userId;
    if (userId == null) {
      showSnackBar('Please sign in to check out.');
      return false;
    }
    if (cart.isEmpty) {
      showSnackBar('Your cart is empty.');
      return false;
    }

    isCheckingOut.value = true;
    try {
      for (final item in cart) {
        await supabase.Supabase.instance.client.from('orders').insert({
          'buyer_id': userId,
          'product_id': item.product.id,
          'quantity': item.quantity,
          'total_price': item.subtotal,
          'status': 'pending',
          if (liveStreamId != null) 'live_stream_id': liveStreamId,
        });
      }

      // TODO: call the Stripe checkout Edge Function here once deployed:
      // final res = await supabase.Supabase.instance.client.functions
      //     .invoke('create-stripe-checkout', body: {'items': cart...});

      clearCart();
      isCheckingOut.value = false;
      showSnackBar('Order placed! Payment integration coming soon.');
      return true;
    } catch (e) {
      isCheckingOut.value = false;
      showSnackBar('Checkout failed: $e');
      return false;
    }
  }

  Future<bool> createProduct({
    required String name,
    required String description,
    required double price,
    required String category,
    String? imagePath,
    int stock = 999,
  }) async {
    final userId = _userId;
    if (userId == null) {
      showSnackBar('Please sign in to add products.');
      return false;
    }
    if (name.trim().isEmpty || price <= 0) {
      showSnackBar('Enter a valid name and price.');
      return false;
    }

    isCreatingProduct.value = true;
    try {
      String? imageUrl;
      if (imagePath != null) {
        final file = File(imagePath);
        final fileName = '$userId/product_${DateTime.now().millisecondsSinceEpoch}.jpg';
        await supabase.Supabase.instance.client.storage.from('thumbnails').upload(
            fileName, file,
            fileOptions: const supabase.FileOptions(upsert: true));
        imageUrl = supabase.Supabase.instance.client.storage
            .from('thumbnails')
            .getPublicUrl(fileName);
      }

      await supabase.Supabase.instance.client.from('products').insert({
        'creator_id': userId,
        'name': name.trim(),
        'description': description.trim(),
        'price': price,
        'image_url': imageUrl,
        'category': category,
        'stock': stock,
      });

      isCreatingProduct.value = false;
      await fetchProducts();
      return true;
    } catch (e) {
      isCreatingProduct.value = false;
      showSnackBar('Failed to add product: $e');
      return false;
    }
  }

  Future<String?> pickProductImage() async {
    final XFile? picked = await MediaPickerHelper.shared.pickImage(source: ImageSource.gallery);
    return picked?.path;
  }

  // ---------------- Live shopping ----------------

  /// Host pins a product to the current live stream so viewers see it
  /// featured in real time.
  Future<void> pinProductToLive({
    required String liveStreamId,
    required ProductModel product,
  }) async {
    final userId = _userId;
    if (userId == null) return;
    try {
      await supabase.Supabase.instance.client.from('live_featured_products').insert({
        'live_stream_id': liveStreamId,
        'product_id': product.id,
        'host_id': userId,
      });
    } catch (e) {
      showSnackBar('Failed to feature product: $e');
    }
  }

  Future<void> unpinLiveProduct(String featuredId) async {
    try {
      await supabase.Supabase.instance.client
          .from('live_featured_products')
          .delete()
          .eq('id', featuredId);
    } catch (e) {
      showSnackBar('Failed to unpin product: $e');
    }
  }

  /// Fetches current pinned products for a live stream and subscribes to
  /// realtime changes so the viewer overlay updates instantly as the host
  /// pins/unpins items.
  Future<void> watchLiveFeaturedProducts(String liveStreamId) async {
    await _fetchLiveFeaturedProducts(liveStreamId);

    _liveChannel?.unsubscribe();
    _liveChannel = supabase.Supabase.instance.client
        .channel('live_featured_$liveStreamId')
        .onPostgresChanges(
          event: supabase.PostgresChangeEvent.all,
          schema: 'public',
          table: 'live_featured_products',
          filter: supabase.PostgresChangeFilter(
            type: supabase.PostgresChangeFilterType.eq,
            column: 'live_stream_id',
            value: liveStreamId,
          ),
          callback: (payload) => _fetchLiveFeaturedProducts(liveStreamId),
        )
        .subscribe();
  }

  void stopWatchingLiveProducts() {
    _liveChannel?.unsubscribe();
    _liveChannel = null;
    liveFeatured.clear();
  }

  Future<void> _fetchLiveFeaturedProducts(String liveStreamId) async {
    try {
      final rows = await supabase.Supabase.instance.client
          .from('live_featured_products')
          .select()
          .eq('live_stream_id', liveStreamId)
          .order('featured_at', ascending: false);

      final list = (rows as List).cast<Map<String, dynamic>>();
      final productIds = list.map((r) => r['product_id'] as String).toSet().toList();

      Map<String, Map<String, dynamic>> productsById = {};
      if (productIds.isNotEmpty) {
        final productRows = await supabase.Supabase.instance.client
            .from('products')
            .select()
            .inFilter('id', productIds);
        for (final p in (productRows as List).cast<Map<String, dynamic>>()) {
          productsById[p['id'] as String] = p;
        }
      }

      liveFeatured.value = list.map((r) {
        final product = productsById[r['product_id']];
        return LiveFeaturedProductModel.fromJson({
          ...r,
          'product': product,
        });
      }).toList();
    } catch (e) {
      showSnackBar('Failed to load featured products: $e');
    }
  }
}
