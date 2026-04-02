import 'package:flutter/material.dart';
import 'package:mindease/services/auth_service.dart';
import 'check_email_screen.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final TextEditingController emailController = TextEditingController();
  bool isLoading = false;

  @override
  void dispose() {
    emailController.dispose();
    super.dispose();
  }

  Future<void> _sendResetLink() async {
    setState(() => isLoading = true);

    try {
      await AuthService().sendPasswordReset(
        emailController.text.trim(),
      );

      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => const CheckEmailScreen(),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : const Color(0xFF4A4A4A);
    final subtextColor = isDark ? Colors.grey.shade400 : const Color(0xFF7A7A7A);
    final fieldFillColor = isDark ? const Color(0xFF1E1E2C) : Colors.white;
    final fieldTextStyle = TextStyle(color: isDark ? Colors.white : Colors.black87);
    final fieldHintStyle = TextStyle(color: isDark ? Colors.grey.shade500 : Colors.grey);

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: isDark
                ? const [Color(0xFF0D0D1A), Color(0xFF1A1A2E)]
                : const [Color(0xFFEDE7F6), Color(0xFFE0F2F1)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              children: [
                const SizedBox(height: 10),

                Align(
                  alignment: Alignment.centerLeft,
                  child: IconButton(
                    icon: Icon(Icons.arrow_back, color: textColor),
                    onPressed: () => Navigator.pop(context),
                  ),
                ),

                const SizedBox(height: 30),

                Container(
                  height: 72,
                  width: 72,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: [Color(0xFF9BE7C4), Color(0xFF7AD7C1)],
                    ),
                  ),
                  child: const Icon(Icons.lock_reset,
                      color: Colors.white, size: 34),
                ),

                const SizedBox(height: 20),

                Text(
                  'Forgot Password?',
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.w600,
                    color: textColor,
                  ),
                ),

                const SizedBox(height: 10),

                Text(
                  'Enter your email address and we\'ll\nsend you a reset link',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    color: subtextColor,
                  ),
                ),

                const SizedBox(height: 40),

                _inputField(
                  label: 'Email Address',
                  hint: 'your.email@example.com',
                  icon: Icons.email_outlined,
                  controller: emailController,
                  textColor: subtextColor,
                  fillColor: fieldFillColor,
                  fieldTextStyle: fieldTextStyle,
                  fieldHintStyle: fieldHintStyle,
                ),

                const Spacer(),

                _primaryButton(
                  text: isLoading ? 'Sending...' : 'Send Reset Link',
                  onTap: isLoading ? null : _sendResetLink,
                ),

                const SizedBox(height: 30),
              ],
            ),
          ),
        ),
      ),
    );
  }

  static Widget _inputField({
    required String label,
    required String hint,
    required IconData icon,
    required TextEditingController controller,
    required Color textColor,
    required Color fillColor,
    required TextStyle fieldTextStyle,
    required TextStyle fieldHintStyle,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style:
            TextStyle(fontSize: 14, color: textColor)),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          style: fieldTextStyle,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: fieldHintStyle,
            prefixIcon: Icon(icon, color: textColor),
            filled: true,
            fillColor: fillColor,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(18),
              borderSide: BorderSide.none,
            ),
          ),
        ),
      ],
    );
  }

  static Widget _primaryButton({
    required String text,
    required VoidCallback? onTap,
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
