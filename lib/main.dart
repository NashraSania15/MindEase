import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'screens/auth/login_screen.dart';
import 'screens/main/main_screen.dart';
import 'firebase_options.dart';
import 'services/prefs_service.dart';
import 'services/theme_service.dart';
import 'services/stress_history_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (e) {
    // Firebase already initialized by native google-services.json — safe to ignore
  }
  // Load saved theme (dark/light) before first frame to avoid flicker
  await ThemeService.initialize();
  await StressHistoryService.init(); // Initialize local history
  runApp(const MindEaseApp());
}


class MindEaseApp extends StatelessWidget {
  const MindEaseApp({super.key});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: themeService,
      builder: (context, _) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'MindEase',
          theme: themeService.lightTheme,
          darkTheme: themeService.darkTheme,
          themeMode: themeService.isDarkMode ? ThemeMode.dark : ThemeMode.light,
          home: const StartDecider(),
        );
      },
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

        // 1️⃣ First time or Not logged in -> Login
        if (user == null) {
          return const LoginScreen();
        }

        // 2️⃣ Logged in -> Main (Tour is handled inside MainScreen after login)
        return const MainScreen();
      },
    );
  }
}