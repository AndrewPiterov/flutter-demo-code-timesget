import 'package:latlong/latlong.dart';

class Address {
  String address;
  double lat;
  double lng;
  String phoneNumber;

  LatLng get loc => LatLng(lat, lng);

  Address(this.address, this.phoneNumber, this.lat, this.lng);

  Map<String, dynamic> get json => {'address': address, 'tel': phoneNumber};

  // static Address fromSnapshot(DocumentSnapshot snapshot) {}

  static Address fromJsonMap(Map<dynamic, dynamic> json) {
    final address = json['address'];
    final lat =
        json.containsKey('lat') ? double.parse(json['lat'].toString()) : 0.0;
    final lng =
        json.containsKey('lon') ? double.parse(json['lon'].toString()) : 0.0;
    final phone = json.containsKey('tel') ? json['tel'].toString() : '';

    return Address(address, phone, lat, lng);
  }
}
