import 'package:flutter/material.dart';
import 'package:timesget/all_translations.dart';
import 'package:timesget/components/buttons.dart';
import 'package:timesget/components/buttons/accept_process_private_data.button.dart';
import 'package:timesget/components/settings_.dart';
import 'package:timesget/models/city.dart';
import 'package:timesget/models/city_provider.dart';
import 'package:timesget/models/country.model.dart';
import 'package:timesget/models/language.model.dart';
import 'package:timesget/pages/home.dart';
import 'package:timesget/services/device_info.dart';
import 'package:timesget/services/preferenses.service.dart';
import 'package:timesget/styles/colors.dart';
import 'package:timesget/styles/constants.dart';
import 'package:timesget/styles/paddings.dart';
import 'package:timesget/styles/text_styles.dart';

const _pageName = "start_settings_page";
String _translate(String key) {
  return allTranslations.concatText([_pageName, key]);
}

class StartSettingsPage extends StatefulWidget {
  @override
  _StartSettingsPageState createState() => _StartSettingsPageState();
}

class _StartSettingsPageState extends State<StartSettingsPage> {
  bool _isAcceptRules = false;

  Language choosedLanguage;
  Country choosedCountry;
  City choosedCity;

  bool _buttonActivity = false;

  void _setButtonActivity() {
    _buttonActivity = _isAcceptRules &&
        choosedLanguage != null &&
        // choosedCountry != null &&
        choosedCity != null;
  }

  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context);
    final size = mq.size;

    return Scaffold(
      backgroundColor: AppColors.white,
      body: CustomScrollView(physics: BouncingScrollPhysics(), slivers: [
        SliverPadding(
            padding: EdgeInsets.fromLTRB(
                AppPaddings.left, 20.0, AppPaddings.left, 0.0),
            sliver: SliverList(
                delegate: SliverChildListDelegate([
              AppConstants.spaceH2(0.35 * size.width),
              Text(
                _translate('hi'),
                textAlign: TextAlign.center,
                style: DeviceInfo.isSmallWidth
                    ? AppTextStyles.h1Small
                    : AppTextStyles.hello,
              ),
              AppConstants.spaceH2(0.05 * size.width),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Text(
                  _translate('subtitle'),
                  softWrap: true,
                  textAlign: TextAlign.center,
                  style: DeviceInfo.isSmallWidth
                      ? AppTextStyles.text
                      : AppTextStyles.helloSubtitle,
                ),
              ),
              AppConstants.spaceH2(0.12 * size.width),
              SettingsBoard(
                initialLang: allTranslations.currentLang,
                initialCountry: ModelProvider.of(context).currentCountry,
                initialCity: ModelProvider.of(context).currentCity,
                callback: (lang, country, city) async {
                  if (choosedLanguage != null &&
                      lang != null &&
                      choosedLanguage.id != lang.id) {
                    await allTranslations.setNewLang(lang);
                  }

                  setState(() {
                    choosedLanguage = lang;
                    choosedCountry = country;
                    choosedCity = city;
                    _setButtonActivity();
                  });
                },
              ),
              AppConstants.spaceH(49.0),
              AcceptRulesButton(_isAcceptRules, onTap: () {
                setState(() {
                  _isAcceptRules = !_isAcceptRules;
                  _setButtonActivity();
                });
              }),
              SafeArea(
                child: AppColoredButton(_translate('start_button'),
                    color: AppColors.buttonActive,
                    // borderThin: 3,
                    isActive: _buttonActivity,
                    activeTitleColor: AppColors.buttonActiveText,
                    onTap: !_buttonActivity
                        ? null
                        : () async {
                            ModelProvider.of(context)
                                .nextCountry
                                .add(choosedCountry);
                            ModelProvider.of(context).nextCity.add(choosedCity);
                            await PrefsService.approve();
                            Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => HomePage(),
                                    settings: RouteSettings(name: 'HomePage')));
                          }),
              ),
              AppConstants.spaceH2(20.0),
            ])))
      ]),
    );
  }
}
