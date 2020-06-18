import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:notification_permissions/notification_permissions.dart';
import 'package:rxdart/subjects.dart';
import 'package:timesget/models/message.dart';
import 'package:timesget/models/token_data.dart';
import 'package:timesget/services/preferenses.service.dart';

class AppMessageService {
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging();
  bool _alreadySetFirebaseMessaging;
  bool _isBusyToSetFirebaseStatus;

  final Map<String, Item> _items = <String, Item>{};

  Item itemForMessage(Map<String, dynamic> message) {
    final String itemId = message['id'];
    final Item item = _items.putIfAbsent(itemId, () => new Item(itemId: itemId))
      ..status = message['status'];
    return item;
  }

  BehaviorSubject<TokenData> _tokenSubject = BehaviorSubject.seeded(null);
  Stream<TokenData> get token$ => _tokenSubject.stream;

  static const String collName = 'fsm-tokens';

  static _updateTokenData(token, data) async {
    //       'token': token,
    //       'lastOpenAppAt': now,
    //       'shouldRecieveNotifications': true,
    //       'createdAt': now
    await Firestore.instance
        .collection(collName)
        .document(token)
        .setData(data, merge: true);
  }

  Future<void> init(BuildContext context) async {
    _setFirebaseMessaging(context);
  }

  static Future<void> updateShouldRecieveNotification(
      bool shouldRecieve) async {
    final token = await PrefsService.getFsmToken();
    if (token == null || token.isEmpty) {
      print('There is no Token!!!');
      return;
    }
    await _updateTokenData(
        token, {'shouldRecieveNotifications': shouldRecieve});
    print('Token shouldRecieveNotifications was update on $shouldRecieve');
  }

  static final AppMessageService _singleton = AppMessageService._();

  factory AppMessageService() {
    return _singleton;
  }

  AppMessageService._() {
    _alreadySetFirebaseMessaging = false;
    _isBusyToSetFirebaseStatus = false;
  }

  Future<void> checkPermission(BuildContext context) async {
    final ok = await getNotificationPermissionStatus();

    if (ok) {
      print('Notification permission is granted.');
    } else {
      print('Notification permission is not allowed.');

      final alreadyDisallow = await PrefsService.disallowNotifications();
      if (alreadyDisallow) {
      } else {
        NotificationPermissions.requestNotificationPermissions()
            .then((_) async {
          // final ok2 = await getNotificationPermissionStatus();
        });
      }
    }
  }

  bool _alreadyDissalowed = false;
  bool _alreadyAllowed = false;

  Future<void> disallowNotifications() async {
    if (_alreadyDissalowed) {
      return;
    }

    await updateShouldRecieveNotification(false);
    await PrefsService.disallowNotifications(setMode: true);
    _alreadyDissalowed = true;
    _alreadyAllowed = false;
  }

  Future<void> allowNotifications() async {
    if (_alreadyAllowed) {
      return;
    }
    await updateShouldRecieveNotification(true);
    await PrefsService.allowNotifications(setMode: true);
    _alreadyDissalowed = false;
    _alreadyAllowed = true;
  }

  Future<bool> getNotificationPermissionStatus() async {
    final status =
        await NotificationPermissions.getNotificationPermissionStatus();
    return status == PermissionStatus.granted;
  }

  Future<void> requestNotificationPermissions() async {
    await NotificationPermissions.requestNotificationPermissions();
  }

  bool _wasUncreated = false;

  Future<void> _setFirebaseMessaging(BuildContext context) async {
    if (_alreadySetFirebaseMessaging) {
      return;
    }

    if (_isBusyToSetFirebaseStatus) {
      return;
    }

    _isBusyToSetFirebaseStatus = true;

    final isOK = true; // await getNotificationPermissionStatus();

    if (isOK) {
      _firebaseMessaging.configure(
        onMessage: (message) async {
          print("onMessage: $message");
          // _showItemDialog(message);
        },
        onLaunch: (message) async {
          print("onLaunch: $message");
          // _navigateToItemDetail(context, message);
        },
        onResume: (message) async {
          print("onResume: $message");
          // _navigateToItemDetail(context, message);
        },
      );

      _firebaseMessaging.requestNotificationPermissions(
          const IosNotificationSettings(sound: true, badge: true, alert: true));

      _firebaseMessaging.onIosSettingsRegistered
          .listen((IosNotificationSettings settings) {
        print("Settings registered: $settings");
      });

      _firebaseMessaging.getToken().then((token) async {
        assert(token != null);

        await PrefsService.setFsmToken(token);

        Firestore.instance
            .collection(collName)
            .document(token)
            .snapshots()
            .map((snapshot) {
          _wasUncreated = !snapshot.exists;
          return snapshot.exists ? TokenData.fromSnapshot(snapshot) : null;
        }).listen((t) async {
          if (_wasUncreated) {
            allowNotifications();
          }

          _tokenSubject.add(t);
        });
      });

      _alreadySetFirebaseMessaging = true;
    }

    _isBusyToSetFirebaseStatus = false;
  }
}
