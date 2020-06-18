import 'dart:async';
import 'package:flutter/material.dart';
import 'package:timesget/all_translations.dart';
import 'package:timesget/components/overlays/funky.overlay.dart';
import 'package:timesget/styles/text_styles.dart';

OverlayEntry buildOverlay(String text, {String title}) {
  OverlayEntry _overlayEntry;
  _overlayEntry = OverlayEntry(builder: (BuildContext context) {
    return FunkyOverlay(_overlayEntry, Text(text, style: AppTextStyles.text),
        title: title == null
            ? allTranslations.concatText(['notification_widget', 'title'])
            : title, dissmissAction: () {
      _overlayEntry.remove();
    });
  });

  return _overlayEntry;
}

class _Pair {
  final OverlayEntry entry;
  final Duration duration;
  VoidCallback _callback;
  bool _cleared = false;

  int get id => entry.hashCode;

  _Pair(this.entry, {this.duration, VoidCallback callback}) {
    this._callback = callback;
  }

  close() {
    if (_callback != null) {
      if (_cleared) {
        _callback = null;
      } else {
        _callback();
        _callback = null;
      }
    }
  }

  clearCallback() {
    _callback = null;
    _cleared = true;
  }
}

class AppNotification {
  // VoidCallback _callback;

  List<_Pair> arr = List<_Pair>();

  AppNotification._();

  void show(BuildContext context, OverlayEntry entry, {Duration duration}) {
    var closeCallback;

    if (duration != null) {
      closeCallback = () {
        entry.remove();
      };

      Timer(duration, () {
        final c = arr.where((x) => x.entry == entry);
        if (c.length == 0) {
          print('already closed');
        } else {
          c.first.close();
          arr.removeWhere((e) => e.id == entry.hashCode);
          // arr.clear(); // arr.remove(entry);
        }
        print('Notifications count is: ${arr.length}');
      });
    }

    arr.add(_Pair(entry, duration: duration, callback: closeCallback));
    Navigator.of(context).overlay.insert(entry);
  }

  void clear() {
    for (var i = 0; i < arr.length; i++) {
      final e = arr[i];
      e.close();
    }
    arr.clear();
  }

  void remove(OverlayEntry entry) {
    final e = arr.firstWhere((x) => x.entry == entry);
    e.clearCallback();
    e.entry.remove();
  }

  static final AppNotification _instance = AppNotification._();

  factory AppNotification() {
    return _instance;
  }
}
