import 'package:flutter/material.dart';
import 'dart:async';
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

  static void pauseForModal() {
    _KingdomRevealOverlayState.pauseForModal();
  }

  static void resumeAfterModal() {
    _KingdomRevealOverlayState.resumeAfterModal();
  }

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
  static bool _globallyPaused = false;
  AudioPlayer? _audioPlayer;
  String? _loadedAudioUrl;
  bool _wasActive = false;

  static void pauseForModal() {
    _globallyPaused = true;
  }

  static void resumeAfterModal() {
    _globallyPaused = false;
  }

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
    if (_frames.isNotEmpty) {
      _ticker!.start();
      // _preloadAudio();
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        final overlayState = Overlay.of(context, rootOverlay: true);
        _entry = OverlayEntry(builder: (context) => _buildFloatingCharacter(context));
        overlayState.insert(_entry!);
      });
    }
  }

  Future<void> _preloadAudio() async {
    final audioUrl = _character?.audioUrl;
    if (audioUrl == null || _loadedAudioUrl == audioUrl) return;
    try {
      final oldPlayer = _audioPlayer;
      _audioPlayer = null;
      unawaited(oldPlayer?.dispose());
      final newPlayer = AudioPlayer();
      _loadedAudioUrl = audioUrl;
      await newPlayer.setUrl(audioUrl);
      await newPlayer.setLoopMode(LoopMode.one);
      if (!mounted) {
        unawaited(newPlayer.dispose());
        return;
      }
      _audioPlayer = newPlayer;
      if (_wasActive) {
        // _playAudio();
      }
    } catch (_) {
      _loadedAudioUrl = null;
    }
  }

  void _playAudio() {
    unawaited(_audioPlayer?.play());
  }

  void _stopAudio() {
    unawaited(_audioPlayer?.pause());
  }

  void _onTick(Duration elapsed) {
    final frames = _frames;
    if (frames.isEmpty) return;

    final isActiveNow = widget.active && !_globallyPaused;
    if (isActiveNow != _wasActive) {
      _wasActive = isActiveNow;
      if (isActiveNow) {
        // _playAudio();
      } else {
        // _stopAudio();
      }
      WidgetsBinding.instance.addPostFrameCallback((_) => _entry?.markNeedsBuild());
    }

    if (!isActiveNow) return;

    _accumulated += const Duration(milliseconds: 16);
    if (_accumulated >= _frameDuration) {
      _accumulated = Duration.zero;
      _frameIndex = (_frameIndex + 1) % frames.length;
      WidgetsBinding.instance.addPostFrameCallback((_) => _entry?.markNeedsBuild());
    }
  }

  @override
  void didUpdateWidget(covariant KingdomRevealOverlay oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.characterId != oldWidget.characterId) {
      _frameIndex = 0;
      _loadedAudioUrl = null;
      WidgetsBinding.instance.addPostFrameCallback((_) => _entry?.markNeedsBuild());
      if (_frames.isNotEmpty && _entry == null) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!mounted || _entry != null) return;
          final overlayState = Overlay.of(context, rootOverlay: true);
          _entry = OverlayEntry(builder: (context) => _buildFloatingCharacter(context));
          overlayState.insert(_entry!);
        });
      }
      if (_ticker != null && !_ticker!.isActive && _frames.isNotEmpty) {
        _ticker!.start();
      }
    }
  }

  @override
  void dispose() {
    _entry?.remove();
    _entry = null;
    _ticker?.dispose();
    _audioPlayer?.dispose();
    super.dispose();
  }

  Widget _buildFloatingCharacter(BuildContext context) {
    if (_globallyPaused || !widget.active) {
      return const SizedBox.shrink();
    }
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
            errorBuilder: (context, error, stackTrace) {
              return const SizedBox.shrink();
            },
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
