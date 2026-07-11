import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shortzz/model/post_story/post_model.dart';
import 'package:shortzz/screen/live_stream/my_live_streams/my_live_streams_controller.dart';
import 'package:shortzz/screen/podcast_screen/podcast_video_player_screen.dart';
import 'package:shortzz/screen/live_stream/my_live_streams/clip_editor_screen.dart';

class MyLiveStreamsScreen extends StatelessWidget {
  const MyLiveStreamsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(MyLiveStreamsController());

    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0F),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0A0A0F),
        elevation: 0,
        title: const Text('My Live Streams',
            style: TextStyle(color: Colors.white, fontSize: 18)),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Obx(() {
        if (controller.isLoading.value && controller.recordings.isEmpty) {
          return const Center(
              child: CircularProgressIndicator(color: Color(0xFF7B2FF7)));
        }
        if (controller.recordings.isEmpty) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(24),
              child: Text(
                'No saved live streams yet.\nGo live and it will show up here automatically - only visible to you.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white54, fontSize: 14),
              ),
            ),
          );
        }
        return RefreshIndicator(
          onRefresh: controller.fetchRecordings,
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: controller.recordings.length,
            itemBuilder: (_, i) {
              final recording = controller.recordings[i];
              return _recordingCard(context, controller, recording);
            },
          ),
        );
      }),
    );
  }

  Widget _recordingCard(BuildContext context, MyLiveStreamsController controller, Post recording) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF12121E),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: const Color(0xFF1A1A2E),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Center(
                    child: Icon(Icons.lock_outline, color: Colors.white54)),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      recording.description ?? 'Untitled Stream',
                      style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 13),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Private - only you can see this',
                      style: TextStyle(color: Colors.white38, fontSize: 11),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _actionButton(
                  icon: Icons.play_arrow,
                  label: 'Watch',
                  onTap: () =>
                      Get.to(() => PodcastVideoPlayerScreen(episode: recording)),
                ),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: _actionButton(
                  icon: Icons.content_cut,
                  label: 'Clip',
                  onTap: () => Get.to(() => ClipEditorScreen(recording: recording)),
                ),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: _actionButton(
                  icon: Icons.download_outlined,
                  label: 'Download',
                  onTap: () => controller.downloadRecording(recording),
                ),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: _actionButton(
                  icon: Icons.public,
                  label: 'Publish',
                  highlighted: true,
                  onTap: () => _confirmPublish(context, controller, recording),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _actionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    bool highlighted = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: highlighted ? const Color(0xFF7B2FF7) : Colors.white.withValues(alpha: 0.06),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          children: [
            Icon(icon, color: Colors.white, size: 18),
            const SizedBox(height: 2),
            Text(label, style: const TextStyle(color: Colors.white, fontSize: 10)),
          ],
        ),
      ),
    );
  }

  void _confirmPublish(BuildContext context, MyLiveStreamsController controller, Post recording) {
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(
          color: Color(0xFF12121E),
          borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Publish this recording as a public podcast episode?\nEveryone will be able to see and play it.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white70, fontSize: 13),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF7B2FF7),
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              onPressed: () {
                Get.back();
                controller.publishAsPodcast(recording);
              },
              child: const Text('Publish', style: TextStyle(color: Colors.white)),
            ),
            const SizedBox(height: 8),
            TextButton(
              onPressed: () => Get.back(),
              child: const Text('Cancel', style: TextStyle(color: Colors.white54)),
            ),
          ],
        ),
      ),
    );
  }
}
