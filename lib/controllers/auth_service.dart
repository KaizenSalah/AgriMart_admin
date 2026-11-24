import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Verifies that [uid] has admin privileges via custom claims or `admins/{uid}`.
  Future<bool> isAdminUser(String uid) async {
    try {
      final user = _auth.currentUser;
      if (user != null && user.uid == uid) {
        final tokenResult = await user.getIdTokenResult();
        if (tokenResult.claims?['admin'] == true) {
          return true;
        }
      }
      final doc = await _firestore.collection('admins').doc(uid).get();
      return doc.exists && (doc.data()?['active'] ?? true) == true;
    } catch (_) {
      return false;
    }
  }

  /// Creates a new admin account only when a valid [inviteCode] is provided.
  Future<String> createAccountWithEmail(
    String email,
    String password, {
    String inviteCode = '',
  }) async {
    final expectedInvite = dotenv.env['ADMIN_INVITE_CODE']?.trim() ?? '';
    if (expectedInvite.isEmpty || inviteCode.trim() != expectedInvite) {
      return "Admin registration requires a valid invite code.";
    }

    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      final user = credential.user;
      if (user == null) {
        return "Account creation failed.";
      }
      await _firestore.collection('admins').doc(user.uid).set({
        'email': email.trim(),
        'role': 'admin',
        'active': true,
        'created_at': FieldValue.serverTimestamp(),
      });
      return "Account Created";
    } on FirebaseAuthException catch (e) {
      return e.message ?? "Authentication failed.";
    }
  }

  /// Signs in with email/password and enforces admin role verification.
  Future<String> loginWithEmail(String email, String password) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      final user = credential.user;
      if (user == null) {
        return "Login failed.";
      }
      final isAdmin = await isAdminUser(user.uid);
      if (!isAdmin) {
        await _auth.signOut();
        return "Access denied: This account does not have admin privileges.";
      }
      return "Login Successful";
    } on FirebaseAuthException catch (e) {
      return e.message ?? "Authentication failed.";
    }
  }

  /// Signs out the current admin user.
  Future<void> logout() async {
    await _auth.signOut();
  }

  /// Sends a password reset email.
  Future<String> resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email.trim());
      return "Mail Sent";
    } on FirebaseAuthException catch (e) {
      return e.message ?? "Password reset failed.";
    }
  }

  /// Checks whether the current user is signed in and has admin privileges.
  Future<bool> isLoggedIn() async {
    final user = _auth.currentUser;
    if (user == null) return false;
    final isAdmin = await isAdminUser(user.uid);
    if (!isAdmin) {
      await _auth.signOut();
      return false;
    }
    return true;
  }
}
