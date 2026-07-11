import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:video_player/video_player.dart';
import 'package:shortzz/model/post_story/post_model.dart';
import 'package:shortzz/screen/live_stream/my_live_streams/clip_editor_controller.dart';

class ClipEditorScreen extends StatelessWidget {
  final Post recording;
  const ClipEditorScreen({super.key, required this.recording});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(ClipEditorController(recording));

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        title: const Text('Create Clip', style: TextStyle(color: Colors.white)),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Obx(() {
        if (controller.isPreparing.value) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(color: Color(0xFF7B2FF7)),
                SizedBox(height: 16),
                Text('Preparing video...', style: TextStyle(color: Colors.white54)),
              ],
            ),
          );
        }

        final preview = controller.previewController;
        if (preview == null || !preview.value.isInitialized) {
          return const Center(
            child: Text('Unable to load video', style: TextStyle(color: Colors.white54)),
          );
        }

        return Column(
          children: [
            Expanded(
              child: GestureDetector(
                onTap: controller.togglePreview,
                child: Center(
                  child: AspectRatio(
                    aspectRatio: preview.value.aspectRatio == 0 ? 9 / 16 : preview.value.aspectRatio,
                    child: VideoPlayer(preview),
                  ),
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
              decoration: const BoxDecoration(
                color: Color(0xFF12121E),
                borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Clip length: ${(controller.endSeconds.value - controller.startSeconds.value).toStringAsFixed(1)}s '
                    '(max ${ClipEditorController.maxClipSeconds.toInt()}s)',
                    style: const TextStyle(color: Colors.white70, fontSize: 12),
                  ),
                  const SizedBox(height: 8),
                  RangeSlider(
                    values: RangeValues(controller.startSeconds.value, controller.endSeconds.value),
                    min: 0,
                    max: controller.totalSeconds.value == 0 ? 1 : controller.totalSeconds.value,
                    activeColor: const Color(0xFF7B2FF7),
                    inactiveColor: Colors.white24,
                    onChanged: (range) {
                      double start = range.start;
                      double end = range.end;
                      if (end - start > ClipEditorController.maxClipSeconds) {
                        // Keep the clip within the max length by anchoring
                        // to whichever handle the user is actively moving.
                        if (start != controller.startSeconds.value) {
                          end = start + ClipEditorController.maxClipSeconds;
                        } else {
                          start = end - ClipEditorController.maxClipSeconds;
                        }
                      }
                      controller.startSeconds.value = start;
                      controller.endSeconds.value = end;
                    },
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF7B2FF7),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)),
                      ),
                      onPressed: controller.isExporting.value ? null : controller.exportClip,
                      child: controller.isExporting.value
                          ? const SizedBox(
                              height: 18,
                              width: 18,
                              child: CircularProgressIndicator(
                                  strokeWidth: 2, color: Colors.white),
                            )
                          : const Text('Create Clip',
                              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      }),
    );
  }
}
