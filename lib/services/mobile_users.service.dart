import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:rxdart/rxdart.dart';

class MobileUsersService {
  final Firestore _db = Firestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  PublishSubject<bool> loading = PublishSubject();

  static final MobileUsersService _singleton = MobileUsersService._();

  factory MobileUsersService() {
    return _singleton;
  }

  Future<bool> doesEmailExist(String email) async {
    final user = await _db
        .collection('/mobile-users')
        .where('email', isEqualTo: email)
        .limit(1)
        .getDocuments();
    final res = user.documents.length == 1;
    return res;
  }

  Future<Null> sendResetPasswordEmail(String email) async {
    loading.add(true);
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } finally {
      loading.add(false);
    }
  }

  MobileUsersService._();
}
