import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:talkflip/features/auth/screens/splash_screen.dart';
import 'package:talkflip/features/dashboard/screens/dashboard_screen.dart';
import 'package:talkflip/features/home/screen/home_screen.dart';
import 'package:talkflip/services/auth_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Firebase may have been auto-initialized by the native platform (especially
  // when using the Firebase Flutter plugins and native config files). Calling
  // `Firebase.initializeApp` when a default app already exists throws a
  // `[core/duplicate-app]` exception. Guard against duplicate initialization.
  try {
    // Prefer explicit initialization with generated options. Some platforms
    // may auto-initialize Firebase on the native side; that can race with the
    // Dart initialization and cause a duplicate-app error. Catch and ignore
    // duplicate-app to make startup robust.
    if (Firebase.apps.isEmpty) {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
    }
  } on FirebaseException catch (e) {
    // Ignore the duplicate-app error which means Firebase was already
    // initialized by native code. Re-throw other Firebase exceptions.
    if (e.code != 'duplicate-app') rethrow;
  }
  runApp(const PronunciationApp());
}

class PronunciationApp extends StatelessWidget {
  const PronunciationApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'TalkFlip',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const AuthWrapper(),
      routes: {
        '/home': (context) => PronunciationScreen(),
        '/dashboard': (context) => const DashboardScreen(),
        '/splash': (context) => const SplashScreen(),
      },
    );
  }
}

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: AuthService().authStateChanges,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const SplashScreen();
        }

        if (snapshot.hasData) {
          // User is logged in
          return const DashboardScreen();
        }

        // User is not logged in
        return const SplashScreen();
      },
    );
  }
}






