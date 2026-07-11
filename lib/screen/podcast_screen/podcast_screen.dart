import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shortzz/model/post_story/post_model.dart';
import 'package:shortzz/screen/podcast_screen/podcast_screen_controller.dart';
import 'package:shortzz/screen/podcast_screen/podcast_video_player_screen.dart';
import 'package:shortzz/screen/live_stream/create_live_stream_screen/create_live_stream_screen.dart';
import 'package:shortzz/screen/live_stream/my_live_streams/my_live_streams_screen.dart';

class PodcastScreen extends StatelessWidget {
  const PodcastScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(PodcastScreenController());

    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0F),
      body: SafeArea(
        child: Column(children: [
          _buildHeader(controller),
          _buildFeatured(controller),
          _buildCategories(controller),
          _buildLiveRow(),
          Expanded(child: _buildEpisodeList(controller)),
        ]),
      ),
      bottomSheet: _buildMiniPlayer(context, controller),
    );
  }

  Widget _buildHeader(PodcastScreenController controller) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      child: Row(children: [
        GestureDetector(
          onTap: controller.onCreateTap,
          child: Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: const LinearGradient(
                      colors: [Color(0xFF7B2FF7), Color(0xFFFF006E)])),
              child: const Icon(Icons.mic, color: Colors.white, size: 22)),
        ),
        const SizedBox(width: 12),
        const Expanded(
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Podcasts for Everyone',
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold)),
          Text('Listen, learn, and be inspired',
              style: TextStyle(color: Colors.white54, fontSize: 12)),
        ])),
        GestureDetector(
          onTap: controller.onCreateTap,
          child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                  gradient: const LinearGradient(
                      colors: [Color(0xFF7B2FF7), Color(0xFF00C6FF)]),
                  borderRadius: BorderRadius.circular(20)),
              child: const Text('+ Create',
                  style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 12))),
        ),
      ]),
    );
  }

  Widget _buildFeatured(PodcastScreenController controller) {
    return Obx(() {
      // Group episodes by category to build featured "show" cards from real data
      final Map<String, List<Post>> byCategory = {};
      for (final ep in controller.episodes) {
        final cat = (ep.metadata?.isNotEmpty ?? false) ? ep.metadata! : 'General';
        byCategory.putIfAbsent(cat, () => []).add(ep);
      }
      final entries = byCategory.entries.toList();

      if (controller.isLoading.value && entries.isEmpty) {
        return const SizedBox(height: 180);
      }
      if (entries.isEmpty) {
        return const SizedBox.shrink();
      }

      return SizedBox(
        height: 180,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
          itemCount: entries.length,
          itemBuilder: (_, i) {
            final cat = entries[i].key;
            final eps = entries[i].value;
            final host = eps.first.user?.fullname ?? eps.first.user?.username ?? 'Creator';
            return GestureDetector(
              onTap: () => controller.onCategoryChanged(cat),
              child: Container(
                width: 160,
                margin: const EdgeInsets.only(right: 12),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  gradient: LinearGradient(colors: [
                    const Color(0xFF7B2FF7).withValues(alpha: 0.3),
                    const Color(0xFF12121E)
                  ], begin: Alignment.topLeft, end: Alignment.bottomRight),
                  border: Border.all(
                      color: const Color(0xFF7B2FF7).withValues(alpha: 0.3)),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('🎙️', style: TextStyle(fontSize: 40)),
                        const Spacer(),
                        Text(cat,
                            style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 14),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis),
                        Text(host,
                            style: const TextStyle(
                                color: Colors.white54, fontSize: 12),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis),
                        Text('${eps.length} episode${eps.length == 1 ? '' : 's'}',
                            style: const TextStyle(
                                color: Color(0xFF7B2FF7), fontSize: 11)),
                      ]),
                ),
              ),
            );
          },
        ),
      );
    });
  }

  Widget _buildCategories(PodcastScreenController controller) {
    return Obx(() {
      final cats = controller.categories;
      return SizedBox(
        height: 44,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
          itemCount: cats.length,
          itemBuilder: (_, i) {
            final sel = controller.selectedCategory.value == cats[i];
            return GestureDetector(
              onTap: () => controller.onCategoryChanged(cats[i]),
              child: Container(
                margin: const EdgeInsets.only(right: 8),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                decoration: BoxDecoration(
                  color: sel ? const Color(0xFF7B2FF7) : const Color(0xFF12121E),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                      color: sel ? const Color(0xFF7B2FF7) : Colors.white12),
                ),
                child: Text(cats[i],
                    style: TextStyle(
                        color: sel ? Colors.white : Colors.white54,
                        fontSize: 13)),
              ),
            );
          },
        ),
      );
    });
  }

  Widget _buildLiveRow() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      child: Row(children: [
        Expanded(
          child: GestureDetector(
            onTap: () => Get.to(() => const CreateLiveStreamScreen(isPodcastMode: true)),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 10),
              decoration: BoxDecoration(
                gradient: const LinearGradient(colors: [Color(0xFFFF006E), Color(0xFF7B2FF7)]),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.podcasts, color: Colors.white, size: 18),
                  SizedBox(width: 6),
                  Text('Go Live', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: GestureDetector(
            onTap: () => Get.to(() => const MyLiveStreamsScreen()),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 10),
              decoration: BoxDecoration(
                color: const Color(0xFF12121E),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.white12),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.lock_outline, color: Colors.white70, size: 18),
                  SizedBox(width: 6),
                  Text('My Live Streams', style: TextStyle(color: Colors.white70, fontWeight: FontWeight.bold, fontSize: 13)),
                ],
              ),
            ),
          ),
        ),
      ]),
    );
  }

  Widget _buildEpisodeList(PodcastScreenController controller) {
    return Obx(() {
      if (controller.isLoading.value && controller.episodes.isEmpty) {
        return const Center(
            child: CircularProgressIndicator(color: Color(0xFF7B2FF7)));
      }
      if (controller.episodes.isEmpty) {
        return const Center(
            child: Text('No episodes yet',
                style: TextStyle(color: Colors.white54)));
      }
      return ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: controller.episodes.length,
        itemBuilder: (_, i) {
          final ep = controller.episodes[i];
          return Obx(() {
            final isCurrentEpisode =
                controller.currentlyPlaying.value?.supabaseId == ep.supabaseId;
            final isPlayingThis = isCurrentEpisode && controller.isPlaying.value;
            return GestureDetector(
              onTap: () => controller.playEpisode(ep),
              onLongPress: () => _showDeleteSheet(controller, ep),
              child: Container(
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                    color: const Color(0xFF12121E),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                        color: isCurrentEpisode
                            ? const Color(0xFF7B2FF7)
                            : Colors.white12)),
                child: Row(children: [
                  Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                          color: const Color(0xFF1A1A2E),
                          borderRadius: BorderRadius.circular(10)),
                      child: const Center(
                          child: Text('🎙️', style: TextStyle(fontSize: 28)))),
                  const SizedBox(width: 12),
                  Expanded(
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                        Text(ep.description ?? 'Untitled Episode',
                            style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 13),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis),
                        Text(
                            '${ep.user?.fullname ?? ep.user?.username ?? "Creator"}'
                            '${controller.formatDuration(ep.durationSeconds).isNotEmpty ? " • ${controller.formatDuration(ep.durationSeconds)}" : ""}',
                            style: const TextStyle(
                                color: Colors.white54, fontSize: 12)),
                      ])),
                  Column(children: [
                    Icon(
                        isPlayingThis
                            ? Icons.pause_circle_filled
                            : Icons.play_circle_fill,
                        color: const Color(0xFF7B2FF7),
                        size: 36),
                    const SizedBox(height: 6),
                    GestureDetector(
                      onTap: () async {
                        await controller.pauseForWatch();
                        Get.to(() => PodcastVideoPlayerScreen(episode: ep));
                      },
                      child: const Icon(Icons.play_circle_outline,
                          color: Colors.white38, size: 20),
                    ),
                  ]),
                ]),
              ),
            );
          });
        },
      );
    });
  }

  Widget _buildMiniPlayer(BuildContext context, PodcastScreenController controller) {
    return Obx(() {
      final current = controller.currentlyPlaying.value;
      if (current == null) return const SizedBox.shrink();

      return Container(
        height: 64,
        decoration: BoxDecoration(
            color: const Color(0xFF12121E),
            border: Border(
                top: BorderSide(color: Colors.white.withValues(alpha: 0.08)))),
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(children: [
          const Text('🎙️', style: TextStyle(fontSize: 28)),
          const SizedBox(width: 12),
          Expanded(
              child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                Text(current.description ?? 'Untitled Episode',
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis),
                Text(current.user?.fullname ?? current.user?.username ?? 'Creator',
                    style: const TextStyle(color: Colors.white54, fontSize: 11)),
              ])),
          SizedBox(
            width: 60,
            child: Row(children: [
              Icon(
                  controller.volume.value == 0
                      ? Icons.volume_off
                      : Icons.volume_up,
                  color: Colors.white54,
                  size: 16),
              Expanded(
                child: SliderTheme(
                  data: SliderTheme.of(context).copyWith(
                    trackHeight: 2,
                    thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 5),
                    overlayShape: SliderComponentShape.noOverlay,
                    activeTrackColor: const Color(0xFF7B2FF7),
                    inactiveTrackColor: Colors.white24,
                    thumbColor: const Color(0xFF7B2FF7),
                  ),
                  child: Slider(
                    value: controller.volume.value,
                    onChanged: controller.setVolume,
                  ),
                ),
              ),
            ]),
          ),
          const SizedBox(width: 8),
          Row(children: [
            IconButton(
                icon: const Icon(Icons.skip_previous, color: Colors.white70),
                onPressed: controller.skipPrevious),
            GestureDetector(
              onTap: controller.togglePlayPause,
              child: Container(
                  width: 36,
                  height: 36,
                  decoration: const BoxDecoration(
                      color: Color(0xFF7B2FF7), shape: BoxShape.circle),
                  child: Icon(
                      controller.isPlaying.value
                          ? Icons.pause
                          : Icons.play_arrow,
                      color: Colors.white,
                      size: 20)),
            ),
            IconButton(
                icon: const Icon(Icons.skip_next, color: Colors.white70),
                onPressed: controller.skipNext),
            IconButton(
                icon: const Icon(Icons.visibility_outlined, color: Colors.white70),
                onPressed: () async {
                  await controller.pauseForWatch();
                  Get.to(() => PodcastVideoPlayerScreen(episode: current));
                }),
          ]),
        ]),
      );
    });
  }

  void _showDeleteSheet(PodcastScreenController controller, Post episode) {
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
            Text(
              episode.description ?? 'Untitled Episode',
              style: const TextStyle(color: Colors.white70, fontSize: 13),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent,
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              icon: const Icon(Icons.delete_outline, color: Colors.white),
              label: const Text('Delete Episode', style: TextStyle(color: Colors.white)),
              onPressed: () {
                Get.back();
                controller.deleteEpisode(episode);
              },
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
