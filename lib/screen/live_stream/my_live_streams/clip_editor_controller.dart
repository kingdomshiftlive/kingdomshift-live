import 'dart:io';

import 'package:video_compress/video_compress.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:video_player/video_player.dart';
import 'package:shortzz/common/controller/base_controller.dart';
import 'package:shortzz/model/post_story/post_model.dart';
import 'package:shortzz/screen/camera_screen/camera_screen_controller.dart';
import 'package:shortzz/screen/create_feed_screen/create_feed_screen.dart';

class ClipEditorController extends BaseController {
  final Post recording;
  ClipEditorController(this.recording);

  VideoPlayerController? previewController;
  String? _localFilePath;

  RxBool isPreparing = true.obs;
  RxBool isExporting = false.obs;
  RxDouble startSeconds = 0.0.obs;
  RxDouble endSeconds = 0.0.obs;
  RxDouble totalSeconds = 0.0.obs;

  static const double maxClipSeconds = 60;

  @override
  void onInit() {
    super.onInit();
    _prepare();
  }

  @override
  void onClose() {
    previewController?.dispose();
    VideoCompress.deleteAllCache();
    super.onClose();
  }

  Future<void> _prepare() async {
    isPreparing.value = true;
    final url = recording.video ?? '';
    if (url.isEmpty) {
      showSnackBar('No video found for this recording');
      isPreparing.value = false;
      return;
    }

    try {
      final response = await http.get(Uri.parse(url));
      final dir = await getTemporaryDirectory();
      final path = '${dir.path}/clip_source_${DateTime.now().millisecondsSinceEpoch}.mp4';
      final file = File(path);
      await file.writeAsBytes(response.bodyBytes);
      _localFilePath = path;

      previewController = VideoPlayerController.file(file);
      await previewController!.initialize();
      final durationSeconds = previewController!.value.duration.inMilliseconds / 1000;
      totalSeconds.value = durationSeconds;
      startSeconds.value = 0;
      endSeconds.value = durationSeconds < maxClipSeconds ? durationSeconds : maxClipSeconds;

      isPreparing.value = false;
    } catch (e) {
      showSnackBar('Failed to load video for clipping: $e');
      isPreparing.value = false;
    }
  }

  void togglePreview() {
    final controller = previewController;
    if (controller == null) return;
    if (controller.value.isPlaying) {
      controller.pause();
    } else {
      controller.seekTo(Duration(milliseconds: (startSeconds.value * 1000).round()));
      controller.play();
    }
  }

  Future<void> exportClip() async {
    final path = _localFilePath;
    if (path == null) return;
    if (endSeconds.value <= startSeconds.value) {
      showSnackBar('Select a valid clip range');
      return;
    }

    isExporting.value = true;
    try {
      // Some transcoders measure the file's true duration slightly
      // shorter than what video_player reports (common with live-recorded,
      // variable-frame-rate footage). Keep a small safety margin so the
      // requested trim end never touches the reported duration exactly.
      const safetyMarginSeconds = 0.5;
      final safeEnd = (endSeconds.value < totalSeconds.value - safetyMarginSeconds)
          ? endSeconds.value
          : (totalSeconds.value - safetyMarginSeconds).clamp(startSeconds.value + 0.1, totalSeconds.value);
      final clipDurationMs = ((safeEnd - startSeconds.value) * 1000).round();
      print('MY CLIP - compressing/trimming from ${startSeconds.value}s, duration ${clipDurationMs}ms (safeEnd=$safeEnd, total=${totalSeconds.value})');
      final info = await VideoCompress.compressVideo(
        path,
        quality: VideoQuality.DefaultQuality,
        startTime: (startSeconds.value * 1000).round(),
        duration: clipDurationMs,
        includeAudio: true,
        frameRate: 30,
      );
      final trimmedPath = info?.path;
      print('MY CLIP - trimmedPath result: $trimmedPath');

      isExporting.value = false;

      if (trimmedPath == null) {
        showSnackBar('Failed to create clip');
        return;
      }

      final clipContent = PostStoryContent(
        type: PostStoryContentType.reel,
        content: trimmedPath,
        duration: (endSeconds.value - startSeconds.value).round(),
      );

      Get.off(() => CreateFeedScreen(
            createType: CreateFeedType.reel,
            content: clipContent,
          ));
    } catch (e, stackTrace) {
      isExporting.value = false;
      print('MY CLIP ERROR: $e');
      print('MY CLIP ERROR STACKTRACE: $stackTrace');
      showSnackBar('Failed to create clip: $e');
    }
  }
}
