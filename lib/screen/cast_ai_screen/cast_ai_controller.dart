import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:shortzz/common/controller/base_controller.dart';
import 'package:shortzz/screen/camera_screen/camera_screen_controller.dart';
import 'package:shortzz/screen/create_feed_screen/create_feed_screen.dart';
import 'package:shortzz/common/functions/media_picker_helper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as supabase;

const _edgeFunctionUrl = 'https://cotcogrkmtgibbpwhxrg.supabase.co/functions/v1/smart-endpoint';
const _supabasePublishableKey = 'sb_publishable_FxXXeD03pQNBCb7fl5OGkQ_JUmKRsJ9';

enum CastAiState { idle, generating, polling, ready, error }

class CastAiController extends BaseController {
  final scriptController = TextEditingController();
  final Rx<CastAiState> state = CastAiState.idle.obs;
  final RxString errorText = ''.obs;
  final RxInt remainingToday = 3.obs;
  final RxString videoUrl = ''.obs;
  String? _jobId;
  Timer? _pollTimer;

  final RxList<Map<String, dynamic>> avatars = <Map<String, dynamic>>[].obs;
  final RxString selectedAvatarId = ''.obs;
  final RxBool isUploadingAvatar = false.obs;

  @override
  void onInit() {
    super.onInit();
    fetchAvatars();
  }

  @override
  void onClose() {
    _pollTimer?.cancel();
    scriptController.dispose();
    super.onClose();
  }

  Future<void> fetchAvatars() async {
    final userId = firebase_auth.FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) return;
    try {
      final response = await http.post(
        Uri.parse(_edgeFunctionUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_supabasePublishableKey',
          'apikey': _supabasePublishableKey,
        },
        body: jsonEncode({'action': 'list_avatars', 'userId': userId}),
      );
      final data = jsonDecode(response.body);
      avatars.value = List<Map<String, dynamic>>.from(data['avatars'] ?? []);
    } catch (e) {
      // Silent - not critical, falls back to default avatar
    }
  }

  Future<void> uploadNewAvatar() async {
    final userId = firebase_auth.FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) {
      showSnackBar('Please sign in to upload an avatar.');
      return;
    }

    final XFile? picked = await MediaPickerHelper.shared.pickImage(source: ImageSource.gallery);
    if (picked == null) return;

    isUploadingAvatar.value = true;
    try {
      final file = File(picked.path);
      final fileName = '$userId/cast_ai_avatar_${DateTime.now().millisecondsSinceEpoch}.jpg';

      await supabase.Supabase.instance.client.storage.from('thumbnails').upload(
          fileName, file,
          fileOptions: const supabase.FileOptions(upsert: true));

      final photoUrl = supabase.Supabase.instance.client.storage
          .from('thumbnails')
          .getPublicUrl(fileName);

      final response = await http.post(
        Uri.parse(_edgeFunctionUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_supabasePublishableKey',
          'apikey': _supabasePublishableKey,
        },
        body: jsonEncode({
          'action': 'create_avatar',
          'userId': userId,
          'photoUrl': photoUrl,
          'avatarName': 'Avatar ${DateTime.now().toIso8601String().split("T").first}',
        }),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        showSnackBar('Avatar created! It may take a few minutes before it\'s ready to use.');
        await fetchAvatars();
      } else {
        showSnackBar(data['error'] ?? 'Failed to create avatar.');
      }
    } catch (e) {
      showSnackBar('Failed to upload avatar: \$e');
    } finally {
      isUploadingAvatar.value = false;
    }
  }

  void selectAvatar(String heygenAvatarId) {
    selectedAvatarId.value = heygenAvatarId;
  }

  Future<void> generate() async {
    final script = scriptController.text.trim();
    if (script.isEmpty) {
      errorText.value = 'Type something for your avatar to say first.';
      return;
    }

    final userId = firebase_auth.FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) {
      errorText.value = 'Please sign in to use Cast AI.';
      return;
    }

    errorText.value = '';
    videoUrl.value = '';
    state.value = CastAiState.generating;

    try {
      final response = await http.post(
        Uri.parse(_edgeFunctionUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_supabasePublishableKey',
          'apikey': _supabasePublishableKey,
        },
        body: jsonEncode({
          'action': 'generate',
          'userId': userId,
          'script': script,
          if (selectedAvatarId.value.isNotEmpty) 'avatarId': selectedAvatarId.value,
        }),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        _jobId = data['jobId'];
        remainingToday.value = data['remainingToday'] ?? 0;
        state.value = CastAiState.polling;
        _startPolling();
      } else if (response.statusCode == 429) {
        errorText.value = data['error'] ?? 'Daily limit reached. Try again tomorrow.';
        state.value = CastAiState.error;
      } else {
        errorText.value = data['error'] ?? 'Something went wrong. Please try again.';
        state.value = CastAiState.error;
      }
    } catch (e) {
      errorText.value = 'Connection error. Please check your internet and try again.';
      state.value = CastAiState.error;
    }
  }

  void _startPolling() {
    _pollTimer?.cancel();
    _pollTimer = Timer.periodic(const Duration(seconds: 5), (_) => _checkStatus());
  }

  Future<void> _checkStatus() async {
    if (_jobId == null) return;
    try {
      final response = await http.post(
        Uri.parse(_edgeFunctionUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_supabasePublishableKey',
          'apikey': _supabasePublishableKey,
        },
        body: jsonEncode({'action': 'status', 'jobId': _jobId}),
      );

      final data = jsonDecode(response.body);
      final status = data['status'];

      if (status == 'completed') {
        _pollTimer?.cancel();
        videoUrl.value = data['video_url'] ?? '';
        state.value = CastAiState.ready;
      } else if (status == 'failed') {
        _pollTimer?.cancel();
        errorText.value = data['error_message'] ?? 'Video generation failed.';
        state.value = CastAiState.error;
      }
      // else still processing, keep polling
    } catch (e) {
      // Silent retry on next tick
    }
  }

  void reset() {
    _pollTimer?.cancel();
    _jobId = null;
    videoUrl.value = '';
    errorText.value = '';
    scriptController.clear();
    state.value = CastAiState.idle;
  }

  Future<void> useInPost() async {
    if (videoUrl.value.isEmpty) return;
    isLoading.value = true;
    try {
      final response = await http.get(Uri.parse(videoUrl.value));
      final dir = await getTemporaryDirectory();
      final path = '${dir.path}/cast_ai_${DateTime.now().millisecondsSinceEpoch}.mp4';
      final file = File(path);
      await file.writeAsBytes(response.bodyBytes);

      isLoading.value = false;

      final content = PostStoryContent(
        type: PostStoryContentType.reel,
        content: path,
      );

      Get.to(() => CreateFeedScreen(createType: CreateFeedType.reel, content: content));
    } catch (e) {
      isLoading.value = false;
      showSnackBar('Failed to prepare video for posting: $e');
    }
  }
}
