import 'package:cloud_firestore/cloud_firestore.dart';

class CompanySpecialization {
  final String id;
  final String title;

  CompanySpecialization(this.id, this.title);

  static CompanySpecialization from(DocumentSnapshot ds) {
    return CompanySpecialization(ds.documentID, ds['title']);
  }

  static CompanySpecialization fromJsonMap(Map json) {
    return CompanySpecialization(json['id'], json['title']);
  }
}
