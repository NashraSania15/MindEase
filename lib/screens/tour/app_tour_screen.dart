import 'dart:async';
import 'package:flutter/material.dart';

class AppTourScreen extends StatefulWidget {
  final VoidCallback onDone;
  const AppTourScreen({super.key, required this.onDone});

  @override
  State<AppTourScreen> createState() => _AppTourScreenState();
}

class _AppTourScreenState extends State<AppTourScreen>
    with TickerProviderStateMixin {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  late AnimationController _fadeCtrl;
  late Animation<double> _fadeAnim;

  final List<_TourStep> _steps = const [
    _TourStep(
      emoji: '🕊️',
      title: 'MindEase Welcome',
      description:
          'Your sanctuary for mental wellness. Feel your stress melt away as we guide you through every step.',
      gradient: [Color(0xFF16222A), Color(0xFF3A6073)],
      lightGradient: [Color(0xFFEDE7F6), Color(0xFFB39DDB)],
    ),
    _TourStep(
      emoji: '👁️',
      title: 'Real-time Detection',
      description:
          'Our AI models read micro-expressions and vocal tones to understand how you truly feel.',
      gradient: [Color(0xFF0F2027), Color(0xFF203A43)],
      lightGradient: [Color(0xFFB2EBF2), Color(0xFF80CBC4)],
    ),
    _TourStep(
      emoji: '📊',
      title: 'Insightful Progress',
      description:
          'See your journey toward calm with beautiful interactive charts and historical trends.',
      gradient: [Color(0xFF2C3E50), Color(0xFF000000)],
      lightGradient: [Color(0xFFFFF9C4), Color(0xFFFFE082)],
    ),
    _TourStep(
      emoji: '🧘',
      title: 'Meditation & Calm',
      description:
          'Personalized exercises and breathing sessions based on your current stress levels.',
      gradient: [Color(0xFF141E30), Color(0xFF243B55)],
      lightGradient: [Color(0xFFE3F2FD), Color(0xFF90CAF9)],
    ),
    _TourStep(
      emoji: '🛡️',
      title: 'Safety Network',
      description:
          'When it matters most, we alert your emergency circle automatically. You are never alone.',
      gradient: [Color(0xFF4B0000), Color(0xFF250000)],
      lightGradient: [Color(0xFFFFEBEE), Color(0xFFEF9A9A)],
    ),
  ];

  @override
  void initState() {
    super.initState();
    _fadeCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _fadeAnim = CurvedAnimation(parent: _fadeCtrl, curve: Curves.easeIn);
    _fadeCtrl.forward();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _fadeCtrl.dispose();
    super.dispose();
  }

  void _next() {
    if (_currentPage < _steps.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOutCubic,
      );
    } else {
      _dismiss();
    }
  }

  void _dismiss() {
    _fadeCtrl.reverse().then((_) => widget.onDone());
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return FadeTransition(
      opacity: _fadeAnim,
      child: Scaffold(
        backgroundColor: isDark ? const Color(0xFF1A1A2E) : const Color(0xFF764BA2),
        body: Stack(
          children: [
            // Full screen animated gradient PageView
            PageView.builder(
              controller: _pageController,
              onPageChanged: (i) => setState(() => _currentPage = i),
              itemCount: _steps.length,
              itemBuilder: (context, index) {
                final step = _steps[index];
                final grad = isDark ? step.gradient : step.lightGradient;
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 400),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: grad,
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  child: SafeArea(
                    child: _TourPageContent(
                      step: step,
                      isActive: index == _currentPage,
                    ),
                  ),
                );
              },
            ),

            // Bottom controls overlay
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.fromLTRB(24, 20, 24, 40),
                child: Column(
                  children: [
                    // Dots
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(_steps.length, (i) {
                        final isActive = _currentPage == i;
                        return AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.fastOutSlowIn,
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          width: isActive ? 28 : 7,
                          height: 7,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            color: isActive
                                ? Colors.white
                                : Colors.white.withOpacity(0.4),
                          ),
                        );
                      }),
                    ),
                    const SizedBox(height: 28),
                    // Next / Get Started button
                    GestureDetector(
                      onTap: _next,
                      child: Container(
                        width: double.infinity,
                        height: 58,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.15),
                              blurRadius: 20,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              _currentPage == _steps.length - 1
                                  ? 'Get Started 🚀'
                                  : 'Next',
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF1A1A2E),
                              ),
                            ),
                            if (_currentPage < _steps.length - 1) ...[
                              const SizedBox(width: 8),
                              const Icon(
                                Icons.arrow_forward_rounded,
                                color: Color(0xFF1A1A2E),
                                size: 20,
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Skip
                    if (_currentPage < _steps.length - 1)
                      GestureDetector(
                        onTap: _dismiss,
                        child: Text(
                          'Skip tour',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.7),
                            fontSize: 15,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TourPageContent extends StatefulWidget {
  final _TourStep step;
  final bool isActive;
  const _TourPageContent({required this.step, required this.isActive});

  @override
  State<_TourPageContent> createState() => _TourPageContentState();
}

class _TourPageContentState extends State<_TourPageContent>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _scale;
  late Animation<double> _fade;
  late Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _scale = Tween<double>(begin: 0.7, end: 1.0).animate(
        CurvedAnimation(parent: _ctrl, curve: Curves.elasticOut));
    _fade = CurvedAnimation(parent: _ctrl, curve: Curves.easeIn);
    _slide = Tween<Offset>(
      begin: const Offset(0, 0.15),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOutCubic));
    if (widget.isActive) _ctrl.forward();
  }

  @override
  void didUpdateWidget(_TourPageContent oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isActive && !oldWidget.isActive) {
      _ctrl.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(28, 40, 28, 180),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Big emoji circle
          ScaleTransition(
            scale: _scale,
            child: Container(
              height: 140,
              width: 140,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.18),
                border: Border.all(
                    color: Colors.white.withOpacity(0.3), width: 2),
              ),
              child: Center(
                child: Text(
                  widget.step.emoji,
                  style: const TextStyle(fontSize: 68),
                ),
              ),
            ),
          ),

          const SizedBox(height: 48),

          // Title
          FadeTransition(
            opacity: _fade,
            child: SlideTransition(
              position: _slide,
              child: Text(
                widget.step.title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                  letterSpacing: -0.5,
                  height: 1.1,
                ),
              ),
            ),
          ),

          const SizedBox(height: 20),

          // Description
          FadeTransition(
            opacity: _fade,
            child: SlideTransition(
              position: _slide,
              child: Text(
                widget.step.description,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 17,
                  color: Colors.white.withOpacity(0.85),
                  height: 1.55,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TourStep {
  final String emoji;
  final String title;
  final String description;
  final List<Color> gradient;
  final List<Color> lightGradient;

  const _TourStep({
    required this.emoji,
    required this.title,
    required this.description,
    required this.gradient,
    required this.lightGradient,
  });
}
