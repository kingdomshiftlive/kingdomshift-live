import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:shortzz/model/post_story/post_model.dart';

class PodcastVideoPlayerScreen extends StatefulWidget {
  final Post episode;
  const PodcastVideoPlayerScreen({super.key, required this.episode});

  @override
  State<PodcastVideoPlayerScreen> createState() => _PodcastVideoPlayerScreenState();
}

class _PodcastVideoPlayerScreenState extends State<PodcastVideoPlayerScreen> {
  VideoPlayerController? _controller;
  bool _isReady = false;
  bool _hasError = false;
  bool _showControls = true;

  @override
  void initState() {
    super.initState();
    final url = widget.episode.video ?? '';
    if (url.isEmpty) {
      _hasError = true;
      return;
    }
    _controller = VideoPlayerController.networkUrl(Uri.parse(url))
      ..initialize().then((_) {
        if (!mounted) return;
        setState(() => _isReady = true);
        _controller?.play();
      }).catchError((e) {
        if (!mounted) return;
        setState(() => _hasError = true);
      });
    _controller?.addListener(() {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Stack(
          children: [
            Center(
              child: _hasError
                  ? const Text('Unable to load video',
                      style: TextStyle(color: Colors.white54))
                  : !_isReady
                      ? const CircularProgressIndicator(color: Color(0xFF7B2FF7))
                      : GestureDetector(
                          onTap: () => setState(() => _showControls = !_showControls),
                          child: AspectRatio(
                            aspectRatio: _controller!.value.aspectRatio == 0
                                ? 16 / 9
                                : _controller!.value.aspectRatio,
                            child: VideoPlayer(_controller!),
                          ),
                        ),
            ),
            Positioned(
              top: 8,
              left: 8,
              child: IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ),
            if (_isReady && _showControls)
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: Container(
                  padding: const EdgeInsets.fromLTRB(16, 24, 16, 12),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [Colors.transparent, Colors.black.withValues(alpha: 0.8)],
                    ),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        widget.episode.description ?? 'Untitled Episode',
                        style: const TextStyle(
                            color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 8),
                      VideoProgressIndicator(
                        _controller!,
                        allowScrubbing: true,
                        colors: const VideoProgressColors(
                          playedColor: Color(0xFF7B2FF7),
                          bufferedColor: Colors.white24,
                          backgroundColor: Colors.white12,
                        ),
                      ),
                      const SizedBox(height: 4),
                      IconButton(
                        icon: Icon(
                          _controller!.value.isPlaying ? Icons.pause : Icons.play_arrow,
                          color: Colors.white,
                          size: 36,
                        ),
                        onPressed: () {
                          setState(() {
                            _controller!.value.isPlaying
                                ? _controller!.pause()
                                : _controller!.play();
                          });
                        },
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
