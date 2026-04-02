import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../services/face_analysis_service.dart';
import '../../services/stress_history_service.dart';
import '../../services/combined_stress_service.dart';

class FaceAnalysisScreen extends StatefulWidget {
  const FaceAnalysisScreen({super.key});

  @override
  State<FaceAnalysisScreen> createState() => _FaceAnalysisScreenState();
}

class _FaceAnalysisScreenState extends State<FaceAnalysisScreen> {
  final ImagePicker _picker = ImagePicker();

  // State
  File? _imageFile;
  bool _isLoading = false;
  FaceAnalysisResult? _result;
  String? _errorMessage;
  bool _isSaving = false;

  // ── Image picking ──────────────────────────────────────────────────────────

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? picked = await _picker.pickImage(
        source: source,
        imageQuality: 85,
        maxWidth: 800,
      );
      if (picked != null) {
        setState(() {
          _imageFile = File(picked.path);
          _result = null;
          _errorMessage = null;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Could not access ${source == ImageSource.camera ? 'camera' : 'gallery'}. Please check permissions.';
      });
    }
  }

  // ── API call ───────────────────────────────────────────────────────────────

  Future<void> _analyzeFace() async {
    if (_imageFile == null) {
      setState(() {
        _errorMessage = 'Please select or capture an image first.';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _result = null;
      _errorMessage = null;
    });

    try {
      final result = await FaceAnalysisService.analyzeFace(_imageFile!);
      // Update combined stress tracker
      CombinedStressService.instance.updateFace(
        result.stressLevel,
        emotion: result.emotion,
      );
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

  // ── Save result to Firestore ───────────────────────────────────────────────

  Future<void> _saveResult() async {
    if (_result == null || _isSaving) return;
    setState(() => _isSaving = true);
    final messenger = ScaffoldMessenger.of(context);
    try {
      final combined = CombinedStressService.instance;
      await StressHistoryService.saveStressResult(
        faceStress: _result!.stressLevel,
        voiceStress: combined.voiceStress,
        textStress: combined.textStress,
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

  // ── Helpers for dynamic theming ────────────────────────────────────────────

  Color _stressColor(double level) {
    if (level >= 70) return const Color(0xFFE53935); // red – high
    if (level >= 40) return const Color(0xFFFFA726); // orange – medium
    return const Color(0xFF43A047);                   // green – calm
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

  // ── Build ──────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardColor = isDark ? const Color(0xFF1E1E2C) : Colors.white;
    final textColor = isDark ? Colors.white : Colors.black87;
    final subtextColor = isDark ? Colors.grey.shade400 : Colors.grey;

    // Dynamic gradient based on result
    List<Color> bgGradient;
    if (_result != null) {
      final color = _stressColor(_result!.stressLevel);
      bgGradient = [color.withValues(alpha: 0.12), color.withValues(alpha: 0.04)];
    } else {
      bgGradient = isDark
          ? const [Color(0xFF0D0D1A), Color(0xFF1A1A2E)]
          : const [Color(0xFFFFE5DC), Color(0xFFFFF1EC)];
    }

    return Scaffold(
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
                      'Face Analysis',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        color: textColor,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                // Camera placeholder / selected image
                Container(
                  height: 300,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: const Color(0xFF1E2A3A),
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(24),
                    child: _imageFile != null
                        ? Image.file(
                            _imageFile!,
                            fit: BoxFit.cover,
                            width: double.infinity,
                            height: 300,
                          )
                        : Stack(
                            alignment: Alignment.center,
                            children: [
                              Container(
                                height: 220,
                                width: 220,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: Colors.white.withValues(alpha: 0.3),
                                    width: 2,
                                    style: BorderStyle.solid,
                                  ),
                                ),
                              ),
                              const Icon(Icons.camera_alt,
                                  color: Colors.white54, size: 48),
                              const Positioned(
                                bottom: 20,
                                child: Text(
                                  'Position your face in the frame',
                                  style: TextStyle(color: Colors.white70),
                                ),
                              ),
                            ],
                          ),
                  ),
                ),

                const SizedBox(height: 20),

                // Image source buttons
                if (_result == null && !_isLoading)
                  Row(
                    children: [
                      Expanded(
                        child: _sourceButton(
                          icon: Icons.camera_alt,
                          label: 'Camera',
                          onTap: () => _pickImage(ImageSource.camera),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _sourceButton(
                          icon: Icons.photo_library,
                          label: 'Gallery',
                          onTap: () => _pickImage(ImageSource.gallery),
                        ),
                      ),
                    ],
                  ),

                const SizedBox(height: 16),

                // Analyze button
                if (_imageFile != null && _result == null && !_isLoading)
                  _primaryButton(
                    text: 'Analyze Face',
                    onTap: _analyzeFace,
                  ),

                // Loading indicator
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
                          'Analyzing your face…',
                          style: TextStyle(color: subtextColor),
                        ),
                      ],
                    ),
                  ),

                // Error message
                if (_errorMessage != null) _errorSection(_errorMessage!),

                // Result section
                if (_result != null) _resultSection(_result!),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ── Result UI (dynamic) ────────────────────────────────────────────────────

  Widget _resultSection(FaceAnalysisResult result) {
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
            border: Border.all(color: color.withValues(alpha: 0.35), width: 1.5),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title
              Text(
                '🧠 Face Analysis Result',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: textColor),
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

        // Action buttons
        Row(
          children: [
            Expanded(
              child: _secondaryButton('Retake', onTap: () {
                setState(() {
                  _imageFile = null;
                  _result = null;
                  _errorMessage = null;
                });
              }),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _primaryButton(
                text: _isSaving ? 'Saving…' : 'Save Result',
                onTap: _isSaving ? null : _saveResult,
              ),
            ),
          ],
        ),
      ],
    );
  }

  String _advice(double level, String emotion) {
    if (level >= 70) {
      return 'Your facial expressions indicate high stress levels. '
          'Consider taking a short break, trying a breathing exercise, '
          'or reaching out to someone you trust.';
    }
    if (level >= 40) {
      return 'Your face shows signs of moderate stress. A brief walk, '
          'mindfulness moment, or some relaxation may help you feel better.';
    }
    return 'You appear to be in a calm state. Keep nurturing that inner peace '
        'with regular self-care routines.';
  }

  // ── Error UI ───────────────────────────────────────────────────────────────

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
        ],
      ),
    );
  }

  // ── Components ─────────────────────────────────────────────────────────────

  Widget _sourceButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 52,
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E1E2C) : Colors.white,
          borderRadius: BorderRadius.circular(18),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 20, color: const Color(0xFF7AD7C1)),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: isDark ? Colors.white : Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _primaryButton({
    required String text,
    VoidCallback? onTap,
  }) {
    return Container(
      height: 52,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        gradient: const LinearGradient(
          colors: [Color(0xFF9BE7C4), Color(0xFF7AD7C1)],
        ),
      ),
      child: TextButton(
        onPressed: onTap,
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
          borderRadius: BorderRadius.circular(18),
          color: isDark ? const Color(0xFF1E1E2C) : Colors.white,
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
