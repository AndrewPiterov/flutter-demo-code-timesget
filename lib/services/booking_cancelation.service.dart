import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:rxdart/rxdart.dart';
import 'package:timesget/models/booking.model.dart';

class BookingCancelService {
  Stream<bool> isBusy$;
  BehaviorSubject<bool> _isBusy;

  Future<bool> cancel(String userId, UserBooking booking) async {
    _isBusy.add(true);

    await Firestore.instance
        .collection('workers')
        .document(booking.worker.id)
        .collection('bookings')
        .document(booking.id)
        .setData({
      'canceledByCustomerAt': Timestamp.now(),
      'canceledByCustomer': true
    }, merge: true);

    _isBusy.add(false);
    return true;
  }

  static final BookingCancelService _singleton = BookingCancelService._();

  factory BookingCancelService() {
    return _singleton;
  }

  BookingCancelService._() {
    _isBusy = BehaviorSubject<bool>.seeded(false);
    isBusy$ = _isBusy.stream;
  }
}
