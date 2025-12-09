 
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:talkflip/features/home/provider/PronounceChecker.dart';
import 'package:talkflip/features/home/screen/simple_form_screen.dart';
import 'package:talkflip/helper/TtsHelper.dart'; 

class PronunciationScreen extends StatefulWidget {
  const PronunciationScreen({super.key});

  @override
  State<PronunciationScreen> createState() => _PronunciationScreenState();
}

class _PronunciationScreenState extends State<PronunciationScreen> {
  final TtsHelper tts = TtsHelper();
  final SpeechToText speech = SpeechToText();
  final PronounceChecker checker = PronounceChecker();

  String targetWord = "COQUETTISH";
  String userSpoken = "";
  String feedback = "";
  double score = 0;
  bool isListening = false;

  // APP SPEAKS WORD
  Future<void> playWord() async {
    await tts.speak(targetWord); 
  }

  // USER SPEAKS WORD
  Future<void> userSpeak() async {
    bool allowed = await checkMicrophonePermission();
    if (!allowed) {
      print("Microphone permission denied");
      return;
    }
    bool ready = await speech.initialize();
    if (!ready) return;

    setState(() {
      isListening = true;
      userSpoken = "";
      score = 0;
      feedback = '';
    });

    speech.listen(
      localeId: "en_US",
      listenFor: const Duration(seconds: 3),
      onResult: (result) {
        userSpoken = result.recognizedWords.toLowerCase();
      },
    );

    await Future.delayed(const Duration(seconds: 3));
    await speech.stop();

    setState(() => isListening = false);

    // SCORE PRONUNCIATION
    if (userSpoken.isNotEmpty) {
      score = checker.finalScore(targetWord, userSpoken);
      feedback = checker.getFeedback(score);
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Pronunciation Practice"),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Target Word
            Text(
              targetWord.toUpperCase(),
              style: const TextStyle(fontSize: 40, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 20),

            // BUTTON: App speaks
            ElevatedButton.icon(
              onPressed: playWord,
              icon: const Icon(Icons.volume_up),
              label: const Text("Play Word"),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.all(15),
                textStyle: const TextStyle(fontSize: 18),
              ),
            ),

            const SizedBox(height: 20),

            // BUTTON: User speaks (MIC BUTTON)
            ElevatedButton.icon(
              onPressed: userSpeak,
              icon: const Icon(Icons.mic, size: 26),
              label: const Text("Speak Now"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent,
                padding: const EdgeInsets.all(15),
                textStyle: const TextStyle(fontSize: 18),
              ),
            ),

            const SizedBox(height: 20),

            // BUTTON: Open Simple Form
            ElevatedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const SimpleFormScreen(),
                  ),
                );
              },
              icon: const Icon(Icons.edit_note),
              label: const Text("Open Form"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.purple,
                padding: const EdgeInsets.all(15),
                textStyle: const TextStyle(fontSize: 18),
              ),
            ),

            const SizedBox(height: 40),

            if (isListening)
              const Text(
                "Listening...",
                style: TextStyle(fontSize: 20, color: Colors.green),
              ),

            const SizedBox(height: 20),

            if (userSpoken.isNotEmpty)
              Text(
                "You said: $userSpoken",
                style: const TextStyle(fontSize: 20),
              ),

            const SizedBox(height: 20),

            if (score > 0)
              Text(
                "Score: ${score.toStringAsFixed(1)}%",
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue,
                ),
              ),
            Text(
              feedback,
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Color.fromARGB(255, 33, 243, 54),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

Future<bool> checkMicrophonePermission() async {
  var status = await Permission.microphone.status;
  if (!status.isGranted) {
    status = await Permission.microphone.request();
  }
  return status.isGranted;
}
