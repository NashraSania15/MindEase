import 'package:flutter/material.dart';
import 'signup_screen.dart';
import 'forgot_password_screen.dart';
import '../main/main_screen.dart';
import 'package:mindease/services/auth_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  bool isLoading = false;
  bool passwordVisible = false;

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    final email = emailController.text.trim();
    final password = passwordController.text.trim();

    // ── Input validation ──────────────────────────────────────────────────────
    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter your email and password.')),
      );
      return;
    }

    setState(() => isLoading = true);

    try {
      await AuthService().login(email: email, password: password);

      if (!mounted) return;
      // Replace the entire stack so user can't go back to login
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const MainScreen()),
        (route) => false,
      );
    } catch (e) {
      if (!mounted) return;
      // AuthService already strips "Exception: " prefix; show the message only.
      final msg = e.toString().replaceFirst('Exception: ', '');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(msg)),
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
    final canPop = Navigator.of(context).canPop();

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
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              children: [
                const SizedBox(height: 10),

                // Only show back button if there's a route to pop
                if (canPop)
                  Align(
                    alignment: Alignment.centerLeft,
                    child: IconButton(
                      icon: Icon(Icons.arrow_back, color: textColor),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ),

                const SizedBox(height: 20),

                Container(
                  height: 72,
                  width: 72,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: [Color(0xFF9BE7C4), Color(0xFF7AD7C1)],
                    ),
                  ),
                  child: const Icon(Icons.eco, color: Colors.white, size: 36),
                ),

                const SizedBox(height: 20),

                Text(
                  'Welcome Back',
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.w600,
                    color: textColor,
                  ),
                ),

                const SizedBox(height: 30),

                _inputField(
                  label: 'Email',
                  hint: 'Enter your email',
                  icon: Icons.email_outlined,
                  controller: emailController,
                  textColor: subtextColor,
                  fillColor: fieldFillColor,
                  fieldTextStyle: fieldTextStyle,
                  fieldHintStyle: fieldHintStyle,
                ),

                _inputField(
                  label: 'Password',
                  hint: 'Create a strong password',
                  icon: Icons.lock_outline,
                  controller: passwordController,
                  obscure: !passwordVisible,
                  textColor: subtextColor,
                  fillColor: fieldFillColor,
                  fieldTextStyle: fieldTextStyle,
                  fieldHintStyle: fieldHintStyle,
                  suffixWidget: IconButton(
                    icon: Icon(
                      passwordVisible ? Icons.visibility : Icons.visibility_off,
                      color: subtextColor,
                    ),
                    onPressed: () {
                      setState(() {
                        passwordVisible = !passwordVisible;
                      });
                    },
                  ),
                ),


                const SizedBox(height: 10),

                Container(
                  padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: isDark
                        ? Colors.white.withValues(alpha: 0.08)
                        : Colors.white.withValues(alpha: 0.7),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.fingerprint,
                          color: Color(0xFF9C27B0)),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'Biometric Lock',
                          style: TextStyle(color: textColor),
                        ),
                      ),
                      Switch(value: false, onChanged: (_) {}),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                _primaryButton(
                  text: isLoading ? 'Signing In...' : 'Sign In',
                  onTap: isLoading ? null : _login,
                ),

                const SizedBox(height: 16),

                GestureDetector(
                  onTap: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const SignupScreen(),
                      ),
                    );
                  },
                  child: const Text(
                    'Create Account',
                    style: TextStyle(
                      fontSize: 16,
                      color: Color(0xFF4CAF50),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const ForgotPasswordScreen(),
                      ),
                    );
                  },
                  child: Text(
                    'Forgot Password?',
                    style: TextStyle(
                      fontSize: 14,
                      color: isDark ? Colors.grey.shade400 : const Color(0xFF9E9E9E),
                    ),
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

  static Widget _inputField({
    required String label,
    required String hint,
    required IconData icon,
    required TextEditingController controller,
    required Color textColor,
    required Color fillColor,
    required TextStyle fieldTextStyle,
    required TextStyle fieldHintStyle,
    bool obscure = false,
    Widget? suffixWidget,
  }) {

    return Padding(
      padding: const EdgeInsets.only(bottom: 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style:
              TextStyle(fontSize: 14, color: textColor)),
          const SizedBox(height: 6),
          TextField(
            controller: controller,
            obscureText: obscure,
            style: fieldTextStyle,
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: fieldHintStyle,
              prefixIcon: Icon(icon, color: textColor),
              suffixIcon: suffixWidget,
              filled: true,
              fillColor: fillColor,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(18),
                borderSide: BorderSide.none,
              ),
            ),
          ),
        ],
      ),
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
