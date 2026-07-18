import 'dart:async';
import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:record/record.dart';
import 'package:path_provider/path_provider.dart';
import 'package:ffmpeg_kit_flutter_new/ffmpeg_kit.dart';
import 'package:ffmpeg_kit_flutter_new/return_code.dart';

/// Captures whatever is rendered inside the widget wrapped by [boundaryKey]
/// (camera preview + chat overlay + gifts + viewer count -- everything on
/// screen) as a sequence of frames, records audio separately, and stitches
/// both into a single mp4 once recording stops. This is the TikTok-style
/// approach: no OS screen-recording permission is ever requested, because
/// we are only capturing pixels the app already owns and draws itself.
class RecordingResult {
  final String videoPath;
  final String? thumbnailPath;
  RecordingResult({required this.videoPath, this.thumbnailPath});
}

class FrameRecorderService {
  final GlobalKey boundaryKey;
  final AudioRecorder _audioRecorder = AudioRecorder();

  Timer? _frameTimer;
  Directory? _frameDir;
  String? _audioPath;
  int _frameIndex = 0;
  bool _isRecording = false;

  /// Frames captured per second. Kept modest since capturing + encoding a
  /// PNG every tick has a real CPU cost on top of the live broadcast itself.
  static const int _fps = 12;
  bool _capturing = false;

  FrameRecorderService(this.boundaryKey);

  bool get isRecording => _isRecording;

  Future<bool> start() async {
    if (_isRecording) return false;
    try {
      final tempDir = await getTemporaryDirectory();
      final sessionId = DateTime.now().millisecondsSinceEpoch;
      _frameDir = Directory('${tempDir.path}/frames_$sessionId');
      await _frameDir!.create(recursive: true);
      _audioPath = '${tempDir.path}/audio_$sessionId.m4a';
      _frameIndex = 0;

      final hasPermission = await _audioRecorder.hasPermission();
      if (hasPermission) {
        await _audioRecorder.start(
          const RecordConfig(encoder: AudioEncoder.aacLc),
          path: _audioPath!,
        );
      }

      _isRecording = true;
      _frameTimer = Timer.periodic(
        Duration(milliseconds: (1000 / _fps).round()),
        (_) => _captureFrame(),
      );
      return true;
    } catch (e) {
      _isRecording = false;
      return false;
    }
  }

  Future<void> _captureFrame() async {
    if (!_isRecording || _capturing) return;
    _capturing = true;
    try {
      final boundary = boundaryKey.currentContext?.findRenderObject()
          as RenderRepaintBoundary?;
      if (boundary == null) return;
      final image = await boundary.toImage(pixelRatio: 1.0);
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      image.dispose();
      if (byteData == null) return;
      final file = File(
          '${_frameDir!.path}/frame_${_frameIndex.toString().padLeft(6, '0')}.png');
      await file.writeAsBytes(byteData.buffer.asUint8List());
      _frameIndex++;
    } catch (e) {
      // Skip this frame rather than crash the whole recording.
    } finally {
      _capturing = false;
    }
  }

  /// Stops recording, stitches frames + audio into an mp4 via FFmpeg, and
  /// returns the finished file path (or null if nothing usable was captured).
  Future<RecordingResult?> stop() async {
    if (!_isRecording) return null;
    _isRecording = false;
    _frameTimer?.cancel();
    _frameTimer = null;

    String? recordedAudioPath;
    try {
      recordedAudioPath = await _audioRecorder.stop();
    } catch (e) {
      recordedAudioPath = null;
    }

    if (_frameDir == null || _frameIndex < 2) {
      await _cleanup(recordedAudioPath);
      return null;
    }

    String? thumbnailPath;
    try {
      final firstFrame = File('${_frameDir!.path}/frame_000000.png');
      if (await firstFrame.exists()) {
        final tempDir = await getTemporaryDirectory();
        final savedThumb =
            File('${tempDir.path}/thumb_${DateTime.now().millisecondsSinceEpoch}.png');
        await firstFrame.copy(savedThumb.path);
        thumbnailPath = savedThumb.path;
      }
    } catch (e) {
      thumbnailPath = null;
    }

    final tempDir = await getTemporaryDirectory();
    final outputPath =
        '${tempDir.path}/live_recording_${DateTime.now().millisecondsSinceEpoch}.mp4';
    final framePattern = '${_frameDir!.path}/frame_%06d.png';

    final hasAudio =
        recordedAudioPath != null && await File(recordedAudioPath).exists();

    final command = hasAudio
        ? '-y -framerate $_fps -i "$framePattern" -i "$recordedAudioPath" '
            '-c:v libx264 -pix_fmt yuv420p -c:a aac -shortest "$outputPath"'
        : '-y -framerate $_fps -i "$framePattern" '
            '-c:v libx264 -pix_fmt yuv420p "$outputPath"';

    final session = await FFmpegKit.execute(command);
    final returnCode = await session.getReturnCode();

    await _cleanup(recordedAudioPath);

    if (returnCode != null && ReturnCode.isSuccess(returnCode)) {
      return RecordingResult(videoPath: outputPath, thumbnailPath: thumbnailPath);
    }
    return null;
  }

  Future<void> _cleanup(String? audioPath) async {
    try {
      if (_frameDir != null && await _frameDir!.exists()) {
        await _frameDir!.delete(recursive: true);
      }
    } catch (_) {}
    if (audioPath != null) {
      try {
        final f = File(audioPath);
        if (await f.exists()) await f.delete();
      } catch (_) {}
    }
    _frameDir = null;
  }
}
