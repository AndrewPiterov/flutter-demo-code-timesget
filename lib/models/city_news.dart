import 'package:cloud_firestore/cloud_firestore.dart';

class CityNews {
  final String title;
  final String text;
  final Timestamp createdAt;
  final Timestamp endAt;

  CityNews(this.title, this.text, this.createdAt, this.endAt);

  static CityNews fromSnapshot(DocumentSnapshot snapshot) {
    // final id = snapshot.documentID;
    final title = snapshot.data['title'];
    final text = snapshot.data['text'];
    final createdAt = snapshot.data['createdAt'] as Timestamp;
    final endAt = snapshot.data['endAt'] as Timestamp;

    return CityNews(title, text, createdAt, endAt);
  }
}
