import 'package:cloud_firestore/cloud_firestore.dart';

class AppImage {
  final String url;
  final double height;
  final double width;

  AppImage(this.url, this.height, this.width);

  static AppImage fromSnapshot(DocumentSnapshot snapshot) {
    return AppImage.fromJson(snapshot.data);
  }

  Map<String, dynamic> get json =>
      {'url': url, 'width': width, 'height': height};

  static AppImage fromJson(json) {
    if (json == null) {
      return null;
    }

    final url = json['url'];
    final width =
        json['width'] == null ? 0.0 : double.parse(json['width'].toString());
    final height =
        json['height'] == null ? 0.0 : double.parse(json['height'].toString());
    return AppImage(url, height, width);
  }
}
