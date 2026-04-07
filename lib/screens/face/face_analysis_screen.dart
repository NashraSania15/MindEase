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
  bool _isAnalyzing = false;
  bool _isSaving = false;
  String? _errorMessage;

  // State
  FaceAnalysisResult? _result;
  File? _latestFrame;

  Future<void> _captureAndAnalyze() async {
    setState(() {
      _errorMessage = null;
      _isAnalyzing = true;
      _result = null;
    });

    try {
      final picker = ImagePicker();
      final xFile = await picker.pickImage(
        source: ImageSource.camera,
        preferredCameraDevice: CameraDevice.front,
      );

      if (xFile == null) {
        setState(() => _isAnalyzing = false);
        return;
      }

      final file = File(xFile.path);
      setState(() => _latestFrame = file);

      final result = await FaceAnalysisService.analyzeFace(file);

      if (mounted) {
        CombinedStressService.instance.updateFace(
          result.stressLevel,
          fatigue: result.fatigueLevel,
          emotion: result.emotion,
        );
        CombinedStressService.instance.latestFaceFile = file;

        setState(() {
          _result = result;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.toString().replaceFirst('Exception: ', '');
        });
      }
    } finally {
      if (mounted) {
        setState(() => _isAnalyzing = false);
      }
    }
  }

  Future<void> _saveResult() async {
    if (_result == null || _isSaving) return;
    setState(() => _isSaving = true);
    final messenger = ScaffoldMessenger.of(context);
    try {
      await StressHistoryService.saveStressResult(
        combinedStress: _result!.stressLevel,
        fatigueLevel: _result!.fatigueLevel,
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

  void _tryAgain() {
    _captureAndAnalyze();
  }

  Color _stressColor(double level) {
    if (level >= 70) return const Color(0xFFE53935);
    if (level >= 40) return const Color(0xFFFFA726);
    return const Color(0xFF43A047);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : Colors.black87;
    final subtextColor = isDark ? Colors.grey.shade400 : Colors.grey;

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
          : const [Color(0xFFFFE5DC), Color(0xFFFFF1EC)];
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
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    IconButton(
                      icon: Icon(Icons.arrow_back, color: textColor),
                      onPressed: () => Navigator.pop(context),
                    ),
                    Text(
                      'Face Stress Analysis',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        color: textColor,
                      ),
                    ),
                  ],
                ),
              ),

              if (_errorMessage != null)
                _errorSection(_errorMessage!),

              Expanded(
                child: Center(
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if (_result == null && !_isAnalyzing) ...[
                          const Icon(Icons.camera_front, size: 80, color: Colors.grey),
                          const SizedBox(height: 24),
                          Text(
                            'One-time capture for analysis',
                            style: TextStyle(color: textColor, fontSize: 18, fontWeight: FontWeight.w500),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Position your face clearly for accuracy',
                            style: TextStyle(color: subtextColor, fontSize: 14),
                          ),
                          const SizedBox(height: 32),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 60),
                            child: _primaryButton(
                              text: 'Open Camera',
                              onTap: _captureAndAnalyze,
                            ),
                          ),
                        ] else if (_isAnalyzing) ...[
                          const CircularProgressIndicator(color: Color(0xFF7AD7C1)),
                          const SizedBox(height: 24),
                          Text(
                            'Analyzing...',
                            style: TextStyle(color: textColor, fontSize: 18, fontWeight: FontWeight.w500),
                          ),
                        ] else if (_result != null) ...[
                          _resultView(isDark, textColor, subtextColor),
                          const SizedBox(height: 32),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 24),
                            child: Row(
                              children: [
                                Expanded(
                                  child: _secondaryButton(
                                    'Analyze Again',
                                    onTap: _isSaving ? null : _tryAgain,
                                  ),
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
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _resultView(bool isDark, Color textColor, Color subtextColor) {
    return Column(
      children: [
        if (_latestFrame != null)
          Container(
            height: 200,
            width: 200,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: _stressColor(_result!.stressLevel), width: 4),
              image: DecorationImage(
                image: FileImage(_latestFrame!),
                fit: BoxFit.cover,
              ),
            ),
          ),
        const SizedBox(height: 24),
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 24),
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1E1E2C) : Colors.white,
            borderRadius: BorderRadius.circular(28),
            boxShadow: [
              BoxShadow(
                color: _stressColor(_result!.stressLevel).withValues(alpha: 0.15),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _metricItem('Stress', '${_result!.stressLevel.toStringAsFixed(0)}%', _stressColor(_result!.stressLevel), subtextColor),
                  Container(width: 1, height: 40, color: Colors.grey.withValues(alpha: 0.2)),
                  _metricItem('Fatigue', '${_result!.fatigueLevel.toStringAsFixed(0)}%', _stressColor(_result!.fatigueLevel), subtextColor),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _metricItem(String label, String value, Color color, Color subtextColor) {
    return Column(
      children: [
        Text(label, style: TextStyle(color: subtextColor, fontSize: 14)),
        const SizedBox(height: 8),
        Text(value, style: TextStyle(color: color, fontSize: 32, fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _errorSection(String message) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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

  Widget _primaryButton({
    required String text,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 56,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: onTap == null
              ? const LinearGradient(colors: [Colors.grey, Colors.grey])
              : const LinearGradient(
                  colors: [Color(0xFF9BE7C4), Color(0xFF7AD7C1)],
                ),
        ),
        child: Center(
          child: Text(
            text,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
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
        height: 56,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: isDark ? const Color(0xFF2C2C3E) : Colors.grey.shade100,
          border: Border.all(color: isDark ? Colors.grey.shade800 : Colors.grey.shade300),
        ),
        child: Center(
          child: Text(
            text,
            style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 16,
              color: isDark ? Colors.white : Colors.black87,
            ),
          ),
        ),
      ),
    );
  }
}
