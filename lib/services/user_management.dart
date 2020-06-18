import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:timesget/models/user.model.dart';

class UserManagement {
  DocumentReference _doc(String uid) {
    return Firestore.instance.collection('/mobile-users').document(uid);
  }
//
//  storeNewUser(user, context) {
//    _doc(user.uid).setData({'email': user.email, 'uid': user.uid}).then((doc) {
//      Navigator.of(context).pop();
//      Navigator.of(context).pushReplacementNamed('/account');
//    }).catchError((e) {
//      print(e);
//    });
//  }

  addDeviceToken(String uid, String token) async {
    if (token == null || token == '') {
      return;
    }

    final snapshot = await _doc(uid).get();

    if (!snapshot.exists) {
      throw Error();
    }

    final user = AppUser.fromSnapshot(snapshot);

    if (user.hasToken(token)) {
      return;
    }

    await _doc(uid).setData({
      'device-tokens': [token]..addAll(user.deviceTokens)
    }, merge: true);
  }
}
