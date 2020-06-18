import 'package:flutter/foundation.dart';
import 'package:timesget/models/work_week.dart';
import 'package:timesget/models/worker.dart';

class BookingDataRequest {
  final Worker worker;
  final Date date;
  final Time time;

  bool get isComplete =>
      this.worker != null && this.date != null && this.time != null;

  bool get isNotComplete => !isComplete;

  BookingDataRequest(
      {@required this.worker, @required this.date, @required this.time});

  @override
  String toString() {
    return '($worker) on $date at $time';
  }
}
