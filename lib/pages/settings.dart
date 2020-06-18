import 'package:flutter/material.dart';
import 'package:timesget/all_translations.dart';
import 'package:timesget/components/buttons.dart';
import 'package:timesget/components/icons.dart';
import 'package:timesget/components/settings_.dart';
import 'package:timesget/models/city.dart';
import 'package:timesget/models/city_provider.dart';
import 'package:timesget/models/country.model.dart';
import 'package:timesget/models/language.model.dart';
import 'package:timesget/pages/home.dart';
import 'package:timesget/styles/colors.dart';
import 'package:timesget/styles/constants.dart';
import 'package:timesget/styles/paddings.dart';
import 'package:timesget/styles/text_styles.dart';

const _pageName = "settings_page";
String _translate(String key) {
  return allTranslations.concatText([_pageName, key]);
}

class SettingsPage extends StatefulWidget {
  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  Widget currLocation() {
    return StreamBuilder(
        stream: ModelProvider.of(context).currentLocation,
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Text('no data');
          }

          final loc = snapshot.data;
          return Text('You are in $loc');
        });
  }

  Language _currLang;
  Country _currCountry;
  City _currCity;

  Language _newLang;
  Country _newCountry;
  City _newCity;

  bool _hasChanges = false;

  void _setButtonActivity() {
    final hasChanges = ((_newLang != null && _currLang.id != _newLang.id) ||
        (_newCountry != null && _currCountry.code != _newCountry?.code) ||
        (_newCity != null && _currCity.id != _newCity?.id));

    final wasChoosedNewCountry = _newCountry != null;

    _hasChanges = hasChanges &&
        (_currCity != null && !wasChoosedNewCountry ||
            (wasChoosedNewCountry && _newCity != null));
  }

  Widget _saveButton() {
    return AppColoredButton(_translate('change_button'),
        color: AppColors.buttonActive,
        activeTitleColor: AppColors.text,
        isActive: _hasChanges, onTap: () async {
      if (_newLang != null) {
        // ModelProvider.of(context).nextLanguage.add(_newLang);
        await allTranslations.setNewLang(_newLang);
      }
      if (_newCountry != null) {
        ModelProvider.of(context).nextCountry.add(_newCountry);
      }
      if (_newCity != null) {
        ModelProvider.of(context).nextCity.add(_newCity);
      }

      Navigator.pushReplacement(
          context,
          MaterialPageRoute(
              builder: (context) => HomePage(),
              settings: RouteSettings(name: 'HomePage')));
    });
  }

  Widget _lanscapeOriented() {
    return SingleChildScrollView(
        child: Padding(
      padding: EdgeInsets.symmetric(horizontal: AppPaddings.left),
      child: Column(
        children: <Widget>[
          AppConstants.spaceH(50),
          Center(
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 45.0, vertical: 40.0),
              constraints: BoxConstraints(maxHeight: 170.0),
              child: AppIcons.settings,
            ),
          ),
          AppConstants.spaceH(50),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 25.0),
            child: Text(
              _translate('subtitle'),
              textAlign: TextAlign.center,
              style: AppTextStyles.settingsLabel,
            ),
          ),
          AppConstants.spaceH(10),
          SettingsBoard(
            initialLang: allTranslations.currentLang,
            initialCountry: ModelProvider.of(context).currentCountry,
            initialCity: ModelProvider.of(context).currentCity,
            callback: (lang, country, city) {
              setState(() {
                _newLang = lang;
                _newCountry = country;
                _newCity = city;
                _setButtonActivity();
              });
            },
          ),
          AppConstants.spaceH(260),
          _saveButton(),
          AppConstants.spaceH(80),
        ],
      ),
    ));
  }

  Widget _portraiteOriented() {
    final board = Column(
      children: [
        Expanded(
          flex: 1,
          child: Container(),
        ),
        SizedBox(
          height: 170,
          child: Column(
            children: <Widget>[
              Center(
                child: Container(
                  constraints: BoxConstraints(maxHeight: 110.0),
                  child: AppIcons.settings,
                ),
              ),
              AppConstants.spaceH(50),
              Center(
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 20.0),
                  child: Text(
                    _translate('subtitle'),
                    textAlign: TextAlign.center,
                    style: AppTextStyles.settingsLabel,
                  ),
                ),
              )
            ],
          ),
        ),
        Expanded(
          flex: 1,
          child: Container(),
        ),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 20.0),
          child: SettingsBoard(
            initialLang: allTranslations.currentLang,
            initialCountry: ModelProvider.of(context).currentCountry,
            initialCity: ModelProvider.of(context).currentCity,
            callback: (lang, country, city) {
              setState(() {
                _newLang = lang;
                _newCountry = country;
                _newCity = city;
                _setButtonActivity();
              });
            },
          ),
        ),
        Container(
          height: 103,
        )
      ],
    );

    final button = Positioned(
      bottom: 15,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 20.0),
        width: MediaQuery.of(context).size.width,
        child: _saveButton(),
      ),
    );

    return Stack(
      children: [board, button],
    );
  }

  @override
  Widget build(BuildContext context) {
    _currLang = allTranslations.currentLang;
    _currCountry = ModelProvider.of(context).currentCountry;
    _currCity = ModelProvider.of(context).currentCity;

    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        automaticallyImplyLeading: false, // Don't show the leading button
        brightness: Brightness.light,
        title: Container(
          margin: EdgeInsets.only(left: 20.0),
          child: InkWell(
            child: Row(children: [
              AppIcons.arrowBack(),
              AppConstants.spaceW(20.0),
              Text(allTranslations.text('cancel'),
                  style: AppTextStyles.navCancel)
            ]),
            onTap: () {
              Navigator.pop(context);
            },
          ),
        ),
        titleSpacing: 0.0,
        backgroundColor: AppColors.white,
        elevation: 0.0,
      ),
      body: SafeArea(child: OrientationBuilder(
        builder: (context, orientation) {
          if (orientation == Orientation.landscape) {
            return _lanscapeOriented();
          }

          return _portraiteOriented();
        },
      )),
    );
  }
}
