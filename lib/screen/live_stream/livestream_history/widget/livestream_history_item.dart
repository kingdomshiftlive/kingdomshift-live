import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shortzz/model/livestream/livestream_history.dart';
import 'package:video_player/video_player.dart';

import '../../../../utilities/theme_res.dart';
import '../livestream_history_controller.dart';
import 'package:shortzz/common/service/api/post_service.dart';
import 'full_screen_video_player.dart';

class LivestreamItemWidget extends StatefulWidget {
  final HistoryItem livestream;
  final String videoUrl;
  final String userId;

  const LivestreamItemWidget({
    super.key,
    required this.livestream,
    required this.videoUrl,
    required this.userId,
  });

  @override
  State<LivestreamItemWidget> createState() => _LivestreamItemWidgetState();
}

class _LivestreamItemWidgetState extends State<LivestreamItemWidget> {
  late VideoPlayerController _controller;
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.networkUrl(Uri.parse(widget.videoUrl))
      ..initialize().then((_) {
        setState(() {
          _isInitialized = true;
        });
      });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    LivestreamHistoryController controller = Get.find<LivestreamHistoryController>();
    return Card(
      elevation: 8,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            colors: [Colors.grey[900]!, Colors.grey[800]!],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 10.0, top: 5, bottom: 5),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      'Livestream',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                  ),
                  PopupMenuButton(
                    popUpAnimationStyle: const AnimationStyle(curve: Curves.easeInCubic),
                    icon: Icon(Icons.more_vert, color: whitePure(context)),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    color: Colors.grey[850],
                    itemBuilder: (context) => [
                      PopupMenuItem(
                        child: Text(
                          'Delete',
                          style: TextStyle(color: whitePure(context)),
                        ),
                        onTap: () async {
                          await controller.deleteLivestreams(widget.livestream.id);
                          // Add delete functionality here
                        },
                      ),
                      PopupMenuItem(
                        child: Text(
                          'Download',
                          style: TextStyle(color: whitePure(context)),
                        ),
                        onTap: () {
                          final videoUrl = widget.videoUrl;
                          final fileName = videoUrl.split('/').last;
                          controller.downloadVideo(videoUrl, fileName);
                        },
                      ),
                      PopupMenuItem(
                        child: Text(
                          'Save as Podcast Episode',
                          style: TextStyle(color: whitePure(context)),
                        ),
                        onTap: () async {
                          final success = await PostService.instance.saveRecordingAsPodcast(
                            videoUrl: widget.videoUrl,
                            title: 'Livestream - ${widget.livestream.createdAt?.split('T').first ?? ''}',
                          );
                          controller.showSnackBar(success
                              ? 'Saved to Podcasts'
                              : 'Failed to save as podcast episode');
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: _isInitialized
                    ? GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => FullScreenVideoPlayer(videoUrl: widget.videoUrl),
                            ),
                          );
                        },
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            VideoPlayer(_controller),
                            AnimatedOpacity(
                              opacity: _controller.value.isPlaying ? 0.0 : 1.0,
                              duration: const Duration(milliseconds: 300),
                              child: Center(
                                child: Container(
                                  width: 45,
                                  height: 45,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Colors.black.withValues(alpha: 0.6),
                                  ),
                                  child: IconButton(
                                    icon: Icon(
                                      _controller.value.isPlaying ? Icons.pause : Icons.play_arrow,
                                      size: 30,
                                      color: Colors.white,
                                    ),
                                    onPressed: () {
                                      setState(() {
                                        _controller.value.isPlaying ? _controller.pause() : _controller.play();
                                      });
                                    },
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      )
                    : const Center(
                        child: CircularProgressIndicator(color: Colors.white),
                      ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 5),
              child: Text(
                widget.livestream.createdAt?.split('T').first ?? 'Livestream',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.white70,
                      fontStyle: FontStyle.italic,
                    ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
