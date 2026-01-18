import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../profile/profile_screen.dart';
import '../auth/login_screen.dart';
import 'package:mindease/services/prefs_service.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool biometricEnabled = false;
  bool loading = true;

  @override
  void initState() {
    super.initState();
    _loadPrefs();
  }

  Future<void> _loadPrefs() async {
    biometricEnabled = await PrefsService().isBiometricEnabled();
    setState(() => loading = false);
  }

  Future<void> _toggleBiometric(bool value) async {
    setState(() => biometricEnabled = value);
    await PrefsService().setBiometric(value);
  }

  // 🔴 FINAL LOGOUT LOGIC
  Future<void> _logout() async {
    try {
      // 1️⃣ Firebase sign out
      await FirebaseAuth.instance.signOut();

      // 2️⃣ Optional: disable biometric on logout
      await PrefsService().setBiometric(false);

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
    if (loading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

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
                icon: Icons.fingerprint,
                title: 'Biometric Lock',
                subtitle: biometricEnabled ? 'Enabled' : 'Disabled',
                trailing: Switch(
                  value: biometricEnabled,
                  onChanged: _toggleBiometric,
                ),
              ),
              _tile(
                icon: Icons.language,
                title: 'Language',
                subtitle: 'English',
              ),

              const SizedBox(height: 20),

              _sectionTitle('Safety'),
              _tile(
                icon: Icons.warning,
                title: 'Emergency Contacts',
                subtitle: 'Manage SOS contacts',
              ),
              _tile(
                icon: Icons.lock,
                title: 'Privacy & Security',
                subtitle: 'Permissions & app lock',
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
