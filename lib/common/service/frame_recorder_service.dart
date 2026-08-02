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
      if (boundary == null) {
        // ignore: avoid_print
        print('[FrameRecorder] DIAG: boundary is null at frame $_frameIndex');
        return;
      }
      final image = await boundary.toImage(pixelRatio: 1.0);
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      image.dispose();
      if (byteData == null) {
        // ignore: avoid_print
        print('[FrameRecorder] DIAG: byteData null at frame $_frameIndex');
        return;
      }
      final file = File(
          '${_frameDir!.path}/frame_${_frameIndex.toString().padLeft(6, '0')}.png');
      await file.writeAsBytes(byteData.buffer.asUint8List());
      // ignore: avoid_print
      print('[FrameRecorder] DIAG: wrote frame $_frameIndex (${byteData.lengthInBytes} bytes)');
      _frameIndex++;
    } catch (e, st) {
      // ignore: avoid_print
      print('[FrameRecorder] DIAG: captureFrame EXCEPTION at frame $_frameIndex: $e\n$st');
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
      // ignore: avoid_print
      print('[FrameRecorder] DIAG: aborting — frameDir=$_frameDir frameIndex=$_frameIndex');
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

    int audioFileSize = 0;
    if (recordedAudioPath != null && await File(recordedAudioPath).exists()) {
      audioFileSize = await File(recordedAudioPath).length();
    }
    // ignore: avoid_print
    print('[FrameRecorder] DIAG: recordedAudioPath=$recordedAudioPath exists=${recordedAudioPath != null && await File(recordedAudioPath).exists()} size=$audioFileSize');

    // Treat a suspiciously small/empty audio file as invalid — a broken
    // audio track (e.g. the recorder failing to finalize on stop) can
    // make FFmpeg reject the whole command rather than just skip it.
    final hasAudio = audioFileSize > 1000;
    // ignore: avoid_print
    print('[FrameRecorder] DIAG: hasAudio decision=$hasAudio (threshold 1000 bytes)');

    final command = hasAudio
        ? '-y -framerate $_fps -i "$framePattern" -i "$recordedAudioPath" '
            '-c:v libx264 -pix_fmt yuv420p -c:a aac -shortest "$outputPath"'
        : '-y -framerate $_fps -i "$framePattern" '
            '-c:v libx264 -pix_fmt yuv420p "$outputPath"';

    // Verify inputs actually exist right before running FFmpeg.
    final frameZero = File('${_frameDir!.path}/frame_000000.png');
    // ignore: avoid_print
    print('[FrameRecorder] DIAG: frame_000000.png exists=${await frameZero.exists()}, frameDir listing=${await _frameDir!.list().map((f) => f.path.split('/').last).toList()}');
    if (hasAudio) {
      // ignore: avoid_print
      print('[FrameRecorder] DIAG: audio file exists=${await File(recordedAudioPath!).exists()}, size=${await File(recordedAudioPath).length()}');
    }

    // ignore: avoid_print
    print('[FrameRecorder] DIAG: frameIndex=$_frameIndex hasAudio=$hasAudio command=$command');

    final session = await FFmpegKit.execute(command);
    final returnCode = await session.getReturnCode();
    final state = await session.getState();
    final failStack = await session.getFailStackTrace();
    // Small delay in case logs are still flushing asynchronously.
    await Future.delayed(const Duration(milliseconds: 300));
    final logs = await session.getAllLogsAsString();
    final logCount = (await session.getLogs()).length;
    // ignore: avoid_print
    print('[FrameRecorder] DIAG: FFmpeg returnCode=$returnCode state=$state logCount=$logCount');
    // ignore: avoid_print
    print('[FrameRecorder] DIAG: FFmpeg failStackTrace=$failStack');
    // ignore: avoid_print
    print('[FrameRecorder] DIAG: FFmpeg logs:\n$logs');
    final outputFile = File(outputPath);
    // ignore: avoid_print
    print('[FrameRecorder] DIAG: output exists=${await outputFile.exists()} size=${await outputFile.exists() ? await outputFile.length() : 0}');

    await _cleanup(recordedAudioPath);

    if (returnCode != null && ReturnCode.isSuccess(returnCode)) {
      // ignore: avoid_print
      print('[FrameRecorder] DIAG: SUCCESS, output at $outputPath');
      return RecordingResult(videoPath: outputPath, thumbnailPath: thumbnailPath);
    }
    // ignore: avoid_print
    print('[FrameRecorder] DIAG: FAILURE, returning null');
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
