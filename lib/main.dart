import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'screens/auth/login_screen.dart';
import 'screens/main/main_screen.dart';
import 'firebase_options.dart';

import 'screens/onboarding/onboarding_screen.dart';
import 'services/prefs_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MindEaseApp());
}


class MindEaseApp extends StatelessWidget {
  const MindEaseApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'MindEase',
      theme: ThemeData(
        useMaterial3: false,
        primaryColor: const Color(0xFF9BE7C4),
        scaffoldBackgroundColor: Colors.white,
      ),
      home: const StartDecider(),
    );
  }
}

class StartDecider extends StatelessWidget {
  const StartDecider({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: PrefsService().isOnboardingDone(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final user = FirebaseAuth.instance.currentUser;

        // 1️⃣ First time → onboarding
        if (!snapshot.data!) {
          return const OnboardingScreen();
        }

        // 2️⃣ After onboarding
        // logged in → main
        // not logged in → login
        return user == null
            ? const LoginScreen()
            : const MainScreen();
      },
    );
  }
}