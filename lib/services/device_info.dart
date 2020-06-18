import 'package:flutter/material.dart';
import 'dart:io' show Platform;

class DeviceInfo {
  static MediaQueryData _mq;

  double width;
  double height;
  double devicePixelRatio;
  double textScaleFactor;

  static final DeviceInfo _singleton = DeviceInfo._();

  factory DeviceInfo() {
    return _singleton;
  }

  DeviceInfo._();

  init(MediaQueryData mq) {
    if (_mq != null) {
      return;
    }
    _mq = mq;
    width = mq.size.width;
    height = mq.size.height;
    devicePixelRatio = mq.devicePixelRatio;
    textScaleFactor = mq.textScaleFactor;
  }

  static double get iosSmallWidth => 320.0;

  static bool get isIosSmallWidth =>
      Platform.isIOS && _mq.size.width <= iosSmallWidth;

  static bool get isIPhone6 {
    return Platform.isIOS &&
        _mq.size.width == 375.0 &&
        _mq.devicePixelRatio == 2.0 &&
        _mq.textScaleFactor == 1.0;
  }

  static bool get isSmallWidth => isIosSmallWidth || isIPhone6 || androidSmall;

  static bool get androidSmall {
    final x = _mq.devicePixelRatio < 2 && _mq.size.width <= 320.0;
    final y = _mq.devicePixelRatio == 2 && _mq.size.width <= 360.0;
    final z = _mq.devicePixelRatio <= 4 && _mq.size.width == 360.0;
    return Platform.isAndroid && (x || y || z);
  }

  printInfo() {
    print(
        'Real screen width = $width * $devicePixelRatio. Text scale factor = $textScaleFactor');
    print('Is Small Screen: $isSmallWidth');
  }
}
