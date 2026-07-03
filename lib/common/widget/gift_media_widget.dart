import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

import 'custom_image.dart';

class GiftMediaWidget extends StatefulWidget {
  final String mediaUrl;
  final Size size;
  final double radius;
  final double cornerSmoothing;
  final bool isShowPlaceHolder;

  const GiftMediaWidget({
    super.key,
    required this.mediaUrl,
    this.size = const Size(50, 50),
    this.radius = 10,
    this.cornerSmoothing = 0,
    this.isShowPlaceHolder = true,
  });

  @override
  State<GiftMediaWidget> createState() => _GiftMediaWidgetState();
}

class _GiftMediaWidgetState extends State<GiftMediaWidget> {
  VideoPlayerController? _controller;
  bool _isVideo = false;
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    // Check if the URL is a video based on its extension
    _isVideo = _isVideoUrl(widget.mediaUrl);
    if (_isVideo) {
      _controller = VideoPlayerController.networkUrl(Uri.parse(widget.mediaUrl))
        ..initialize().then((_) {
          setState(() {
            _isInitialized = true;
          });
        }).catchError((error) {
          setState(() {
            _isInitialized =
                false; // Fallback to placeholder if initialization fails
          });
        });
    }
  }

  bool _isVideoUrl(String url) {
    final lowerUrl = url.toLowerCase();
    return lowerUrl.endsWith('.mp4') ||
        lowerUrl.endsWith('.mov') ||
        lowerUrl.endsWith('.avi') ||
        lowerUrl.endsWith('.mkv');
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_isVideo) {
      // Fallback to CustomImage for non-video URLs
      return CustomImage(
        size: widget.size,
        image: widget.mediaUrl,
        cornerSmoothing: widget.cornerSmoothing,
        radius: widget.radius,
        isShowPlaceHolder: widget.isShowPlaceHolder,
      );
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(widget.radius),
      child: SizedBox.fromSize(
        size: widget.size,
        child: _isInitialized && _controller != null
            ? Stack(
                alignment: Alignment.center,
                children: [
                  VideoPlayer(_controller!),
                  Container(
                    width: 30,
                    height: 30,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.black.withValues(alpha: 0.6),
                    ),
                    child: const Icon(
                      Icons.play_arrow,
                      size: 20,
                      color: Colors.white,
                    ),
                  ),
                ],
              )
            : Container(
                color: Colors.grey[300],
                child: widget.isShowPlaceHolder
                    ? const Center(
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : null,
              ),
      ),
    );
  }
}
