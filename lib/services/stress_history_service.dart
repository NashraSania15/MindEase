import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

/// Service for saving and reading stress history from Firestore.
///
/// Firestore path: users/{uid}/stress_history/{docId}
/// Fields: { timestamp, faceStress, voiceStress, textStress }
class StressHistoryService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  static String? get _uid => FirebaseAuth.instance.currentUser?.uid;

  static CollectionReference<Map<String, dynamic>> _historyRef(String uid) =>
      _firestore.collection('users').doc(uid).collection('stress_history');

  /// **Shared stress computation** — used by dashboard AND history.
  ///
  /// If the document contains a pre-computed `finalStress` field (0–100),
  /// that value is used directly (backward compatibility).
  /// Otherwise it averages only the non-zero modalities:
  ///   finalStress = sum(nonZeroValues) / nonZeroValues.length
  static double computeStress(Map<String, dynamic> d) {
    // 1. Check for pre-computed value first
    final precomputed = (d['finalStress'] as num?)?.toDouble();
    if (precomputed != null && precomputed > 0) {
      return precomputed.clamp(0.0, 100.0);
    }

    // 2. Compute from individual modalities
    final face  = (d['faceStress']  as num?)?.toDouble() ?? 0;
    final voice = (d['voiceStress'] as num?)?.toDouble() ?? 0;
    final text  = (d['textStress']  as num?)?.toDouble() ?? 0;
    final values = [face, voice, text].where((v) => v > 0).toList();
    if (values.isEmpty) return 0;
    return (values.reduce((a, b) => a + b) / values.length).clamp(0.0, 100.0);
  }

  /// Save a stress result to Firestore.
  /// Pass only the stress value(s) that were actually measured; the rest default to 0.
  /// Also stores pre-computed `finalStress` for fast reads.
  static Future<void> saveStressResult({
    double faceStress = 0,
    double voiceStress = 0,
    double textStress = 0,
  }) async {
    final uid = _uid;
    if (uid == null || uid.isEmpty) {
      throw Exception('User is not logged in.');
    }

    final fClamped = faceStress.clamp(0.0, 100.0).toDouble();
    final vClamped = voiceStress.clamp(0.0, 100.0).toDouble();
    final tClamped = textStress.clamp(0.0, 100.0).toDouble();

    // Pre-compute finalStress using the shared formula
    final data = {
      'faceStress': fClamped,
      'voiceStress': vClamped,
      'textStress': tClamped,
    };
    final finalStress = computeStress(data);

    await _historyRef(uid).add({
      'timestamp': FieldValue.serverTimestamp(),
      'faceStress': fClamped,
      'voiceStress': vClamped,
      'textStress': tClamped,
      'finalStress': finalStress,
    });
  }

  /// Real-time stream of stress history, ordered newest first.
  static Stream<QuerySnapshot<Map<String, dynamic>>> historyStream() {
    final uid = _uid;
    if (uid == null || uid.isEmpty) return const Stream.empty();
    return _historyRef(uid)
        .orderBy('timestamp', descending: true)
        .snapshots();
  }

  /// Stream of the single latest stress entry.
  static Stream<QuerySnapshot<Map<String, dynamic>>> latestEntryStream() {
    final uid = _uid;
    if (uid == null || uid.isEmpty) return const Stream.empty();
    return _historyRef(uid)
        .orderBy('timestamp', descending: true)
        .limit(1)
        .snapshots();
  }
}
