import 'package:flutter/material.dart';
import 'package:timesget/all_translations.dart';
import 'package:timesget/components/app_bar.dart';
import 'package:timesget/components/app_bottom_bars.dart';
import 'package:timesget/components/app_drawer.dart';
import 'package:timesget/components/tags/h1.dart';
import 'package:timesget/components/tags/p.dart';
import 'package:timesget/models/city_provider.dart';
import 'package:timesget/models/company.dart';
import 'package:timesget/services/workWeek.utils.dart';
import 'package:timesget/styles/colors.dart';
import 'package:timesget/styles/constants.dart';
import 'package:timesget/styles/text_styles.dart';

const _pageName = "contacts_page";
String _translate(String key) {
  return allTranslations.concatText([_pageName, key]);
}

class ContactsPage extends StatelessWidget {
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: getAppBar(
        context,
      ),
      backgroundColor: AppColors.white,
      drawer: AppDrawer.of(context),
      body: Column(
        children: <Widget>[
          Expanded(
            child: CustomScrollView(
              physics: BouncingScrollPhysics(),
              slivers: <Widget>[
                H1(_translate('title')),
                AppConstants.spaceInSliver(30),
                _ContactsBoard()
              ],
            ),
          ),
          AppBottomTabBars()
        ],
      ),
    );
  }
}

class _ContactsBoard extends StatelessWidget {
  TextStyle _keyStyle = TextStyle(
          fontSize: AppTextStyles.fontSize14,
          fontWeight: FontWeight.w500,
          height: 1.3)
      .copyWith(color: AppColors.keyValueKey);

  Widget _getInfo(BuildContext context, Company company) {
    var phones = List<Text>();
    for (var a in company.addresses) {
      for (var p in a.phoneNumber.split(';').map((p) => p.trim())) {
        phones.add(Text(
          p,
          style: AppTextStyles.text.copyWith(height: 1.2),
        ));
      }
    }

    final addresses = company.addresses
        .map((x) => Text(
              x.address,
              style: AppTextStyles.text.copyWith(height: 1.2),
            ))
        .toList();

    final spaceBetweenInfos = 13.0 * AppConstants.ration;

    return SingleChildScrollView(
      child: ListBody(
        children: <Widget>[
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                allTranslations.text('address') + ':',
                style: _keyStyle,
              ),
            ]..addAll(addresses),
          ),
          AppConstants.spaceH(spaceBetweenInfos),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                allTranslations.text('phone') + ':',
                style: _keyStyle,
              ),
            ]..addAll(phones),
          ),
          AppConstants.spaceH(spaceBetweenInfos),
          Text(_translate('schedule'), style: _keyStyle),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: WorkWeekUtils.getRows(context, company.workWeek),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: ModelProvider.of(context).company$,
      builder: (context, AsyncSnapshot<Company> snap) {
        var child;

        if (!snap.hasData) {
          child = AppConstants.spinner;
        } else {
          final company = snap.data;
          child = _getInfo(context, company);
        }

        return p2(child);
      },
    );
  }
}
