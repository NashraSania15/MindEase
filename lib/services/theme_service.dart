import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Global theme notifier — listened to by MaterialApp to toggle dark mode.
class ThemeService extends ChangeNotifier {
  static const String _key = 'dark_mode_enabled';

  ThemeService() {
    _loadFromPrefs();
  }

  bool _isDarkMode = false;
  bool _initialized = false;
  bool get isDarkMode => _isDarkMode;

  /// Call once at app startup before runApp() to avoid theme flicker.
  static Future<void> initialize() async {
    final prefs = await SharedPreferences.getInstance();
    themeService._isDarkMode = prefs.getBool(_key) ?? false;
    themeService._initialized = true;
  }

  // ─── Light Theme ────────────────────────────────────────────────────────────
  ThemeData get lightTheme => ThemeData(
        useMaterial3: false,
        brightness: Brightness.light,
        primaryColor: const Color(0xFF9BE7C4),
        scaffoldBackgroundColor: Colors.white,
        colorScheme: const ColorScheme.light(
          primary: Color(0xFF9BE7C4),
          secondary: Color(0xFF7AD7C1),
          surface: Colors.white,
        ),
        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          backgroundColor: Colors.white,
          selectedItemColor: Color(0xFF4CAF50),
          unselectedItemColor: Colors.grey,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white,
          foregroundColor: Colors.black87,
          elevation: 0,
        ),
        cardColor: Colors.white,
        dividerColor: Colors.grey.shade200,
      );

  // ─── Dark Theme ─────────────────────────────────────────────────────────────
  ThemeData get darkTheme => ThemeData(
        useMaterial3: false,
        brightness: Brightness.dark,
        primaryColor: const Color(0xFF9BE7C4),
        scaffoldBackgroundColor: const Color(0xFF121212),
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFF9BE7C4),
          secondary: Color(0xFF7AD7C1),
          surface: Color(0xFF1E1E2C),
        ),
        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          backgroundColor: Color(0xFF1A1A2E),
          selectedItemColor: Color(0xFF9BE7C4),
          unselectedItemColor: Colors.grey,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF1A1A2E),
          foregroundColor: Colors.white,
          elevation: 0,
        ),
        cardColor: const Color(0xFF1E1E2C),
        dividerColor: Colors.white12,
      );

  /// Current theme — used by MaterialApp.
  ThemeData get currentTheme => _isDarkMode ? darkTheme : lightTheme;

  void toggleTheme() {
    _isDarkMode = !_isDarkMode;
    _saveToPrefs();
    notifyListeners();
  }

  Future<void> _loadFromPrefs() async {
    if (_initialized) return; // Already loaded by initialize()
    final prefs = await SharedPreferences.getInstance();
    _isDarkMode = prefs.getBool(_key) ?? false;
    notifyListeners();
  }

  Future<void> _saveToPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_key, _isDarkMode);
  }
}

/// Singleton accessor so every screen can read the same instance.
final ThemeService themeService = ThemeService();
