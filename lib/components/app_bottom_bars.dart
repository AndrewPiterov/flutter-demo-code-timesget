import 'package:flutter/material.dart';
import 'package:keyboard_visibility/keyboard_visibility.dart';
import 'package:timesget/all_translations.dart';
import 'package:timesget/components/badge.dart';
import 'package:timesget/components/icons.dart';
import 'package:timesget/models/city_provider.dart';
import 'package:timesget/pages/account/my_bookings.dart';
import 'package:timesget/pages/company_list.dart';
import 'package:timesget/pages/hot_offer.dart';
import 'package:timesget/pages/worker_list.dart';
import 'package:timesget/services/user.services.dart';
import 'package:timesget/styles/colors.dart';
import 'package:timesget/styles/constants.dart';
import 'package:timesget/styles/text_styles.dart';

enum AppPages { home, workers, myBookings, hotOffers, more }

const _widgetName = "bottom_nav_bar";
String _translate(String key) {
  return allTranslations.concatText([_widgetName, key]);
}

class AppBottomTabBars extends StatefulWidget {
  final AppPages page;

  AppBottomTabBars({this.page});

  static Column _barTitle(String firstLine, {String secondLine = ""}) {
    final lineHeight = 14.0;
    final scaleFactor = 0.99;
    final style = AppTextStyles.bottomTabBarLabel;

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        AppConstants.spaceH(12),
        Container(
            height: lineHeight,
            child: Text(
              firstLine,
              textScaleFactor: scaleFactor,
              style: style,
              textAlign: TextAlign.center,
            )),
        Container(
          height: lineHeight,
          child: Text(
            secondLine,
            textScaleFactor: scaleFactor,
            style: style,
            textAlign: TextAlign.center,
          ),
        )
      ],
    );
  }

  @override
  _AppBottomTabBarsState createState() => _AppBottomTabBarsState();
}

class _AppBottomTabBarsState extends State<AppBottomTabBars> {
  final Color _color = AppColors.bottomTabBar;

  bool isKeybordVisible;

  @override
  void initState() {
    super.initState();
    isKeybordVisible = false;
    KeyboardVisibilityNotification().addNewListener(
      onChange: (visible) {
        // print('Keyboard is open? - $visible');
        setState(() {
          isKeybordVisible = visible;
        });
      },
    );
  }

  Widget _buildButton(
      BuildContext context, AppPages requiredPage, double width, onTap,
      {Stream<int> badgeStream}) {
    var _iconHeight = AppConstants.sizeOf(90);
    var title;
    var pageIcon;

    switch (requiredPage) {
      case AppPages.home:
        title = _translate('home');
        pageIcon = widget.page == AppPages.home
            ? AppIcons.home(i: 2, height: _iconHeight)
            : AppIcons.home(height: _iconHeight);
        break;
      case AppPages.workers:
        title = _translate('workers');
        pageIcon = widget.page == AppPages.workers
            ? AppIcons.workers(i: 2, height: _iconHeight)
            : AppIcons.workers(height: _iconHeight);
        break;
      case AppPages.myBookings:
        title = _translate('my_bookings');
        pageIcon = widget.page == AppPages.myBookings
            ? AppIcons.myBookings(i: 2, height: _iconHeight)
            : AppIcons.myBookings(height: _iconHeight);
        break;
      case AppPages.hotOffers:
        title = _translate('hot');
        _iconHeight = AppConstants.sizeOf(105);
        pageIcon = widget.page == AppPages.hotOffers
            ? AppIcons.early(i: 2, height: _iconHeight)
            : AppIcons.early(height: _iconHeight);
        break;
      case AppPages.more:
        title = _translate('more');
        pageIcon = widget.page == null || widget.page == AppPages.more
            ? AppIcons.more(i: 2, height: _iconHeight)
            : AppIcons.more(height: _iconHeight);
        break;
    }

    return InkWell(
        onTap: widget.page == requiredPage ? null : onTap,
        child: Stack(
          children: <Widget>[
            Column(children: [
              Padding(
                padding: EdgeInsets.only(
                    top: requiredPage == AppPages.hotOffers ? 4.0 : 9.0),
                child: pageIcon,
              ),
              AppConstants.spaceH(1),
              _getTitle(title)
            ]),
            badgeStream == null ? Container() : _buildBadge(badgeStream, width)
          ],
        ));
  }

  Widget _getTitle(String title) {
    final arr = title.split(' ');
    return AppBottomTabBars._barTitle(arr[0],
        secondLine: arr.length > 1 ? arr[1] : "");
  }

  Widget _buildBadge(Stream<int> stream, double width) {
    return StreamBuilder(
      stream: stream,
      builder: (context, AsyncSnapshot<int> snapshot) {
        if (!snapshot.hasData || snapshot.data == 0) {
          return Container();
        }

        return Positioned(
          child: AppBadge(
            snapshot.data,
            color: AppColors.chipBadge,
          ),
          top: 0.0,
          right: width / 2 - 25.0,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context);
    // final b = mq.viewInsets.bottom;
    // final isopen = b != 0;
    final width = mq.size.width / 5;

    return isKeybordVisible
        ? AppConstants.nothing
        : Container(
            padding: EdgeInsets.fromLTRB(10.0, 0.0, 10.0,
                mq.padding.bottom + (mq.padding.bottom > 0 ? 0.0 : 4.0)),
            decoration: BoxDecoration(color: _color),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: <Widget>[
                Expanded(
                  child: _buildButton(
                      context,
                      AppPages.home,
                      width,
                      () => Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => CompanyListPage(),
                              settings: RouteSettings(name: 'HomePage')))),
                ),
                Expanded(
                  child: _buildButton(
                      context,
                      AppPages.myBookings,
                      width,
                      () => Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => AccountBookingsPage(),
                              settings: RouteSettings(name: 'MyBookingsPage'),
                              maintainState: false)),
                      badgeStream: UserService().futureBookingCount$),
                ),
                Expanded(
                  child: _buildButton(
                    context,
                    AppPages.workers,
                    width,
                    () => Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => WorkerListPage(),
                            settings: RouteSettings(name: 'WorkersPage'))),
                  ),
                ),
                Expanded(
                  child: _buildButton(
                      context,
                      AppPages.hotOffers,
                      width,
                      () => Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => HotOffersPage(),
                              settings: RouteSettings(name: 'HotOffersPage'))),
                      badgeStream: ModelProvider.of(context).hotOfferCount),
                ),
                Expanded(
                  child: _buildButton(context, AppPages.more, width,
                      () => Scaffold.of(context).openDrawer(),
                      badgeStream: ModelProvider.of(context).hasMoreChanges),
                ),
              ],
            ),
          );
  }
}
