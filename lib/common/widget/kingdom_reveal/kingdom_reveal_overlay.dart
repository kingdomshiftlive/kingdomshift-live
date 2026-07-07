import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:just_audio/just_audio.dart';
import 'package:shortzz/common/model/kingdom_reveal/kingdom_reveal_character.dart';

class KingdomRevealOverlay extends StatefulWidget {
  const KingdomRevealOverlay({
    super.key,
    required this.characterId,
    this.active = true,
  });

  final String? characterId;
  final bool active;

  @override
  State<KingdomRevealOverlay> createState() => _KingdomRevealOverlayState();
}

class _KingdomRevealOverlayState extends State<KingdomRevealOverlay>
    with SingleTickerProviderStateMixin {
  Ticker? _ticker;
  int _frameIndex = 0;
  Duration _accumulated = Duration.zero;
  static const _frameDuration = Duration(milliseconds: 125);
  OverlayEntry? _entry;
  static OverlayEntry? _globalEntry;
  AudioPlayer? _audioPlayer;
  String? _loadedAudioUrl;

  KingdomRevealCharacter? get _character {
    if (widget.characterId == null || widget.characterId == 'none') return null;
    try {
      return kingdomRevealCharacters.firstWhere((c) => c.id == widget.characterId);
    } catch (_) {
      return null;
    }
  }

  List<String> get _frames => _character?.frameUrls ?? [];

  @override
  void initState() {
    super.initState();
    _ticker = createTicker(_onTick);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.active && _frames.isNotEmpty) {
        _showOverlay();
        _ticker!.start();
        _playAudio();
      }
    });
  }

  Future<void> _playAudio() async {
    final audioUrl = _character?.audioUrl;
    if (audioUrl == null) return;
    if (_loadedAudioUrl != audioUrl) {
      _audioPlayer?.dispose();
      _audioPlayer = AudioPlayer();
      _loadedAudioUrl = audioUrl;
      try {
        await _audioPlayer!.setUrl(audioUrl);
        await _audioPlayer!.setLoopMode(LoopMode.one);
      } catch (_) {
        return;
      }
    }
    _audioPlayer?.play();
  }

  void _stopAudio() {
    _audioPlayer?.pause();
  }

  void _showOverlay() {
    if (_entry != null || !mounted) return;
    _globalEntry?.remove();
    _globalEntry = null;
    final overlayState = Overlay.of(context, rootOverlay: true);
    _entry = OverlayEntry(builder: (context) => _buildFloatingCharacter(context));
    _globalEntry = _entry;
    overlayState.insert(_entry!);
  }

  void _hideOverlay() {
    if (identical(_globalEntry, _entry)) {
      _globalEntry = null;
    }
    _entry?.remove();
    _entry = null;
  }

  void _onTick(Duration elapsed) {
    final frames = _frames;
    if (frames.isEmpty) return;
    _accumulated += const Duration(milliseconds: 16);
    if (_accumulated >= _frameDuration) {
      _accumulated = Duration.zero;
      _frameIndex = (_frameIndex + 1) % frames.length;
      _entry?.markNeedsBuild();
    }
  }

  @override
  void didUpdateWidget(covariant KingdomRevealOverlay oldWidget) {
    super.didUpdateWidget(oldWidget);
    final hasFrames = _frames.isNotEmpty;
    final shouldShow = widget.active && hasFrames;
    final wasShowing = _entry != null;

    if (widget.characterId != oldWidget.characterId && _entry != null) {
      _entry?.markNeedsBuild();
    }

    if (shouldShow && !wasShowing) {
      _showOverlay();
      _ticker?.start();
      _playAudio();
    } else if (!shouldShow && wasShowing) {
      _hideOverlay();
      _ticker?.stop();
      _stopAudio();
    }
  }

  @override
  void dispose() {
    _hideOverlay();
    _ticker?.dispose();
    _audioPlayer?.dispose();
    super.dispose();
  }

  Widget _buildFloatingCharacter(BuildContext context) {
    final frames = _frames;
    if (frames.isEmpty) {
      return const SizedBox.shrink();
    }
    final safeIndex = _frameIndex < frames.length ? _frameIndex : 0;
    final screenWidth = MediaQuery.of(context).size.width;
    final overlayWidth = screenWidth * 0.5;

    return Positioned(
      right: 0,
      bottom: 70,
      width: overlayWidth,
      child: IgnorePointer(
        ignoring: true,
        child: Container(
          decoration: BoxDecoration(
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.5),
                blurRadius: 24,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Image.network(
            frames[safeIndex],
            fit: BoxFit.contain,
            gaplessPlayback: true,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return const SizedBox.shrink();
  }
}
