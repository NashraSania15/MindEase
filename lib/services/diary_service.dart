import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';

class DiaryService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  // Always resolve UID fresh — never cache it as a getter that silently allows null.
  String _requireUid() {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null || uid.isEmpty) {
      throw Exception('User is not logged in. Please sign in and try again.');
    }
    return uid;
  }

  // ─── Diary Entries ────────────────────────────────────────────────────────

  Future<void> addEntry({
    required String text,
    required String mood,
    String? audioUrl,
    double? textStress,
  }) async {
    final uid = _requireUid();
    await _firestore
        .collection('users')
        .doc(uid)
        .collection('diary_entries')
        .add({
      'text': text,
      'mood': mood,
      'audioUrl': audioUrl,
      'textStress': textStress,
      'createdAt': Timestamp.now(),
    });
  }

  Stream<QuerySnapshot> getEntries() {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null || uid.isEmpty) return const Stream.empty();
    return _firestore
        .collection('users')
        .doc(uid)
        .collection('diary_entries')
        .orderBy('createdAt', descending: true)
        .snapshots();
  }

  // ─── Audio Upload ─────────────────────────────────────────────────────────

  Future<String> uploadAudio(File file) async {
    final uid = _requireUid();
    final ref = _storage
        .ref()
        .child('users/$uid/audio/${DateTime.now().millisecondsSinceEpoch}.m4a');
    final task = await ref.putFile(file);
    return task.ref.getDownloadURL();
  }

  // ─── PIN Lock ─────────────────────────────────────────────────────────────

  Future<bool> hasPinSet() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null || uid.isEmpty) return false;

    try {
      final doc =
          await _firestore.collection('users').doc(uid).get();
      if (!doc.exists) return false;
      final data = doc.data();
      if (data == null) return false;
      final pin = data['diaryPin'];
      return pin != null && pin.toString().isNotEmpty;
    } catch (_) {
      return false;
    }
  }

  Future<void> setPin(String pin) async {
    final uid = _requireUid();
    await _firestore
        .collection('users')
        .doc(uid)
        .set({'diaryPin': pin}, SetOptions(merge: true));
  }

  Future<bool> verifyPin(String pin) async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null || uid.isEmpty) return false;

    try {
      final doc =
          await _firestore.collection('users').doc(uid).get();
      if (!doc.exists) return false;
      final data = doc.data();
      if (data == null) return false;
      return data['diaryPin']?.toString() == pin;
    } catch (_) {
      return false;
    }
  }

  /// Change PIN — verifies old PIN first, then writes new PIN.
  Future<bool> resetPin(String oldPin, String newPin) async {
    final isValid = await verifyPin(oldPin);
    if (!isValid) return false;
    await setPin(newPin);
    return true;
  }

  /// Forgot PIN — re-authenticates with account password, then writes new PIN.
  /// Throws [FirebaseAuthException] on wrong password.
  /// Throws [Exception] if user is not logged in.
  Future<void> resetPinWithPassword(String password, String newPin) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      throw Exception('User is not logged in. Please sign in and try again.');
    }
    if (user.email == null || user.email!.isEmpty) {
      throw Exception('No email associated with this account.');
    }

    // Re-authenticate — throws FirebaseAuthException on wrong password.
    final credential = EmailAuthProvider.credential(
      email: user.email!,
      password: password,
    );
    await user.reauthenticateWithCredential(credential);

    // Re-read UID after re-auth (currentUser is guaranteed non-null here).
    final uid = FirebaseAuth.instance.currentUser?.uid ?? user.uid;
    await _firestore
        .collection('users')
        .doc(uid)
        .set({'diaryPin': newPin}, SetOptions(merge: true));
  }
}
