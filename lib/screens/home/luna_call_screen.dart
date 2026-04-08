// 2. luna_call_screen.dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:flutter_tts/flutter_tts.dart';
import '../../services/ai_service.dart';

class LunaCallScreen extends StatefulWidget {
  const LunaCallScreen({super.key});

  @override
  State<LunaCallScreen> createState() => _LunaCallScreenState();
}

class _LunaCallScreenState extends State<LunaCallScreen> with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  bool _isMuted = false;
  String _statusText = "Initializing...";
  late stt.SpeechToText _speech;
  late FlutterTts _tts;
  bool _isListening = false;
  String _currentWords = "";
  final List<Map<String, String>> _chatHistory = [];
  Timer? _pauseTimer;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );
    _initVoiceServices();
  }

  Future<void> _initVoiceServices() async {
    _speech = stt.SpeechToText();
    _tts = FlutterTts();

    await _tts.setLanguage("en-US");
    await _tts.setSpeechRate(0.5);
    await _tts.setPitch(1.1);

    _tts.setCompletionHandler(() {
      if (mounted && !_isMuted) {
        _startListening();
      }
    });

    bool available = await _speech.initialize(
      onStatus: (val) {
        if (val == 'done' || val == 'notListening') {
          if (_isListening && _currentWords.isEmpty && !_isMuted && mounted && _statusText != "Thinking...") {
            _startListening();
          }
        }
      },
      onError: (val) => print('STT Error: $val'),
    );

    if (available) {
      _chatHistory.add({
        "role": "system",
        "content": "You are Luna, a highly empathetic and supportive AI mental health assistant. Keep responses short and comforting."
      });
      _speakInitialMessage();
    } else {
      if (mounted) setState(() => _statusText = "Microphone unavailable");
    }
  }

  Future<void> _speakInitialMessage() async {
    if (!mounted) return;
    setState(() {
      _pulseController.repeat(reverse: true);
      _statusText = "Speaking...";
    });
    
    const greeting = "Hey... I'm here for you. What's on your mind?";
    _chatHistory.add({"role": "assistant", "content": greeting});
    
    await _tts.speak(greeting);
  }

  void _startListening() {
    if (_isMuted || !mounted) return;
    setState(() {
      _pulseController.repeat(reverse: true);
      _statusText = "Listening...";
      _isListening = true;
      _currentWords = "";
    });

    _speech.listen(
      onResult: (val) {
        setState(() => _currentWords = val.recognizedWords);
        _pauseTimer?.cancel();
        _pauseTimer = Timer(const Duration(seconds: 4), () {
          if (_currentWords.isNotEmpty) _processVoiceInput(_currentWords);
        });
      },
      listenFor: const Duration(minutes: 1),
      pauseFor: const Duration(seconds: 5),
    );
  }

  void _stopListening() {
    _pauseTimer?.cancel();
    _speech.stop();
    if (mounted) {
      setState(() {
        _isListening = false;
        _pulseController.stop();
      });
    }
  }

  Future<void> _processVoiceInput(String text) async {
    if (text.trim().isEmpty) return;
    _stopListening();
    setState(() {
      _pulseController.repeat(reverse: true, period: const Duration(milliseconds: 500));
      _statusText = "Thinking...";
    });

    _chatHistory.add({"role": "user", "content": text});
    String aiResponse = await AiService.sendMessage(text, history: _chatHistory);
    _chatHistory.add({"role": "assistant", "content": aiResponse});

    if (mounted) {
      setState(() {
        _pulseController.repeat(reverse: true, period: const Duration(seconds: 1));
        _statusText = "Speaking...";
      });
      await _tts.speak(aiResponse);
    }
  }

  void _toggleMute() {
    setState(() {
      _isMuted = !_isMuted;
      if (_isMuted) {
        _stopListening();
        _tts.stop();
        _statusText = "Muted";
      } else {
        _startListening();
      }
    });
  }

  @override
  void dispose() {
    _pauseTimer?.cancel();
    _speech.stop();
    _tts.stop();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF1A1A2E) : const Color(0xFFEFF6F5),
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Spacer(),
            AnimatedBuilder(
              animation: _pulseController,
              builder: (context, child) {
                return Stack(
                  alignment: Alignment.center,
                  children: [
                    Container(
                      width: 150 + (_pulseController.value * 40),
                      height: 150 + (_pulseController.value * 40),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: const Color(0xFF9BE7C4).withOpacity(0.2),
                      ),
                    ),
                    Container(
                      width: 120 + (_pulseController.value * 20),
                      height: 120 + (_pulseController.value * 20),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: const Color(0xFF7AD7C1).withOpacity(0.4),
                      ),
                    ),
                    Container(
                      width: 100,
                      height: 100,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(
                          colors: [Color(0xFF9BE7C4), Color(0xFF43A047)],
                        ),
                      ),
                      child: const Icon(Icons.smart_toy, color: Colors.white, size: 50),
                    ),
                  ],
                );
              },
            ),
            const SizedBox(height: 40),
            Text(
              "Luna",
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black87),
            ),
            const SizedBox(height: 8),
            Text(
              _statusText,
              style: TextStyle(fontSize: 16, color: isDark ? Colors.white70 : Colors.black54),
            ),
            const Spacer(),
            Padding(
              padding: const EdgeInsets.only(bottom: 50, left: 40, right: 40),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  GestureDetector(
                    onTap: _toggleMute,
                    child: Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: _isMuted ? (isDark ? Colors.white24 : Colors.grey.shade300) : (isDark ? const Color(0xFF2A2A3E) : Colors.white),
                        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
                      ),
                      child: Icon(_isMuted ? Icons.mic_off : Icons.mic, color: isDark ? Colors.white : Colors.black87, size: 28),
                    ),
                  ),
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      width: 70,
                      height: 70,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.redAccent,
                        boxShadow: [BoxShadow(color: Colors.redAccent.withOpacity(0.4), blurRadius: 15, spreadRadius: 2)],
                      ),
                      child: const Icon(Icons.call_end, color: Colors.white, size: 32),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
