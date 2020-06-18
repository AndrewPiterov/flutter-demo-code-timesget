import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:timesget/models/app_image.dart';
import 'package:timesget/models/company_type.dart';

class BannerModel {
  final String id;
  final Timestamp endAt;
  final AppImage image;
  final String externalLink;
  final List<CompanyType> types;
  final int order;
  BannerModel(this.id, this.image, this.endAt, this.types, this.externalLink,
      this.order);

  static BannerModel fromSnapshot(DocumentSnapshot snapshot) {
    final id = snapshot.documentID;
    final image = AppImage.fromJson(snapshot.data['image']);
    final endAt = snapshot.data['endAt'] as Timestamp;
    final specs = snapshot.data.containsKey('types')
        ? (snapshot.data['types'] as Iterable)
            .map((x) => CompanyType.fromJsonMap(x))
            .toList()
        : List<CompanyType>();
    final link = snapshot.data.containsKey('externalLink')
        ? snapshot.data['externalLink']
        : null;
    final order =
        snapshot.data.containsKey('order') ? snapshot.data['order'] : null;
    return BannerModel(id, image, endAt, specs, link, order);
  }
}
