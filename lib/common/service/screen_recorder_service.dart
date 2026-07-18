import 'package:flutter/services.dart';

/// Bridges to native Android screen recording (MediaProjection + MediaRecorder).
/// This records the ENTIRE app screen (camera preview + chat overlay + gifts +
/// viewer count, etc.) for local saving/replay. It does NOT affect what is
/// broadcast live to viewers — that still goes through Zego as normal.
class ScreenRecorderService {
  static const MethodChannel _channel =
      MethodChannel('com.kingdomshift.live/screen_record');

  /// Triggers the one-time Android "Start recording or casting?" system
  /// permission dialog. Call this once, right when going live, before
  /// starting the actual recording.
  static Future<bool> requestPermission() async {
    try {
      final granted = await _channel.invokeMethod<bool>('requestPermission');
      return granted ?? false;
    } catch (e) {
      return false;
    }
  }

  /// Starts recording the full app screen to [path] (should end in .mp4).
  /// Must be called after [requestPermission] has returned true.
  static Future<bool> startRecording(String path) async {
    try {
      final started =
          await _channel.invokeMethod<bool>('startRecording', {'path': path});
      return started ?? false;
    } catch (e) {
      return false;
    }
  }

  /// Stops the current screen recording. The finished file will be at the
  /// path you passed to [startRecording].
  static Future<void> stopRecording() async {
    try {
      await _channel.invokeMethod('stopRecording');
    } catch (e) {
      // no-op — recording may not have been running
    }
  }
}
