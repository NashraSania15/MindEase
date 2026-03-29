import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../profile/profile_screen.dart';
import '../auth/login_screen.dart';
import '../emergency/emergency_screen.dart';
import 'language_screen.dart';
import 'privacy_settings_screen.dart';

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

      // 3️⃣ Navigate to login & clear stack
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const LoginScreen()),
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

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFF7F7FB), Color(0xFFEFF6F5)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              const Text(
                'Settings',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w600,
                ),
              ),

              const SizedBox(height: 20),

              _sectionTitle('Account'),
              _tile(
                icon: Icons.person,
                title: 'Profile',
                subtitle: 'View & edit profile',
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

              _sectionTitle('Preferences'),
              _tile(
                icon: Icons.language,
                title: 'Language',
                subtitle: 'English',
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

              _sectionTitle('Safety'),
              _tile(
                icon: Icons.warning,
                title: 'Emergency Contacts',
                subtitle: 'Manage SOS contacts',
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

              _sectionTitle('Other'),
              _tile(
                icon: Icons.logout,
                title: 'Logout',
                subtitle: 'Sign out from app',
                iconColor: Colors.red,
                onTap: _logout,
              ),
            ],
          ),
        ),
      ),
    );
  }

  static Widget _sectionTitle(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 14,
          color: Colors.grey,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  static Widget _tile({
    required IconData icon,
    required String title,
    required String subtitle,
    Color iconColor = Colors.green,
    Widget? trailing,
    VoidCallback? onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
      ),
      child: ListTile(
        onTap: onTap,
        leading: Icon(icon, color: iconColor),
        title: Text(title),
        subtitle: Text(subtitle),
        trailing: trailing ?? const Icon(Icons.chevron_right),
      ),
    );
  }
}
