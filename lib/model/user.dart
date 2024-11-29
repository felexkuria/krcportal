import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AppUser {
  final String uid;
  final String email;
  final DateTime registrationTime;
  DateTime? lastLoginTime;

  // Constructor
  AppUser({
    required this.uid,
    required this.email,
    required this.registrationTime,
    this.lastLoginTime,
  });

  // Factory method to create an AppUser from Firestore document
  factory AppUser.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map;
    return AppUser(
      uid: doc.id,
      email: data['email'],
      registrationTime: (data['registrationTime'] as Timestamp).toDate(),
      lastLoginTime: data['lastLoginTime'] != null
          ? (data['lastLoginTime'] as Timestamp).toDate()
          : null,
    );
  }

  // Convert AppUser to Firestore-compatible map
  Map<String, dynamic> toMap() {
    return {
      'email': email,
      'registrationTime': registrationTime,
      'lastLoginTime': lastLoginTime,
    };
  }

  // Firebase Authentication and Firestore methods for user actions
  static Future<AppUser?> register(String email, String password) async {
    try {
      UserCredential userCredential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: email, password: password);

      User? user = userCredential.user;
      if (user != null) {
        // Create user in Firestore with registration time
        await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
          'email': email,
          'registrationTime': DateTime.now(),
          'lastLoginTime': null,
        });

        // Return the created AppUser
        return AppUser(
          uid: user.uid,
          email: user.email!,
          registrationTime: DateTime.now(),
        );
      }
    } catch (e) {
      print('Error during registration: $e');
    }
    return null;
  }

  static Future<AppUser?> login(String email, String password) async {
    try {
      UserCredential userCredential = await FirebaseAuth.instance
          .signInWithEmailAndPassword(email: email, password: password);

      User? user = userCredential.user;
      if (user != null) {
        // Update the last login time in Firestore
        await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .update({
          'lastLoginTime': DateTime.now(),
        });

        // Get the user data from Firestore
        DocumentSnapshot doc = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();
        return AppUser.fromFirestore(doc);
      }
    } catch (e) {
      print('Error during login: $e');
    }
    return null;
  }

  static Future<void> logout() async {
    await FirebaseAuth.instance.signOut();
  }

  static Future<void> resetPassword(String email) async {
    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
    } catch (e) {
      print('Error during password reset: $e');
    }
  }
}
