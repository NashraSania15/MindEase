import 'package:flutter/material.dart';
import '../../services/text_analysis_service.dart';

class TextAnalysisScreen extends StatefulWidget {
  const TextAnalysisScreen({super.key});

  @override
  State<TextAnalysisScreen> createState() => _TextAnalysisScreenState();
}

class _TextAnalysisScreenState extends State<TextAnalysisScreen> {
  final TextEditingController _controller = TextEditingController();

  // API state
  bool _isLoading = false;
  TextAnalysisResult? _result;
  String? _errorMessage;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  // ── API call ────────────────────────────────────────────────────────────────
  Future<void> _analyzeText() async {
    final text = _controller.text.trim();
    if (text.length < 10) return;

    setState(() {
      _isLoading = true;
      _result = null;
      _errorMessage = null;
    });

    try {
      final result = await TextAnalysisService.analyzeText(text);
      setState(() {
        _result = result;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString().replaceFirst('Exception: ', '');
        _isLoading = false;
      });
    }
  }

  // ── Helpers for dynamic theming ─────────────────────────────────────────────

  /// Returns a color based on the stress level value (0–100).
  Color _stressColor(double level) {
    if (level >= 70) return const Color(0xFFE53935); // red – high
    if (level >= 40) return const Color(0xFFFFA726); // orange – medium
    return const Color(0xFF43A047);                   // green – calm
  }

  /// Returns a user-friendly label for any stress level.
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

  /// Maps the emotion string returned by the model to a display-friendly string
  /// and an emoji.
  ({String label, String emoji}) _emotionDisplay(String emotion) {
    switch (emotion.toLowerCase()) {
      case 'joy':
      case 'happiness':
      case 'happy':
        return (label: 'joyful', emoji: '😊');
      case 'sadness':
      case 'sad':
        return (label: 'sad', emoji: '😢');
      case 'anger':
      case 'angry':
        return (label: 'angry', emoji: '😠');
      case 'fear':
      case 'fearful':
        return (label: 'fearful', emoji: '😨');
      case 'nervousness':
      case 'anxious':
      case 'anxiety':
        return (label: 'anxious', emoji: '😰');
      case 'calm':
      case 'neutral':
        return (label: 'calm', emoji: '😌');
      case 'stress':
      case 'stressed':
        return (label: 'stressed', emoji: '😟');
      case 'surprise':
      case 'surprised':
        return (label: 'surprised', emoji: '😲');
      default:
        return (label: emotion, emoji: '🧠');
    }
  }

  // ── Build ───────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFE6F7F6), Color(0xFFF1FBFA)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // ── Header ──────────────────────────────────────────────────
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back),
                      onPressed: () => Navigator.pop(context),
                    ),
                    const Text(
                      'Text Stress Check',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 8),

                const Text(
                  'Type freely. This will analyze stress — not save automatically.',
                  style: TextStyle(color: Colors.grey),
                ),

                const SizedBox(height: 20),

                // ── Text Input Card ─────────────────────────────────────────
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "What's on your mind right now?",
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: _controller,
                        maxLines: 6,
                        onChanged: (_) => setState(() {}),
                        decoration: const InputDecoration(
                          hintText: 'Start typing...',
                          border: InputBorder.none,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '${_controller.text.length} characters',
                            style: const TextStyle(color: Colors.grey),
                          ),
                          Text(
                            _controller.text.length >= 10
                                ? 'Ready to analyze'
                                : 'Min 10 characters',
                            style: TextStyle(
                              color: _controller.text.length >= 10
                                  ? Colors.green
                                  : Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // ── Analyze Button ──────────────────────────────────────────
                _primaryButton(
                  text: _isLoading ? 'Analyzing…' : 'Analyze Text',
                  enabled: _controller.text.length >= 10 && !_isLoading,
                  onTap: _analyzeText,
                ),

                const SizedBox(height: 20),

                // ── Loading indicator ───────────────────────────────────────
                if (_isLoading)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 24),
                    child: Column(
                      children: [
                        CircularProgressIndicator(
                          color: Color(0xFF7AD7C1),
                        ),
                        SizedBox(height: 12),
                        Text(
                          'Analyzing your text…',
                          style: TextStyle(color: Colors.grey),
                        ),
                      ],
                    ),
                  ),

                // ── Error message ───────────────────────────────────────────
                if (_errorMessage != null) _errorSection(_errorMessage!),

                // ── Result Section ──────────────────────────────────────────
                if (_result != null) _resultSection(_result!),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ── Result UI (dynamic) ─────────────────────────────────────────────────────

  Widget _resultSection(TextAnalysisResult result) {
    final stressValue = result.stressLevel.clamp(0, 100).toDouble();
    final color = _stressColor(stressValue);
    final stressLbl = _stressLabel(stressValue);
    final stressEmoji = _stressEmoji(stressValue);
    final bgColor = color.withValues(alpha: 0.08);

    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: color.withValues(alpha: 0.35), width: 1.5),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title
              const Text(
                '🧠 Stress Analysis Result',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
              ),

              const SizedBox(height: 16),

              // Stress-level-driven banner
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 14),
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
                        const Text(
                          'You seem:',
                          style: TextStyle(color: Colors.grey, fontSize: 12),
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
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.grey,
                  fontStyle: FontStyle.italic,
                ),
              ),

              const SizedBox(height: 16),

              // Stress level bar
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Stress Level',
                    style: TextStyle(fontWeight: FontWeight.w500),
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

              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: LinearProgressIndicator(
                  value: stressValue / 100,
                  minHeight: 10,
                  backgroundColor: Colors.grey.shade200,
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
                  style: const TextStyle(fontSize: 14, height: 1.5),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 20),

        // Action buttons
        Row(
          children: [
            Expanded(
              child: _secondaryButton(
                'Try Again',
                onTap: () {
                  setState(() {
                    _result = null;
                    _errorMessage = null;
                    _controller.clear();
                  });
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _primaryButton(
                text: 'Save to Diary',
                onTap: () {},
              ),
            ),
          ],
        ),
      ],
    );
  }

  /// Returns contextual advice text based on stress level and emotion.
  String _advice(double level, String emotion) {
    if (level >= 70) {
      return 'Your words indicate high stress. Consider taking a short break, '
          'trying a breathing exercise, or reaching out to someone you trust.';
    }
    if (level >= 40) {
      return 'You\'re experiencing moderate stress. A brief walk, '
          'mindfulness moment, or journaling your thoughts further may help.';
    }
    return 'You appear to be in a calm state. Keep nurturing that inner peace '
        'with regular self-care routines.';
  }

  // ── Error UI ────────────────────────────────────────────────────────────────

  Widget _errorSection(String message) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFFEBEE),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.red.shade200),
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
        ],
      ),
    );
  }

  // ── Components ──────────────────────────────────────────────────────────────

  Widget _primaryButton({
    required String text,
    bool enabled = true,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: enabled ? onTap : null,
      child: Container(
        height: 52,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          gradient: enabled
              ? const LinearGradient(
            colors: [Color(0xFF9BE7C4), Color(0xFF7AD7C1)],
          )
              : null,
          color: enabled ? null : Colors.grey.shade300,
        ),
        child: Center(
          child: Text(
            text,
            style: TextStyle(
              color: enabled ? Colors.white : Colors.grey,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }

  Widget _secondaryButton(String text, {VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 52,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
        ),
        child: Center(
          child: Text(
            text,
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
        ),
      ),
    );
  }
}
