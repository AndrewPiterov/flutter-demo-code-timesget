import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter/foundation.dart';

enum AppTemplates { none, auto, beauty, medico }

class AppFeatures {
  final bool charity;

  AppFeatures({this.charity});
}

class AppConfig {
  static final AppConfig _singleton = new AppConfig._();

  static String get appName => DotEnv().env['APP_NAME'];
  static String get _templateCode => DotEnv().env['PROJECT_TEMPLATE'];
  static AppTemplates get template => _templateCode == 'medico'
      ? AppTemplates.medico
      : _templateCode == 'auto'
          ? AppTemplates.auto
          : _templateCode == 'beauty' ? AppTemplates.beauty : AppTemplates.none;
  static AppFeatures features = AppFeatures(charity: false);

  static String get googleMapApiKey => DotEnv().env['GOOGLE_MAP_API_KEY'];

  static bool get isProduction =>
      kReleaseMode || DotEnv().env['APP_MODE'].contains('prod');

  factory AppConfig() {
    return _singleton;
  }

  Future<void> load() async {
    await DotEnv().load();
    print("The App is '$appName' and $_templateCode template.");
  }

  AppConfig._() {}
}
