import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:telephony/telephony.dart';

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

  /// Update an existing emergency contact by its Firestore document ID.
  Future<void> updateContact({
    required String contactId,
    required String name,
    required String phone,
    String relation = '',
  }) async {
    final uid = _requireUid();
    await _contactsRef(uid).doc(contactId).update({
      'name': name.trim(),
      'phone': phone.trim(),
      'relation': relation.trim(),
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

  /// Send SMS directly in the background without opening any app (Android only).
  /// Falls back to the url_launcher flow on iOS or if permission denied.
  /// Returns `true` if the SMS was sent directly.
  Future<bool> sendSmsDirect(String phone, String message) async {
    // Direct SMS only works on Android
    if (!Platform.isAndroid) {
      return _sendSmsViaLauncher(phone, message);
    }

    try {
      // Request SMS permission
      final status = await Permission.sms.request();
      if (!status.isGranted) {
        return _sendSmsViaLauncher(phone, message);
      }

      final telephony = Telephony.instance;
      final clean = _cleanPhone(phone);
      await telephony.sendSms(
        to: clean,
        message: message,
        isMultipart: true,
      );
      return true;
    } catch (_) {
      // Fallback to url_launcher
      return _sendSmsViaLauncher(phone, message);
    }
  }

  /// Open the SMS app addressed to [phone] with [message] pre-filled.
  /// Used as a fallback when direct SMS is not available.
  Future<bool> _sendSmsViaLauncher(String phone, String message) async {
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

  /// Open the SMS app addressed to [phone] with [message] pre-filled.
  /// Public method for manual SOS use.
  Future<bool> sendSmsAlert(String phone, String message) async {
    return sendSmsDirect(phone, message);
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
      '🚨 MindEase Alert: I might be under stress. '
      'My current stress level is ${stressLevel.toStringAsFixed(0)}%. '
      'Please check on me.';

  /// Sends the alert message to ALL saved contacts.
  /// Uses direct SMS (background, no UI) first; also attempts WhatsApp.
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

        // Send SMS directly (background — no user interaction needed)
        await sendSmsDirect(phone, message);

        // Also try WhatsApp (note: this may open WhatsApp on some devices)
        // For automatic alerts, we skip WhatsApp to avoid user interruption.
      }
    } catch (_) {
      // Silently fail — UI shows its own error handling.
    }
  }

  /// Sends alert to all contacts including WhatsApp attempt (manual SOS only).
  Future<void> sendAlertToAllWithWhatsApp(double stressLevel) async {
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
        // Try WhatsApp first; if it fails, fall back to SMS.
        final sentViaWa = await sendWhatsAppAlert(phone, message);
        if (!sentViaWa) {
          await sendSmsDirect(phone, message);
        }
      }
    } catch (_) {
      // Silently fail — UI shows its own error handling.
    }
  }

  // ─── Cooldown ──────────────────────────────────────────────────────────────

  /// Tracks the last time an automatic alert was sent.
  /// Shared across all instances since it's static.
  static DateTime? _lastAlertTime;

  /// Cooldown period between automatic alerts (15 minutes).
  static const Duration _alertCooldown = Duration(minutes: 15);

  /// Whether the cooldown has elapsed since the last alert.
  bool get _isCooldownExpired {
    if (_lastAlertTime == null) return true;
    return DateTime.now().difference(_lastAlertTime!) >= _alertCooldown;
  }

  /// Auto-trigger — only fires when [stressLevel] >= 75 AND the 15-minute
  /// cooldown has elapsed since the last automatic alert.
  ///
  /// This should ONLY be called from the dashboard with the FINAL combined
  /// stress score, NOT from individual model screens.
  ///
  /// Returns `true` if an alert was actually sent, `false` if suppressed
  /// by threshold or cooldown.
  Future<bool> triggerEmergencyAlert(double stressLevel) async {
    if (stressLevel < 75) return false;
    if (!_isCooldownExpired) return false;

    _lastAlertTime = DateTime.now();
    await sendAlertToAll(stressLevel);
    return true;
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
