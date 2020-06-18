import 'package:cloud_firestore/cloud_firestore.dart';

class Charity {
  final String image;
  final String title;
  final String text;
  final Timestamp createdAt;
  final Timestamp endAt;

  Charity(this.title, this.image, this.text, this.createdAt, this.endAt);

  static Charity fromSnapshot(DocumentSnapshot snapshot) {
    // final id = snapshot.documentID;
    final title = snapshot.data['title'];
    final text = snapshot.data['text'];
    final image = snapshot.data['image']['url'];
    final createdAt = snapshot.data['createdAt'] as Timestamp;
    final endAt = snapshot.data['endAt'] as Timestamp;

    return Charity(title, image, text, createdAt, endAt);
  }
}
