import 'dart:io';

/// In-memory singleton that tracks the latest modality results from the
/// current session. Call the update methods after each analysis completes
/// and read [combinedScore] to get the merged final stress (0–100).
///
/// This service does NOT touch Firestore — it is a lightweight cache so that
/// the dashboard, chatbot, and save flows can access a unified score without
/// re-querying the backend.
class CombinedStressService {
  CombinedStressService._();
  static final CombinedStressService instance = CombinedStressService._();

  double _faceStress = 0;
  double _fatigueLevel = 0;
  double _voiceStress = 0;
  double _textStress = 0;
  String _latestEmotion = '';

  File? latestFaceFile;
  File? latestAudioFile;
  String latestText = '';

  // ── Getters ──────────────────────────────────────────────────────────────

  double get faceStress => _faceStress;
  double get fatigueLevel => _fatigueLevel;
  double get voiceStress => _voiceStress;
  double get textStress => _textStress;
  String get latestEmotion => _latestEmotion;

  /// Combined stress = average of non-zero modalities.
  /// Returns 0 if nothing has been measured yet.
  double get combinedScore {
    final values = <double>[_faceStress, _voiceStress, _textStress]
        .where((v) => v > 0)
        .toList();
    if (values.isEmpty) return 0;
    return (values.reduce((a, b) => a + b) / values.length).clamp(0.0, 100.0);
  }

  /// `true` if at least one modality has been measured this session.
  bool get hasData => _faceStress > 0 || _voiceStress > 0 || _textStress > 0;

  /// Number of modalities that contributed to the combined score.
  int get activeModalities =>
      [_faceStress, _voiceStress, _textStress].where((v) => v > 0).length;

  // ── Update methods ───────────────────────────────────────────────────────

  void updateFace(double stress, {double fatigue = 0, String emotion = ''}) {
    _faceStress = stress.clamp(0.0, 100.0);
    _fatigueLevel = fatigue.clamp(0.0, 100.0);
    if (emotion.isNotEmpty) _latestEmotion = emotion;
  }

  void updateVoice(double stress, {String emotion = ''}) {
    _voiceStress = stress.clamp(0.0, 100.0);
    if (emotion.isNotEmpty) _latestEmotion = emotion;
  }

  void updateText(double stress, {String emotion = ''}) {
    _textStress = stress.clamp(0.0, 100.0);
    if (emotion.isNotEmpty) _latestEmotion = emotion;
  }

  // ── Reset ────────────────────────────────────────────────────────────────

  /// Clear all cached values (e.g. on logout or new session).
  void reset() {
    _faceStress = 0;
    _fatigueLevel = 0;
    _voiceStress = 0;
    _textStress = 0;
    _latestEmotion = '';
    latestFaceFile = null;
    latestAudioFile = null;
    latestText = '';
  }
}
