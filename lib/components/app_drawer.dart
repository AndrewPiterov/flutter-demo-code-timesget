import 'package:flutter/material.dart';
import 'package:timesget/all_translations.dart';
import 'package:timesget/components/badge.dart';
import 'package:timesget/models/city_provider.dart';
import 'package:timesget/models/user.model.dart';
import 'package:timesget/pages/about_work.dart';
import 'package:timesget/pages/account/my_bookings.dart';
import 'package:timesget/pages/best_time.dart';
import 'package:timesget/pages/need_help.dart';
import 'package:timesget/pages/news.dart';
import 'package:timesget/pages/hot_offer.dart';
import 'package:timesget/pages/mobil_cards.dart';
import 'package:timesget/pages/promos.dart';
import 'package:timesget/pages/search_by_lastname.dart';
import 'package:timesget/pages/top_workers.dart';
import 'package:timesget/services/auth.service.dart';
import 'package:timesget/services/device_info.dart';
import 'package:timesget/services/mobile_card.service.dart';
import 'package:timesget/styles/colors.dart';
import 'package:timesget/styles/constants.dart';
import 'package:timesget/styles/decorationd.dart';
import 'package:timesget/styles/text_styles.dart';

const _widgetName = 'app_drawer';
String _translate(String key) {
  return allTranslations.concatText([_widgetName, key]);
}

class AppDrawer {
  static Widget of(BuildContext context) {
    final leftPad = DeviceInfo.isSmallWidth ? 20.0 : 45.0;

    // final padding = EdgeInsets.only(left: leftPad, bottom: 30.0, right: 22.0);
    final linkPadding = DeviceInfo.isSmallWidth
        ? EdgeInsets.fromLTRB(leftPad, 10.0, 16.0, 10.0)
        : EdgeInsets.fromLTRB(leftPad, 14.0, 16.0, 14.0);

    final linkTextStyle = AppTextStyles.drawerLink;

    StreamBuilder _buildBadge(Stream<int> stream, {Color color}) {
      color = color ?? AppColors.chipBadge;
      return StreamBuilder(
        stream: stream,
        builder: (context, snapshot) {
          if (!snapshot.hasData || snapshot.data == 0) {
            return Container();
          }
          return Container(
            margin: EdgeInsets.only(left: 10.0),
            child: AppBadge(
              snapshot.data,
              color: color,
            ),
          );
        },
      );
    }

    Widget _buildBagedRow(String title, Stream<int> count) {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Text(
            title,
            style: linkTextStyle,
          ),
          _buildBadge(count)
        ],
      );
    }

    return Drawer(
      elevation: 4.0,
      child: ListView(
        // Important: Remove any padding from the ListView.
        padding: EdgeInsets.zero,
        children: <Widget>[
          AppConstants.spaceH(190),
          Container(
              padding: EdgeInsets.only(left: 21.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  AppConstants.close(onTap: () {
                    Navigator.pop(context);
                  })
                ],
              )),
          AppConstants.spaceH(20),
          InkWell(
            child: Container(
                padding: linkPadding.copyWith(left: leftPad - 4, bottom: 10.0),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: EdgeInsets.fromLTRB(12.0, 7.0, 12.0, 4.0),
                      decoration: AppDecorations.borderedDrawerItem,
                      child: Text(
                        _translate('my_bookings'),
                        style: linkTextStyle,
                      ),
                    )
                  ],
                )),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => AccountBookingsPage(),
                      settings: RouteSettings(name: 'AccountBookingsPage')));
            },
          ),
          InkWell(
            child: Padding(
              padding: linkPadding,
              child: Container(
                child: Text(
                  _translate('search_worker_by_name'),
                  style: linkTextStyle,
                ),
              ),
            ),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => SearchByLastName(),
                      settings: RouteSettings(name: 'SearchByLastName')));
            },
          ),
          InkWell(
            child: Container(
              padding: linkPadding,
              child: Text(
                _translate('top'),
                style: linkTextStyle,
              ),
            ),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => CompareWorkersPage(),
                      settings: RouteSettings(name: 'CompareWorkersPage')));
            },
          ),
          InkWell(
            child: Container(
                padding: linkPadding,
                child: Text(
                  _translate('handy_time'),
                  style: linkTextStyle,
                )),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => BestTimePage(),
                      settings: RouteSettings(name: 'BestTimePage')));
            },
          ),
          InkWell(
            child: Padding(
              padding: linkPadding,
              child: Text(
                _translate('auction'),
                style: linkTextStyle,
              ),
            ),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => NeedHelpPage(),
                      settings: RouteSettings(name: 'NeedHelpPage')));
            },
          ),
          InkWell(
            child: Padding(
                padding: linkPadding,
                child: _buildBagedRow(_translate('hot'),
                    ModelProvider.of(context).hotOfferCount)),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => HotOffersPage(),
                      settings: RouteSettings(name: 'HotOffersPage')));
            },
          ),
          InkWell(
            child: Padding(
                padding: linkPadding,
                child: _buildBagedRow(_translate('promocodes'),
                    ModelProvider.of(context).hasUnreadPromocodes)),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => PromosPage(),
                      settings: RouteSettings(name: 'PromosPage')));
            },
          ),
          InkWell(
            child: Padding(
                padding: linkPadding,
                child: _buildBagedRow(_translate('mobil_cards'),
                    MobilCardService().hasUnreadMobileCards)),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => MobilCardsPage(),
                      settings: RouteSettings(name: 'MobilCardsPage')));
            },
          ),
          InkWell(
            child: Padding(
                padding: linkPadding,
                child: _buildBagedRow(_translate('news'),
                    ModelProvider.of(context).hasUnreadNews)),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => NewsPage(),
                      settings: RouteSettings(name: 'NewsPage')));
            },
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(leftPad, 22.0, 90.0, 0.0),
            child: Container(
              color: AppColors.drawerMenuShortLine,
              height: 1.5,
            ),
          ),
          AppConstants.spaceH(75),
          InkWell(
            child: Padding(
              padding: linkPadding,
              child: Text(
                _translate('about'),
                style: linkTextStyle.copyWith(fontWeight: FontWeight.w800),
              ),
            ),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => AboutWorkPage(),
                      settings: RouteSettings(name: 'AboutWorkPage')));
            },
          ),
          StreamBuilder(
            stream: AuthService().profile,
            builder: (context, AsyncSnapshot<AppUser> snap) {
              if (!snap.hasData) {
                return InkWell(
                  child: Container(
                      padding: linkPadding,
                      child: Text(
                        _translate('login'),
                        style:
                            linkTextStyle.copyWith(fontWeight: FontWeight.w800),
                      )),
                  onTap: () async {
                    Navigator.pop(context);
                    Navigator.of(context).pushNamed('/login');
                  },
                );
              }

              return InkWell(
                child: Container(
                    padding: linkPadding,
                    child: Text(
                      _translate('account'),
                      style:
                          linkTextStyle.copyWith(fontWeight: FontWeight.w800),
                    )),
                onTap: () async {
                  Navigator.pop(context);
                  Navigator.of(context).pushNamed('/account');
                },
              );
            },
          ),
          DeviceInfo.isSmallWidth ? AppConstants.spaceH(100) : Container(),
        ],
      ),
    );
  }
}
