import 'package:just_audio/just_audio.dart';

class KingdomRevealAudioController {
  KingdomRevealAudioController._();
  static final KingdomRevealAudioController instance = KingdomRevealAudioController._();

  final AudioPlayer _player = AudioPlayer();
  String? _loadedUrl;
  bool _busy = false;
  bool? _lastWantsPlaying;
  String? _lastRequestedUrl;

  void setAndPlay(String? url) {
    if (url == null) return;
    if (_lastWantsPlaying == true && _lastRequestedUrl == url) return;
    _lastWantsPlaying = true;
    _lastRequestedUrl = url;
    _doSetAndPlay(url);
  }

  void pause() {
    if (_lastWantsPlaying == false) return;
    _lastWantsPlaying = false;
    _doPause();
  }

  Future<void> _doSetAndPlay(String url) async {
    if (_busy) return;
    _busy = true;
    try {
      if (_loadedUrl != url) {
        await _player.stop();
        await _player.setUrl(url);
        await _player.setLoopMode(LoopMode.one);
        _loadedUrl = url;
      }
      if (!_player.playing) {
        await _player.play();
      }
    } catch (_) {
    } finally {
      _busy = false;
    }
  }

  Future<void> _doPause() async {
    if (_busy) return;
    _busy = true;
    try {
      if (_player.playing) {
        await _player.pause();
      }
    } catch (_) {
    } finally {
      _busy = false;
    }
  }
}
