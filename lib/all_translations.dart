import 'dart:async';
import 'dart:convert';
import 'dart:ui';
import 'package:flutter/services.dart';
import 'package:timesget/models/language.model.dart';
import 'package:shared_preferences/shared_preferences.dart';

List<Language> get allLanguages => _supportedLanguages;

///
/// Preferences related
///
const String _storageKey = "newdoc_";

final List<Language> _supportedLanguages = [
  // Language('ar', 'عربي', rtl: true),
  // Language('en', 'English'),
  Language('ru', 'Русский', rtl: false),
];

Future<SharedPreferences> _prefs = SharedPreferences.getInstance();

class GlobalTranslations {
  Locale _locale;
  Map<dynamic, dynamic> _localizedValues;
  VoidCallback _onLocaleChangedCallback;

  ///
  /// Returns the list of supported Locales
  ///
  Iterable<Locale> supportedLocales() =>
      _supportedLanguages.map<Locale>((lang) => Locale(lang.id, ''));

  ///
  /// Returns the translation that corresponds to the [key]
  ///
  String text(String key) {
    if (_localizedValues == null) {
      return '** $key not found';
    }

    final path = key.split('.').toList();
    var node = _localizedValues;
    for (var p in path) {
      if (node[p] is Map) {
        node = node[p];
      }
    }

    final val = node[path.last] ?? '** $key not found';
    return val.toString();
  }

  String concatText(List<String> path) {
    var key = path[0];
    for (final p in path.skip(1)) {
      key += '.$p';
    }
    return text(key);
  }

  TextDirection get dir =>
      _supportedLanguages.firstWhere((l) => l.id == _locale.languageCode).rtl
          ? TextDirection.rtl
          : TextDirection.ltr;

  ///
  /// Returns the current language code
  ///
  String get currentLanguage => _locale == null ? '' : _locale.languageCode;

  Language get currentLang =>
      allLanguages.firstWhere((x) => x.id == currentLanguage);

  ///
  /// Returns the current Locale
  ///
  get locale => _locale;

  ///
  /// One-time initialization
  ///
  Future<Null> init([String language]) async {
    if (_locale == null) {
      await setNewLanguage(language);
    }
    return null;
  }

  /// ----------------------------------------------------------
  /// Method that saves/restores the preferred language
  /// ----------------------------------------------------------
  getPreferredLanguage() async {
    return _getApplicationSavedInformation('language');
  }

  setPreferredLanguage(String lang) async {
    return _setApplicationSavedInformation('language', lang);
  }

  ///
  /// Routine to change the language
  ///
  Future<Null> setNewLanguage(
      [String newLanguage, bool saveInPrefs = true]) async {
    String language = newLanguage;
    if (language == null) {
      language = await getPreferredLanguage();
    }

    // Set the locale
    if (language == "") {
      language = "ru";
    }
    _locale = Locale(language, "");

    final langFile = "locale/${_locale.languageCode}.json";

    // Load the language strings
    String jsonContent = await rootBundle.loadString(langFile);
    _localizedValues = json.decode(jsonContent);

    // If we are asked to save the new language in the application preferences
    if (saveInPrefs) {
      await setPreferredLanguage(language);
    }

    // If there is a callback to invoke to notify that a language has changed
    if (_onLocaleChangedCallback != null) {
      _onLocaleChangedCallback();
    }

    return null;
  }

  Future<Null> setNewLang(
      [Language newLanguage, bool saveInPrefs = true]) async {
    return await setNewLanguage(newLanguage.id, saveInPrefs);
  }

  ///
  /// Callback to be invoked when the user changes the language
  ///
  set onLocaleChangedCallback(VoidCallback callback) {
    _onLocaleChangedCallback = callback;
  }

  ///
  /// Application Preferences related
  ///
  /// ----------------------------------------------------------
  /// Generic routine to fetch an application preference
  /// ----------------------------------------------------------
  Future<String> _getApplicationSavedInformation(String name) async {
    final SharedPreferences prefs = await _prefs;

    return prefs.getString(_storageKey + name) ?? '';
  }

  /// ----------------------------------------------------------
  /// Generic routine to saves an application preference
  /// ----------------------------------------------------------
  Future<bool> _setApplicationSavedInformation(
      String name, String value) async {
    final SharedPreferences prefs = await _prefs;

    return prefs.setString(_storageKey + name, value);
  }

  ///
  /// Singleton Factory
  ///
  static final GlobalTranslations _translations =
      GlobalTranslations._internal();
  factory GlobalTranslations() {
    return _translations;
  }
  GlobalTranslations._internal();
}

GlobalTranslations allTranslations = GlobalTranslations();
