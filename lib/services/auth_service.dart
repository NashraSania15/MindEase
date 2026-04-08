import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // ─── Current user ────────────────────────────────────────────────────────────

  User? get currentUser => _auth.currentUser;

  /// Stream that emits whenever auth state changes (login / logout / app restart).
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // ─── Sign Up ──────────────────────────────────────────────────────────────────

  Future<void> signup({
    required String name,
    required String email,
    required String password,
  }) async {
    try {
      // 1. Create Firebase Auth account
      final UserCredential credential =
          await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final String uid = credential.user!.uid;

      // 2. Persist display name on the Auth user object
      await credential.user!.updateDisplayName(name);

      // 3. Write user document to Firestore (users/{uid})
      final userModel = UserModel(
        uid: uid,
        name: name,
        email: email,
        createdAt: DateTime.now(),
      );

      await _firestore
          .collection('users')
          .doc(uid)
          .set(userModel.toMap())
          .timeout(const Duration(seconds: 10));
    } on FirebaseAuthException catch (e) {
      throw Exception(_mapAuthError(e.code));
    } catch (e) {
      throw Exception('Sign up failed. Please try again.');
    }
  }

  // ─── Login ────────────────────────────────────────────────────────────────────

  Future<void> login({
    required String email,
    required String password,
  }) async {
    try {
      await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
    } on FirebaseAuthException catch (e) {
      throw Exception(_mapAuthError(e.code));
    } catch (e) {
      throw Exception('Login failed. Please try again.');
    }
  }

  // ─── Logout ───────────────────────────────────────────────────────────────────

  Future<void> logout() async {
    await _auth.signOut();
  }

  // ─── Password Reset ───────────────────────────────────────────────────────────

  Future<void> sendPasswordReset(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      throw Exception(_mapAuthError(e.code));
    }
  }

  // ─── Fetch User Data from Firestore ──────────────────────────────────────────

  /// Returns the [UserModel] for [uid] from Firestore, or null if not found.
  Future<UserModel?> getUserData(String uid) async {
    try {
      final doc = await _firestore.collection('users').doc(uid).get();
      if (!doc.exists || doc.data() == null) return null;
      return UserModel.fromMap(doc.data()!, uid);
    } catch (e) {
      return null;
    }
  }

  // ─── Update User Name ──────────────────────────────────────────────────────────

  /// Updates the user's display name in both Firebase Auth and Firestore.
  Future<void> updateUserName(String newName) async {
    try {
      final user = _auth.currentUser;
      if (user == null) throw Exception('Not logged in.');

      // Update Firebase Auth display name
      await user.updateDisplayName(newName);

      // Update Firestore user document
      await _firestore
          .collection('users')
          .doc(user.uid)
          .update({'name': newName});
    } catch (e) {
      throw Exception('Failed to update name. Please try again.');
    }
  }

  // ─── Error Mapping ────────────────────────────────────────────────────────────

  /// Maps Firebase Auth error codes to human-readable messages.
  String _mapAuthError(String code) {
    switch (code) {
      case 'user-not-found':
        return 'No account found with this email.';
      case 'wrong-password':
        return 'Incorrect password. Please try again.';
      case 'invalid-credential':
        // Firebase SDK v5+ unifies wrong-password & user-not-found
        return 'Incorrect email or password.';
      case 'email-already-in-use':
        return 'An account already exists with this email.';
      case 'weak-password':
        return 'Password must be at least 6 characters.';
      case 'invalid-email':
        return 'Please enter a valid email address.';
      case 'network-request-failed':
        return 'Network error. Check your connection.';
      case 'too-many-requests':
        return 'Too many attempts. Please try again later.';
      case 'user-disabled':
        return 'This account has been disabled.';
      default:
        return 'Something went wrong. Please try again.';
    }
  }
}
