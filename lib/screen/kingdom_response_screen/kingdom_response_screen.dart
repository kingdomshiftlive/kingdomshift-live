import 'dart:async';
import 'dart:io';
import 'package:camera/camera.dart';
import 'package:file_picker/file_picker.dart';
import 'package:gal/gal.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:supabase_flutter/supabase_flutter.dart' as supabase;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:video_player/video_player.dart';
import 'package:shortzz/common/service/frame_recorder_service.dart';
import 'package:shortzz/common/service/api/post_service.dart';
import 'package:shortzz/model/post_story/post_model.dart';
import 'package:shortzz/screen/camera_screen/camera_screen_controller.dart';
import 'package:shortzz/screen/create_feed_screen/create_feed_screen.dart';

/// "Kingdom Response" — replaces Kingdom Dual as the app's react feature.
/// The source video plays in the top half while the responder's camera
/// records live in the bottom half. Both halves are captured together
/// using the same frame-capture + FFmpeg pipeline built for live
/// recordings.
///
/// Source video can come from an existing in-app post (pass
/// [originalPost]) or, if none is passed, from the responder's own
/// device via an in-screen "Upload video" picker — this is the entry
/// point used from the main nav bar.
///
/// After recording, mirrors Kingdom Dual's review flow: Retake / Save to
/// Gallery / Use in a Post, plus a background save into the Reactions
/// library (content_type: 'kingdom_response') so recordings show up in
/// their own tab on the profile, same mechanism Kingdom Dual used.
class KingdomResponseScreen extends StatefulWidget {
  final Post? originalPost;
  const KingdomResponseScreen({super.key, this.originalPost});

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
  bool _isPaused = false;
  bool _needsSourcePick = false;
  bool _isSaving = false;
  String? _saveMessage;
  String? _resultVideoPath;
  VideoPlayerController? _previewController;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    if (widget.originalPost != null) {
      _setup(networkUrl: widget.originalPost!.video ?? '');
    } else {
      _needsSourcePick = true;
      _initCameraOnly();
    }
  }

  Future<void> _initCameraOnly() async {
    try {
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
      if (mounted) setState(() {});
    } catch (e) {
      setState(() => _errorMessage = 'Failed to set up camera: $e');
    }
  }

  Future<void> _pickVideoFromDevice() async {
    try {
      final result = await FilePicker.platform.pickFiles(type: FileType.video);
      final path = result?.files.single.path;
      if (path == null) return; // user cancelled
      setState(() => _needsSourcePick = false);
      await _setup(localFile: File(path));
    } catch (e) {
      setState(() => _errorMessage = 'Failed to load video: $e');
    }
  }

  Future<void> _setup({String? networkUrl, File? localFile}) async {
    try {
      _originalVideoController = localFile != null
          ? VideoPlayerController.file(localFile)
          : VideoPlayerController.networkUrl(Uri.parse(networkUrl ?? ''));
      await _originalVideoController!.initialize();
      _originalVideoController!.setLooping(false);

      if (_cameraController == null || !_cameraController!.value.isInitialized) {
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
      }

      _originalVideoController!.addListener(_onVideoProgress);

      if (mounted) setState(() => _isReady = true);
    } catch (e) {
      setState(() => _errorMessage = 'Failed to set up Kingdom Response: $e');
    }
  }

  void _onVideoProgress() {
    final controller = _originalVideoController;
    if (controller == null || !_isRecording || _isPaused) return;
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
    setState(() {
      _isRecording = true;
      _isPaused = false;
    });
    await _originalVideoController!.seekTo(Duration.zero);
    await _originalVideoController!.play();
  }

  /// Pauses/resumes playback of the source video only — the camera keeps
  /// recording the whole time so the responder can talk over a paused
  /// frame, matching how react-style content actually gets made.
  Future<void> _togglePauseSource() async {
    if (!_isRecording) return;
    if (_isPaused) {
      await _originalVideoController!.play();
    } else {
      await _originalVideoController!.pause();
    }
    setState(() => _isPaused = !_isPaused);
  }

  Future<void> _stopRecording() async {
    if (!_isRecording) return;
    setState(() {
      _isRecording = false;
      _isPaused = false;
    });
    await _originalVideoController?.pause();
    final result = await _frameRecorderService?.stop();
    _frameRecorderService = null;

    if (result == null || !mounted) {
      if (mounted) {
        setState(() => _errorMessage = 'Recording did not save. Please try again.');
      }
      return;
    }

    setState(() => _resultVideoPath = result.videoPath);
    _previewController = VideoPlayerController.file(File(result.videoPath))
      ..initialize().then((_) {
        if (mounted) setState(() {});
        _previewController?.play();
        _previewController?.setLooping(true);
      });
    _uploadToLibrary();
  }

  Future<void> _saveToGallery() async {
    if (_resultVideoPath == null || _isSaving) return;
    setState(() {
      _isSaving = true;
      _saveMessage = null;
    });
    try {
      await Gal.putVideo(_resultVideoPath!);
      if (mounted) setState(() => _saveMessage = 'Saved to your gallery');
    } catch (e) {
      if (mounted) setState(() => _saveMessage = 'Could not save: $e');
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  /// Saves a copy into Supabase tagged content_type: 'kingdom_response' —
  /// this is what makes it show up in the Reactions tab on the profile,
  /// reusing the same mechanism Kingdom Dual used for its tab.
  Future<void> _uploadToLibrary() async {
    if (_resultVideoPath == null) return;
    try {
      final firebaseUser = firebase_auth.FirebaseAuth.instance.currentUser;
      if (firebaseUser == null) return;
      final file = File(_resultVideoPath!);
      if (!await file.exists()) return;
      final fileName =
          '${firebaseUser.uid}/kingdom_response_${DateTime.now().millisecondsSinceEpoch}.mp4';
      await supabase.Supabase.instance.client.storage.from('videos').upload(
          fileName, file,
          fileOptions: const supabase.FileOptions(upsert: true));
      final videoUrl = supabase.Supabase.instance.client.storage
          .from('videos')
          .getPublicUrl(fileName);
      await supabase.Supabase.instance.client.from('videos').insert({
        'creator_id': firebaseUser.uid,
        'title':
            'Kingdom Response - ${DateTime.now().toIso8601String().split('T').first}',
        'description': 'Recorded with Kingdom Response',
        'video_url': videoUrl,
        'thumbnail_url': '',
        'category': 'Faith',
        'status': 'published',
        'content_type': 'kingdom_response',
        'visibility': 'private',
      });
    } catch (e) {
      // Non-fatal — the file is already safely saved locally even if
      // this library upload fails.
    }
  }

  void _postToFeed() {
    if (_resultVideoPath == null) return;
    Get.off(() => CreateFeedScreen(
          createType: CreateFeedType.reel,
          content: PostStoryContent(
            type: PostStoryContentType.reel,
            content: _resultVideoPath,
          ),
        ));
  }

  void _retake() {
    setState(() {
      _resultVideoPath = null;
      _saveMessage = null;
      _previewController?.dispose();
      _previewController = null;
    });
  }

  @override
  void dispose() {
    _originalVideoController?.removeListener(_onVideoProgress);
    _originalVideoController?.dispose();
    _cameraController?.dispose();
    _previewController?.dispose();
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
          : _needsSourcePick
              ? _buildSourcePicker()
              : !_isReady
                  ? const Center(
                      child: CircularProgressIndicator(color: Color(0xFF14C9B8)))
                  : _resultVideoPath != null
                      ? _buildPreview()
                      : _buildRecordView(),
      floatingActionButton: _isReady &&
              _errorMessage == null &&
              !_needsSourcePick &&
              _resultVideoPath == null
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

  Widget _buildSourcePicker() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.video_call_outlined, color: Colors.white54, size: 48),
            const SizedBox(height: 16),
            const Text(
              'Pick a video from your device to react to',
              style: TextStyle(color: Colors.white70),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF14C9B8),
              ),
              onPressed: _pickVideoFromDevice,
              child: const Text('Upload video'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecordView() {
    return RepaintBoundary(
      key: _recordingBoundaryKey,
      child: Column(
        children: [
          Expanded(
            child: Stack(
              fit: StackFit.expand,
              children: [
                AspectRatio(
                  aspectRatio: _originalVideoController!.value.aspectRatio,
                  child: VideoPlayer(_originalVideoController!),
                ),
                if (_isRecording)
                  Positioned(
                    bottom: 12,
                    right: 12,
                    child: _PauseButton(
                      isPaused: _isPaused,
                      onTap: _togglePauseSource,
                    ),
                  ),
              ],
            ),
          ),
          Container(height: 2, color: const Color(0xFF14C9B8)),
          Expanded(
            child: _cameraController != null && _cameraController!.value.isInitialized
                ? CameraPreview(_cameraController!)
                : const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }

  Widget _buildPreview() {
    return Column(
      children: [
        Expanded(
          child: _previewController != null && _previewController!.value.isInitialized
              ? AspectRatio(
                  aspectRatio: _previewController!.value.aspectRatio,
                  child: VideoPlayer(_previewController!),
                )
              : const Center(
                  child: CircularProgressIndicator(color: Color(0xFF14C9B8))),
        ),
        Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              if (_saveMessage != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Text(_saveMessage!,
                      style: const TextStyle(color: Colors.white54, fontSize: 12)),
                ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  OutlinedButton(
                    onPressed: _retake,
                    child: const Text('Retake',
                        style: TextStyle(color: Colors.white70)),
                  ),
                  OutlinedButton(
                    onPressed: _isSaving ? null : _saveToGallery,
                    child: Text(_isSaving ? 'Saving...' : 'Save to Gallery',
                        style: const TextStyle(color: Colors.white70)),
                  ),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF14C9B8)),
                    onPressed: _postToFeed,
                    child: const Text('Use in a Post',
                        style: TextStyle(color: Colors.white)),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _PauseButton extends StatelessWidget {
  final bool isPaused;
  final VoidCallback onTap;
  const _PauseButton({required this.isPaused, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.black54,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Icon(
          isPaused ? Icons.play_arrow_rounded : Icons.pause_rounded,
          color: Colors.white,
          size: 28,
        ),
      ),
    );
  }
}
