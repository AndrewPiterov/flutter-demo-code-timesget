import 'package:cloud_firestore/cloud_firestore.dart';

class CompanyType {
  final String id;
  final String title;

  CompanyType(this.id, this.title);

  static CompanyType fromSnapshot(DocumentSnapshot snapshot) {
    return CompanyType.fromJsonMap(snapshot.data, id: snapshot.documentID);
  }

  static CompanyType fromJsonMap(Map json, {id}) {
    final title = json['title'];
    return CompanyType(id ?? json['id'], title);
  }
}
