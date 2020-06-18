import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:timesget/components/app_drawer.dart';
import 'package:timesget/models/city_provider.dart';
import 'package:timesget/pages/company_list.dart';
import 'package:timesget/services/app_message.service.dart';
import 'package:timesget/styles/colors.dart';
import 'package:timesget/styles/constants.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with SingleTickerProviderStateMixin, WidgetsBindingObserver {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  int _currentTabIndex = 0;
  Widget _currentPage;

  @override
  void initState() {
    super.initState();
    _currentPage = CompanyListPage();

    // set up the notification permissions class
    // set up the future to fetch the notification data
    _permissionStatusFuture =
        AppMessageService().getNotificationPermissionStatus();
    // With this, we will be able to check if the permission is granted or not
    // when returning to the application
    WidgetsBinding.instance.addObserver(this);

    AppMessageService().init(context).then((_) => print('FSM Initialized.'));
  }

  Future<bool> _permissionStatusFuture;
  bool _notAllowedChecked = false;

  /// When the application has a resumed status, check for the permission
  /// status
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      setState(() {
        _notAllowedChecked = true;
        _permissionStatusFuture =
            AppMessageService().getNotificationPermissionStatus();
      });
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  void onPageChanged(int page) {
    setState(() {
      this._currentTabIndex = page;
    });
  }

  @override
  Widget build(BuildContext context) {
    ModelProvider.navogatorOf(context).setNavigator((page, index) {
      setState(() {
        _currentPage = page;
        _currentTabIndex = index == null ? 9999 : index;
      });
    }, _scaffoldKey);

    return Scaffold(
        key: _scaffoldKey,
        drawer: AppDrawer.of(context),
        body: FutureBuilder<bool>(
          future: _permissionStatusFuture,
          builder: (context, snap) {
            if (snap.connectionState == ConnectionState.waiting) {
              return AppConstants.circleSpinner;
            }

            final ok = snap.data;

            if (!ok) {
              if (!_notAllowedChecked) {
                AppMessageService().checkPermission(context);
              } else {
                AppMessageService().disallowNotifications();
              }
            }

            return CompanyListPage();
          },
        ),
        backgroundColor: AppColors.white);
  }
}
