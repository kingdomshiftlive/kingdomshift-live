import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shortzz/screen/brain_battle_screen/brain_battle_game_controller.dart';

class BrainBattleGameScreen extends StatelessWidget {
  final String category;
  final BrainBattleMode mode;
  const BrainBattleGameScreen({super.key, required this.category, required this.mode});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(BrainBattleGameController(category: category, mode: mode));

    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0F),
      body: SafeArea(
        child: Obx(() {
          if (controller.isLoading.value) {
            return const Center(
                child: CircularProgressIndicator(color: Color(0xFF7B2FF7)));
          }
          if (controller.questions.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text('No questions found for $category yet.',
                    style: const TextStyle(color: Colors.white54),
                    textAlign: TextAlign.center),
              ),
            );
          }
          if (controller.isGameOver.value) {
            return _buildResults(context, controller);
          }
          return _buildGame(context, controller);
        }),
      ),
    );
  }

  Widget _buildGame(BuildContext context, BrainBattleGameController controller) {
    final q = controller.currentQuestion;
    if (q == null) return const SizedBox.shrink();

    return Column(children: [
      Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
        child: Row(children: [
          IconButton(
            icon: const Icon(Icons.close, color: Colors.white54),
            onPressed: () => Get.back(),
          ),
          Expanded(
            child: Column(children: [
              Text(category,
                  style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 13,
                      fontWeight: FontWeight.bold)),
              if (controller.mode == BrainBattleMode.speedRound)
                Text('Score: ${controller.score.value}',
                    style: const TextStyle(color: Colors.white54, fontSize: 12)),
            ]),
          ),
          if (controller.mode == BrainBattleMode.speedRound)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: controller.secondsLeft.value <= 10
                    ? Colors.red.withValues(alpha: 0.2)
                    : const Color(0xFF7B2FF7).withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text('${controller.secondsLeft.value}s',
                  style: TextStyle(
                      color: controller.secondsLeft.value <= 10
                          ? Colors.redAccent
                          : Colors.white,
                      fontWeight: FontWeight.bold)),
            )
          else
            const SizedBox(width: 48),
        ]),
      ),
      const SizedBox(height: 24),
      Expanded(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(q.question,
                  style: const TextStyle(
                      color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center),
              const SizedBox(height: 32),
              _answerButton(controller, 'A', q.optionA),
              const SizedBox(height: 12),
              _answerButton(controller, 'B', q.optionB),
              const SizedBox(height: 12),
              _answerButton(controller, 'C', q.optionC),
              const SizedBox(height: 12),
              _answerButton(controller, 'D', q.optionD),
            ],
          ),
        ),
      ),
      const SizedBox(height: 24),
    ]);
  }

  Widget _answerButton(BrainBattleGameController controller, String letter, String text) {
    final selected = controller.lastSelectedAnswer.value == letter;
    final isCorrectAnswer = controller.currentQuestion?.correctAnswer == letter;
    final showFeedback = controller.answerLocked.value;

    Color bgColor = const Color(0xFF12121E);
    Color borderColor = Colors.white12;

    if (showFeedback) {
      if (isCorrectAnswer) {
        bgColor = Colors.green.withValues(alpha: 0.2);
        borderColor = Colors.greenAccent;
      } else if (selected) {
        bgColor = Colors.red.withValues(alpha: 0.2);
        borderColor = Colors.redAccent;
      }
    }

    return GestureDetector(
      onTap: () => controller.selectAnswer(letter),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: borderColor),
        ),
        child: Row(children: [
          CircleAvatar(
              radius: 12,
              backgroundColor: Colors.white12,
              child: Text(letter,
                  style: const TextStyle(color: Colors.white, fontSize: 12))),
          const SizedBox(width: 12),
          Expanded(
              child: Text(text, style: const TextStyle(color: Colors.white, fontSize: 14))),
        ]),
      ),
    );
  }

  Widget _buildResults(BuildContext context, BrainBattleGameController controller) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('🏆', style: TextStyle(fontSize: 56)),
            const SizedBox(height: 16),
            const Text('Round Complete!',
                style: TextStyle(
                    color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            if (controller.mode == BrainBattleMode.speedRound)
              Text('Score: ${controller.score.value}',
                  style: const TextStyle(
                      color: Color(0xFF7B2FF7),
                      fontSize: 28,
                      fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text(
                '${controller.correctCount.value} correct out of ${controller.currentIndex.value + 1}',
                style: const TextStyle(color: Colors.white54, fontSize: 14)),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF7B2FF7),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                onPressed: () => Get.back(),
                child: const Text('Done', style: TextStyle(color: Colors.white)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
