import 'dart:io';
import 'package:gal/gal.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:supabase_flutter/supabase_flutter.dart' as supabase;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:multicamera/multicamera.dart';
import 'package:video_player/video_player.dart';
import 'package:shortzz/common/service/frame_recorder_service.dart';
import 'package:shortzz/screen/camera_screen/camera_screen_controller.dart';
import 'package:shortzz/screen/create_feed_screen/create_feed_screen.dart';

/// Kingdom Dual -- records front and back cameras at the same time, split
/// screen (front on top, back on bottom). Requires a device with
/// hardware/OS support for concurrent camera access (Android 11+ and a
/// camera sensor setup that supports it -- most phones from ~2020 onward).
/// On unsupported devices, shows a clear explanation instead of a broken
/// screen.
class DualCameraScreen extends StatefulWidget {
  const DualCameraScreen({super.key});

  @override
  State<DualCameraScreen> createState() => _DualCameraScreenState();
}

class _DualCameraScreenState extends State<DualCameraScreen> {
  final GlobalKey _recordingBoundaryKey = GlobalKey();
  FrameRecorderService? _frameRecorderService;

  Camera? _frontCamera;
  Camera? _backCamera;

  bool _isLoading = true;
  bool _isSupported = true;
  bool _isRecording = false;
  bool _isSaving = false;
  String? _saveMessage;
  String? _resultVideoPath;
  VideoPlayerController? _previewController;

  @override
  void initState() {
    super.initState();
    _setup();
  }

  Future<void> _setup() async {
    try {
      _frontCamera = Camera(direction: CameraDirection.front);
      _backCamera = Camera(direction: CameraDirection.back);
      await Future.wait([
        _frontCamera!.initialize(),
        _backCamera!.initialize(),
      ]);
      if (mounted) setState(() => _isLoading = false);
    } catch (e) {
      // Most likely cause: this device doesn't support two concurrent
      // camera streams (older/budget hardware, or Android < 11).
      if (mounted) {
        setState(() {
          _isSupported = false;
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _startRecording() async {
    if (_isRecording) return;
    _frameRecorderService = FrameRecorderService(_recordingBoundaryKey);
    final started = await _frameRecorderService!.start();
    if (started && mounted) {
      setState(() => _isRecording = true);
    }
  }

  Future<void> _stopRecording() async {
    if (!_isRecording) return;
    setState(() => _isRecording = false);
    final result = await _frameRecorderService?.stop();
    _frameRecorderService = null;
    if (result != null && mounted) {
      setState(() => _resultVideoPath = result.videoPath);
      _previewController = VideoPlayerController.file(File(result.videoPath))
        ..initialize().then((_) {
          if (mounted) setState(() {});
          _previewController?.play();
          _previewController?.setLooping(true);
        });
      _uploadToLibrary();
    }
  }

  Future<void> _saveToGallery() async {
    if (_resultVideoPath == null || _isSaving) return;
    setState(() {
      _isSaving = true;
      _saveMessage = null;
    });
    try {
      await Gal.putVideo(_resultVideoPath!);
      if (mounted) {
        setState(() => _saveMessage = 'Saved to your gallery');
      }
    } catch (e) {
      if (mounted) {
        setState(() => _saveMessage = 'Could not save: $e');
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  Future<void> _uploadToLibrary() async {
    if (_resultVideoPath == null) return;
    try {
      final firebaseUser = firebase_auth.FirebaseAuth.instance.currentUser;
      if (firebaseUser == null) return;
      final file = File(_resultVideoPath!);
      if (!await file.exists()) return;
      final fileName =
          '${firebaseUser.uid}/kingdom_dual_${DateTime.now().millisecondsSinceEpoch}.mp4';
      await supabase.Supabase.instance.client.storage.from('videos').upload(
          fileName, file,
          fileOptions: const supabase.FileOptions(upsert: true));
      final videoUrl = supabase.Supabase.instance.client.storage
          .from('videos')
          .getPublicUrl(fileName);
      await supabase.Supabase.instance.client.from('videos').insert({
        'creator_id': firebaseUser.uid,
        'title':
            'Kingdom Dual - ${DateTime.now().toIso8601String().split('T').first}',
        'description': 'Recorded with Kingdom Dual',
        'video_url': videoUrl,
        'thumbnail_url': '',
        'category': 'Faith',
        'status': 'published',
        'content_type': 'kingdom_dual',
        'visibility': 'private',
      });
    } catch (e) {
      // Non-fatal -- the file is already safely saved locally even if
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
    _frontCamera?.dispose();
    _backCamera?.dispose();
    _previewController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text('Kingdom Dual',
            style: TextStyle(color: Colors.white, fontSize: 16)),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: Color(0xFF14C9B8)))
          : !_isSupported
              ? _buildUnsupportedMessage()
              : _resultVideoPath != null
                  ? _buildPreview()
                  : _buildCameraView(),
      floatingActionButton: _isSupported && !_isLoading && _resultVideoPath == null
          ? FloatingActionButton(
              backgroundColor:
                  _isRecording ? Colors.redAccent : const Color(0xFF14C9B8),
              onPressed: _isRecording ? _stopRecording : _startRecording,
              child: Icon(
                  _isRecording ? Icons.stop_rounded : Icons.fiber_manual_record,
                  color: Colors.white),
            )
          : null,
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  Widget _buildUnsupportedMessage() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.camera_alt_outlined, color: Colors.white38, size: 48),
            const SizedBox(height: 16),
            const Text(
              'Kingdom Dual isn\'t supported on this device',
              style: TextStyle(
                  color: Colors.white, fontSize: 17, fontWeight: FontWeight.w600),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 10),
            const Text(
              'Recording both cameras at once needs a phone with hardware support for it -- generally phones from 2020 or newer (Android 11+). Everything else in KingdomShift.Live works normally on your device.',
              style: TextStyle(color: Colors.white54, fontSize: 13),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCameraView() {
    return RepaintBoundary(
      key: _recordingBoundaryKey,
      child: Column(
        children: [
          Expanded(
            child: _frontCamera != null
                ? CameraPreview(camera: _frontCamera!, mirror: true, crop: true)
                : const SizedBox.shrink(),
          ),
          Container(height: 2, color: const Color(0xFF14C9B8)),
          Expanded(
            child: _backCamera != null
                ? CameraPreview(camera: _backCamera!, mirror: false, crop: true)
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
          child: _previewController != null &&
                  _previewController!.value.isInitialized
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
