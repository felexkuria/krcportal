import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService {
  static final FirebaseAuth _auth = FirebaseAuth.instance;
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Stream to listen to authentication state changes
  static Stream<User?> get userStream => _auth.authStateChanges();

  // Login method
  static Future<AuthResult> login(
      {required String email, required String password}) async {
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Update last login time in Firestore
      await _updateLastLoginTime(userCredential.user);

      return AuthResult(
          success: true,
          user: userCredential.user,
          message: 'Login successful');
    } on FirebaseAuthException catch (e) {
      return AuthResult(
          success: false, message: _getErrorMessage(e), errorCode: e.code);
    } catch (e) {
      return AuthResult(
          success: false,
          message: 'An unexpected error occurred',
          errorCode: 'unexpected_error');
    }
  }

  // Register method
  static Future<AuthResult> register(
      {required String email,
      required String password,
      required String name}) async {
    try {
      UserCredential userCredential =
          await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Create user document in Firestore
      await _createUserDocument(
          uid: userCredential.user!.uid, email: email, name: name);

      return AuthResult(
          success: true,
          user: userCredential.user,
          message: 'Registration successful');
    } on FirebaseAuthException catch (e) {
      return AuthResult(
          success: false, message: _getErrorMessage(e), errorCode: e.code);
    }
  }

  // Logout method
  static Future<void> logout() async {
    await _auth.signOut();
  }

  // Update last login time in Firestore
  static Future<void> _updateLastLoginTime(User? user) async {
    if (user != null) {
      await _firestore.collection('users').doc(user.uid).update({
        'lastLoginTime': FieldValue.serverTimestamp(),
      });
    }
  }

  // Create user document in Firestore
  static Future<void> _createUserDocument(
      {required String uid,
      required String email,
      required String name}) async {
    await _firestore.collection('users').doc(uid).set({
      'email': email,
      'name': name,
      'createdAt': FieldValue.serverTimestamp(),
      'lastLoginTime': FieldValue.serverTimestamp(),
    });
  }

  // Translate Firebase Auth error codes to user-friendly messages
  static String _getErrorMessage(FirebaseAuthException e) {
    switch (e.code) {
      case 'weak-password':
        return 'The password is too weak.';
      case 'email-already-in-use':
        return 'An account already exists with this email.';
      case 'invalid-email':
        return 'The email address is not valid.';
      case 'user-not-found':
        return 'No user found with this email.';
      case 'wrong-password':
        return 'Incorrect password.';
      case 'too-many-requests':
        return 'Too many login attempts. Please try again later.';
      default:
        return 'An authentication error occurred.';
    }
  }
}

// Authentication result class for handling login/register responses
class AuthResult {
  final bool success;
  final User? user;
  final String message;
  final String? errorCode;

  AuthResult({
    required this.success,
    this.user,
    required this.message,
    this.errorCode,
  });
}
