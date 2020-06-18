import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:timesget/models/address.dart';
import 'package:timesget/models/app_image.dart';
import 'package:timesget/models/company_specialization.dart';
import 'package:timesget/models/company_type.dart';
import 'package:timesget/models/model_mapper.dart';
import 'package:timesget/models/work_week.dart';

class SocialMediaLinks {
  final String instagram;
  final String facebook;
  final String youTube;
  final String vk;
  final String ok;

  get isEmpty {
    return _isNullOrEmpty(instagram) &&
        _isNullOrEmpty(facebook) &&
        _isNullOrEmpty(youTube) &&
        _isNullOrEmpty(vk) &&
        _isNullOrEmpty(ok);
  }

  _isNullOrEmpty(String val) {
    return val == null || val == "";
  }

  SocialMediaLinks(
      {this.instagram, this.facebook, this.youTube, this.vk, this.ok});

  static SocialMediaLinks from(DocumentSnapshot ds) {
    const String key = "socialMediaLinks";
    if (!ds.data.containsKey(key)) {
      return SocialMediaLinks();
    }

    final data = ds.data[key];

    return SocialMediaLinks(
      instagram: data["instagram"],
      facebook: data["facebook"],
      youTube: data["youTube"],
      vk: data["vk"],
      ok: data["ok"],
    );
  }
}

class Company {
  final String id;
  final String name;
  final AppImage preview;
  final String shortDescription;
  final String longDescription;
  final String address;
  final int order;

  final AppImage aboutWorkImage;
  final String aboutWorkText;

  final String rulesUrl;
  final String privacyUrl;

  final List<Address> addresses;

  final WorkWeek workWeek;

  final List<CompanySpecialization> specs;
  final List<CompanyType> types;

  final bool isVip;
  final DateTime deactivatedAt;
  final DateTime deletedAt;

  String get specsTitle {
    if (specs.length == 0) {
      return '';
    }
    final titles = specs.map((x) => x.title).reduce((x, y) => '$x, $y');
    return titles;
  }

  final SocialMediaLinks links;

  Company(this.id, this.name, this.preview, this.longDescription,
      {this.address = '',
      this.shortDescription,
      this.isVip,
      this.order,
      this.links,
      this.aboutWorkImage,
      this.aboutWorkText = '',
      this.rulesUrl = '',
      this.privacyUrl = '',
      this.specs = const [],
      this.types = const [],
      this.workWeek,
      this.timeCuttingInterval = 60,
      this.addresses = const [],
      this.deactivatedAt,
      this.deletedAt});

  final int timeCuttingInterval;

  static Company from(DocumentSnapshot ds) {
    final preview =
        ds['preview'] == null ? null : AppImage.fromJson(ds['preview']);
    final isVip = ds.data['isVip'];
    final order = ds.data['order'] ?? 999999;
    final deactivatedAt = ds.data['deactivatedAt'];
    final deletedAt = ds.data['deletedAt'];

    final aboutWorkImage = ds['aboutWorkImage'] == null
        ? null
        : AppImage.fromJson(ds['aboutWorkImage']);
    final aboutWorkText = ds.data['aboutWorkText'];

    final rulesUrl = ds['rulesUrl'];
    final privacyUrl = ds['privacyUrl'];

    final links = SocialMediaLinks.from(ds);

    return Company(ds["id"], ds["name"], preview, ds['longDescription'],
        shortDescription: ds['shortDescription'],
        address: ds['address'],
        specs: _specializationList(ds),
        types: _typeList(ds),
        workWeek: ModelMapper.workWeek(ds.data),
        timeCuttingInterval: ds.data.containsKey('timeCuttingInterval')
            ? ds.data['timeCuttingInterval']
            : 60,
        addresses: _addresses(ds.data),
        isVip: isVip,
        order: order,
        links: links,
        aboutWorkImage: aboutWorkImage,
        aboutWorkText: aboutWorkText,
        rulesUrl: rulesUrl,
        privacyUrl: privacyUrl,
        deletedAt: deletedAt,
        deactivatedAt: deactivatedAt);
  }

  static List<Address> _addresses(Map<String, dynamic> json) {
    if (!json.containsKey('addresses')) {
      return List<Address>();
    }

    final arr = (json['addresses'] as Iterable)
        .map((x) => Address.fromJsonMap(x))
        .toList();
    return arr;
  }

  static List<CompanySpecialization> _specializationList(
      DocumentSnapshot snapshot) {
    final prop = snapshot['specializations'];
    if (prop == null || (prop is Iterable && prop.isEmpty)) {
      return [];
    }

    final res = (prop as Iterable)
        .map((x) => CompanySpecialization(x['id'], x['title']))
        .toList();
    return res;
  }

  static List<CompanyType> _typeList(DocumentSnapshot snapshot) {
    final prop = snapshot['types'];
    if (prop == null || (prop is Iterable && prop.isEmpty)) {
      return [];
    }

    final res = (prop as Iterable)
        .map((x) => CompanyType(x['id'], x['title']))
        .toList();
    return res;
  }
}
