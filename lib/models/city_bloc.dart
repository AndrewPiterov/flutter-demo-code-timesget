import 'dart:async';
import 'dart:math';
import 'package:camera/camera.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:timesget/models/booking.model.dart';
import 'package:timesget/models/charity.dart';
import 'package:timesget/models/city.dart';
import 'package:timesget/models/city_news.dart';
import 'package:timesget/models/company.dart';
import 'package:timesget/models/country.model.dart';
import 'package:timesget/models/user.model.dart';
import 'package:timesget/models/worker.dart';
import 'package:timesget/models/worker_specialization.dart';
import 'package:timesget/models/hot_offer.model.dart';
import 'package:timesget/models/promocode.dart';
import 'package:timesget/models/work_week.dart';
import 'package:timesget/services/company_service.dart';
import 'package:timesget/services/workers.service.dart';
import 'package:timesget/services/mobile_card.service.dart';
import 'package:timesget/services/preferenses.service.dart';
import 'package:rx_command/rx_command.dart';
import 'package:rxdart/rxdart.dart';
import 'package:location/location.dart';
import 'package:uuid/uuid.dart';

class ModelBloc {
  RxCommand<bool, bool> shouldRecieveNitificationSwitchChangedCommand;

  BehaviorSubject<Country> nextCountry = BehaviorSubject<Country>();
  BehaviorSubject<City> nextCity = BehaviorSubject<City>();

  // GETTERS
  City _currentCity;

  City get currentCity => _currentCity;

  Country _currentCountry;

  Country get currentCountry => _currentCountry;

  // Current location
  StreamSubscription<LocationData> _locationSubscription;
  ReplaySubject<LocationData> currentLocation = ReplaySubject();
  LocationData lastLocation;

  Location _location = new Location();
  List<CameraDescription> cameras;
  ReplaySubject<bool> hasLocationPermission = ReplaySubject();

  RxCommand<String, List<Worker>> updateWorkersByNameCommand;

  Stream<Company> get company$ => CompanyDataService().company$;

