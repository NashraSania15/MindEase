import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:url_launcher/url_launcher.dart';

/// All Emergency Contacts logic — Firestore CRUD + SMS/Call via url_launcher.
///
/// Firestore path: users/{uid}/emergency_contacts/{contactId}
/// Fields per document: { name, phone, relation, createdAt }
class EmergencyService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // ─── Auth ─────────────────────────────────────────────────────────────────

  String _requireUid() {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null || uid.isEmpty) {
      throw Exception('User is not logged in.');
    }
    return uid;
  }

  // ─── Firestore helpers ────────────────────────────────────────────────────

  CollectionReference<Map<String, dynamic>> _contactsRef(String uid) =>
      _firestore
          .collection('users')
          .doc(uid)
          .collection('emergency_contacts');

  // ─── Contacts CRUD ────────────────────────────────────────────────────────

  /// Real-time stream of all emergency contacts for the current user.
  Stream<QuerySnapshot<Map<String, dynamic>>> contactsStream() {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null || uid.isEmpty) return const Stream.empty();
    return _contactsRef(uid)
        .orderBy('createdAt', descending: false)
        .snapshots();
  }

  /// Add a new emergency contact.
  Future<void> addContact({
    required String name,
    required String phone,
    String relation = '',
  }) async {
    final uid = _requireUid();
    await _contactsRef(uid).add({
      'name': name.trim(),
      'phone': phone.trim(),
      'relation': relation.trim(),
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  /// Permanently delete a contact by its Firestore document ID.
  Future<void> deleteContact(String contactId) async {
    final uid = _requireUid();
    await _contactsRef(uid).doc(contactId).delete();
  }

  // ─── Calling & SMS ────────────────────────────────────────────────────────

  /// Open the phone dialler with [phone] pre-filled.
  Future<bool> makeCall(String phone) async {
    final clean = _cleanPhone(phone);
    final uri = Uri(scheme: 'tel', path: clean);
    if (await canLaunchUrl(uri)) {
      return launchUrl(uri);
    }
    return false;
  }

  /// Open the SMS app addressed to [phone] with [message] pre-filled.
  Future<bool> sendSmsAlert(String phone, String message) async {
    final clean = _cleanPhone(phone);
    final uri = Uri(
      scheme: 'sms',
      path: clean,
      queryParameters: {'body': message},
    );
    if (await canLaunchUrl(uri)) {
      return launchUrl(uri);
    }
    return false;
  }

  /// Open WhatsApp addressed to [phone] with [message] pre-filled.
  /// [phone] must include country code, e.g. +919876543210.
  Future<bool> sendWhatsAppAlert(String phone, String message) async {
    // wa.me requires digits only — no '+', spaces, dashes, or parens.
    final clean = phone.replaceAll(RegExp(r'[^\d]'), '');
    if (clean.isEmpty) return false;
    final encoded = Uri.encodeComponent(message);
    final url = 'https://wa.me/$clean?text=$encoded';
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      return launchUrl(uri, mode: LaunchMode.externalApplication);
    }
    return false;
  }

  // ─── Alert Logic ──────────────────────────────────────────────────────────

  /// Build the standard alert message for a given stress level (0–100).
  String _alertMessage(double stressLevel) =>
      'I might be under stress. My current stress level is '
      '${stressLevel.toStringAsFixed(0)}%. Please check on me.';

  /// Manual SOS — sends the alert message to ALL saved contacts.
  /// Tries WhatsApp first; falls back to SMS if WhatsApp is unavailable.
  Future<void> sendAlertToAll(double stressLevel) async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null || uid.isEmpty) return;

    try {
      final snapshot = await _contactsRef(uid).get();
      if (snapshot.docs.isEmpty) return;

      final message = _alertMessage(stressLevel);
      for (final doc in snapshot.docs) {
        final data = doc.data();
        final phone = (data['phone'] ?? '').toString().trim();
        if (phone.isEmpty) continue;
        // Try WhatsApp first; if it fails or is not installed, fall back to SMS.
        final sentViaWa = await sendWhatsAppAlert(phone, message);
        if (!sentViaWa) {
          await sendSmsAlert(phone, message);
        }
      }
    } catch (_) {
      // Silently fail — UI shows its own error handling.
    }
  }

  /// Auto-trigger — only fires when [stressLevel] > 70.
  /// Call this from any analysis screen after computing the stress result.
  ///
  /// Example:
  /// ```dart
  /// await EmergencyService().triggerEmergencyAlert(analysisResult.stressScore);
  /// ```
  Future<void> triggerEmergencyAlert(double stressLevel) async {
    if (stressLevel <= 70) return;
    await sendAlertToAll(stressLevel);
  }

  // ─── Utility ──────────────────────────────────────────────────────────────

  /// Strip common formatting characters so the tel/sms scheme is clean.
  String _cleanPhone(String phone) =>
      phone.replaceAll(RegExp(r'[\s\-()]'), '');

  /// Validate a phone number — must have at least 7 digits.
  static bool isValidPhone(String phone) {
    final digits = phone.replaceAll(RegExp(r'\D'), '');
    return digits.length >= 7;
  }
}
