import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:timesget/models/app_image.dart';

class Promocode {
  final AppImage image;
  final Timestamp createdAt;
  final Timestamp endAt;

  Promocode(this.image, this.createdAt, this.endAt);

  static Promocode fromSnapshot(DocumentSnapshot snapshot) {
    final image = AppImage.fromJson(snapshot.data['image']);
    final createdAt = snapshot.data['createdAt'] as Timestamp;
    final endAt = snapshot.data['endAt'] as Timestamp;
    return Promocode(image, createdAt, endAt);
  }
}
