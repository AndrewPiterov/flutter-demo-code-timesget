import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:rxdart/rxdart.dart';
import 'package:timesget/models/address.dart';
import 'package:timesget/models/company.dart';

class CompanyDataService {
  BehaviorSubject<Company> _companySubject =
      BehaviorSubject<Company>.seeded(null);

// Contacts
  Stream<List<Address>> get companyContacts$ =>
      _companyContactsSubject.asBroadcastStream();
  BehaviorSubject<List<Address>> _companyContactsSubject =
      BehaviorSubject<List<Address>>.seeded([]);

// Social links
  Stream<SocialMediaLinks> get socialMediaLinks$ =>
      _socialMediaLinksSubject.asBroadcastStream();
  BehaviorSubject<SocialMediaLinks> _socialMediaLinksSubject =
      BehaviorSubject<SocialMediaLinks>.seeded(SocialMediaLinks());

  Stream<Company> get company$ => _companySubject.stream;

  Company _company;

  int get timeCuttingMinutes {
    return _company == null ? 60 : _company.timeCuttingInterval;
  }

  CompanyDataService._internal() {
    // init things inside this
    Firestore.instance
        .collection('detail')
        .document("1")
        .snapshots()
        .map((snapshot) => !snapshot.exists ? null : Company.from(snapshot))
        .listen((company) {
      _company = company;
      _companySubject.add(company);
      _socialMediaLinksSubject.add(company.links);
      _companyContactsSubject.add(company.addresses);

      print('... company has been fetched  IN SINGLETON...');
    });
  }

  static final CompanyDataService _instance = CompanyDataService._internal();
  factory CompanyDataService() => _instance;
}
