import 'dart:math';
import 'package:flutter/material.dart';
import 'package:timesget/models/worker.dart';
import 'package:timesget/services/app_utils.dart';

class AppFakes {
  static get companyImage => AssetImage('assets/img/HomeImage.jpg');

  static DateTime get initialDate => DateTime.utc(2000);

  static String get remoteBookingType => 'office';

  static Iterable<WorkerTime> generateRandomWorkerHours({int from, int till}) {
    final hours = AppUtils.generateHours(from: from, till: till);
    final r = Random();
    return hours.map((h) => WorkerTime(h.hour, h.minute, isFree: r.nextBool()));
  }
}
