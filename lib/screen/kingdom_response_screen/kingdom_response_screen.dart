import 'dart:async';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:video_player/video_player.dart';
import 'package:shortzz/common/service/frame_recorder_service.dart';
import 'package:shortzz/common/service/api/post_service.dart';
import 'package:shortzz/model/post_story/post_model.dart';
import 'package:shortzz/screen/camera_screen/camera_screen_controller.dart';
import 'package:shortzz/screen/create_feed_screen/create_feed_screen.dart';

/// "Kingdom Response" — a split-screen duet-style feature. The original
/// creator's video plays in the top half while the responder's camera
/// records live in the bottom half. Both halves are captured together
/// using the same frame-capture + FFmpeg pipeline built for live
/// recordings, then handed off to the normal post-creation flow.
class KingdomResponseScreen extends StatefulWidget {
  final Post originalPost;
  const KingdomResponseScreen({super.key, required this.originalPost});

  @override
  State<KingdomResponseScreen> createState() => _KingdomResponseScreenState();
}

class _KingdomResponseScreenState extends State<KingdomResponseScreen> {
  final GlobalKey _recordingBoundaryKey = GlobalKey();
  FrameRecorderService? _frameRecorderService;

  VideoPlayerController? _originalVideoController;
  CameraController? _cameraController;

  bool _isReady = false;
  bool _isRecording = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _setup();
  }

  Future<void> _setup() async {
    try {
      // Original video (top half)
      final videoUrl = widget.originalPost.video ?? '';
      _originalVideoController = VideoPlayerController.networkUrl(Uri.parse(videoUrl));
      await _originalVideoController!.initialize();
      _originalVideoController!.setLooping(false);

      // Live camera (bottom half)
      final cameras = await availableCameras();
      if (cameras.isEmpty) {
        setState(() => _errorMessage = 'No camera available on this device.');
        return;
      }
      final frontCamera = cameras.firstWhere(
        (c) => c.lensDirection == CameraLensDirection.front,
        orElse: () => cameras.first,
      );
      _cameraController = CameraController(frontCamera, ResolutionPreset.medium,
          enableAudio: true);
      await _cameraController!.initialize();

      _originalVideoController!.addListener(_onVideoProgress);

      if (mounted) setState(() => _isReady = true);
    } catch (e) {
      setState(() => _errorMessage = 'Failed to set up Kingdom Response: $e');
    }
  }

  void _onVideoProgress() {
    final controller = _originalVideoController;
    if (controller == null || !_isRecording) return;
    final position = controller.value.position;
    final duration = controller.value.duration;
    if (duration.inMilliseconds > 0 &&
        position.inMilliseconds >= duration.inMilliseconds - 100) {
      _stopRecording();
    }
  }

  Future<void> _startRecording() async {
    if (_isRecording || !_isReady) return;
    _frameRecorderService = FrameRecorderService(_recordingBoundaryKey);
    final started = await _frameRecorderService!.start();
    if (!started) {
      setState(() => _errorMessage = 'Could not start recording.');
      return;
    }
    setState(() => _isRecording = true);
    await _originalVideoController!.seekTo(Duration.zero);
    await _originalVideoController!.play();
  }

  Future<void> _stopRecording() async {
    if (!_isRecording) return;
    setState(() => _isRecording = false);
    await _originalVideoController?.pause();
    final result = await _frameRecorderService?.stop();
    _frameRecorderService = null;

    if (result == null || !mounted) {
      if (mounted) {
        setState(() => _errorMessage = 'Recording did not save. Please try again.');
      }
      return;
    }

    Get.off(() => CreateFeedScreen(
          createType: CreateFeedType.reel,
          content: PostStoryContent(
            type: PostStoryContentType.reel,
            content: result.videoPath,
            thumbNail: result.thumbnailPath,
          ),
        ));
  }

  @override
  void dispose() {
    _originalVideoController?.removeListener(_onVideoProgress);
    _originalVideoController?.dispose();
    _cameraController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text('Kingdom Response',
            style: TextStyle(color: Colors.white, fontSize: 16)),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: _errorMessage != null
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(_errorMessage!,
                    style: const TextStyle(color: Colors.white70),
                    textAlign: TextAlign.center),
              ),
            )
          : !_isReady
              ? const Center(
                  child: CircularProgressIndicator(color: Color(0xFF14C9B8)))
              : RepaintBoundary(
                  key: _recordingBoundaryKey,
                  child: Column(
                    children: [
                      Expanded(
                        child: AspectRatio(
                          aspectRatio: _originalVideoController!.value.aspectRatio,
                          child: VideoPlayer(_originalVideoController!),
                        ),
                      ),
                      Expanded(
                        child: _cameraController != null &&
                                _cameraController!.value.isInitialized
                            ? CameraPreview(_cameraController!)
                            : const SizedBox.shrink(),
                      ),
                    ],
                  ),
                ),
      floatingActionButton: _isReady && _errorMessage == null
          ? FloatingActionButton(
              backgroundColor:
                  _isRecording ? Colors.redAccent : const Color(0xFF14C9B8),
              onPressed: _isRecording ? _stopRecording : _startRecording,
              child: Icon(_isRecording ? Icons.stop_rounded : Icons.fiber_manual_record,
                  color: Colors.white),
            )
          : null,
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}
