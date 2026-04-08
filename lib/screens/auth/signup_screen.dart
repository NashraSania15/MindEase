import 'package:flutter/material.dart';
import 'login_screen.dart';
import '../main/main_screen.dart';
import 'package:mindease/services/auth_service.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
  TextEditingController();
  bool passwordVisible = false;
  bool confirmPasswordVisible = false;

  bool isLoading = false;
  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _signup() async {
    final name = nameController.text.trim();
    final email = emailController.text.trim();
    final password = passwordController.text.trim();
    final confirmPassword = confirmPasswordController.text.trim();

    // ── Input validation ────────────────────────────────────────────────────
    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter your name.')),
      );
      return;
    }
    if (email.isEmpty || !email.contains('@')) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid email address.')),
      );
      return;
    }
    if (password.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Password must be at least 6 characters.')),
      );
      return;
    }
    if (password != confirmPassword) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Passwords do not match.')),
      );
      return;
    }

    setState(() => isLoading = true);

    try {
      await AuthService().signup(name: name, email: email, password: password);

      if (!mounted) return;
      // Replace entire stack so user can't go back to signup
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const MainScreen()),
        (route) => false,
      );
    } catch (e) {
      if (!mounted) return;
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
      backgroundColor: isDark ? const Color(0xFF1A1A2E) : const Color(0xFFE0F2F1),
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

                if (canPop)
                  Align(
                    alignment: Alignment.centerLeft,
                    child: IconButton(
                      icon: Icon(Icons.arrow_back, color: textColor),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ),

                const SizedBox(height: 10),

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
                  'Create Your Safe Space',
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.w600,
                    color: textColor,
                  ),
                ),

                const SizedBox(height: 6),

                Text(
                  "Let's get started with MindEase",
                  style: TextStyle(
                    fontSize: 14,
                    color: subtextColor,
                  ),
                ),

                const SizedBox(height: 30),

                _inputField(
                  label: 'Full Name',
                  hint: 'Enter your name',
                  icon: Icons.person_outline,
                  controller: nameController,
                  textColor: subtextColor,
                  fillColor: fieldFillColor,
                  fieldTextStyle: fieldTextStyle,
                  fieldHintStyle: fieldHintStyle,
                ),

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


                _inputField(
                  label: 'Confirm Password',
                  hint: 'Re-enter your password',
                  icon: Icons.lock_outline,
                  controller: confirmPasswordController,
                  obscure: !confirmPasswordVisible,
                  textColor: subtextColor,
                  fillColor: fieldFillColor,
                  fieldTextStyle: fieldTextStyle,
                  fieldHintStyle: fieldHintStyle,
                  suffixWidget: IconButton(
                    icon: Icon(
                      confirmPasswordVisible
                          ? Icons.visibility
                          : Icons.visibility_off,
                      color: subtextColor,
                    ),
                    onPressed: () {
                      setState(() {
                        confirmPasswordVisible = !confirmPasswordVisible;
                      });
                    },
                  ),
                ),


                const SizedBox(height: 20),

                _primaryButton(
                  text: isLoading ? 'Creating...' : 'Create Account',
                  onTap: isLoading ? null : _signup,
                ),

                const SizedBox(height: 24),

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Already have an account? ',
                      style: TextStyle(color: subtextColor),
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const LoginScreen(),
                          ),
                        );
                      },
                      child: const Text(
                        'Log in',
                        style: TextStyle(
                          color: Color(0xFF4CAF50),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
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
