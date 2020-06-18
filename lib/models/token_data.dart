import 'package:cloud_firestore/cloud_firestore.dart';

class TokenData {
  final String token;
  final bool shouldRecieveNotifications;
  final Timestamp createdAt;
  final Timestamp lastOpenAppAt;

  bool get hasToken => token != null && token != '';

  TokenData(this.token, this.shouldRecieveNotifications, this.lastOpenAppAt,
      this.createdAt);

  static TokenData fromSnapshot(DocumentSnapshot snapshot) {
    final token = snapshot.data['token'] ?? snapshot.documentID;
    final createdAt = snapshot.data['createdAt'] as Timestamp;
    final shouldRecieve = snapshot.data['shouldRecieveNotifications'] ?? false;
    final lastOpenAt = snapshot.data['lastOpenAppAt'] as Timestamp;
    return TokenData(token, shouldRecieve, lastOpenAt, createdAt);
  }
}
