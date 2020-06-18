import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:timesget/all_translations.dart';
import 'package:timesget/components/app_bar.dart';
import 'package:timesget/components/app_bottom_bars.dart';
import 'package:timesget/components/app_drawer.dart';
import 'package:timesget/components/row_card.dart';
import 'package:timesget/components/tags/h1.dart';
import 'package:timesget/components/tags/text.dart';
import 'package:timesget/models/city_news.dart';
import 'package:timesget/models/city_provider.dart';
import 'package:timesget/models/token_data.dart';
import 'package:timesget/services/app_message.service.dart';
import 'package:timesget/styles/colors.dart';
import 'package:timesget/styles/constants.dart';
import 'package:timesget/styles/paddings.dart';
import 'package:timesget/styles/text_styles.dart';

const _pageName = "news_page";
String _translate(String key) {
  return allTranslations.concatText([_pageName, key]);
}

class NewsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    ModelProvider.of(context).newsHasBeenOpened.add(DateTime.now());
    final String title = _translate('title');
    return Scaffold(
        appBar: getAppBar(
          context,
        ),
        drawer: AppDrawer.of(context),
        backgroundColor: AppColors.pageBackground,
        body: Column(children: [
          Expanded(
              child: CustomScrollView(
            physics: BouncingScrollPhysics(),
            shrinkWrap: true,
            slivers: <Widget>[
              HeaderBoard(
                title,
                children: <Widget>[
                  text(_translate('subtitle')),
                  AppConstants.spaceH(10),
                  _Switch(),
                ],
              ),
              _NewsList()
            ],
          )),
          AppBottomTabBars()
        ]));
  }
}

class _Switch extends StatefulWidget {
  @override
  _SwitchState createState() => _SwitchState();
}

class _SwitchState extends State<_Switch> {
  bool _lights = false;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<TokenData>(
      stream: AppMessageService().token$,
      builder: (context, AsyncSnapshot<TokenData> snapshot) {
        final token = snapshot.hasData ? snapshot.data : null;
        return MergeSemantics(
            child: FutureBuilder<bool>(
          future: AppMessageService().getNotificationPermissionStatus(),
          builder: (context, snap) {
            if (!snap.hasData) {
              return AppConstants.circleSpinner;
            }

            final peremissionStatusIsOk = snap.data;
            print('Permission status is $peremissionStatusIsOk');

            return ListTile(
              contentPadding: EdgeInsets.all(0.0),
              title:
                  Text(_translate('toggle_button'), style: AppTextStyles.text),
              trailing: CupertinoSwitch(
                activeColor: AppColors.switchToggle,
                value: peremissionStatusIsOk &&
                    (token != null &&
                        token.hasToken &&
                        token.shouldRecieveNotifications),
                onChanged: peremissionStatusIsOk
                    ? (value) {
                        setState(() {
                          _lights = value;
                          AppMessageService.updateShouldRecieveNotification(
                              _lights);
                        });
                      }
                    : (value) async {
                        await _requestPermission();
                      },
              ),
            );
          },
        ));
      },
    );
  }

  Future<void> _requestPermission() async {
    await AppMessageService().requestNotificationPermissions();
    // AppMessageService().setFirebaseMessaging(context);
    setState(() {});
  }
}

class _NewsList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: ModelProvider.of(context).cityNews,
      builder: (context, AsyncSnapshot<List<CityNews>> snapshot) {
        if (!snapshot.hasData) {
          return AppConstants.circleSpinnerSlivered;
        }

        final arr = snapshot.data;
        ModelProvider.of(context).newsHasBeenOpened.add(DateTime.now());

        return SliverPadding(
          padding: EdgeInsets.all(AppPaddings.left),
          sliver: SliverList(
            delegate: SliverChildBuilderDelegate((builder, i) {
              final news = arr[i];
              return Column(
                children: <Widget>[
                  _CityNewsRow(news),
                  AppConstants.betweenRowCards
                ],
              );
            }, childCount: arr.length),
          ),
        );
      },
    );
  }
}

class _CityNewsRow extends StatelessWidget {
  final CityNews news;
  _CityNewsRow(this.news);

  @override
  Widget build(BuildContext context) {
    return RowCardComponent(
      paddings: EdgeInsets.all(0.0),
      child: Column(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.fromLTRB(20.0, 22.0, 20.0, 20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  news.title,
                  style: AppTextStyles.postTitle.copyWith(fontSize: 16.0),
                ),
                AppConstants.spaceH(46),
                Text(news.text, style: AppTextStyles.text),
                AppConstants.spaceH(36)
              ],
            ),
          )
        ],
      ),
    );
  }
}
