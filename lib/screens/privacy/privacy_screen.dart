import 'package:flutter/material.dart';
import '../auth/signup_screen.dart';

class PrivacyScreen extends StatelessWidget {
  const PrivacyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFEDE7F6), Color(0xFFE0F2F1)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              children: [
                const SizedBox(height: 30),

                // Shield Icon
                Container(
                  height: 72,
                  width: 72,
                  decoration: const BoxDecoration(
                    color: Color(0xFF9BE7C4),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.shield_outlined,
                    size: 36,
                    color: Colors.white,
                  ),
                ),

                const SizedBox(height: 20),

                const Text(
                  'Your Privacy Matters',
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF4A4A4A),
                  ),
                ),

                const SizedBox(height: 8),

                const Text(
                  'We need a few permissions to help you track\nand manage stress effectively',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    color: Color(0xFF7A7A7A),
                  ),
                ),

                const SizedBox(height: 30),

                _permissionCard(
                  icon: Icons.mic,
                  iconColor: Color(0xFFFFB3C7),
                  title: 'Microphone Access',
                  subtitle:
                  'Analyze your voice patterns to detect stress levels and emotional state',
                ),

                _permissionCard(
                  icon: Icons.camera_alt,
                  iconColor: Color(0xFFFFD6A5),
                  title: 'Camera Access',
                  subtitle:
                  'Use facial analysis to measure stress, fatigue, and emotional well-being',
                ),

                _permissionCard(
                  icon: Icons.description,
                  iconColor: Color(0xFFBEE7E8),
                  title: 'Text Analysis',
                  subtitle:
                  'Understand your emotional state through your written words and journal entries',
                ),

                const SizedBox(height: 20),

                // Privacy Promise
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE3F2FD),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Icon(Icons.lock, color: Color(0xFF4A90E2)),
                      SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'Privacy Promise\nAll data is encrypted and stored securely on your device. '
                              'We never share your personal information without your explicit consent. '
                              'You can revoke permissions anytime in settings.',
                          style: TextStyle(
                            fontSize: 13,
                            color: Color(0xFF4A4A4A),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 30),

                // Allow Permissions
                _primaryButton(
                  text: 'Allow Permissions',
                  onTap: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const SignupScreen(),
                      ),
                    );
                  },
                ),

                const SizedBox(height: 12),

                TextButton(
                  onPressed: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const SignupScreen(),
                      ),
                    );
                  },
                  child: const Text(
                    'Skip for Now',
                    style: TextStyle(color: Color(0xFF7A7A7A)),
                  ),
                ),

                const SizedBox(height: 10),

                const Text(
                  'You can enable these later in Settings to unlock full app functionality',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 12,
                    color: Color(0xFF9E9E9E),
                  ),
                ),

                const SizedBox(height: 30),
              ],
            ),
          ),
        ),
      ),
    );
  }

  static Widget _permissionCard({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            height: 44,
            width: 44,
            decoration: BoxDecoration(
              color: iconColor,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: Colors.white),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 13,
                    color: Color(0xFF7A7A7A),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  static Widget _primaryButton({
    required String text,
    required VoidCallback onTap,
  }) {
    return Container(
      width: double.infinity,
      height: 56,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        gradient: const LinearGradient(
          colors: [Color(0xFF9BE7C4), Color(0xFF7AD7C1)],
        ),
      ),
      child: TextButton(
        onPressed: onTap,
        child: Text(
          text,
          style: const TextStyle(color: Colors.white, fontSize: 18),
        ),
      ),
    );
  }
}
