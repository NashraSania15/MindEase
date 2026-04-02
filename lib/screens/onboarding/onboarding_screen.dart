import 'package:flutter/material.dart';
import '../auth/login_screen.dart';
import '../privacy/privacy_screen.dart';
import '../tour/app_tour_screen.dart';
import '../../services/prefs_service.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _controller = PageController();
  int currentIndex = 0;
  double _pageOffset = 0.0;

  @override
  void initState() {
    super.initState();
    _controller.addListener(() {
      if (mounted) {
        setState(() {
          _pageOffset = _controller.page ?? _controller.initialPage.toDouble();
        });
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  final List<_OnboardData> pages = [
    _OnboardData(
      lightGradient: const LinearGradient(
        colors: [Color(0xFFFFE0EC), Color(0xFFF3E5F5)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      darkGradient: const LinearGradient(
        colors: [Color(0xFF1A0D14), Color(0xFF1A1028)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      title: 'Detect Stress Early',
      subtitle:
      'Understand your stress using voice, text, and face analysis.',
      image: 'assets/icons/phone.png',
      buttonText: 'Continue',
    ),
    _OnboardData(
      lightGradient: const LinearGradient(
        colors: [Color(0xFFE0F7FA), Color(0xFFE8F5E9)],
      ),
      darkGradient: const LinearGradient(
        colors: [Color(0xFF0D1A1A), Color(0xFF0D1A14)],
      ),
      title: 'Track & Heal',
      subtitle:
      'See mood trends, journal privately, and get AI guidance.',
      image: 'assets/icons/chart.png',
      buttonText: 'Continue',
    ),
    _OnboardData(
      lightGradient: const LinearGradient(
        colors: [Color(0xFFFFEDE7), Color(0xFFFFEBEE)],
      ),
      darkGradient: const LinearGradient(
        colors: [Color(0xFF1A140D), Color(0xFF1A0D0D)],
      ),
      title: "You're Not Alone",
      subtitle:
      'Emergency alerts and supportive AI when you need it most.',
      image: 'assets/icons/heart.png',
      buttonText: 'Continue',
    ),
    _OnboardData(
      lightGradient: const LinearGradient(
        colors: [Color(0xFFEDE7F6), Color(0xFFE0F2F1)],
      ),
      darkGradient: const LinearGradient(
        colors: [Color(0xFF0D0D1A), Color(0xFF1A1A2E)],
      ),
      title: 'MindEase',
      subtitle: 'Your AI Stress Detection Companion',
      image: 'assets/icons/leaf.png',
      buttonText: 'Get Started',
      showLogin: true,
    ),
  ];

  Future<void> _finishOnboarding({bool goToPrivacy = false}) async {
    await PrefsService().setOnboardingDone();

    if (!mounted) return;

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) =>
        goToPrivacy ? const PrivacyScreen() : const LoginScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AppTourScreen(
      onDone: () => _finishOnboarding(goToPrivacy: true),
    );
  }
}

class _OnboardPage extends StatelessWidget {
  final _OnboardData data;
  final int index;
  final int currentIndex;
  final double pageOffset;
  final int total;
  final VoidCallback onNext;
  final VoidCallback onSkip;

  const _OnboardPage({
    required this.data,
    required this.index,
    required this.currentIndex,
    required this.pageOffset,
    required this.total,
    required this.onNext,
    required this.onSkip,
  });

  @override
  Widget build(BuildContext context) {
    final diff = (pageOffset - index);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : const Color(0xFF4A4A4A);
    final subtextColor = isDark ? Colors.grey.shade400 : const Color(0xFF7A7A7A);
    final gradient = isDark ? data.darkGradient : data.lightGradient;

    return Container(
      decoration: BoxDecoration(gradient: gradient),
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: SafeArea(
        child: Column(
          children: [
            Align(
              alignment: Alignment.topRight,
              child: TextButton(
                onPressed: onSkip,
                child: Text('Skip',
                    style: TextStyle(fontSize: 16, color: subtextColor)),
              ),
            ),

            const Spacer(),

            Transform.translate(
              offset: Offset(diff * 120, diff.abs() * 50),
              child: Transform.scale(
                scale: (1 - diff.abs() * 0.3).clamp(0.0, 1.0),
                child: Opacity(
                  opacity: (1 - diff.abs() * 0.8).clamp(0.0, 1.0),
                  child: Container(
                    height: 200,
                    width: 200,
                    decoration: BoxDecoration(
                      color: isDark
                          ? Colors.white.withValues(alpha: 0.1)
                          : Colors.white.withValues(alpha: 0.7),
                      borderRadius: BorderRadius.circular(40),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.08),
                          blurRadius: 30,
                          offset: const Offset(0, 15),
                        ),
                      ],
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(32),
                      child: Image.asset(data.image, fit: BoxFit.contain),
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 50),

            Transform.translate(
              offset: Offset(diff * 80, 0),
              child: Opacity(
                opacity: (1 - diff.abs() * 0.5).clamp(0.0, 1.0),
                child: Text(
                  data.title,
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.w700,
                    color: textColor,
                    letterSpacing: -0.5,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),

            const SizedBox(height: 16),

            Transform.translate(
              offset: Offset(diff * 50, 0),
              child: Opacity(
                opacity: (1 - diff.abs() * 0.5).clamp(0.0, 1.0),
                child: Text(
                  data.subtitle,
                  style: TextStyle(
                    fontSize: 17,
                    height: 1.4,
                    color: subtextColor,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),

            const SizedBox(height: 40),

            // Animated dot indicator
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(total, (i) {
                final isActive = currentIndex == i;
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 350),
                  curve: Curves.fastOutSlowIn,
                  margin: const EdgeInsets.symmetric(horizontal: 5),
                  width: isActive ? 32 : 8,
                  height: 8,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    gradient: isActive
                        ? const LinearGradient(
                            colors: [Color(0xFF9BE7C4), Color(0xFF60C8B5)],
                          )
                        : null,
                    color: isActive
                        ? null
                        : isDark
                            ? Colors.white.withValues(alpha: 0.25)
                            : Colors.black.withValues(alpha: 0.15),
                  ),
                );
              }),
            ),

            const SizedBox(height: 36),

            // CTA button
            GestureDetector(
              onTap: onNext,
              child: Container(
                width: double.infinity,
                height: 60,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  gradient: const LinearGradient(
                    colors: [Color(0xFF9BE7C4), Color(0xFF60C8B5)],
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF7AD7C1).withOpacity(0.45),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      data.buttonText,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.3,
                      ),
                    ),
                    const SizedBox(width: 10),
                    const Icon(Icons.arrow_forward_rounded,
                        color: Colors.white, size: 22),
                  ],
                ),
              ),
            ),

            if (data.showLogin) ...[
              const SizedBox(height: 18),
              TextButton(
                onPressed: onSkip,
                child: Text(
                  'Already have an account? Login',
                  style: TextStyle(
                    color: subtextColor,
                    fontSize: 14,
                    decoration: TextDecoration.underline,
                    decorationColor: subtextColor,
                  ),
                ),
              ),
            ],

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}

class _OnboardData {
  final LinearGradient lightGradient;
  final LinearGradient darkGradient;
  final String title;
  final String subtitle;
  final String image;
  final String buttonText;
  final bool showLogin;

  _OnboardData({
    required this.lightGradient,
    required this.darkGradient,
    required this.title,
    required this.subtitle,
    required this.image,
    required this.buttonText,
    this.showLogin = false,
  });
}
