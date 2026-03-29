import 'package:shared_preferences/shared_preferences.dart';

class PrefsService {
  static const String _onboardingKey = 'onboarding_done';
  static const String _languageKey = 'selected_language';
  static const String _appLockKey = 'app_lock_enabled';

  Future<bool> isOnboardingDone() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_onboardingKey) ?? false;
  }

  Future<void> setOnboardingDone() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_onboardingKey, true);
  }

  // ─── Language ───────────────────────────────────────────────────────────────

  /// Returns the saved language code ('en' or 'hi'). Defaults to 'en'.
  Future<String> getLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_languageKey) ?? 'en';
  }

  Future<void> setLanguage(String langCode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_languageKey, langCode);
  }

  // ─── App Lock ───────────────────────────────────────────────────────────────

  Future<bool> isAppLockEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_appLockKey) ?? false;
  }

  Future<void> setAppLockEnabled(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_appLockKey, enabled);
  }

  // ─── Clear All ──────────────────────────────────────────────────────────────

  /// Clears all stored preferences (used during logout).
  Future<void> clearAll() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }
}