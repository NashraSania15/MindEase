import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:record/record.dart';
import 'package:path_provider/path_provider.dart';
import '../../services/voice_analysis_service.dart';
import '../../services/stress_history_service.dart';
import '../../services/combined_stress_service.dart';

class VoiceAnalysisScreen extends StatefulWidget {
  const VoiceAnalysisScreen({super.key});

  @override
  State<VoiceAnalysisScreen> createState() => _VoiceAnalysisScreenState();
}

class _VoiceAnalysisScreenState extends State<VoiceAnalysisScreen> {
  int step = 0; // 0-idle, 1-recording, 2-result
  int secondsRemaining = 10;

  final AudioRecorder _recorder = AudioRecorder();
  Timer? _timer;
  String? _recordingPath;
  Color subtextColor = Colors.grey;

  // API state
  bool _isLoading = false;
  VoiceAnalysisResult? _result;
  String? _errorMessage;

  bool _isSaving = false;

  @override
  void dispose() {
    _timer?.cancel();
    _recorder.dispose();
    super.dispose();
  }

  // ── Recording ─────────────────────────────────────────────────────────────

  Future<void> _startRecording() async {
    if (_isLoading) return;
    try {
      if (await _recorder.hasPermission()) {
        final dir = await getTemporaryDirectory();
        final path =
            '${dir.path}/mindease_voice_${DateTime.now().millisecondsSinceEpoch}.wav';

        await _recorder.start(
          const RecordConfig(
            encoder: AudioEncoder.wav,
            sampleRate: 16000,
            numChannels: 1,
          ),
          path: path,
        );

        setState(() {
          step = 1;
          secondsRemaining = 10;
          _recordingPath = path;
          _result = null;
          _errorMessage = null;
        });

        _timer = Timer.periodic(const Duration(seconds: 1), (t) {
          if (mounted) {
            setState(() {
              if (secondsRemaining > 1) {
                secondsRemaining--;
              } else {
                secondsRemaining = 0;
                _stopRecording();
              }
            });
          }
        });
      } else {
        setState(() {
          _errorMessage =
              'Microphone permission denied. Please grant access in settings.';
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage =
            'Could not start recording. Please check microphone permissions.';
      });
    }
  }

  Future<void> _stopRecording() async {
    _timer?.cancel();
    _timer = null;

    try {
      final path = await _recorder.stop();
      if (path != null) {
        _recordingPath = path;
      }
    } catch (_) {}

    if (_recordingPath == null) {
      setState(() {
        step = 0;
        _errorMessage = 'No recording found. Please try again.';
      });
      return;
    }

    final voiceFile = File(_recordingPath!);
    if (!await voiceFile.exists()) {
      setState(() {
        step = 0;
        _errorMessage = 'No recording found. Please try again.';
      });
      return;
    }

    // Check file size (10s WAV at 16kHz mono should be ~320KB, 1KB is definitely silent/empty)
    if (await voiceFile.length() < 1024) {
      setState(() {
        step = 0;
        _errorMessage = 'No voice detected. Please try again.';
      });
      return;
    }

    // Send to API
    await _analyzeVoice();
  }

  // ── API call ──────────────────────────────────────────────────────────────

  Future<void> _analyzeVoice() async {
    setState(() {
      _isLoading = true;
      step = 2;
      _result = null;
      _errorMessage = null;
    });

    try {
      final result =
          await VoiceAnalysisService.analyzeVoice(File(_recordingPath!));
      // Update combined stress tracker
      CombinedStressService.instance.updateVoice(
        result.stressLevel,
        emotion: result.emotion,
      );
      CombinedStressService.instance.latestAudioFile = File(_recordingPath!);
      setState(() {
        _result = result;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        // Map any API/Server error to the requested user-friendly message
        _errorMessage = 'No voice detected. Please try again.';
        _isLoading = false;
      });
    }
  }

  // ── Save result to Firestore ──────────────────────────────────────────────

  Future<void> _saveResult() async {
    if (_result == null || _isSaving) return;
    setState(() => _isSaving = true);
    final messenger = ScaffoldMessenger.of(context);
    try {
      final combined = CombinedStressService.instance;
      await StressHistoryService.saveStressResult(
        combinedStress: _result!.stressLevel,
        emotion: _result!.emotion,
      );
      if (mounted) {
        messenger.showSnackBar(
          const SnackBar(content: Text('Result saved ✅')),
        );
      }
    } catch (e) {
      if (mounted) {
        messenger.showSnackBar(
          const SnackBar(content: Text('Failed to save. Try again.')),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  // ── Helpers for dynamic theming ───────────────────────────────────────────

  Color _stressColor(double level) {
    if (level >= 70) return const Color(0xFFE53935); // red – high
    if (level >= 40) return const Color(0xFFFFA726); // orange – medium
    return const Color(0xFF43A047); // green – calm
  }

  String _stressLabel(double level) {
    if (level >= 70) return 'High Stress';
    if (level >= 40) return 'Moderate';
    return 'Calm';
  }

  /// Returns an emoji based on stress level (NOT emotion).
  String _stressEmoji(double level) {
    if (level >= 70) return '😰';
    if (level >= 40) return '😐';
    return '😌';
  }

  ({String label, String emoji}) _emotionDisplay(String emotion) {
    switch (emotion.toLowerCase()) {
      case 'neutral':
      case 'calm':
        return (label: 'calm', emoji: '😌');
      case 'happy':
      case 'happiness':
      case 'joy':
        return (label: 'joyful', emoji: '😊');
      case 'sad':
      case 'sadness':
        return (label: 'low mood', emoji: '😔');
      case 'fear':
      case 'fearful':
      case 'nervousness':
      case 'anxious':
      case 'anxiety':
        return (label: 'anxious', emoji: '😰');
      case 'angry':
      case 'anger':
        return (label: 'tense', emoji: '😠');
      case 'surprise':
      case 'surprised':
        return (label: 'surprised', emoji: '😲');
      case 'disgust':
        return (label: 'uneasy', emoji: '😣');
      default:
        return (label: emotion, emoji: '🧠');
    }
  }

  String _advice(double level, String emotion) {
    if (level >= 70) {
      return 'Your voice patterns indicate high stress levels. '
          'Consider taking a short break, trying a breathing exercise, '
          'or reaching out to someone you trust.';
    }
    if (level >= 40) {
      return 'Your voice shows signs of moderate stress. A brief walk, '
          'mindfulness moment, or some relaxation may help you feel better.';
    }
    return 'You appear to be in a calm state. Keep nurturing that inner peace '
        'with regular self-care routines.';
  }

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : Colors.black87;
    final subtextColor = isDark ? Colors.grey.shade400 : Colors.grey;

    // Dynamic gradient based on result
    List<Color> bgGradient;
    if (_result != null) {
      final color = _stressColor(_result!.stressLevel);
      bgGradient = [
        color.withValues(alpha: 0.12),
        color.withValues(alpha: 0.04),
      ];
    } else {
      bgGradient = isDark
          ? const [Color(0xFF0D0D1A), Color(0xFF1A1A2E)]
          : const [Color(0xFFFFE5F0), Color(0xFFFFF1F6)];
    }

    return Scaffold(
      backgroundColor: bgGradient.last,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: bgGradient,
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // Header
                Row(
                  children: [
                    IconButton(
                      icon: Icon(Icons.arrow_back, color: textColor),
                      onPressed: () => Navigator.pop(context),
                    ),
                    Text(
                      'Voice Analysis',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        color: textColor,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                _instruction(),

                const SizedBox(height: 40),

                if (step == 0) _idleMic(),
                if (step == 1) _recordingMic(),

                // Loading indicator (after recording stops, before result)
                if (_isLoading)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 24),
                    child: Column(
                      children: [
                        const CircularProgressIndicator(
                          color: Color(0xFF7AD7C1),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Analyzing your voice...',
                          style: TextStyle(
                            color: subtextColor,
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),

                // Error message
                if (_errorMessage != null) _errorSection(_errorMessage!),

                // Result section (dynamic)
                if (_result != null && !_isLoading) _resultSection(_result!),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ---------- UI STATES ----------

  Widget _instruction() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardColor = isDark ? const Color(0xFF1E1E2C) : Colors.white;
    final textColor = isDark ? Colors.white : Colors.black87;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Text(
        'Speak clearly for 10 seconds',
        style: TextStyle(fontSize: 16, color: textColor),
      ),
    );
  }

  Widget _idleMic() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : Colors.black87;

    return Column(
      children: [
        GestureDetector(
          onTap: _isLoading ? null : _startRecording,
          child: Opacity(
            opacity: _isLoading ? 0.6 : 1.0,
            child: _micCircle(
              color1: const Color(0xFF9BE7C4),
              color2: const Color(0xFF7AD7C1),
              icon: Icons.mic,
            ),
          ),
        ),
        const SizedBox(height: 14),
        Text('Tap to start 10s recording', style: TextStyle(color: textColor)),
      ],
    );
  }

  Widget _recordingMic() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : Colors.black87;

    return Column(
      children: [
        const SizedBox(height: 20),

        // Countdown display
        Text(
          'Remaining: ${secondsRemaining}s',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: secondsRemaining <= 3 ? Colors.redAccent : textColor,
          ),
        ),

        const SizedBox(height: 10),

        // Fake wave
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(
            12,
            (index) => Container(
              margin: const EdgeInsets.symmetric(horizontal: 2),
              height: 20.0 + (index % 5) * 6,
              width: 4,
              decoration: BoxDecoration(
                color: Colors.greenAccent,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),
        ),

        const SizedBox(height: 30),

        _micCircle(
          color1: Colors.redAccent,
          color2: Colors.red,
          icon: Icons.mic_rounded,
        ),

        const SizedBox(height: 14),
        Text('Recording... Speak naturally', style: TextStyle(color: textColor, fontWeight: FontWeight.w500)),
        const SizedBox(height: 4),
        Text('Stay in a quiet place for better results', style: TextStyle(color: subtextColor, fontSize: 12)),
      ],
    );
  }

  // ── Result UI (dynamic) ───────────────────────────────────────────────────

  Widget _resultSection(VoiceAnalysisResult result) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardColor = isDark ? const Color(0xFF1E1E2C) : Colors.white;
    final textColor = isDark ? Colors.white : Colors.black87;
    final subtextColor = isDark ? Colors.grey.shade400 : Colors.grey;

    final stressValue = result.stressLevel.clamp(0, 100).toDouble();
    final color = _stressColor(stressValue);
    final stressLbl = _stressLabel(stressValue);
    final stressEmoji = _stressEmoji(stressValue);
    final bgColor = color.withValues(alpha: 0.08);

    return Column(
      children: [
        const SizedBox(height: 4),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: cardColor,
            borderRadius: BorderRadius.circular(20),
            border:
                Border.all(color: color.withValues(alpha: 0.35), width: 1.5),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title
              Text(
                'Here’s your stress analysis',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: textColor),
              ),

              const SizedBox(height: 16),

              // Stress-level-driven banner
              Container(
                width: double.infinity,
                padding:
                    const EdgeInsets.symmetric(vertical: 12, horizontal: 14),
                decoration: BoxDecoration(
                  color: bgColor,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Row(
                  children: [
                    Text(
                      stressEmoji,
                      style: const TextStyle(fontSize: 28),
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'You seem:',
                          style: TextStyle(color: subtextColor, fontSize: 12),
                        ),
                        Text(
                          stressLbl,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: color,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 12),

              // Emotion displayed separately
              Text(
                'Emotion detected: ${result.emotion}',
                style: TextStyle(
                  fontSize: 14,
                  color: subtextColor,
                  fontStyle: FontStyle.italic,
                ),
              ),

              const SizedBox(height: 16),

              // Stress level bar
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Stress Level',
                    style: TextStyle(fontWeight: FontWeight.w500, color: textColor),
                  ),
                  Text(
                    '${stressValue.toStringAsFixed(0)}%  •  $stressLbl',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: color,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 8),

              // Color indicator bar
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: LinearProgressIndicator(
                  value: stressValue / 100,
                  minHeight: 10,
                  backgroundColor: isDark ? Colors.grey.shade800 : Colors.grey.shade200,
                  valueColor: AlwaysStoppedAnimation<Color>(color),
                ),
              ),

              const SizedBox(height: 16),

              // Contextual advice
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: bgColor,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Text(
                  _advice(stressValue, result.emotion),
                  style: TextStyle(fontSize: 14, height: 1.5, color: textColor),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 20),

        // Suggestions
        _suggestion('🚶', 'Take a 10-minute walk'),
        _suggestion('💧', 'Drink a glass of water'),
        _suggestion('🫁', 'Practice deep breathing'),

        const SizedBox(height: 20),

        // Action buttons
        Row(
          children: [
            Expanded(
              child: _secondaryButton(
                'Try Again',
                onTap: () {
                  setState(() {
                    step = 0;
                    _result = null;
                    _errorMessage = null;
                    _recordingPath = null;
                  });
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: GestureDetector(
                onTap: _isSaving ? null : _saveResult,
                child: _primaryButton(_isSaving ? 'Saving…' : 'Save Result'),
              ),
            ),
          ],
        ),
      ],
    );
  }

  // ── Error UI ──────────────────────────────────────────────────────────────

  Widget _errorSection(String message) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF3A1A1A) : const Color(0xFFFFEBEE),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isDark ? Colors.red.shade800 : Colors.red.shade200),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline, color: Colors.red),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(color: Colors.red),
            ),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: () {
              setState(() {
                step = 0;
                _errorMessage = null;
              });
            },
            child: Row(
              children: [
                const Icon(Icons.refresh, color: Colors.red, size: 20),
                const SizedBox(width: 4),
                Text(
                  'Retry',
                  style: TextStyle(
                    color: Colors.red,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ---------- COMPONENTS ----------

  Widget _micCircle({
    required Color color1,
    required Color color2,
    required IconData icon,
  }) {
    return Container(
      height: 120,
      width: 120,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(colors: [color1, color2]),
      ),
      child: Icon(icon, size: 48, color: Colors.white),
    );
  }

  Widget _suggestion(String emoji, String text) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E2C) : Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 22)),
          const SizedBox(width: 10),
          Text(text, style: TextStyle(color: isDark ? Colors.white : Colors.black87)),
        ],
      ),
    );
  }

  Widget _primaryButton(String text) {
    return Container(
      height: 52,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        gradient: const LinearGradient(
          colors: [Color(0xFF9BE7C4), Color(0xFF7AD7C1)],
        ),
      ),
      child: Center(
        child: Text(
          text,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget _secondaryButton(String text, {VoidCallback? onTap}) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 52,
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E1E2C) : Colors.white,
          borderRadius: BorderRadius.circular(18),
        ),
        child: Center(
          child: Text(
            text,
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: isDark ? Colors.white : Colors.black87,
            ),
          ),
        ),
      ),
    );
  }
}
