import 'package:cloud_firestore/cloud_firestore.dart';

class UserProfile {
  final String uid;
  final String email;
  final String? displayName;
  final bool locationNotificationsEnabled;

  UserProfile({
    required this.uid,
    required this.email,
    this.displayName,
    this.locationNotificationsEnabled = true,
  });

  Map<String, dynamic> toMap() {
    return {
      'email': email,
      'displayName': displayName,
      'locationNotificationsEnabled': locationNotificationsEnabled,
    };
  }

  factory UserProfile.fromDocument(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return UserProfile(
      uid: doc.id,
      email: data['email'] ?? '',
      displayName: data['displayName'],
      locationNotificationsEnabled:
          data['locationNotificationsEnabled'] ?? true,
    );
  }
}
