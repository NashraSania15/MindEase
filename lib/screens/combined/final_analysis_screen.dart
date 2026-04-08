import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../services/final_analysis_service.dart';
import '../../services/combined_stress_service.dart';
import '../../services/stress_history_service.dart';
import '../../services/report_service.dart';
import '../../models/report_model.dart';

class FinalAnalysisScreen extends StatefulWidget {
  const FinalAnalysisScreen({super.key});

  @override
  State<FinalAnalysisScreen> createState() => _FinalAnalysisScreenState();
}

class _FinalAnalysisScreenState extends State<FinalAnalysisScreen> {
  bool _isLoading = true;
  FinalAnalysisResult? _result;
  String? _errorMessage;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _fetchAnalysis();
  }

  Future<void> _fetchAnalysis() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final combined = CombinedStressService.instance;
      
      if (combined.latestText.isEmpty && combined.latestFaceFile == null && combined.latestAudioFile == null) {
        throw Exception('No inputs detected.\n\nPlease complete at least one analysis (Face, Voice, or Text) from the Dashboard before requesting a combined result.');
      }

      final result = await FinalAnalysisService.analyzeAll(
        text: combined.latestText,
        imageFile: combined.latestFaceFile,
        audioFile: combined.latestAudioFile,
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

  Future<void> _saveResult() async {
    if (_result == null || _isSaving) return;
    setState(() => _isSaving = true);
    final messenger = ScaffoldMessenger.of(context);
    try {
      final combined = CombinedStressService.instance;
      final user = FirebaseAuth.instance.currentUser;
      final userName = user?.displayName ?? "User"; // Fallback to "User" if name not set

      // 1. Create ReportModel object
      final report = ReportModel(
        name: userName,
        date: DateFormat('MMM dd, yyyy • hh:mm a').format(DateTime.now()),
        face: combined.faceStress.round(),
        voice: combined.voiceStress.round(),
        text: combined.textStress.round(),
        combined: _result!.stressLevel.round(),
        emotion: _result!.emotion,
        reason: _result!.reason,
        future: _result!.futureSimulation,
      );

      // 2. Save locally (use shared_preferences)
      await ReportService.saveReport(report);

      // 3. Save to dashboard history (Part 3)
      await StressHistoryService.saveStressResult(
        combinedStress: _result!.stressLevel,
        emotion: _result!.emotion,
      );

      if (mounted) {
        // Notification
        messenger.showSnackBar(
          const SnackBar(
            content: Text('Report saved. Check in Profile'),
            backgroundColor: Color(0xFF7AD7C1),
          ),
        );
        Navigator.pop(context); // Go back to Home
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

  Color _stressColor(double level) {
    if (level >= 70) return const Color(0xFFE53935);
    if (level >= 40) return const Color(0xFFFFA726);
    return const Color(0xFF43A047);
  }

  String _stressLabel(double level) {
    if (level >= 70) return 'High Stress';
    if (level >= 40) return 'Moderate';
    return 'Calm';
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardColor = isDark ? const Color(0xFF1E1E2C) : Colors.white;
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
          : const [Color(0xFFE8F5E9), Color(0xFFE0F2F1)];
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
                      'Final Analysis',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        color: textColor,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: _isLoading
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const CircularProgressIndicator(
                              color: Color(0xFF7AD7C1),
                            ),
                            const SizedBox(height: 24),
                            Text(
                              'Syncing all your inputs...',
                              style: TextStyle(
                                color: textColor,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 40),
                              child: Text(
                                'This takes a bit longer because we are processing text, voice, and face simultaneously using 3 AI models.',
                                textAlign: TextAlign.center,
                                style: TextStyle(color: subtextColor, fontSize: 14),
                              ),
                            ),
                          ],
                        ),
                      )
                    : _errorMessage != null
                        ? Padding(
                            padding: const EdgeInsets.all(24),
                            child: Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(Icons.error_outline,
                                      color: Colors.red, size: 48),
                                  const SizedBox(height: 16),
                                  Text(
                                    _errorMessage!,
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(
                                      color: Colors.red,
                                      fontSize: 16,
                                    ),
                                  ),
                                  const SizedBox(height: 24),
                                  ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.redAccent,
                                      foregroundColor: Colors.white,
                                    ),
                                    onPressed: _fetchAnalysis,
                                    child: const Text('Retry'),
                                  )
                                ],
                              ),
                            ),
                          )
                        : _buildResultContent(isDark, cardColor, textColor, subtextColor),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildResultContent(bool isDark, Color cardColor, Color textColor, Color subtextColor) {
    final stressValue = _result!.stressLevel.clamp(0, 100).toDouble();
    final color = _stressColor(stressValue);
    final stressLbl = _result!.stressCategory.isNotEmpty ? _result!.stressCategory : _stressLabel(stressValue);

    final futureText = _result!.futureSimulation.isNotEmpty
        ? _result!.futureSimulation
        : "Your current mental state appears stable. Continue maintaining healthy habits for long-term well-being.";

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: cardColor,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: color.withValues(alpha: 0.35), width: 1.5),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Combined Stress',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: textColor,
                      ),
                    ),
                    Text(
                      '${stressValue.toStringAsFixed(0)}%',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: color,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  stressLbl,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: color,
                  ),
                ),
                const SizedBox(height: 16),
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: LinearProgressIndicator(
                    value: stressValue / 100,
                    minHeight: 10,
                    backgroundColor: isDark ? Colors.grey.shade800 : Colors.grey.shade200,
                    valueColor: AlwaysStoppedAnimation<Color>(color),
                  ),
                ),
                const SizedBox(height: 24),
                _sectionTitle('Emotion', textColor),
                const SizedBox(height: 8),
                Text(
                  _result!.emotion,
                  style: TextStyle(fontSize: 15, color: subtextColor, height: 1.4),
                ),
                const SizedBox(height: 20),
                _sectionTitle('Reason', textColor),
                const SizedBox(height: 8),
                Text(
                  _result!.reason.isNotEmpty ? _result!.reason : "No specific reason identified from inputs.",
                  style: TextStyle(fontSize: 15, color: subtextColor, height: 1.4),
                ),
                const SizedBox(height: 20),
                _sectionTitle('Future Simulation', textColor),
                const SizedBox(height: 8),
                Text(
                  futureText,
                  style: TextStyle(fontSize: 15, color: subtextColor, height: 1.4),
                ),
                const SizedBox(height: 20),
                _sectionTitle('Message', textColor),
                const SizedBox(height: 8),
                Text(
                  _result!.message,
                  style: TextStyle(fontSize: 15, color: subtextColor, height: 1.4),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          GestureDetector(
            onTap: _isSaving ? null : _saveResult,
            child: Container(
              height: 54,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(18),
                gradient: const LinearGradient(
                  colors: [Color(0xFF9BE7C4), Color(0xFF7AD7C1)],
                ),
              ),
              child: Center(
                child: Text(
                  _isSaving ? 'Saving…' : 'Save Result',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget _sectionTitle(String title, Color textColor) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: textColor,
      ),
    );
  }
}
