import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:timesget/models/app_image.dart';

class CustomerCard {
  final CardNumber barcode;
  final MobileCard card;

  CustomerCard(this.card, {this.barcode});
}

class CardNumber {
  final String id;
  final String cardId;
  final String value;

  final String uid;
  final String email;

  final String type;

  bool get hasOwner => email != null && email != '';

  CardNumber(this.id, this.cardId, this.value, this.type, this.uid, this.email);

  static CardNumber fromSnapshot(DocumentSnapshot snap) {
    final id = snap.documentID;
    final cardId = snap.data['cardId'];
    final value = snap.data['value'];
    final email = snap.data['email'];
    final type = snap.data['type'];
    final uid = snap.data['uid'];

    return CardNumber(id, cardId, value, type, uid, email);
  }
}

class MobileCard {
  final String id;
  final AppImage mainImage;
  // AppImage barcodeImage;
  final bool onlyScan;

  final String title;
  final Timestamp endAt;
  final Timestamp createdAt;
  final Timestamp updatedAt;

  final int freeNumberCount;
  bool get hasFreeNumbers => freeNumberCount > 0;

  MobileCard._(this.id, this.title, this.mainImage, this.createdAt,
      this.updatedAt, this.endAt, this.freeNumberCount, this.onlyScan);

  static MobileCard fromSnapshot(DocumentSnapshot snapshot) {
    final title = snapshot.data['title'];
    final mainImage = AppImage.fromJson(snapshot.data['mainImage']);
    // final barcodeImage = AppImage.fromJson(snapshot.data['barcodeImage']);
    final createdAt = snapshot.data['createdAt'] as Timestamp;
    final updatedAt = snapshot.data['updatedAt'] as Timestamp;
    final endAt = snapshot.data['endAt'] as Timestamp;
    final freeNumberCount = snapshot.data.containsKey('freeNumberCount')
        ? snapshot.data['freeNumberCount']
        : 0;
    final onlyScan = snapshot.data['onlyScan'];
    return MobileCard._(snapshot.documentID, title, mainImage, createdAt,
        updatedAt, endAt, freeNumberCount, onlyScan);
  }
}