  ModelBloc(this.cameras) {
    print('>>>>>>>>>>>> City Bloc has been initialized');

    Firestore().settings().then((_) => print('firebase settings updated'));

    nextCountry.listen((country) {
      PrefsService.saveCountryPreference(country);
      _currentCountry = country;
    });

    nextCity.listen((city) {
      _currentCity = city;
      PrefsService.saveCityPreference(_currentCity);
    });

    PrefsService.getLastOpenPromocodeAt()
        .then((onValue) => this.promocodesHasBeenOpened.add(onValue));

    PrefsService.getLastOpenNewsAt()
        .then((onValue) => this.newsHasBeenOpened.add(onValue));

    PrefsService.getLastOpenCharitiesAt().then((onValue) {
      return this.charityHasBeenOpened.add(onValue);
    });

    company$.listen((company) {
      if (company == null) {
        return;
      }
      print('Company is ${company.name}');
    });

    nextCity.listen((city) async {
      _hotOffers = city == null
          ? Stream.empty()
          : _buildHotOffersStream(city).asBroadcastStream();
      _hotOffers.listen((onData) {
        _hotOfferCountSubject.add(onData.length);
        _hotOffersSubject.add(onData);
      });

      // news

      newsHasBeenOpened.listen((time) async {
        await PrefsService.lastOpenNewsAt(time);
      });

      _cityNews = city == null
          ? Stream.empty()
          : _buildCityNewsStream(city).asBroadcastStream();

      _cityNews.listen((onData) {
        _cityNewsSubject.add(onData);
      });

      Observable.combineLatest2(_cityNewsSubject, newsHasBeenOpened,
          (List<CityNews> news, DateTime lastOpen) {
        return news.where((x) => x.createdAt.toDate().isAfter(lastOpen)).length;
      }).listen((count) => hasUnreadNews.add(count));

      // mobile cards

      // promocodes

      promocodesHasBeenOpened.listen((time) async {
        await PrefsService.lastOpenPromocodeAt(time);
      });

      _cityPromocodes =
          city == null ? Stream.empty() : _buildCityPromocodesStream(city);

      _cityPromocodes.listen((onData) {
        _cityPromocodeSubject.add(onData);
      });

      Observable.combineLatest2(_cityPromocodeSubject, promocodesHasBeenOpened,
          (List<Promocode> promocodes, DateTime lastOpen) {
        return promocodes
            .where((x) => x.createdAt.toDate().isAfter(lastOpen))
            .length;
      }).listen((count) => hasUnreadPromocodes.add(count));

      // charities

      charityHasBeenOpened.listen((time) async {
        await PrefsService.lastOpenCharitiesAt(time);
      });

      _cityCharities =
          city == null ? Stream.empty() : _buildCharityStream(city);

      _cityCharities.listen((onData) {
        _cityCharitiesSubject.add(onData);
      });

      Observable.combineLatest2(_cityCharitiesSubject, charityHasBeenOpened,
          (List<Charity> charities, DateTime lastOpen) {
        final count = charities
            .where((x) => x.createdAt.toDate().isAfter(lastOpen))
            .length;
        print('New charities: $count');
        return count;
      }).listen((count) => hasUnreadCharities.add(count));

      // Total updates
      Observable.combineLatest4(
              hasUnreadNews,
              hasUnreadPromocodes,
              MobilCardService().hasUnreadMobileCards,
              hasUnreadCharities,
              (x, y, z, c) => x + y + z + c)
          .listen((onData) => hasMoreChanges.add(onData));
    });

    PrefsService.getCountryPreference().then((country) {
      nextCountry.add(country);
    });

    PrefsService.getCityPreferences().then((savedCity) {
      nextCity.add(savedCity);
    });

    // _workerLastNameController.stream.listen((lastName) {
    //   if (lastName == null || lastName.isEmpty) {
    //   } else {
    //     final filteredByLastName = _workersSubject
    //         // .where((x) =>
    //         //     x.fullName.toLowerCase().indexOf(lastName.toLowerCase()) > -1)
    //         .toList();

    //     _workersSubject.add([]);
    //   }
    // });

    try {
      _location.hasPermission().asStream().listen((onData) {
        hasLocationPermission.add(onData);
        print("Traking user' location is ${onData ? 'allowed' : 'denied'}.");
        if (onData) {
          try {
            _location.getLocation().then((onValue) {
              _locationSubscription =
                  _location.onLocationChanged().listen((LocationData result) {
                currentLocation.add(result);
                lastLocation = result;
                // print('Current location is $result.');
              });
            });
          } on Exception {
            currentLocation = null;
            print('Exception of Location Permission2.');
          }
        }
      });
    } on Exception {
      print('Exception of Location Permission1.');
    }

    fetchCountries();
  }

  reset() async {
    _currentCity = null;
    await PrefsService.reset();
    print('Bloc and Prefs has been cleaned.');
  }

  final _isLoadingSubject = BehaviorSubject<bool>.seeded(false);

  final _workerLastNameController = StreamController<String>();

  Sink<String> get workerLastName => _workerLastNameController.sink;

  getWorkersAndUpdate() async {
    _isLoadingSubject.add(true);
    _isLoadingSubject.add(false);
  }

  void logError(String code, String message) =>
      print('Error: $code\nError Message: $message');

  // --- Countries

  Stream<List<Country>> get countries => _countriesSubject.stream;
  final _countriesSubject =
      BehaviorSubject<List<Country>>.seeded(List<Country>());

  Future<List<Country>> fetchCountries() async {
    final res = await Firestore.instance.collection('countries').getDocuments();
    final list = res.documents.map((x) => Country.fromSnapshot(x)).toList();
    _countriesSubject.add(list..sort((a, b) => a.name.compareTo(b.name)));
    return list;
  }

  // ------- Worker In the City Collection

  // --- Get Bookings

  Stream<bool> get isBusyFetchBooking => _isBusyFetchBookingSubject.stream;
  final _isBusyFetchBookingSubject = BehaviorSubject<bool>.seeded(false);

  Future<List<Booking>> fetchBookings(Worker worker, Date date) async {
    _isBusyFetchBookingSubject.add(true);
    final res = await WorkerService.fetchBookings(worker, date);
    _isBusyFetchBookingSubject.add(false);
    return res;
  }

  // --- Booking

  Stream<bool> get isBusyBooking => _isBusyBookingSubject.stream;
  final _isBusyBookingSubject = BehaviorSubject<bool>.seeded(false);

