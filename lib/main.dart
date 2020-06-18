import 'dart:async';
import 'package:camera/camera.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_analytics/observer.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:timesget/all_translations.dart';
import 'package:timesget/config/app_config.dart';
import 'package:timesget/models/city_bloc.dart';
import 'package:timesget/models/city_provider.dart';
import 'package:timesget/models/model_command.dart';
import 'package:timesget/pages/account.dart';
import 'package:timesget/pages/barcode_scan.dart';
import 'package:timesget/pages/home.dart';
import 'package:timesget/pages/login.dart';
import 'package:timesget/pages/signup.dart';
import 'package:timesget/pages/splash_screen.dart';
import 'package:timesget/ru_localization.dart';
import 'package:timesget/styles/colors.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:page_transition/page_transition.dart';
import 'package:timesget/styles/text_styles.dart';

List<CameraDescription> cameras;

FirebaseAnalytics analytics = FirebaseAnalytics();

Iterable<LocalizationsDelegate<dynamic>> localDelegates =
    <LocalizationsDelegate<dynamic>>[
  // ... app-specific localization delegate[s] here
  ChineseCupertinoLocalizations.delegate,
  DefaultCupertinoLocalizations.delegate,
  GlobalMaterialLocalizations.delegate,
  GlobalWidgetsLocalizations.delegate,
];

var locale = <Locale>[
  // const Locale('en'), // English
  const Locale('ru'), // Russia
];

Future<Null> main() async {
  await AppConfig().load();

  // add this, and it should be the first line in main method
  WidgetsFlutterBinding.ensureInitialized();

  // Initializes the translation module
  await allTranslations.init();

  // Fetch the available cameras before initializing the app.
  try {
    cameras = await availableCameras();
  } on CameraException catch (e) {
    print('Error: ${e.code}\nError Message: ${e.description}');
  }
  runApp(MyApp());
}

ThemeData _buildAppTheme() {
  final ThemeData base = ThemeData(fontFamily: 'Geometria');
  return base.copyWith(
    primaryColor: AppColors.primaryColor,
    hintColor: AppColors.hintColor,
    inputDecorationTheme: InputDecorationTheme(
      border: OutlineInputBorder(),
      labelStyle: TextStyle(
          color: AppColors.imputDecorationLabelStyle,
          fontSize: AppTextStyles.imputDecorationLabelStyle),
    ),
  );
}

class MyApp extends StatefulWidget {
  @override
  MyAppState createState() {
    return new MyAppState();
  }
}

class MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();

    // Initializes a callback should something need
    // to be done when the language is changed
    allTranslations.onLocaleChangedCallback = _onLocaleChanged;
  }

  ///
  /// If there is anything special to do when the user changes the language
  ///
  _onLocaleChanged() async {
    // do anything you need to do if the language changes
    print('Language has been changed to: ${allTranslations.currentLanguage}');
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final cityBloc = ModelBloc(cameras);
    final modelCommand = ModelCommand();

    return ModelProvider(
      cityBloc: cityBloc,
      modelCommand: modelCommand,
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        localizationsDelegates: localDelegates,
        // Tells the system which are the supported languages
        supportedLocales: allTranslations.supportedLocales(),
        onGenerateTitle: (context) => allTranslations.text('app_title'),
        theme: _buildAppTheme(),
        home: SplashScreen(),
        navigatorObservers: [
          FirebaseAnalyticsObserver(analytics: analytics),
        ],
        onGenerateRoute: (settings) {
          switch (settings.name) {
            case '/splash':
              return PageTransition(
                  child: SplashScreen(), type: PageTransitionType.fade);
              break;
            case '/login':
              return PageTransition(
                  child: LoginPage(), type: PageTransitionType.downToUp);
              break;
            case '/signup':
              return PageTransition(
                  child: SignupPage(), type: PageTransitionType.downToUp);
              break;
            case '/account':
              return PageTransition(
                  child: AccountPage(), type: PageTransitionType.rightToLeft);
            case '/barcode-scanner':
              return PageTransition(
                  child: BarcodeScanPage(),
                  type: PageTransitionType.rightToLeft);
              break;
            case '/home':
              return PageTransition(
                  child: HomePage(), type: PageTransitionType.downToUp);
            default:
              return null;
          }
        },
      ),
    );
  }
}
