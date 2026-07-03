import 'dart:convert';
import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shortzz/model/livestream/livestream_history.dart';
import 'package:shortzz/utilities/const_res.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../common/controller/base_controller.dart';

class LivestreamHistoryController extends BaseController {
  var livestreams = <HistoryItem>[].obs;
  final String apiUrl =
      'https://admin.godinfluencex.com/api/recording-history/';
  final String deleteApiUrl =
      'https://admin.godinfluencex.com/api/delete-recording-history/';
  var downloadProgress = <String, double>{}.obs;

  final String userId;

  LivestreamHistoryController({required this.userId});

  @override
  void onInit() {
    super.onInit();
// Register callback only if flutter_downloader is initialized
    if (FlutterDownloader.initialized) {
      FlutterDownloader.registerCallback(downloadCallback);
    } else {
      FlutterDownloader.initialize(debug: true).then((_) {
        FlutterDownloader.registerCallback(downloadCallback);
      }).catchError((e) {
        showSnackBar('Download plugin initialization failed: $e');
      });
    }
    // Delay fetchLivestreams until after the build phase
    WidgetsBinding.instance.addPostFrameCallback((_) {
      fetchLivestreams(userId);
    });
  }

  Future<void> fetchLivestreams(String userId) async {
    print('test 0');
    try {
      showLoader();
      print('test 1');

      final response = await http.get(Uri.parse(apiUrl + userId));
      print('test 2 user id = $userId = ${response.body}');

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        final livestreamHistory = LivestreamHistory.fromJson(jsonData);
        if (livestreamHistory.status == true &&
            livestreamHistory.history != null) {
          final sortedHistory = livestreamHistory.history!;
          sortedHistory.sort((a, b) => (b.id ?? 0).compareTo(a.id ?? 0));
          livestreams.value = sortedHistory;
        } else {
          showSnackBar('No livestreams found');
        }
      } else {
        showSnackBar('Failed to load livestreams: ${response.statusCode}');
      }
    } catch (e) {
      showSnackBar('Error: $e');
    } finally {
      stopLoader();
    }
  }

  Future<void> deleteLivestreams(int? videoId) async {
    try {
      showLoader();
      final response =
          await http.get(Uri.parse(deleteApiUrl + videoId.toString()));
      if (response.statusCode == 200) {
        livestreams.remove(livestreams
            .where(
              (element) => element.id == videoId,
            )
            .first);
        stopLoader();
        showSnackBar('History Deleted successfully!');
      } else {
        stopLoader();
        showSnackBar('Failed to delete livestreams: ${response.statusCode}');
      }
    } catch (e) {
      stopLoader();
      showSnackBar('Error: $e');
    } finally {
      stopLoader();
    }
  }

  // Download callback to handle progress and status updates
  @pragma('vm:entry-point')
  static void downloadCallback(String id, int status, int progress) {
    final controller = Get.find<LivestreamHistoryController>();
    print(
        'download test callback = id: $id, status: $status, progress: $progress');

    controller.downloadProgress[id] = progress / 100.0;
    final downloadStatus = DownloadTaskStatus.fromInt(status);
    print('download test download status = ${downloadStatus.name}');

    if (downloadStatus == DownloadTaskStatus.running && !Get.isDialogOpen!) {
      Get.dialog(
        AlertDialog(
          title: const Text('Downloading'),
          content: Obx(() => Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  LinearProgressIndicator(
                      value: controller.downloadProgress[id] ?? 0.0),
                  const SizedBox(height: 10),
                  Text(
                      '${(controller.downloadProgress[id]! * 100).toStringAsFixed(0)}% complete'),
                ],
              )),
          actions: [
            TextButton(
              onPressed: () {
                FlutterDownloader.cancel(taskId: id);
                Get.back();
              },
              child: const Text('Cancel'),
            ),
          ],
        ),
        barrierDismissible: false,
      );
    } else if (downloadStatus == DownloadTaskStatus.complete ||
        downloadStatus == DownloadTaskStatus.failed ||
        downloadStatus == DownloadTaskStatus.canceled) {
      if (Get.isDialogOpen!) Get.back();
      controller.showSnackBar(
        downloadStatus == DownloadTaskStatus.complete
            ? 'Download complete'
            : downloadStatus == DownloadTaskStatus.failed
                ? 'Download failed'
                : 'Download canceled',
      );
      controller.downloadProgress.remove(id);
    }
  }

  Future<void> downloadVideo(String fileUrl, String fileName) async {
    try {
      // Step 1: Permission Check
      bool permission = await requestStoragePermission();

      if (!permission) {
        showSnackBar("Storage permission denied");
        return;
      }

      // Step 2: Directory Path
      Directory? dir;
      if (Platform.isAndroid) {
        dir = Directory('/storage/emulated/0/Download');
        if (!(await dir.exists())) {
          dir = await getExternalStorageDirectory();
        }
      } else {
        dir = await getApplicationDocumentsDirectory();
      }
      // Step 3: Start download with flutter_downloader
      final taskId = await FlutterDownloader.enqueue(
        url: fileUrl,
        savedDir: dir!.path,
        fileName: fileName,
        showNotification: true,
        openFileFromNotification: true,
        saveInPublicStorage: true,
      );

      if (taskId != null) {
        downloadProgress[taskId] = 0.0; // Initialize progress tracking
      } else {
        showSnackBar("Failed to start download");
      }
    } catch (e) {
      showSnackBar("Download failed: $e");
    } finally {
      if (await canLaunchUrl(Uri.parse(fileUrl))) {
        await launchUrl(Uri.parse(fileUrl));
      }
    }
  }

  Future<bool> requestStoragePermission() async {
    if (Platform.isAndroid) {
      final androidInfo = await DeviceInfoPlugin().androidInfo;
      final sdkInt = androidInfo.version.sdkInt;

      if (sdkInt >= 33) {
        // Android 13+
        var status = await Permission.videos.status;
        if (status.isGranted) return true;

        var result = await Permission.videos.request();
        if (result.isGranted) return true;

        if (result.isPermanentlyDenied) openAppSettings();
        return false;
      } else {
        // Android 12 or below
        var status = await Permission.storage.status;
        if (status.isGranted) return true;

        var result = await Permission.storage.request();
        if (result.isGranted) return true;

        if (result.isPermanentlyDenied) openAppSettings();
        return false;
      }
    } else if (Platform.isIOS) {
      // iOS doesn't require explicit storage permissions for app-specific directories
      return true;
    }
    return true;
  }

  Future<void> showPermissionDialog() async {
    await Get.defaultDialog(
      title: 'Permission Required',
      middleText:
          'Storage permission is permanently denied.\nPlease enable it from settings.',
      confirm: ElevatedButton(
        child: const Text("Open Settings"),
        onPressed: () {
          openAppSettings();
          Get.back();
        },
      ),
      cancel: TextButton(
        onPressed: () => Get.back(),
        child: const Text("Cancel"),
      ),
    );
  }

  String getFullVideoUrl(String? relativeUrl) =>
      relativeUrl != null ? videoBaseUrl + relativeUrl : '';
}