  Future<String> book(AppUser user, String bookingType, Date date, Time time,
      Worker worker, String phone, String comment,
      {HotOffer hotOffer}) async {
    _isBusyBookingSubject.add(true);

    final durationInMinutes = CompanyDataService().timeCuttingMinutes;
    final endTime = time.add('minutes', durationInMinutes);

    final bookingDateTime =
        DateTime(date.year, date.month, date.day, time.hour, time.minute);


    final bookingId = "${Random().nextInt(1000)}_${Uuid().v1()}";
    final data = {
      'id': bookingId,
      'bookingType': bookingType,
      'dateTime': Timestamp.fromDate(bookingDateTime),
      'year': bookingDateTime.year,
      'month': bookingDateTime.month,
      'day': bookingDateTime.day,
      'startTime': time.label,
      'endTime': endTime.label,
      'hour': bookingDateTime.hour,
      'minute': bookingDateTime.minute,
      'durationInMinutes': durationInMinutes,
      'workerId': worker.id,
      'worker': worker.json(),
      'customerId': user.uid,
      'customer': user.asCustomerJson(phone),
      'isApproved': false,
      'approvedAt': null,
      'canceledByCustomer': false,
      'canceledByCustomerAt': null,
      'canceledByManagerAt': null,
      'comment': comment,
      'createdAt': Timestamp.now(),
      'hotAt': null,
      'hotOfferDiscount': hotOffer?.discount,
      'from':
          DateTime(date.year, date.month, date.day, time.hour, time.minute, 0)
              .millisecondsSinceEpoch,
      'till': DateTime(
              date.year, date.month, date.day, endTime.hour, endTime.minute, 0)
          .millisecondsSinceEpoch,
    };

    print('try book: $data');

    final bookingRef = Firestore.instance
        .collection('/workers/${worker.id}/bookings')
        .document(bookingId);

    if (hotOffer != null) {
      final res = await Firestore.instance.runTransaction((tx) async {
        await tx.delete(
            Firestore.instance.collection('hot-offers').document(hotOffer.id));

        await tx.set(bookingRef, data);
      });
      final x = res;
    } else {
      await bookingRef.setData(data);
    }

    _isBusyBookingSubject.add(false);
    return bookingRef.documentID;
  }

  // --- worker' commenting

  Stream<bool> get isBusyCommenting => _isBusyCommentingSubject.stream;
  final _isBusyCommentingSubject = BehaviorSubject<bool>.seeded(false);

  Future<String> sendReview(Worker worker, String customerEmail,
      String customerName, String text, int rating) async {
    _isBusyCommentingSubject.add(true);
    print('try comment...');

    final res =
        await Firestore.instance.collection('workers-unapproved-reviews').add({
      'workerId': worker.id,
      'worker': {
        'id': worker.id,
        'fullName': worker.fullName,
        'cityId': _currentCity.id
      },
      'customer': {'email': customerEmail, 'fullName': customerName},
      'text': text,
      'rating': rating,
      'reviewDate': DateTime.now()
    });

    _isBusyCommentingSubject.add(false);
    return res.documentID;
  }

  // --- Auction

  Stream<bool> get isBusyAuction => _isBusyAuctionSubject.stream;
  final _isBusyAuctionSubject = BehaviorSubject<bool>.seeded(false);

  Future<String> auction(
      WorkerSpecialization spec, String phone, String comment) async {
    _isBusyAuctionSubject.add(true);
    final auction = {
      'requiredSpecialization': {'id': spec.id, 'title': spec.title},
      'customer': {'fullName': null, 'phone': phone},
      'description': comment
    };

    final res =
        await Firestore.instance.collection('help-requests').add(auction);

    _isBusyAuctionSubject.add(false);

    return res.documentID;
  }

  // --- Hot Offers
  Stream<int> get hotOfferCount => _hotOfferCountSubject.stream;
  final _hotOfferCountSubject = BehaviorSubject<int>.seeded(0);

  Stream<List<HotOffer>> _hotOffers = Stream.empty();

  Stream<List<HotOffer>> get hotOffers => _hotOffersSubject.stream;
  BehaviorSubject<List<HotOffer>> _hotOffersSubject =
      BehaviorSubject<List<HotOffer>>.seeded(List<HotOffer>());

