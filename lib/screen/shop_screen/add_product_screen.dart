import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shortzz/screen/shop_screen/shop_controller.dart';

class AddProductScreen extends StatefulWidget {
  const AddProductScreen({super.key});

  @override
  State<AddProductScreen> createState() => _AddProductScreenState();
}

class _AddProductScreenState extends State<AddProductScreen> {
  final ShopController controller = Get.find<ShopController>();
  final nameController = TextEditingController();
  final descController = TextEditingController();
  final priceController = TextEditingController();
  final RxString category = 'Merch'.obs;
  final RxString imagePath = ''.obs;
  final cats = ['Books', 'Courses', 'Merch', 'Digital', 'Templates'];

  @override
  void dispose() {
    nameController.dispose();
    descController.dispose();
    priceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0F),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0A0A0F),
        elevation: 0,
        title: const Text('Add Product', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Center(
              child: GestureDetector(
                onTap: () async {
                  final path = await controller.pickProductImage();
                  if (path != null) imagePath.value = path;
                },
                child: Obx(() => Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        color: const Color(0xFF12121E),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.white12),
                        image: imagePath.value.isNotEmpty
                            ? DecorationImage(image: FileImage(File(imagePath.value)), fit: BoxFit.cover)
                            : null,
                      ),
                      child: imagePath.value.isEmpty
                          ? const Icon(Icons.add_a_photo_outlined, color: Colors.white38, size: 32)
                          : null,
                    )),
              ),
            ),
            const SizedBox(height: 24),
            const Text('Product Name', style: TextStyle(color: Colors.white70, fontSize: 13)),
            const SizedBox(height: 8),
            _field(nameController, 'e.g. God In You'),
            const SizedBox(height: 20),
            const Text('Description', style: TextStyle(color: Colors.white70, fontSize: 13)),
            const SizedBox(height: 8),
            _field(descController, 'What is this product?', maxLines: 4),
            const SizedBox(height: 20),
            const Text('Price (USD)', style: TextStyle(color: Colors.white70, fontSize: 13)),
            const SizedBox(height: 8),
            _field(priceController, 'e.g. 19.99', keyboardType: TextInputType.number),
            const SizedBox(height: 20),
            const Text('Category', style: TextStyle(color: Colors.white70, fontSize: 13)),
            const SizedBox(height: 8),
            Obx(() => Wrap(
                  spacing: 8,
                  children: cats.map((c) {
                    final sel = category.value == c;
                    return GestureDetector(
                      onTap: () => category.value = c,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                        decoration: BoxDecoration(
                          color: sel ? const Color(0xFFFFB800) : const Color(0xFF12121E),
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(color: sel ? const Color(0xFFFFB800) : Colors.white12),
                        ),
                        child: Text(c,
                            style: TextStyle(
                                color: sel ? Colors.black : Colors.white54,
                                fontWeight: sel ? FontWeight.bold : FontWeight.normal,
                                fontSize: 12)),
                      ),
                    );
                  }).toList(),
                )),
            const SizedBox(height: 32),
            Obx(() => SizedBox(
                  width: double.infinity,
                  child: GestureDetector(
                    onTap: controller.isCreatingProduct.value
                        ? null
                        : () async {
                            final price = double.tryParse(priceController.text.trim()) ?? 0;
                            final ok = await controller.createProduct(
                              name: nameController.text,
                              description: descController.text,
                              price: price,
                              category: category.value,
                              imagePath: imagePath.value.isEmpty ? null : imagePath.value,
                            );
                            if (ok) Get.back();
                          },
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      decoration: BoxDecoration(
                          color: const Color(0xFFFFB800), borderRadius: BorderRadius.circular(12)),
                      child: Center(
                        child: controller.isCreatingProduct.value
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(color: Colors.black, strokeWidth: 2))
                            : const Text('Add Product',
                                style: TextStyle(
                                    color: Colors.black, fontWeight: FontWeight.bold, fontSize: 14)),
                      ),
                    ),
                  ),
                )),
          ]),
        ),
      ),
    );
  }

  Widget _field(TextEditingController c, String hint,
      {int maxLines = 1, TextInputType? keyboardType}) {
    return TextField(
      controller: c,
      maxLines: maxLines,
      keyboardType: keyboardType,
      style: const TextStyle(color: Colors.white, fontSize: 14),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: Colors.white24, fontSize: 13),
        filled: true,
        fillColor: const Color(0xFF12121E),
        contentPadding: const EdgeInsets.all(14),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Colors.white12)),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Colors.white12)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFFFB800))),
      ),
    );
  }
}
