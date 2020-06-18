import 'dart:async';
import 'package:timesget/models/city.dart';
import 'package:timesget/models/country.model.dart';
import 'package:timesget/models/fakes.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PrefsService {
  static String _cityKey = 'city';

  static Future<Null> reset() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }

  static Future<bool> isApproved() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('isApproved') ?? false;
  }

  static Future<bool> approve() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isApproved', true);
    return true;
  }

  static Future<bool> disallowNotifications({bool setMode = false}) async {
    final prefs = await SharedPreferences.getInstance();
    const key = "isNotificationAllowed";
    if (setMode) {
      await prefs.setString(key, 'false');
    } else {
      final c = prefs.get(key);
      return c == 'false';
    }

    return true;
  }

  static Future<bool> allowNotifications({bool setMode = false}) async {
    final prefs = await SharedPreferences.getInstance();
    const key = "isNotificationAllowed";
    if (setMode) {
      await prefs.setString(key, 'true');
    } else {
      final c = prefs.get(key);
      return c == null || c == 'true';
    }

    return true;
  }

  static Future<City> saveCityPreference(City city) async {
    final prefs = await SharedPreferences.getInstance();
    if (city == null) {
      await prefs.remove(_cityKey);
    } else {
      await prefs.setString(_cityKey, '${city.id},${city.name}');
    }
    print('Current City now is ${city?.name}');
    return city;
  }

  static Future<Null> saveCountryPreference(Country country) async {
    final prefs = await SharedPreferences.getInstance();

    if (country == null) {
      await prefs.remove('country');
    } else {
      await prefs.setString(
          'country', '${country.code}-${country.name}-${country.cur}');
    }

    print('Country now is is ${country?.code}');
  }

  static Future<Country> getCountryPreference() async {
    final prefs = await SharedPreferences.getInstance();
    final c = prefs.get('country');

    if (c == null) {
      return null;
    }

    final parts = c.toString().split('-');
    return Country(parts[0], parts[1], parts[2]);
  }

  static Future<String> setFsmToken(String fsmToken) async {
    final prefs = await SharedPreferences.getInstance();
    if (fsmToken == null) {
      await prefs.remove('fsm-token');
    } else {
      await prefs.setString('fsm-token', fsmToken);
    }
    return fsmToken;
  }

  static Future<String> getFsmToken() async {
    final prefs = await SharedPreferences.getInstance();
    final val = prefs.getString('fsm-token');
    if (val == null || val.isEmpty) {
      return null;
    }
    return val;
  }

  static Future<City> getCityPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    final val = prefs.getString(_cityKey);
    if (val == null || val.isEmpty) {
      return null;
    }
    final arr = val.split(',');
    final city = City(arr[0], arr[1], arr[0].split('_')[0]);
    return city;
  }

  // News

  static Future<DateTime> lastOpenNewsAt(DateTime time) async {
    final prefs = await SharedPreferences.getInstance();
    if (time == null) {
      await prefs.remove('news-has-been-opened-at');
      print('last opened news time was clean.');
    } else {
      await prefs.setString('news-has-been-opened-at', time.toIso8601String());
      print('last opened news time is ${time.toIso8601String()}.');
    }
    return time;
  }

  static Future<DateTime> getLastOpenNewsAt() async {
    final prefs = await SharedPreferences.getInstance();
    final val = prefs.getString('news-has-been-opened-at');
    if (val == null || val.isEmpty) {
      return AppFakes.initialDate;
    }
    return DateTime.parse(val);
  }

  // Mobile cards

  static Future<DateTime> lastOpenMobileCardsAt(DateTime time) async {
    final prefs = await SharedPreferences.getInstance();
    if (time == null) {
      await prefs.remove('mobilecards-has-been-opened-at');
      print('last opened mobilecards time was clean.');
    } else {
      await prefs.setString(
          'mobilecards-has-been-opened-at', time.toIso8601String());
      print('last opened mobilecards time is ${time.toIso8601String()}.');
    }
    return time;
  }

  static Future<DateTime> getLastOpenMobilCardsAt() async {
    final prefs = await SharedPreferences.getInstance();
    final val = prefs.getString('mobilecards-has-been-opened-at');
    if (val == null || val.isEmpty) {
      return AppFakes.initialDate;
    }
    return DateTime.parse(val);
  }

  // Promocodes

  static Future<DateTime> lastOpenPromocodeAt(DateTime time) async {
    final prefs = await SharedPreferences.getInstance();
    if (time == null) {
      await prefs.remove('promocodes-has-been-opened-at');
      print('last opened promocode\'s time was clean.');
    } else {
      await prefs.setString(
          'promocodes-has-been-opened-at', time.toIso8601String());
      print('last opened promocode\'s time is ${time.toIso8601String()}.');
    }
    return time;
  }

  static Future<DateTime> getLastOpenPromocodeAt() async {
    final prefs = await SharedPreferences.getInstance();
    final val = prefs.getString('promocodes-has-been-opened-at');
    if (val == null || val.isEmpty) {
      return AppFakes.initialDate;
    }
    return DateTime.parse(val);
  }

  // charities

  static Future<DateTime> lastOpenCharitiesAt(DateTime time) async {
    final prefs = await SharedPreferences.getInstance();
    if (time == null) {
      await prefs.remove('charities-has-been-opened-at');
      print('last opened charities\'s time was clean.');
    } else {
      await prefs.setString(
          'charities-has-been-opened-at', time.toIso8601String());
      print('last opened charities\'s time is ${time.toIso8601String()}.');
    }
    return time;
  }

  static Future<DateTime> getLastOpenCharitiesAt() async {
    final prefs = await SharedPreferences.getInstance();
    final val = prefs.getString('charities-has-been-opened-at');
    if (val == null || val.isEmpty) {
      return AppFakes.initialDate;
    }
    return DateTime.parse(val);
  }

  // User

  static Future<String> setCurrentUserId(String uid) async {
    final prefs = await SharedPreferences.getInstance();

    if (uid == null || uid == '') {
      await prefs.remove('uid');
      return null;
    }

    await prefs.setString('uid', uid);
    return uid;
  }

  static Future<String> getCurrentUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return await prefs.get('uid');
  }
}
