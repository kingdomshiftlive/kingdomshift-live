import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shortzz/screen/live_stream/livestream_screen/livestream_screen_controller.dart';

class BrainBattleLiveOverlay extends StatefulWidget {
  final LivestreamScreenController controller;
  const BrainBattleLiveOverlay({super.key, required this.controller});

  @override
  State<BrainBattleLiveOverlay> createState() => _BrainBattleLiveOverlayState();
}

class _BrainBattleLiveOverlayState extends State<BrainBattleLiveOverlay> {
  Timer? _tickTimer;

  @override
  void initState() {
    super.initState();
    // Local ticker just to redraw the countdown every second - the actual
    // question/answer state comes from Firestore via controller.liveData.
    _tickTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _tickTimer?.cancel();
    super.dispose();
  }

  int get _secondsLeft {
    final startedAt = widget.controller.liveData.value.brainBattleQuestionStartedAt;
    if (startedAt == null) return LivestreamScreenController.brainBattleQuestionSeconds;
    final elapsed = DateTime.now().millisecondsSinceEpoch - startedAt;
    final remaining = LivestreamScreenController.brainBattleQuestionSeconds - (elapsed / 1000).floor();
    return remaining.clamp(0, LivestreamScreenController.brainBattleQuestionSeconds);
  }

  static const List<String> _categories = [
    'Bible', 'Business', 'Finance', 'Health', 'History', 'Science', 'Music', 'Culture'
  ];

  void _showCategoryPicker(BuildContext context) {
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(
          color: Color(0xFF12121E),
          borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Start Brain Battle',
                style: TextStyle(
                    color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _categories.map((cat) {
                return GestureDetector(
                  onTap: () {
                    Get.back();
                    widget.controller.startLiveBrainBattle(cat);
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    decoration: BoxDecoration(
                      color: const Color(0xFF7B2FF7).withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: const Color(0xFF7B2FF7)),
                    ),
                    child: Text(cat, style: const TextStyle(color: Colors.white)),
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHostTrigger() {
    if (!widget.controller.isHost) return const SizedBox.shrink();
    return Obx(() {
      final active = widget.controller.liveData.value.brainBattleActive;
      return Positioned(
        right: 12,
        top: 100,
        child: GestureDetector(
          onTap: () {
            if (active) {
              widget.controller.stopLiveBrainBattle();
            } else {
              _showCategoryPicker(context);
            }
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: active
                  ? Colors.red.withValues(alpha: 0.8)
                  : const Color(0xFF7B2FF7).withValues(alpha: 0.8),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(mainAxisSize: MainAxisSize.min, children: [
              Text(active ? '⏹' : '🧠', style: const TextStyle(fontSize: 14)),
              const SizedBox(width: 4),
              Text(active ? 'Stop' : 'Brain Battle',
                  style: const TextStyle(
                      color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold)),
            ]),
          ),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(children: [
      _buildHostTrigger(),
      Obx(() {
      final live = widget.controller.liveData.value;
      if (!live.brainBattleActive) return const SizedBox.shrink();

      final isHost = widget.controller.isHost;
      final question = live.brainBattleQuestionText ?? '';
      final options = {
        'A': live.brainBattleOptionA ?? '',
        'B': live.brainBattleOptionB ?? '',
        'C': live.brainBattleOptionC ?? '',
        'D': live.brainBattleOptionD ?? '',
      };
      final score = live.brainBattleHostScore ?? 0;

      return Positioned(
        left: 12,
        right: 12,
        bottom: 100,
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.75),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFF7B2FF7).withValues(alpha: 0.6)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(children: [
                    const Text('🧠', style: TextStyle(fontSize: 16)),
                    const SizedBox(width: 6),
                    Text('Brain Battle Live',
                        style: const TextStyle(
                            color: Color(0xFFFFB800),
                            fontWeight: FontWeight.bold,
                            fontSize: 12)),
                  ]),
                  Row(children: [
                    Text('Score: $score',
                        style: const TextStyle(
                            color: Colors.white70, fontSize: 12)),
                    const SizedBox(width: 10),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: _secondsLeft <= 3
                            ? Colors.red.withValues(alpha: 0.3)
                            : const Color(0xFF7B2FF7).withValues(alpha: 0.3),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text('${_secondsLeft}s',
                          style: const TextStyle(
                              color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold)),
                    ),
                  ]),
                ],
              ),
              const SizedBox(height: 8),
              Text(question,
                  style: const TextStyle(
                      color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              if (isHost)
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: options.entries.map((entry) {
                    return GestureDetector(
                      onTap: () => widget.controller.selectLiveBrainBattleAnswer(entry.key),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.white24),
                        ),
                        child: Text('${entry.key}. ${entry.value}',
                            style: const TextStyle(color: Colors.white, fontSize: 12)),
                      ),
                    );
                  }).toList(),
                )
              else
                Row(children: [
                  const Icon(Icons.card_giftcard, color: Color(0xFFFFB800), size: 16),
                  const SizedBox(width: 6),
                  const Expanded(
                    child: Text('Cheer them on - send a gift!',
                        style: TextStyle(color: Colors.white70, fontSize: 12)),
                  ),
                ]),
            ],
          ),
        ),
      );
      }),
    ]);
  }
}
