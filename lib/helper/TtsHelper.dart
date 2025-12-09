import 'package:flutter_tts/flutter_tts.dart';

class TtsHelper {
  final FlutterTts tts = FlutterTts();

  Future<void> speak(String word) async {
    await tts.setLanguage("en-US");
    await tts.setPitch(1.0); // HIGHER for masculine voice (1.2-1.5)
    await tts.setSpeechRate(0.5); // Normal speed
    await tts.setVolume(1.0);

    // Platform-specific voice settings for male voice
    await tts.setVoice({
      "name": "en-gb-x-gbd-local",
      "locale": "en-GB",
    }); // British

    await tts.speak(word);
  }

  // // Enhanced method with pronunciation emphasis
  // Future<void> speakWithEmphasis(String word, {bool slow = false}) async {
  //   await tts.setLanguage("en-US");
  //   await tts.setPitch(1.15); // Even more boy-like
  //   await tts.setSpeechRate(slow ? 0.35 : 0.42); // Extra slow if needed
  //   await tts.setVolume(1.0);

  //   // Add slight pause between syllables for difficult words
  //   if (word.length >= 8 || _hasComplexSounds(word)) {
  //     await tts.setSpeechRate(0.38);
  //   }

  //   await tts.speak(word);
  // }

  // // Method for spelling out words
  // Future<void> spellWord(String word) async {
  //   await tts.setLanguage("en-US");
  //   await tts.setPitch(1.2); // Higher pitch for spelling
  //   await tts.setSpeechRate(0.5); // Faster for spelling
  //   await tts.setVolume(1.0);

  //   // Spell with pauses between letters
  //   for (int i = 0; i < word.length; i++) {
  //     await tts.speak(word[i]);
  //     await Future.delayed(const Duration(milliseconds: 300));
  //   }

  //   // Say the complete word after spelling
  //   await Future.delayed(const Duration(milliseconds: 500));
  //   await speak(word);
  // }

  // // Method for syllable-by-syllable pronunciation
  // Future<void> speakBySyllables(String word) async {
  //   List<String> syllables = _extractSyllables(word);

  //   await tts.setLanguage("en-US");
  //   await tts.setPitch(1.1);
  //   await tts.setSpeechRate(0.4);
  //   await tts.setVolume(1.0);

  //   for (int i = 0; i < syllables.length; i++) {
  //     await tts.speak(syllables[i]);
  //     if (i < syllables.length - 1) {
  //       await Future.delayed(const Duration(milliseconds: 400));
  //     }
  //   }

  //   // Say the complete word after syllables
  //   await Future.delayed(const Duration(milliseconds: 600));
  //   await speak(word);
  // }

  // // Method with emotional tone (excited, curious, etc.)
  // Future<void> speakWithTone(String word, {String tone = 'neutral'}) async {
  //   await tts.setLanguage("en-US");

  //   switch (tone) {
  //     case 'excited':
  //       await tts.setPitch(1.25);
  //       await tts.setSpeechRate(0.5);
  //       await tts.setVolume(1.0);
  //       break;
  //     case 'curious':
  //       await tts.setPitch(1.3);
  //       await tts.setSpeechRate(0.45);
  //       await tts.setVolume(0.9);
  //       break;
  //     case 'encouraging':
  //       await tts.setPitch(1.15);
  //       await tts.setSpeechRate(0.4);
  //       await tts.setVolume(1.0);
  //       break;
  //     default: // neutral
  //       await tts.setPitch(1.1);
  //       await tts.setSpeechRate(0.42);
  //       await tts.setVolume(1.0);
  //   }

  //   await tts.speak(word);
  // }

  // // Helper method to check for complex sounds
  // bool _hasComplexSounds(String word) {
  //   final complexPatterns = [
  //     'th', 'sh', 'ch', 'ph', 'gh', 'wh', // Digraphs
  //     'ough', 'augh', 'eigh', // Complex vowel combinations
  //     'tion', 'sion', 'cian', // Common suffixes
  //     'able', 'ible', 'ment'  // More suffixes
  //   ];

  //   return complexPatterns.any((pattern) => word.contains(pattern));
  // }

  // // Syllable extraction helper
  // List<String> _extractSyllables(String word) {
  //   List<String> syllables = [];
  //   String currentSyllable = '';

  //   for (int i = 0; i < word.length; i++) {
  //     currentSyllable += word[i];
  //     if (i < word.length - 1 && _isVowel(word[i]) && !_isVowel(word[i + 1])) {
  //       syllables.add(currentSyllable);
  //       currentSyllable = '';
  //     }
  //   }

  //   if (currentSyllable.isNotEmpty) {
  //     syllables.add(currentSyllable);
  //   }

  //   return syllables.isNotEmpty ? syllables : [word];
  // }

  // bool _isVowel(String char) {
  //   return 'aeiouy'.contains(char.toLowerCase());
  // }

  // // Method to stop speaking
  // Future<void> stop() async {
  //   await tts.stop();
  // }

  // // Method to check if TTS is speaking
  // // Future<bool> isSpeaking() async {
  // //   return await tts.isSpeaking();
  // // }

  // // Initialize TTS with better settings
  // Future<void> initialize() async {
  //   await tts.setLanguage("en-US");
  //   await tts.setPitch(1.1);
  //   await tts.setSpeechRate(0.42);
  //   await tts.setVolume(1.0);
  //   await tts.setSharedInstance(true);

  //   // Set completion handler
  //   tts.setCompletionHandler(() {
  //     print("TTS completed");
  //   });

  //   tts.setErrorHandler((msg) {
  //     print("TTS error: $msg");
  //   });
  // }
}
