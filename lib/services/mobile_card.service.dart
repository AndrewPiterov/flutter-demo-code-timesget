import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:timesget/models/city.dart';
import 'package:timesget/models/mobile_card.dart';
import 'package:timesget/models/user.model.dart';
import 'package:timesget/services/auth.service.dart';
import 'package:timesget/services/preferenses.service.dart';
import 'package:timesget/services/result.dart';
import 'package:rxdart/rxdart.dart';

class MobilCardService {
  PublishSubject<bool> loading = PublishSubject();
  final Firestore _db = Firestore.instance;

  Stream<List<CardNumber>> _barcodes = Stream.empty();
  Stream<List<CardNumber>> get myBarcodes => _barcodesSubject.stream;
  BehaviorSubject<List<CardNumber>> _barcodesSubject =
      BehaviorSubject<List<CardNumber>>.seeded(List<CardNumber>());

  Stream<List<MobileCard>> _cityMobileCards = Stream.empty();

  BehaviorSubject<List<MobileCard>> _cityMobileCardsSubject =
      BehaviorSubject<List<MobileCard>>.seeded(List<MobileCard>());

  Stream<CardNumber> buildStreamForWaitSuccessChoosingNumber(
      MobileCard forCard, AppUser user) {
    return Firestore.instance
        .collection('mobile-card-numbers')
        .where('uid', isEqualTo: user.uid)
        .where('cardId', isEqualTo: forCard.id)
        .snapshots()
        .skipWhile((x) => x.documents.length == 0)
        .take(1)
        .map((snapshot) {
      if (snapshot.documents.length == 0) {
        return null;
      }
      final number = snapshot.documents
          .map((document) => CardNumber.fromSnapshot(document))
          .toList()
          .first;

      // print('Customer barcodes: ${arr.length}.');

      return number;
    });
  }

  Stream<List<MobileCard>> _allMobileCardStream(City city) {
    return Firestore.instance
        .collection('/mobile-cards')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      if (snapshot.documents.length == 0) {
        return List<MobileCard>();
      }
      final arr = snapshot.documents
          .map((document) => MobileCard.fromSnapshot(document))
          .where((x) =>
              x.endAt == null || x.endAt.toDate().isAfter(DateTime.now()))
          .toList();

      print('Mobile cards: ${arr.length}.');

      return arr;
    });
  }

  Stream<List<CardNumber>> _barcodesStream(AppUser user) {
    return Firestore.instance
        .collection('mobile-card-numbers')
        .where('uid', isEqualTo: user.uid)
        .snapshots()
        .map((snapshot) {
      if (snapshot.documents.length == 0) {
        return List<CardNumber>();
      }
      final arr = snapshot.documents
          .map((document) => CardNumber.fromSnapshot(document))
          .toList();

      print('Customer barcodes: ${arr.length}.');

      return arr;
    });
  }

  Future<AppResult> bindScannedBarcodeToUser(
      AppUser user, String barcode) async {
    loading.add(true);

    try {
      final snap = await _db
          .collection('/mobile-card-numbers')
          .where('value', isEqualTo: barcode)
          .limit(1)
          .getDocuments();

      if (snap.documents.length == 0) {
        return AppResult.fail(Errors.NotFound);
      }

      final cardNumber = CardNumber.fromSnapshot(snap.documents.first);
      if (cardNumber.hasOwner) {
        if (cardNumber.uid == user.uid) {
          return AppResult.fail(Errors.YouHaveAlreadyThisCardNumber);
        }

        return AppResult.fail(Errors.CardNumberHasOwner);
      }

      final allCardsSnap = await _db
          .collection('/mobile-card-numbers')
          .where('uid', isEqualTo: user.uid)
          .getDocuments();
      final allcards =
          allCardsSnap.documents.map((c) => CardNumber.fromSnapshot(c));
      if (allcards.any((c) => c.cardId == cardNumber.cardId)) {
        return AppResult.fail(Errors.AlreadyHasNumberInGroup);
      }

      await _db
          .collection('/mobile-card-numbers')
          .document(cardNumber.id)
          .setData({'uid': user.uid, 'email': user.email}, merge: true);
      return AppResult.ok();
    } catch (err) {
      print(err);
      throw (err);
    } finally {
      loading.add(false);
    }
  }

  static final MobilCardService _singleton = new MobilCardService._internal();

  factory MobilCardService() {
    return _singleton;
  }

  BehaviorSubject<int> hasUnreadMobileCards = BehaviorSubject<int>.seeded(0);

  BehaviorSubject<List<CustomerCard>> cards =
      BehaviorSubject<List<CustomerCard>>.seeded([]);

  BehaviorSubject<DateTime> mobilcardsHasBeenOpened =
      BehaviorSubject<DateTime>.seeded(null);

  // Constractor
  MobilCardService._internal() {
    PrefsService.getLastOpenMobilCardsAt()
        .then((onValue) => this.mobilcardsHasBeenOpened.add(onValue));

    _cityMobileCards = _allMobileCardStream(null).asBroadcastStream();
    _cityMobileCards.listen((onData) {
      _cityMobileCardsSubject.add(onData);
    });

    AuthService().profile.listen((user) {
      if (user == null) {
        // add empty list when user is null
        _barcodes = Stream.empty();
        _barcodesSubject.add([]);
      } else {
        _barcodes = _barcodesStream(user).asBroadcastStream();
        _barcodes.listen((onData) {
          _barcodesSubject.add(onData);
        });
      }
    });

    Observable.combineLatest2(_cityMobileCardsSubject, mobilcardsHasBeenOpened,
        (List<MobileCard> cards, DateTime lastOpen) {
      final count = cards
          .where((x) =>
              x.hasFreeNumbers &&
              !x.onlyScan &&
              x.createdAt.toDate().isAfter(lastOpen))
          .length;
      print('New mobile cards: $count');
      return count;
    }).listen((count) => hasUnreadMobileCards.add(count));

    // Customer Cards
    Observable.combineLatest2(_cityMobileCardsSubject, _barcodesSubject,
        (List<MobileCard> cards, List<CardNumber> numbers) {
      final list = List<CustomerCard>();

      for (var c in cards) {
        final onlyScan = c.onlyScan;

        final barcode =
            numbers.firstWhere((x) => x.cardId == c.id, orElse: () => null);

        if (onlyScan && barcode == null) {
          continue;
        }

        list.add(CustomerCard(c, barcode: barcode));
      }

      final filtered = list.where((x) =>
          x.card.hasFreeNumbers ||
          x.barcode !=
              null); // has free numbers to choose or already has a card

      return filtered.toList()
        ..sort((a, b) =>
            (a.barcode == null ? 1 : 0).compareTo(b.barcode == null ? 1 : 0));
    }).listen((list) => cards.add(list));

    mobilcardsHasBeenOpened.listen((time) async {
      await PrefsService.lastOpenMobileCardsAt(time);
    });
  }

  Future<void> requestNumber(MobileCard forCard, AppUser customer) async {
    final data = {'uid': customer.uid, 'requestAt': Timestamp.now()};

    return await Firestore.instance
        .collection('mobile-cards')
        .document(forCard.id)
        .collection('number-requests')
        .document(customer.uid)
        .setData(data, merge: true);
  }
}
