import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:timesget/models/user.model.dart';
import 'package:rxdart/rxdart.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final Firestore _db = Firestore.instance;

  AppUser _cachedUser;
  AppUser get cachedUser => _cachedUser;

  // Observable<FirebaseUser> _user; // firebase user
  BehaviorSubject<AppUser> profile = new BehaviorSubject<AppUser>.seeded(
      null); // custom user data in firestore
  PublishSubject<bool> loading = PublishSubject();

  StreamController<FirebaseUser> _userController = new StreamController();

  Future<FirebaseUser> createUserWithEmailAndPassword(
      String email, String password) async {
    loading.add(true);
    try {
      final authResult = await _auth.createUserWithEmailAndPassword(
          email: email, password: password);
      final user = authResult.user;
      updateUserData(user);
      return user;
    } finally {
      loading.add(false);
    }
  }

  Future<FirebaseUser> signInWithEmailAndPassword(
      String email, String password) async {
    loading.add(true);
    try {
      final authResult = await _auth.signInWithEmailAndPassword(
          email: email, password: password);
      final user = authResult.user;
      updateUserData(user);
      print('Successfully loggin');
      return user;
    } catch (err) {
      print(err);
      throw (err);
    } finally {
      loading.add(false);
    }
  }

  void updateUserData(FirebaseUser user) {
    try {
      final ref = _db.collection('/mobile-users').document(user.uid);
      ref.setData({
        'email': user.email,
        'uid': user.uid,
        'photoURL': user.photoUrl,
        'displayName': user.displayName,
        'lastSeen': DateTime.now()
      }, merge: true);
    } catch (e) {
      print('>>>> ERROR:' + e);
      throw (e);
    }
  }

  Future<void> sendPasswordResetEmail(String email) async {
    await _auth.sendPasswordResetEmail(email: email);
  }

  void signOut() {
    _auth.signOut().then((_) {
      print('Success sign out');
    }).catchError((e) {
      print(e);
      throw (e);
    });
  }

  static final AuthService _singleton = AuthService._();

  factory AuthService() {
    return _singleton;
  }

  AuthService._() {
    _auth.currentUser().then((currentUser) {
      print(currentUser != null
          ? 'Current user is ${currentUser.uid}'
          : 'Current user is null');
      _userController.add(currentUser);
    });

    _userController.stream.listen((u) {
      print('>>> USER CONTROLLER STREAM $u');
      _cachedUser = u == null ? null : AppUser.fromFirebaseUser(u);
      profile.add(cachedUser);
    });

    _auth.onAuthStateChanged.listen((user) {
      print('>>> onAuthStateChanged is changed on $user');
      _userController.add(user);
    });
  }
}
