import 'package:flutter/material.dart';
import '../auth/login_screen.dart';
import '../privacy/privacy_screen.dart';
import '../../services/prefs_service.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _controller = PageController();
  int currentIndex = 0;

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
    return Scaffold(
      body: PageView.builder(
        controller: _controller,
        itemCount: pages.length,
        onPageChanged: (index) {
          setState(() => currentIndex = index);
        },
        itemBuilder: (context, index) {
          return _OnboardPage(
            data: pages[index],
            currentIndex: currentIndex,
            total: pages.length,
            onNext: () {
              if (index == pages.length - 1) {
                _finishOnboarding(goToPrivacy: true);
              } else {
                _controller.nextPage(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.ease,
                );
              }
            },
            onSkip: () {
              _finishOnboarding();
            },
          );
        },
      ),
    );
  }
}

class _OnboardPage extends StatelessWidget {
  final _OnboardData data;
  final int currentIndex;
  final int total;
  final VoidCallback onNext;
  final VoidCallback onSkip;

  const _OnboardPage({
    required this.data,
    required this.currentIndex,
    required this.total,
    required this.onNext,
    required this.onSkip,
  });

  @override
  Widget build(BuildContext context) {
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

            Container(
              height: 180,
              width: 180,
              decoration: BoxDecoration(
                color: isDark
                    ? Colors.white.withValues(alpha: 0.1)
                    : Colors.white.withValues(alpha: 0.7),
                borderRadius: BorderRadius.circular(28),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.08),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: const Center(
                child: Icon(Icons.favorite, size: 60, color: Colors.green),
              ),
            ),

            const SizedBox(height: 40),

            Text(
              data.title,
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w600,
                color: textColor,
              ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 12),

            Text(
              data.subtitle,
              style: TextStyle(
                fontSize: 16,
                color: subtextColor,
              ),
              textAlign: TextAlign.center,
            ),

            const Spacer(),

            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                total,
                    (index) => Container(
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  width: currentIndex == index ? 24 : 8,
                  height: 8,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    gradient: currentIndex == index
                        ? const LinearGradient(
                      colors: [
                        Color(0xFF9BE7C4),
                        Color(0xFF7AD7C1),
                      ],
                    )
                        : null,
                    color: currentIndex == index
                        ? null
                        : isDark
                            ? Colors.white.withValues(alpha: 0.2)
                            : Colors.white.withValues(alpha: 0.6),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 24),

            Container(
              width: double.infinity,
              height: 56,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(28),
                gradient: const LinearGradient(
                  colors: [Color(0xFF9BE7C4), Color(0xFF7AD7C1)],
                ),
              ),
              child: TextButton(
                onPressed: onNext,
                child: Text(
                  data.buttonText,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                  ),
                ),
              ),
            ),

            if (data.showLogin) ...[
              const SizedBox(height: 16),
              TextButton(
                onPressed: onSkip,
                child: Text('Login',
                    style: TextStyle(color: subtextColor)),
              ),
            ],

            const SizedBox(height: 30),
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
