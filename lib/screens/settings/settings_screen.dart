import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../profile/profile_screen.dart';
import '../onboarding/onboarding_screen.dart';
import '../emergency/emergency_screen.dart';
import 'language_screen.dart';
import 'privacy_settings_screen.dart';
import '../../services/theme_service.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {

  @override
  void initState() {
    super.initState();
  }

  // 🔴 FINAL LOGOUT LOGIC
  Future<void> _logout() async {
    try {
      // 1️⃣ Clear all SharedPreferences session data
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();

      // 2️⃣ Firebase sign out
      await FirebaseAuth.instance.signOut();

      if (!mounted) return;

      // 3️⃣ Navigate to onboarding & clear stack (no going back)
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const OnboardingScreen()),
            (route) => false,
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Logout failed. Please try again.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardColor = isDark ? const Color(0xFF1E1E2C) : Colors.white;
    final textColor = isDark ? Colors.white : Colors.black87;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: isDark
                ? [const Color(0xFF0D0D1A), const Color(0xFF1A1A2E)]
                : [const Color(0xFFF7F7FB), const Color(0xFFEFF6F5)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Text(
                'Settings',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w600,
                  color: textColor,
                ),
              ),

              const SizedBox(height: 20),

              _sectionTitle('Account', isDark),
              _tile(
                icon: Icons.person,
                title: 'Profile',
                subtitle: 'View & edit profile',
                cardColor: cardColor,
                textColor: textColor,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const ProfileScreen(),
                    ),
                  );
                },
              ),

              const SizedBox(height: 20),

              _sectionTitle('Appearance', isDark),
              // ── Dark Mode Toggle ──
              Container(
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  color: cardColor,
                  borderRadius: BorderRadius.circular(18),
                ),
                child: AnimatedBuilder(
                  animation: themeService,
                  builder: (context, _) {
                    return SwitchListTile(
                      secondary: Icon(
                        themeService.isDarkMode
                            ? Icons.dark_mode
                            : Icons.light_mode,
                        color: themeService.isDarkMode
                            ? const Color(0xFFFFD54F)
                            : Colors.orange,
                      ),
                      title: Text(
                        'Dark Mode',
                        style: TextStyle(color: textColor),
                      ),
                      subtitle: Text(
                        themeService.isDarkMode
                            ? 'Switch to light theme'
                            : 'Switch to dark theme',
                        style: TextStyle(
                          color: isDark ? Colors.grey.shade400 : Colors.grey,
                        ),
                      ),
                      value: themeService.isDarkMode,
                      activeColor: const Color(0xFF9BE7C4),
                      onChanged: (_) => themeService.toggleTheme(),
                    );
                  },
                ),
              ),

              _sectionTitle('Preferences', isDark),
              _tile(
                icon: Icons.language,
                title: 'Language',
                subtitle: 'English',
                cardColor: cardColor,
                textColor: textColor,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const LanguageScreen(),
                    ),
                  );
                },
              ),

              const SizedBox(height: 20),

              _sectionTitle('Safety', isDark),
              _tile(
                icon: Icons.warning,
                title: 'Emergency Contacts',
                subtitle: 'Manage SOS contacts',
                cardColor: cardColor,
                textColor: textColor,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const EmergencyScreen(),
                    ),
                  );
                },
              ),
              _tile(
                icon: Icons.lock,
                title: 'Privacy & Security',
                subtitle: 'Permissions & app lock',
                cardColor: cardColor,
                textColor: textColor,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const PrivacySettingsScreen(),
                    ),
                  );
                },
              ),


              const SizedBox(height: 20),

              _sectionTitle('Other', isDark),
              _tile(
                icon: Icons.logout,
                title: 'Logout',
                subtitle: 'Sign out from app',
                iconColor: Colors.red,
                cardColor: cardColor,
                textColor: textColor,
                onTap: _logout,
              ),
            ],
          ),
        ),
      ),
    );
  }

  static Widget _sectionTitle(String text, bool isDark) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 14,
          color: isDark ? Colors.grey.shade400 : Colors.grey,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  static Widget _tile({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color cardColor,
    required Color textColor,
    Color iconColor = Colors.green,
    Widget? trailing,
    VoidCallback? onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(18),
      ),
      child: ListTile(
        onTap: onTap,
        leading: Icon(icon, color: iconColor),
        title: Text(title, style: TextStyle(color: textColor)),
        subtitle: Text(subtitle),
        trailing: trailing ?? Icon(Icons.chevron_right, color: textColor.withValues(alpha: 0.5)),
      ),
    );
  }
}
