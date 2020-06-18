import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:rxdart/rxdart.dart';
import 'package:timesget/models/booking.model.dart';
import 'package:timesget/models/user.model.dart';
import 'package:timesget/services/auth.service.dart';

class UserService {
  Stream<List<UserBooking>> bookings$;
  BehaviorSubject<List<UserBooking>> _bookings;

  Stream<int> futureBookingCount$;
  Stream<List<UserBooking>> futuredBookings$;

  BehaviorSubject<List<UserBooking>> _passedBookings;

  final int _perPage = 3;

  Stream<bool> _onUpdates;
  Stream<bool> _buildOnUpdatesStream(AppUser user) {
    return Firestore.instance
        .collection('mobile-users')
        .document(user.uid)
        .collection('bookings')
        // .orderBy('dateTime', descending: true)
        // .where('dateTime', isLessThanOrEqualTo: Timestamp.now())
        .limit(1)
        .snapshots()
        .map((snapshot) => true);
  }

  Stream<List<UserBooking>> _buildFuturedBookingsStream(AppUser user) {
    return Firestore.instance
        .collection('mobile-users')
        .document(user.uid)
        .collection('bookings')
        .where('dateTime', isGreaterThan: Timestamp.now())
        .orderBy('dateTime')
        // all .limit(_perPage)
        .snapshots()
        .map((snap) {
      final all =
          snap.documents.map((doc) => UserBooking.fromSnapshot(doc)).toList();

      final canceled = all.where((x) => x.canceled);
      final notCanceled = all.where((x) => !x.canceled);
      return [...notCanceled, ...canceled.toList().reversed];
    });
  }

  List<UserBooking> _cachedUserBookings = [];
  Stream<bool> isBusy$;
  BehaviorSubject<bool> _isBusy;

  DocumentSnapshot _lastDocument;

  getPassedBookings(AppUser user) async {
    _cachedUserBookings = [];
    _isBusy.add(true);
    Query q = Firestore.instance
        .collection('mobile-users')
        .document(user.uid)
        .collection('bookings')
        .orderBy('dateTime', descending: true)
        .where('dateTime', isLessThanOrEqualTo: Timestamp.now())
        .limit(_perPage);

    QuerySnapshot snap = await q.getDocuments();
    _lastDocument = snap.documents.isEmpty
        ? null
        : snap.documents[snap.documents.length - 1];

    _addToCache(snap.documents);
    print('Loaded first passed ${snap.documents.length} bookings');

    _isBusy.add(false);
  }

  getMorePassedBookings(AppUser user) async {
    if (_lastDocument == null) {
      return;
    }

    if (_isBusy.value) {
      return;
    }

    print('TRY TO GET MORE ITEMS');
    _isBusy.add(true);

    Query q = Firestore.instance
        .collection('mobile-users')
        .document(user.uid)
        .collection('bookings')
        .orderBy('dateTime', descending: true)
        .where('dateTime', isLessThanOrEqualTo: Timestamp.now())
        .startAfterDocument(_lastDocument)
        .limit(_perPage);

    QuerySnapshot snap = await q.getDocuments();
    _lastDocument = snap.documents.isEmpty
        ? null
        : snap.documents[snap.documents.length - 1];

    if (snap.documents.isNotEmpty) {
      print('LOADED MORE PASSED ${snap.documents.length} bookings');
      _addToCache(snap.documents);
    }

    _isBusy.add(false);
  }

  _addToCache(List<DocumentSnapshot> documents) {
    _cachedUserBookings.addAll(documents
        .map((doc) => UserBooking.fromSnapshot(doc))
        .where((x) => !_cachedUserBookings.any((y) => y.id == x.id))
        .toList());
    _passedBookings.add(_cachedUserBookings);
  }

  static final UserService _singleton = UserService._();

  factory UserService() {
    return _singleton;
  }

  UserService._() {
    _bookings = BehaviorSubject<List<UserBooking>>.seeded([]);
    _passedBookings = BehaviorSubject<List<UserBooking>>.seeded([]);
    bookings$ = _bookings.stream;

    futuredBookings$ = bookings$.map((x) => x
        .where(
            (b) => !b.canceled && b.dateTime.toDate().isAfter(DateTime.now()))
        .toList());

    futureBookingCount$ = futuredBookings$.map((x) => x.length);

    _isBusy = BehaviorSubject.seeded(false);
    isBusy$ = _isBusy.stream;

    _onUpdates = Stream<bool>.empty();

    AuthService().profile.listen((user) {
      if (user != null) {
        _onUpdates = this._buildOnUpdatesStream(user);

        _onUpdates.listen((_) {
          getPassedBookings(user);

          Observable.combineLatest2<List<UserBooking>, List<UserBooking>,
                  List<UserBooking>>(
              _buildFuturedBookingsStream(user), _passedBookings,
              (futured, passed) {
            return [...futured, ...passed];
          }).listen((bookings) {
            _bookings.add(bookings);
          });
        });
      } else {
        _onUpdates = Stream<bool>.empty();
        this._bookings.add([]);
      }
    });
  }
}
