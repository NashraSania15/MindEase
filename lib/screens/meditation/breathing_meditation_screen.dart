import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:math' as math;

class BreathingMeditationScreen extends StatefulWidget {
  const BreathingMeditationScreen({super.key});

  @override
  State<BreathingMeditationScreen> createState() =>
      _BreathingMeditationScreenState();
}

class _BreathingMeditationScreenState
    extends State<BreathingMeditationScreen>
    with TickerProviderStateMixin {
  late AnimationController _breathController;
  late Animation<double> _breathAnimation;
  late AnimationController _glowController;
  late Animation<double> _glowAnimation;

  String instruction = "Breathe In";
  int _phase = 0; // 0=in, 1=hold, 2=out
  Timer? _cycleTimer;
  int _cycleCount = 0;

  @override
  void initState() {
    super.initState();

    // Main breathing circle animation
    _breathController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    );

    _breathAnimation = Tween<double>(begin: 120, end: 220).animate(
      CurvedAnimation(parent: _breathController, curve: Curves.easeInOut),
    );

    // Glow pulsing animation
    _glowController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);

    _glowAnimation = Tween<double>(begin: 0.2, end: 0.6).animate(
      CurvedAnimation(parent: _glowController, curve: Curves.easeInOut),
    );

    _startBreathingCycle();
  }

  void _startBreathingCycle() {
    // Start with inhale
    _breathController.forward();

    _cycleTimer = Timer.periodic(const Duration(seconds: 4), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }

      setState(() {
        _phase = (_phase + 1) % 3;
        switch (_phase) {
          case 0: // Breathe In
            instruction = "Breathe In";
            _breathController.forward();
            break;
          case 1: // Hold
            instruction = "Hold";
            _breathController.stop();
            break;
          case 2: // Breathe Out
            instruction = "Breathe Out";
            _breathController.reverse();
            _cycleCount++;
            break;
        }
      });
    });
  }

  String get _phaseTime {
    switch (_phase) {
      case 0:
        return '4 seconds';
      case 1:
        return '4 seconds';
      case 2:
        return '4 seconds';
      default:
        return '';
    }
  }

  @override
  void dispose() {
    _cycleTimer?.cancel();
    _breathController.dispose();
    _glowController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : Colors.black87;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: isDark
                ? [const Color(0xFF0D0D1A), const Color(0xFF1A1A2E)]
                : [const Color(0xFFF0F8F5), const Color(0xFFE8F5E9)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Header
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                child: Row(
                  children: [
                    IconButton(
                      icon: Icon(Icons.arrow_back, color: textColor),
                      onPressed: () => Navigator.pop(context),
                    ),
                    Text(
                      "Breathing Exercise",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: textColor,
                      ),
                    ),
                  ],
                ),
              ),

              const Spacer(),

              // Animated breathing circle with glow
              AnimatedBuilder(
                animation: Listenable.merge([_breathAnimation, _glowAnimation]),
                builder: (context, child) {
                  return Stack(
                    alignment: Alignment.center,
                    children: [
                      // Outer glow ring
                      Container(
                        height: _breathAnimation.value + 40,
                        width: _breathAnimation.value + 40,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: const Color(0xFF9BE7C4)
                              .withOpacity(_glowAnimation.value * 0.15),
                        ),
                      ),
                      // Middle ring
                      Container(
                        height: _breathAnimation.value + 20,
                        width: _breathAnimation.value + 20,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: const Color(0xFF9BE7C4)
                              .withOpacity(_glowAnimation.value * 0.25),
                        ),
                      ),
                      // Inner breathing circle
                      Container(
                        height: _breathAnimation.value,
                        width: _breathAnimation.value,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: RadialGradient(
                            colors: [
                              const Color(0xFF9BE7C4)
                                  .withOpacity(_glowAnimation.value + 0.2),
                              const Color(0xFF7AD7C1)
                                  .withOpacity(_glowAnimation.value),
                            ],
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF9BE7C4)
                                  .withOpacity(_glowAnimation.value * 0.5),
                              blurRadius: 30,
                              spreadRadius: 5,
                            ),
                          ],
                        ),
                        child: Center(
                          child: Text(
                            _phase == 0
                                ? '🌬️'
                                : _phase == 1
                                    ? '⏸️'
                                    : '💨',
                            style: const TextStyle(fontSize: 40),
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),

              const SizedBox(height: 30),

              // Instruction Text
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 400),
                child: Text(
                  instruction,
                  key: ValueKey(instruction),
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w700,
                    color: textColor,
                  ),
                ),
              ),

              const SizedBox(height: 8),

              Text(
                _phaseTime,
                style: TextStyle(
                  fontSize: 14,
                  color: isDark ? Colors.grey.shade400 : Colors.grey,
                ),
              ),

              const SizedBox(height: 16),

              // Progress dots
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(3, (i) {
                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    height: 10,
                    width: _phase == i ? 24 : 10,
                    decoration: BoxDecoration(
                      color: _phase == i
                          ? const Color(0xFF9BE7C4)
                          : (isDark ? Colors.grey.shade700 : Colors.grey.shade300),
                      borderRadius: BorderRadius.circular(5),
                    ),
                  );
                }),
              ),

              const Spacer(),

              // Cycle counter
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 40),
                padding: const EdgeInsets.symmetric(
                    vertical: 12, horizontal: 20),
                decoration: BoxDecoration(
                  color: isDark
                      ? const Color(0xFF1E1E2C)
                      : Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 8,
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('🔄', style: TextStyle(fontSize: 18)),
                    const SizedBox(width: 8),
                    Text(
                      'Cycles completed: $_cycleCount',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: textColor,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 12),

              Padding(
                padding: const EdgeInsets.only(bottom: 24),
                child: Text(
                  "Follow the circle 🌿",
                  style: TextStyle(
                    fontSize: 13,
                    color: isDark ? Colors.grey.shade500 : Colors.grey[500],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}