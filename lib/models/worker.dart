import 'dart:core';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:timesget/models/address.dart';
import 'package:timesget/models/app_image.dart';
import 'package:timesget/models/worker_specialization.dart';
import 'package:timesget/models/model_mapper.dart';
import 'package:timesget/models/work_week.dart';

class Worker {
  final String id;
  final last;
  final first;
  final surname;
  String get fullName => '$last $first $surname'.trim();
  final List<Address> address;
  final WorkWeek workWeek;
  final double rating;

  String get addressDescription {
    if (address.isEmpty) {
      return '';
    }

    if (address.length == 1) {
      return address.first.address;
    }

    return address.map((a) => a.address).reduce((x, y) => '$x, $y');
  }

  String get specializationsDescription {
    if (specializations.isEmpty) {
      return '';
    }

    if (specializations.length == 1) {
      return specializations.first.title;
    }
    return specializations
        .map((x) => x.title)
        .reduce((x, y) => '$x, $y')
        .toString();
  }

  final List<WorkerSpecialization> specializations;
  final int worksSince;
  int get workYears => DateTime.now().year - worksSince;
  final int commentCount;
  final AppImage photo;
  String get image => photo != null ? photo.url : null;
  final String about;
  final double hourRateSalary;
  final int order;

  Worker(
      {this.id,
      this.last,
      this.first,
      this.surname,
      this.address,
      this.specializations,
      this.worksSince,
      // this.stars,
      this.commentCount,
      this.photo,
      this.about,
      this.hourRateSalary,
      this.workWeek,
      this.rating,
      this.order});

  Map<String, dynamic> json({withDescription = false, withWorkWeek = false}) {
    final json = {
      'id': id,
      'last': last,
      'first': first,
      'surname': surname,
      'photo': photo == null ? null : photo.json,
      'addresses': address.map((x) => x.json).toList(),
      'commentCount': commentCount,
      'hourRateSalary': hourRateSalary,
      'rating': rating,
      'specializations': specializations.map((x) => x.json).toList(),
      'worksSince': worksSince
    };

    if (withDescription) {
      json['description'] = about;
    }

    if (withWorkWeek) {
      throw ("'With Work Week' Not implemented!");
    }

    return json;
  }

  static Worker fromSnapshot(DocumentSnapshot snapshot) {
    return Worker.fromJsonMap(snapshot.data);
  }

  static Worker fromJsonMap(Map<String, dynamic> json) {
    final id = json['id'];
    final about = json['description'] == null ? '' : json['description'];
    final salary = _hourRateSalary(json);
    final worksSince =
        json['worksSince'] == null ? DateTime.now().year : json['worksSince'];
    final specs = _specs(json);
    final addresses = _address(json);
    final photo = AppImage.fromJson(json['photo']);
    final wweek = ModelMapper.workWeek(json);
    final commentCount = json['commentCount'] ?? 0;
    final rating =
        json['rating'] == null ? .0 : double.parse(json['rating'].toString());
    final order = json['order'] ?? 99999;

    final d = Worker(
        id: id,
        last: json['last'],
        first: json['first'],
        surname: json['surname'],
        about: about,
        hourRateSalary: salary,
        worksSince: worksSince,
        specializations: specs,
        address: addresses,
        photo: photo,
        workWeek: wweek,
        rating: rating,
        commentCount: commentCount,
        order: order);
    return d;
  }

  static List<Address> _address(Map<String, dynamic> json) {
    final val = json['addresses'];
    if (val == null || (val is Iterable && val.length == 0)) {
      return [];
    }
    final res = (val as Iterable).map((x) => Address.fromJsonMap(x)).toList();
    return res;
  }

  static List<WorkerSpecialization> _specs(Map<String, dynamic> json) {
    final val = json['specializations'];

    if (val == null || (val is Iterable && (val).length == 0)) {
      return List<WorkerSpecialization>();
    }

    var res = (val as Iterable).map((x) => WorkerSpecialization.fromJsonMap(x));
    return res.toList();
  }

  static double _hourRateSalary(Map<String, dynamic> json) {
    final val = json['hourRateSalary'];
    if (val == null) {
      return null;
    }

    return val / 1;
  }

  @override
  String toString() {
    return '$fullName';
  }
}

class WorkerTime {
  final int hour;
  final int minute;
  final bool isFree;

  WorkerTime(this.hour, this.minute, {this.isFree = true});

  Time get time => Time(hour: hour, minute: minute);

  @override
  String toString() => '$hour:$minute is ${isFree ? "free" : "busy"}';
}
