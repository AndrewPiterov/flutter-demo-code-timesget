import 'dart:async';
import 'package:timesget/models/city.dart';
import 'package:timesget/services/preferenses.service.dart';

class AppRepo{
  Future<City> getCity() async {
    var city = await PrefsService.getCityPreferences();
    return city;
  }
}