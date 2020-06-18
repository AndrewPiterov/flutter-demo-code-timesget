import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:timesget/models/work_week.dart';
import 'package:timesget/models/worker.dart';

class Booking {
  TimeRange range;
  int durationInMinutes;

  Booking(this.range, this.durationInMinutes);

  static Booking fromSnapshot(DocumentSnapshot snap) {
    return fromJsonMap(snap.data);
  }

  static Booking fromJsonMap(Map<String, dynamic> json) {
    final start = Time.fromStr(json['startTime']);
    final end = Time.fromStr(json['endTime']);
    final dur = json['durationInMinutes'];

    final range = TimeRange(start: start, end: end);
    if (range.durationInMinutes != dur) {
      print(
          'Error: Durations are not equal: ${range.durationInMinutes} != dur');
    }

    return Booking(range, dur);
  }

  bool isCross(TimeRange another) => range.isCross(another);
}

class UserBooking {
  final String id;

  final Worker worker;

  final Timestamp dateTime;
  final Time time;

  final Timestamp approvedAt;

  final Timestamp canceledByCustomerAt;
  final Timestamp canceledByManagerAt;

  bool get canceled {
    return canceledByCustomerAt != null || canceledByManagerAt != null;
  }

  final num discount;

  final TimeRange range;

  UserBooking(this.id, this.dateTime, this.worker, this.time, this.range,
      this.approvedAt, this.canceledByCustomerAt, this.canceledByManagerAt,
      {this.discount = 0});

  static UserBooking fromSnapshot(DocumentSnapshot snap) {
    return fromJsonMap(snap.documentID, snap.data);
  }

  static UserBooking fromJsonMap(String id, Map<String, dynamic> data) {
    final ts = data['dateTime'];
    final start = Time.fromStr(data['startTime']);
    final end = Time.fromStr(data['endTime']);
    final dur = data['durationInMinutes'];

    final approvedAt = data['approvedAt'];
    final cc = data['canceledByCustomerAt'];
    final cm = data['canceledByManagerAt'];
    final canceledByCustomer = cc == null ? null : cc;
    final canceledByManager = cm == null ? null : cm;

    final discount = data['discount'];

    final range = TimeRange(start: start, end: end);
    if (range.durationInMinutes != dur) {
      print(
          'Error: Durations are not equal: ${range.durationInMinutes} != dur');
    }

    final w = Map<String, dynamic>.from(data['worker']);
    final worker = Worker.fromJsonMap(w);

    return UserBooking(id, ts, worker, start, range, approvedAt,
        canceledByCustomer, canceledByManager,
        discount: discount);
  }
}
