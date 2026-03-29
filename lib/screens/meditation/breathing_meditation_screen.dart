import 'package:flutter/material.dart';
import 'dart:async';

class BreathingMeditationScreen extends StatefulWidget {
  const BreathingMeditationScreen({super.key});

  @override
  State<BreathingMeditationScreen> createState() =>
      _BreathingMeditationScreenState();
}

class _BreathingMeditationScreenState
    extends State<BreathingMeditationScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  String instruction = "Breathe In";
  int seconds = 4;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    );

    _animation = Tween<double>(begin: 120, end: 220).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    _startBreathingCycle();
  }

  void _startBreathingCycle() {
    Timer.periodic(const Duration(seconds: 4), (timer) {
      if (!mounted) return;

      setState(() {
        if (instruction == "Breathe In") {
          instruction = "Hold";
          seconds = 2;
          _controller.stop();
        } else if (instruction == "Hold") {
          instruction = "Breathe Out";
          seconds = 6;
          _controller.reverse();
        } else {
          instruction = "Breathe In";
          seconds = 4;
          _controller.forward();
        }
      });
    });

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
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
          child: Column(
            children: [
              // Header
              Padding(
                padding:
                const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back),
                      onPressed: () => Navigator.pop(context),
                    ),
                    const Text(
                      "Breathing Exercise",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),

              const Spacer(),

              // Animated Circle
              AnimatedBuilder(
                animation: _animation,
                builder: (context, child) {
                  return Container(
                    height: _animation.value,
                    width: _animation.value,
                    decoration: BoxDecoration(
                      color: const Color(0xFF9BE7C4).withOpacity(0.4),
                      shape: BoxShape.circle,
                    ),
                  );
                },
              ),

              const SizedBox(height: 30),

              // Instruction Text
              Text(
                instruction,
                style: const TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w600,
                ),
              ),

              const SizedBox(height: 8),

              Text(
                "$seconds seconds",
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.grey,
                ),
              ),

              const Spacer(),

              Padding(
                padding: const EdgeInsets.only(bottom: 24),
                child: Text(
                  "Follow the circle 🌿",
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey[500],
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