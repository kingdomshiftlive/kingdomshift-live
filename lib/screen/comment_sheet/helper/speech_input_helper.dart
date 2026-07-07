import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

class SpeechInputHelper {
  final stt.SpeechToText _speech = stt.SpeechToText();
  bool _initialized = false;
  final ValueNotifier<bool> isListening = ValueNotifier(false);

  Future<void> toggleListening({
    required TextEditingController controller,
    required VoidCallback onChanged,
  }) async {
    if (isListening.value) {
      await _speech.stop();
      isListening.value = false;
      return;
    }

    if (!_initialized) {
      _initialized = await _speech.initialize(
        onStatus: (status) {
          if (status == 'done' || status == 'notListening') {
            isListening.value = false;
          }
        },
        onError: (error) {
          isListening.value = false;
        },
      );
    }

    if (!_initialized) return;

    isListening.value = true;
    await _speech.listen(
      onResult: (result) {
        controller.text = result.recognizedWords;
        controller.selection = TextSelection.fromPosition(
          TextPosition(offset: controller.text.length),
        );
        onChanged();
      },
    );
  }

  void dispose() {
    _speech.stop();
    isListening.dispose();
  }
}
