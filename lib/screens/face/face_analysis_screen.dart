import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import '../../services/face_analysis_service.dart';
import '../../services/stress_history_service.dart';
import '../../services/combined_stress_service.dart';

class FaceAnalysisScreen extends StatefulWidget {
  const FaceAnalysisScreen({super.key});

  @override
  State<FaceAnalysisScreen> createState() => _FaceAnalysisScreenState();
}

class _FaceAnalysisScreenState extends State<FaceAnalysisScreen> {
  CameraController? _cameraController;
  Timer? _captureTimer;
  bool _isCameraReady = false;
  bool _isAnalyzing = false;
  bool _isSaving = false;
  String? _errorMessage;

  // State
  FaceAnalysisResult? _result;
  File? _latestFrame;

  @override
  void dispose() {
    _captureTimer?.cancel();
    _cameraController?.dispose();
    super.dispose();
  }

  Future<void> _openCamera() async {
    setState(() {
      _errorMessage = null;
    });

    try {
      final cameras = await availableCameras();
      final frontCamera = cameras.firstWhere(
        (c) => c.lensDirection == CameraLensDirection.front,
        orElse: () => cameras.first,
      );

      _cameraController = CameraController(
        frontCamera,
        ResolutionPreset.medium,
        enableAudio: false,
      );

      await _cameraController!.initialize();
      if (!mounted) return;

      setState(() {
        _isCameraReady = true;
      });

      _startAutoCapture();
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Could not access camera. Please check permissions.';
        });
      }
    }
  }

  void _startAutoCapture() {
    _captureTimer?.cancel();
    _captureTimer = Timer.periodic(const Duration(seconds: 2), (_) async {
      if (!_isCameraReady || _isAnalyzing || !mounted) return;

      try {
        _isAnalyzing = true;
        final xFile = await _cameraController!.takePicture();
        final file = File(xFile.path);
        
        final result = await FaceAnalysisService.analyzeFace(file);
        
        if (mounted) {
          CombinedStressService.instance.updateFace(
            result.stressLevel,
            emotion: result.emotion,
          );
          CombinedStressService.instance.latestFaceFile = file;

          setState(() {
            _result = result;
            _latestFrame = file;
          });
        }
      } catch (_) {
        // Ignore errors during auto-capture to maintain smooth flow
      } finally {
        _isAnalyzing = false;
      }
    });
  }

  void _stopAutoCapture() {
    _captureTimer?.cancel();
    _cameraController?.dispose();
    setState(() {
      _isCameraReady = false;
    });
  }

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
        _stopAutoCapture(); // Stop after saving to finalize
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
    _captureTimer?.cancel();
    setState(() {
      _result = null;
      _latestFrame = null;
    });
    if (!_isCameraReady) {
      _openCamera();
    } else {
      _startAutoCapture();
    }
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
                      'Live Face Analysis',
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
                child: !_isCameraReady
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.camera_front, size: 60, color: Colors.grey),
                            const SizedBox(height: 16),
                            Text(
                              'Position your face in the frame',
                              style: TextStyle(color: subtextColor, fontSize: 16),
                            ),
                            const SizedBox(height: 24),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 40),
                              child: _primaryButton(
                                text: 'Open Camera',
                                onTap: _openCamera,
                              ),
                            ),
                          ],
                        ),
                      )
                    : Column(
                        children: [
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 16),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(24),
                                child: Stack(
                                  fit: StackFit.expand,
                                  children: [
                                    CameraPreview(_cameraController!),
                                    // Animated scan effect overlay (optional, looks cool)
                                    if (_isAnalyzing)
                                      Container(
                                        decoration: BoxDecoration(
                                          border: Border.all(
                                            color: const Color(0xFF7AD7C1).withOpacity(0.5),
                                            width: 4,
                                          ),
                                          borderRadius: BorderRadius.circular(24),
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          if (_result != null)
                            Padding(
                              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                              child: Container(
                                padding: const EdgeInsets.all(20),
                                decoration: BoxDecoration(
                                  color: isDark ? const Color(0xFF1E1E2C) : Colors.white,
                                  borderRadius: BorderRadius.circular(24),
                                  boxShadow: [
                                    BoxShadow(
                                      color: _stressColor(_result!.stressLevel).withOpacity(0.15),
                                      blurRadius: 15,
                                      offset: const Offset(0, 5),
                                    ),
                                  ],
                                  border: Border.all(
                                    color: _stressColor(_result!.stressLevel).withOpacity(0.3),
                                    width: 1.5,
                                  ),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                                  children: [
                                    Column(
                                      children: [
                                        Text(
                                          'Stress Level',
                                          style: TextStyle(
                                            color: subtextColor,
                                            fontSize: 14,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                        const SizedBox(height: 6),
                                        Text(
                                          '${_result!.stressLevel.toStringAsFixed(0)}%',
                                          style: TextStyle(
                                            color: _stressColor(_result!.stressLevel),
                                            fontWeight: FontWeight.bold,
                                            fontSize: 28,
                                          ),
                                        ),
                                      ],
                                    ),
                                    Container(
                                      width: 1.5,
                                      height: 40,
                                      color: isDark ? Colors.grey.withOpacity(0.2) : Colors.grey.withOpacity(0.3),
                                    ),
                                    Column(
                                      children: [
                                        Text(
                                          'Emotion',
                                          style: TextStyle(
                                            color: subtextColor,
                                            fontSize: 14,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                        const SizedBox(height: 6),
                                        Text(
                                          _result!.emotion.toUpperCase(),
                                          style: TextStyle(
                                            color: textColor,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 20,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                        ],
                      ),
              ),
              
              const SizedBox(height: 20),

              if (_isCameraReady || (_latestFrame != null && !_isCameraReady))
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
                  child: Row(
                    children: [
                      Expanded(
                        child: _secondaryButton(
                          'Try Again',
                          onTap: _tryAgain,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _primaryButton(
                          text: _isSaving ? 'Saving…' : 'Save Result',
                          onTap: _isSaving || _result == null ? null : _saveResult,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
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
        height: 52,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
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
