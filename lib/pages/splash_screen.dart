import 'dart:async';
import 'package:flutter/material.dart';
import 'package:timesget/all_translations.dart';
import 'package:timesget/components/alert.dart';
import 'package:timesget/components/fade_route.dart';
import 'package:timesget/components/icons.dart';
import 'package:timesget/components/scale_route.dart';
import 'package:timesget/pages/home.dart';
import 'package:timesget/pages/start_settings.dart';
import 'package:timesget/services/device_info.dart';
import 'package:timesget/services/preferenses.service.dart';
import 'package:connectivity/connectivity.dart';
import 'package:timesget/styles/text_styles.dart';
import 'package:flutter/animation.dart';
import 'package:device_info/device_info.dart';
import 'dart:io' show Platform;

const _pageName = "splash_screen";
String _translate(String key) {
  return allTranslations.concatText([_pageName, key]);
}

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  AnimationController _logoController;
  Animation<double> _animation;

  Connectivity connectivity;
  StreamSubscription<ConnectivityResult> sub;

  bool _alreadyGotConnect = false;

  @override
  void initState() {
    super.initState();
    _init();
    _showDeviceInfo();
  }

  void _init() {
    connectivity = Connectivity();
    connectivity.checkConnectivity().then((connResult) {
      print('Connectivity is $connResult');

      if (connResult == ConnectivityResult.none) {
        _showNonConnection();

        sub = connectivity.onConnectivityChanged.listen((connResult) {
          print('Connectivity is $connResult');
          if (connResult != ConnectivityResult.none && !_alreadyGotConnect) {
            _alreadyGotConnect = true;
            _navigateToHome();
          }
        });
      } else {
        _alreadyGotConnect = true;
        _navigateToHome();
      }
    });

    sub = connectivity.onConnectivityChanged.listen((connResult) {});

    _logoController = AnimationController(
        duration: const Duration(milliseconds: 2300), vsync: this);
    _animation = Tween<double>(begin: .9, end: 0.2).animate(_logoController);

    _logoController.forward();
  }

  void _showNonConnection() async {
    final dialog = CustomAlertDialog(
      title: Text(
        allTranslations.text('warn'),
        style: AppTextStyles.dialogTitle,
      ),
      content: SingleChildScrollView(
          child: ListBody(children: [
        Text(allTranslations.text('no_internet_connection'),
            style: AppTextStyles.text)
      ])),
      hasCloseIcon: true,
    );

    await showDialog(
        barrierDismissible: true,
        context: context,
        builder: (context) => dialog);
  }

  void _navigateToHome() {
    PrefsService.isApproved().then((isApproved) {
      print('Has the User approved the app\'s rules? - $isApproved');

      Timer(Duration(milliseconds: 1500), () {
        if (!isApproved) {
          Navigator.pushReplacement(
              context, ScaleRoute(widget: StartSettingsPage()));
        }

        PrefsService.getCityPreferences().then((city) {
          if (city == null) {
            Navigator.pushReplacement(
                context, ScaleRoute(widget: StartSettingsPage()));
          } else {
            print('Current city is ${city?.name}');
            Navigator.pushReplacement(context, FadeRoute(widget: HomePage()));
          }
        });
      });
    });
  }

  _showDeviceInfo() async {
    DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();

    if (Platform.isIOS) {
      IosDeviceInfo iosInfo = await deviceInfo.iosInfo;
      print(
          'iOS: ${iosInfo.model} ${iosInfo.systemVersion} ${iosInfo.identifierForVendor}');
    } else if (Platform.isAndroid) {
      AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
      print('Android: ${androidInfo.display}');
    }
  }

  @override
  Widget build(BuildContext context) {
    DeviceInfo().init(MediaQuery.of(context));
    DeviceInfo().printInfo();

    return Scaffold(
        backgroundColor: Colors.white,
        body: OrientationBuilder(
          builder: (context, orientation) {
            final mq = MediaQuery.of(context);
            final w = mq.size.width;
            final h = mq.size.height;
            final pxr = mq.devicePixelRatio;

            print('($h x $w) * $pxr');

            final logo = Container(
              padding: EdgeInsets.only(bottom: pxr == 3 ? 13 : 20.0),
              child: Image.asset(
                AppImages.splashScreenLogoPath,
                width: w / 2,
              ),
            );

            final bg = Column(
              children: <Widget>[
                Expanded(
                  child: Center(
                    child: logo,
                  ),
                )
              ],
            );

            final subtitle = Positioned(
              child: Container(
                padding: EdgeInsets.only(bottom: 10.0),
                width: w,
                child: Text(
                  _translate('bottom_text'),
                  textAlign: TextAlign.center,
                  style: AppTextStyles.text,
                ),
              ),
              bottom: 0,
              left: 0,
            );

            return SafeArea(
                child: Stack(
              children: [bg, subtitle],
            ));
          },
        ));
  }

  @override
  void dispose() {
    sub.cancel();
    _logoController?.dispose();
    super.dispose();
  }
}
