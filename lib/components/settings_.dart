import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:timesget/all_translations.dart';
import 'package:timesget/components/dd_button_bordered.dart';
import 'package:timesget/models/city.dart';
import 'package:timesget/models/city_provider.dart';
import 'package:timesget/models/country.model.dart';
import 'package:timesget/models/language.model.dart';
import 'package:timesget/services/device_info.dart';
import 'package:timesget/styles/constants.dart';
import 'package:timesget/styles/text_styles.dart';
import 'package:rxdart/rxdart.dart';

const _widgetName = "settings_board";

typedef void SettingsBoardCallback(Language lang, Country country, City city);

class SettingsBoard extends StatefulWidget {
  final Language initialLang;
  final Country initialCountry;
  final City initialCity;
  final SettingsBoardCallback callback;

  SettingsBoard(
      {@required this.initialLang,
      @required this.initialCountry,
      @required this.initialCity,
      @required this.callback});

  @override
  _SettingsBoardState createState() => _SettingsBoardState();
}

class _SettingsBoardState extends State<SettingsBoard> {
  BehaviorSubject<Language> nextLang = BehaviorSubject();
  BehaviorSubject<Country> nextCountry = BehaviorSubject();
  BehaviorSubject<City> nextCity = BehaviorSubject();

  Language _choosedLanguage;
  Country choosedCountry;
  City choosedCity;

  @override
  void initState() {
    super.initState();

    _choosedLanguage = widget.initialLang;
    nextLang.add(_choosedLanguage);

    nextCountry.add(widget.initialCountry);
    nextCity.add(widget.initialCity);
  }

  @override
  void dispose() {
    nextCountry.close();
    nextCity.close();
    nextLang.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final smallWidth = DeviceInfo.isSmallWidth;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Row(crossAxisAlignment: CrossAxisAlignment.end, children: <Widget>[
          Container(
              width: 120.0,
              child: Text(
                  allTranslations.text('$_widgetName.favorite_language'),
                  style: AppTextStyles.text)),
          AppConstants.spaceW(50.0),
          AppDropDownButton<Language>(
            AppDropDownButtonType.underline,
            stream: BehaviorSubject.seeded(allLanguages),
            initialValueStream: nextLang,
            isHintCentered: true,
            hint: allTranslations.text('$_widgetName.choose_language'),
            title: allTranslations.text('$_widgetName.choose_language'),
            getTitleDelegate: (x) => x.name,
            onChange: (lang) {
              _choosedLanguage = lang;
              nextLang.add(lang);
              widget.callback(_choosedLanguage, choosedCountry, choosedCity);
            },
          )
        ]),
        AppConstants.spaceH(50),
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: <Widget>[
            Container(
                width: 120.0,
                child: Text(allTranslations.text('$_widgetName.your_country'),
                    style: AppTextStyles.text)),
            AppConstants.spaceW(50.0),
            AppDropDownButton<Country>(
              AppDropDownButtonType.underline,
              stream: ModelProvider.of(context).countries,
              initialValueStream: nextCountry,
              isHintCentered: true,
              hint: smallWidth
                  ? allTranslations
                      .text('$_widgetName.choose_country')
                      .split(' ')[0]
                  : allTranslations.text('$_widgetName.choose_country'),
              title: allTranslations.text('$_widgetName.choose_country'),
              getTitleDelegate: (x) => x.name,
              onChange: (country) {
                choosedCountry = country;
                nextCountry.add(country);
                nextCity.add(null);
                choosedCity = null;
                widget.callback(_choosedLanguage, choosedCountry, choosedCity);
              },
            )
          ],
        ),
        AppConstants.spaceH(130),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            StreamBuilder(
                stream: nextCountry,
                builder: (context, snapshot) {
                  return AppDropDownButton<City>(AppDropDownButtonType.bordered,
                      stream: !snapshot.hasData
                          ? Stream.fromIterable([])
                          : Firestore.instance
                              .collection('cities')
                              .where('countryId', isEqualTo: snapshot.data.code)
                              .snapshots()
                              .map((QuerySnapshot snap) {
                              if (snap.documents.length == 0) {
                                return List<City>();
                              }

                              var list = snap.documents
                                  .map((doc) => City.from(doc))
                                  .toList();

                              return list
                                ..sort((a, b) => a.name.compareTo(b.name));
                            }),
                      title: allTranslations.text('$_widgetName.choose_city'),
                      hint: allTranslations.text('$_widgetName.city_hint'),
                      initialValueStream: nextCity,
                      getTitleDelegate: (city) => city.name,
                      isActive: snapshot.hasData,
                      onChange: (city) {
                        choosedCity = city;
                        nextCity.add(city);
                        widget.callback(
                            _choosedLanguage, choosedCountry, choosedCity);
                      });
                })
          ],
        )
      ],
    );
  }
}
