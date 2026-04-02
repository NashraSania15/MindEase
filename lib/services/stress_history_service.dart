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

  /// **Shared stress computation** — used by dashboard, history AND profile.
  ///
  /// Always computes from the individual modality fields so that the result
  /// is the average of only the non-zero modalities:
  ///   finalStress = sum(nonZeroValues) / nonZeroValues.length
  ///
  /// Example: text = 5, voice = 20 → (5 + 20) / 2 = 12.5
  ///
  /// The legacy `finalStress` field stored in Firestore is ignored here to
  /// guarantee consistency — old documents may have stored a single
  /// modality's raw value rather than the combined average.
  static double computeStress(Map<String, dynamic> d) {
    final face  = (d['faceStress']  as num?)?.toDouble() ?? 0;
    final voice = (d['voiceStress'] as num?)?.toDouble() ?? 0;
    final text  = (d['textStress']  as num?)?.toDouble() ?? 0;
    final values = [face, voice, text].where((v) => v > 0).toList();
    if (values.isEmpty) return 0;
    return (values.reduce((a, b) => a + b) / values.length).clamp(0.0, 100.0);
  }

  /// Save a stress result to Firestore.
  /// Pass only the stress value(s) that were actually measured; the rest default to 0.
  /// Also stores pre-computed `finalStress` and an optional [emotion] string.
  static Future<void> saveStressResult({
    double faceStress = 0,
    double voiceStress = 0,
    double textStress = 0,
    String emotion = '',
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
      'emotion': emotion,
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

  /// Stream of the latest 2 stress entries — used for trend comparison.
  static Stream<QuerySnapshot<Map<String, dynamic>>> latestTwoEntriesStream() {
    final uid = _uid;
    if (uid == null || uid.isEmpty) return const Stream.empty();
    return _historyRef(uid)
        .orderBy('timestamp', descending: true)
        .limit(2)
        .snapshots();
  }

  /// Stream of the latest [n] stress entries — used for dashboard mini-chart.
  static Stream<QuerySnapshot<Map<String, dynamic>>> latestEntriesStream(int n) {
    final uid = _uid;
    if (uid == null || uid.isEmpty) return const Stream.empty();
    return _historyRef(uid)
        .orderBy('timestamp', descending: true)
        .limit(n)
        .snapshots();
  }

  /// One-shot Future returning the latest stress data, or `null` if none.
  /// Used by the chatbot to fetch contextual data without a stream.
  static Future<Map<String, dynamic>?> latestStressFuture() async {
    final uid = _uid;
    if (uid == null || uid.isEmpty) return null;
    final snap = await _historyRef(uid)
        .orderBy('timestamp', descending: true)
        .limit(1)
        .get();
    if (snap.docs.isEmpty) return null;
    return snap.docs.first.data();
  }
}

