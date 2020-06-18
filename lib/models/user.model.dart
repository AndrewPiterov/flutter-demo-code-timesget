import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AppUser {
  final String uid;
  final String email;
  final List<String> deviceTokens = List<String>();

  AppUser(this.uid, this.email);

  Map<String, dynamic> asCustomerJson(String phoneNumber) =>
      {'id': uid, 'email': email, 'phoneNumber': phoneNumber};

  static AppUser fromSnapshot(DocumentSnapshot snapshot) {
    final uid = snapshot.data['uid'];
    final email = snapshot.data['email'];
    final tokens = snapshot.data['device-tokens'];
    final u = AppUser(uid, email);

    if (tokens != null && (tokens as List<dynamic>).length > 0) {
      (tokens as List<dynamic>).forEach((token) => u._addToken(token));
    }

    return u;
  }

  void _addToken(String token) => deviceTokens.add(token);

  bool hasToken(String token) => deviceTokens.any((x) => x == token);

  static fromFirebaseUser(FirebaseUser u) {
    return AppUser(u.uid, u.email);
  }
}
