import 'package:cloud_firestore/cloud_firestore.dart';

class WorkerSpecialization {
  final String id;
  final String title;

  WorkerSpecialization(this.id, this.title);

  static WorkerSpecialization fromSnapshot(DocumentSnapshot snapshot) {
    return WorkerSpecialization.fromJsonMap(snapshot.data,
        id: snapshot.documentID);
  }

  Map<String, dynamic> get json => {'id': id, 'title': title};

  static WorkerSpecialization fromJsonMap(Map json, {id}) {
    final title = json['title'];
    return WorkerSpecialization(id ?? json['id'], title);
  }
}
