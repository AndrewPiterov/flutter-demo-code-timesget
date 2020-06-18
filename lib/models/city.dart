import 'package:cloud_firestore/cloud_firestore.dart';

class City {
  final String id;
  final String name;
  final String countryId;

  City(this.id, this.name, this.countryId);

  static City from(DocumentSnapshot snapshot) =>
      City(snapshot.documentID, snapshot['name'], snapshot['countryId']);
}
