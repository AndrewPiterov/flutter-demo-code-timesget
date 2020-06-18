import 'package:cloud_firestore/cloud_firestore.dart';

class Country {
  final String code;
  final String name;
  final String cur;

  Country(this.code, this.name, this.cur);

  static Country fromSnapshot(DocumentSnapshot snap) {
    return Country(snap.data['code'], snap.data['name'], snap.data['cur']);
  }
}
