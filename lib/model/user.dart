import 'package:cloud_firestore/cloud_firestore.dart';

class AppUser {
  final String uid;
  final String email;
  final String name;
  final DateTime registrationTime;
  DateTime? lastLoginTime;

  // Constructor
  AppUser({
    required this.uid,
    required this.email,
    required this.name,
    required this.registrationTime,
    this.lastLoginTime,
  });

  // Factory method to create an AppUser from Firestore document
  factory AppUser.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return AppUser(
      uid: doc.id,
      email: data['email'],
      name: data['name'],
      registrationTime: (data['createdAt'] as Timestamp).toDate(),
      lastLoginTime: data['lastLoginTime'] != null
          ? (data['lastLoginTime'] as Timestamp).toDate()
          : null,
    );
  }

  // Convert AppUser to Firestore-compatible map
  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'email': email,
      'name': name,
      'createdAt': registrationTime,
      'lastLoginTime': lastLoginTime,
    };
  }
}
