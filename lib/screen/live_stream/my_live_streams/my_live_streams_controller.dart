import 'dart:io';

import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:get/get.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shortzz/common/controller/base_controller.dart';
import 'package:shortzz/common/service/api/post_service.dart';
import 'package:shortzz/model/post_story/post_model.dart';

class MyLiveStreamsController extends BaseController {
  RxList<Post> recordings = <Post>[].obs;
  RxMap<String, double> downloadProgress = <String, double>{}.obs;

  @override
  void onInit() {
    super.onInit();
    if (FlutterDownloader.initialized) {
      FlutterDownloader.registerCallback(downloadCallback);
    } else {
      FlutterDownloader.initialize(debug: true).then((_) {
        FlutterDownloader.registerCallback(downloadCallback);
      });
    }
    fetchRecordings();
  }

  Future<void> fetchRecordings() async {
    isLoading.value = true;
    recordings.value = await PostService.instance.fetchMyLiveRecordings();
    isLoading.value = false;
  }

  Future<void> publishAsPodcast(Post recording) async {
    final id = recording.supabaseId;
    if (id == null) return;
    final success =
        await PostService.instance.publishLiveRecordingAsPodcast(supabaseId: id);
    if (success) {
      recordings.removeWhere((e) => e.supabaseId == id);
      showSnackBar('Published to Podcasts');
    } else {
      showSnackBar('Failed to publish');
    }
  }

  Future<void> deleteRecording(Post recording) async {
    final id = recording.supabaseId;
    if (id == null) return;
    final success = await PostService.instance.deleteSupabaseVideo(supabaseId: id);
    if (success) {
      recordings.removeWhere((e) => e.supabaseId == id);
    }
  }

  Future<void> downloadRecording(Post recording) async {
    final url = recording.video ?? '';
    if (url.isEmpty) return;

    final hasPermission = await _requestStoragePermission();
    if (!hasPermission) {
      showSnackBar('Storage permission denied');
      return;
    }

    Directory? dir;
    if (Platform.isAndroid) {
      dir = Directory('/storage/emulated/0/Download');
      if (!(await dir.exists())) {
        dir = await getExternalStorageDirectory();
      }
    } else {
      dir = await getApplicationDocumentsDirectory();
    }
    if (dir == null) return;

    final fileName = url.split('/').last;
    final taskId = await FlutterDownloader.enqueue(
      url: url,
      savedDir: dir.path,
      fileName: fileName,
      showNotification: true,
      openFileFromNotification: true,
      saveInPublicStorage: true,
    );
    if (taskId != null) {
      downloadProgress[taskId] = 0.0;
      showSnackBar('Download started');
    }
  }

  Future<bool> _requestStoragePermission() async {
    if (Platform.isIOS) return true;
    var status = await Permission.videos.status;
    if (status.isGranted) return true;
    var result = await Permission.videos.request();
    if (result.isGranted) return true;
    // Fall back for older Android versions
    status = await Permission.storage.status;
    if (status.isGranted) return true;
    result = await Permission.storage.request();
    return result.isGranted;
  }

  @pragma('vm:entry-point')
  static void downloadCallback(String id, int status, int progress) {
    if (!Get.isRegistered<MyLiveStreamsController>()) return;
    final controller = Get.find<MyLiveStreamsController>();
    controller.downloadProgress[id] = progress / 100.0;
  }
}
