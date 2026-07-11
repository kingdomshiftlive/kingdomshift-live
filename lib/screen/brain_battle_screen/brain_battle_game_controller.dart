import 'dart:async';
import 'dart:math';

import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:get/get.dart';
import 'package:shortzz/common/controller/base_controller.dart';
import 'package:shortzz/common/manager/session_manager.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as supabase;

enum BrainBattleMode { speedRound, study }

class BrainBattleQuestion {
  final String id;
  final String question;
  final String optionA;
  final String optionB;
  final String optionC;
  final String optionD;
  final String correctAnswer;

  BrainBattleQuestion({
    required this.id,
    required this.question,
    required this.optionA,
    required this.optionB,
    required this.optionC,
    required this.optionD,
    required this.correctAnswer,
  });

  factory BrainBattleQuestion.fromJson(Map<String, dynamic> json) {
    return BrainBattleQuestion(
      id: json['id'].toString(),
      question: json['question'] ?? '',
      optionA: json['option_a'] ?? '',
      optionB: json['option_b'] ?? '',
      optionC: json['option_c'] ?? '',
      optionD: json['option_d'] ?? '',
      correctAnswer: json['correct_answer'] ?? '',
    );
  }
}

class BrainBattleGameController extends BaseController {
  final String category;
  final BrainBattleMode mode;
  BrainBattleGameController({required this.category, required this.mode});

  RxList<BrainBattleQuestion> questions = <BrainBattleQuestion>[].obs;
  RxInt currentIndex = 0.obs;
  RxInt score = 0.obs;
  RxInt correctCount = 0.obs;
  RxInt secondsLeft = 60.obs;
  RxBool isGameOver = false.obs;
  RxString? selectedAnswer;
  final Rx<String?> lastSelectedAnswer = Rx<String?>(null);
  final RxBool answerLocked = false.obs;

  Timer? _timer;

  @override
  void onInit() {
    super.onInit();
    _loadQuestions();
  }

  @override
  void onClose() {
    _timer?.cancel();
    super.onClose();
  }

  Future<void> _loadQuestions() async {
    isLoading.value = true;
    try {
      final response = await supabase.Supabase.instance.client
          .from('brain_battle_questions')
          .select()
          .eq('category', category)
          .limit(50);

      final list = (response as List)
          .map((e) => BrainBattleQuestion.fromJson(e))
          .toList()
        ..shuffle(Random());

      questions.value = list;
    } catch (e) {
      showSnackBar('Failed to load questions: $e');
    } finally {
      isLoading.value = false;
      if (mode == BrainBattleMode.speedRound) {
        _startTimer();
      }
    }
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (secondsLeft.value <= 1) {
        secondsLeft.value = 0;
        timer.cancel();
        _endGame();
      } else {
        secondsLeft.value--;
      }
    });
  }

  BrainBattleQuestion? get currentQuestion {
    if (currentIndex.value >= questions.length) return null;
    return questions[currentIndex.value];
  }

  void selectAnswer(String letter) {
    if (answerLocked.value || isGameOver.value) return;
    final q = currentQuestion;
    if (q == null) return;

    answerLocked.value = true;
    lastSelectedAnswer.value = letter;

    final isCorrect = letter == q.correctAnswer;
    if (isCorrect) {
      correctCount.value++;
      score.value += mode == BrainBattleMode.speedRound ? 100 : 10;
    }

    Future.delayed(const Duration(milliseconds: 700), () {
      answerLocked.value = false;
      lastSelectedAnswer.value = null;
      _nextQuestion();
    });
  }

  void _nextQuestion() {
    if (currentIndex.value + 1 >= questions.length) {
      if (mode == BrainBattleMode.study) {
        // Loop back for endless study practice
        currentIndex.value = 0;
        questions.shuffle();
      } else {
        _endGame();
      }
      return;
    }
    currentIndex.value++;
  }

  Future<void> _endGame() async {
    if (isGameOver.value) return;
    isGameOver.value = true;
    _timer?.cancel();

    if (mode == BrainBattleMode.speedRound) {
      await _saveScore();
    }
  }

  Future<void> _saveScore() async {
    try {
      final firebaseUser = firebase_auth.FirebaseAuth.instance.currentUser;
      if (firebaseUser == null) return;

      String username = 'Player';
      try {
        final profile = await supabase.Supabase.instance.client
            .from('app_profiles')
            .select('username, full_name')
            .eq('id', firebaseUser.uid)
            .maybeSingle();
        if (profile != null) {
          username = (profile['username'] as String?)?.trim().isNotEmpty == true
              ? profile['username']
              : (profile['full_name'] as String?)?.trim().isNotEmpty == true
                  ? profile['full_name']
                  : 'Player';
        }
      } catch (_) {
        // Fall back to session user if the profile lookup fails
        final user = SessionManager.instance.getUser();
        username = user?.username ?? user?.fullname ?? 'Player';
      }

      await supabase.Supabase.instance.client.from('brain_battle_scores').insert({
        'user_id': firebaseUser.uid,
        'username': username,
        'score': score.value,
        'category': category,
        'questions_answered': currentIndex.value + 1,
        'correct_answers': correctCount.value,
      });
    } catch (e) {
      showSnackBar('Failed to save score: $e');
    }
  }
}
