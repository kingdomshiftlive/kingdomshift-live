import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shortzz/screen/groups_screen/groups_controller.dart';

class CreateGroupScreen extends StatefulWidget {
  const CreateGroupScreen({super.key});

  @override
  State<CreateGroupScreen> createState() => _CreateGroupScreenState();
}

class _CreateGroupScreenState extends State<CreateGroupScreen> {
  final GroupsController controller = Get.find<GroupsController>();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController descController = TextEditingController();
  final RxBool isPrivate = false.obs;
  final RxString coverPath = ''.obs;

  @override
  void dispose() {
    nameController.dispose();
    descController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0F),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0A0A0F),
        elevation: 0,
        title: const Text('Create Group',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: GestureDetector(
                  onTap: () async {
                    final path = await controller.pickCoverImage();
                    if (path != null) coverPath.value = path;
                  },
                  child: Obx(() => Container(
                        width: 96,
                        height: 96,
                        decoration: BoxDecoration(
                          color: const Color(0xFF12121E),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: Colors.white12),
                          image: coverPath.value.isNotEmpty
                              ? DecorationImage(
                                  image: FileImage(File(coverPath.value)),
                                  fit: BoxFit.cover)
                              : null,
                        ),
                        child: coverPath.value.isEmpty
                            ? const Icon(Icons.add_a_photo_outlined,
                                color: Colors.white38, size: 28)
                            : null,
                      )),
                ),
              ),
              const SizedBox(height: 24),
              const Text('Group Name',
                  style: TextStyle(color: Colors.white70, fontSize: 13)),
              const SizedBox(height: 8),
              _field(nameController, 'e.g. Kingdom Builders Circle'),
              const SizedBox(height: 20),
              const Text('Description',
                  style: TextStyle(color: Colors.white70, fontSize: 13)),
              const SizedBox(height: 8),
              _field(descController, 'What is this group about?', maxLines: 4),
              const SizedBox(height: 20),
              Obx(() => Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: const Color(0xFF12121E),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.white12),
                    ),
                    child: Row(children: [
                      const Icon(Icons.lock_outline, color: Colors.white54, size: 18),
                      const SizedBox(width: 10),
                      const Expanded(
                        child: Text('Private Group',
                            style: TextStyle(color: Colors.white, fontSize: 13)),
                      ),
                      Switch(
                        value: isPrivate.value,
                        activeThumbColor: const Color(0xFF7B2FF7),
                        onChanged: (v) => isPrivate.value = v,
                      ),
                    ]),
                  )),
              const SizedBox(height: 4),
              const Text(
                  'Private groups require admin approval to join. Public groups let anyone join instantly.',
                  style: TextStyle(color: Colors.white24, fontSize: 11)),
              const SizedBox(height: 32),
              Obx(() => SizedBox(
                    width: double.infinity,
                    child: GestureDetector(
                      onTap: controller.isCreating.value
                          ? null
                          : () async {
                              final ok = await controller.createGroup(
                                name: nameController.text,
                                description: descController.text,
                                isPrivate: isPrivate.value,
                                coverImagePath: coverPath.value.isEmpty
                                    ? null
                                    : coverPath.value,
                              );
                              if (ok) Get.back();
                            },
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                              colors: [Color(0xFF7B2FF7), Color(0xFF00C6FF)]),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Center(
                          child: controller.isCreating.value
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                      color: Colors.white, strokeWidth: 2))
                              : const Text('Create Group',
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14)),
                        ),
                      ),
                    ),
                  )),
            ],
          ),
        ),
      ),
    );
  }

  Widget _field(TextEditingController c, String hint, {int maxLines = 1}) {
    return TextField(
      controller: c,
      maxLines: maxLines,
      style: const TextStyle(color: Colors.white, fontSize: 14),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: Colors.white24, fontSize: 13),
        filled: true,
        fillColor: const Color(0xFF12121E),
        contentPadding: const EdgeInsets.all(14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.white12),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.white12),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF7B2FF7)),
        ),
      ),
    );
  }
}