  Stream<List<HotOffer>> _buildHotOffersStream(City city) {
    return Firestore.instance
        .collection('hot-offers')
        .orderBy('dateTime')
        .where('dateTime', isGreaterThan: Timestamp.now())
        .snapshots()
        .map<List<HotOffer>>((snapshot) {
      if (snapshot.documents.length == 0) {
        return List<HotOffer>();
      }

      var list =
          snapshot.documents.map((doc) => HotOffer.fromSnapshot(doc)).toList();

      return list;
    });
  }

  Stream<List<CityNews>> _cityNews = Stream.empty();

  Stream<List<CityNews>> get cityNews => _cityNewsSubject.stream;
  BehaviorSubject<List<CityNews>> _cityNewsSubject =
      BehaviorSubject<List<CityNews>>.seeded(List<CityNews>());

  Stream<List<CityNews>> _buildCityNewsStream(City city) {
    return Firestore.instance
        .collection('news')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      if (snapshot.documents.length == 0) {
        return List<CityNews>();
      }

      var list = snapshot.documents
          .map((doc) => CityNews.fromSnapshot(doc))
          .where((x) =>
              x.endAt == null || x.endAt.toDate().isAfter(DateTime.now()))
          .toList();

      return list;
    });
  }

  BehaviorSubject<int> hasUnreadPromocodes = BehaviorSubject<int>.seeded(0);
  BehaviorSubject<int> hasUnreadNews = BehaviorSubject<int>.seeded(0);

  BehaviorSubject<int> hasUnreadCharities = BehaviorSubject<int>.seeded(0);

  // Workers
  // Stream<List<Worker>> _workers = Firestore.instance
  //     .collection('workers')
  //     .where('isDeleted', isEqualTo: false)
  //     .where('isDeactivated', isEqualTo: false)
  //     .orderBy('rating', descending: true)
  //     .snapshots()
  //     .map((sn) {
  //   if (sn.documents.isEmpty) {
  //     return List<Worker>();
  //   }

  //   final list = sn.documents.map((x) => Worker.fromJsonMap(x.data));

  //   return list.toList();
  // });

  // Stream<List<Worker>> get workers => _workersSubject.stream;
  // final _workersSubject = BehaviorSubject<List<Worker>>.seeded(List<Worker>());

  // Promocodes
  Stream<List<Promocode>> _cityPromocodes = Stream.empty();

  Stream<List<Promocode>> get cityPromocodes => _cityPromocodeSubject.stream;
  BehaviorSubject<List<Promocode>> _cityPromocodeSubject =
      BehaviorSubject<List<Promocode>>.seeded(List<Promocode>());

  Stream<List<Promocode>> _buildCityPromocodesStream(City city) {
    return Firestore.instance
        .collection('promocodes')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      if (snapshot.documents.length == 0) {
        return List<Promocode>();
      }

      final arr = snapshot.documents
          .map((x) => Promocode.fromSnapshot(x))
          .where((x) =>
              x.endAt == null || x.endAt.toDate().isAfter(DateTime.now()))
          .toList();

      return arr;
    });
  }

  // charity

  Stream<List<Charity>> _cityCharities = Stream.empty();

  Stream<List<Charity>> get cityCharities => _cityCharitiesSubject.stream;
  BehaviorSubject<List<Charity>> _cityCharitiesSubject =
      BehaviorSubject<List<Charity>>.seeded(List<Charity>());

  Stream<List<Charity>> _buildCharityStream(City city) {
    return Firestore.instance
        .collection('charities')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      if (snapshot.documents.length == 0) {
        return List<Charity>();
      }
      final arr = snapshot.documents
          .map((x) => Charity.fromSnapshot(x))
          .where((x) =>
              x.endAt == null || x.endAt.toDate().isAfter(DateTime.now()))
          .toList();

      return arr;
    });
  }

  // Page's last opened time

  BehaviorSubject<DateTime> promocodesHasBeenOpened =
      BehaviorSubject<DateTime>.seeded(null);

  BehaviorSubject<DateTime> charityHasBeenOpened =
      BehaviorSubject<DateTime>.seeded(null);

  BehaviorSubject<DateTime> newsHasBeenOpened =
      BehaviorSubject<DateTime>.seeded(null);

  // total More changes
  BehaviorSubject<int> hasMoreChanges = BehaviorSubject<int>.seeded(0);
}
