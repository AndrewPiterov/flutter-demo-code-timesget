import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:timesget/models/worker.dart';
import 'package:timesget/services/app_utils.dart';
import 'package:rxdart/rxdart.dart';

class ScrollHourPicker extends StatefulWidget {
  final List<WorkerTime> hours;
  final dynamic callback;
  final WorkerTime init;

  Stream<WorkerTime> get time => _isTimeSubject.stream;
  BehaviorSubject<WorkerTime> _isTimeSubject;

  ScrollHourPicker({@required this.hours, this.init, this.callback}) {
    _isTimeSubject = BehaviorSubject<WorkerTime>.seeded(init);
  }

  @override
  _ScrollHourPickerState createState() => _ScrollHourPickerState();
}

class _ScrollHourPickerState extends State<ScrollHourPicker> {
  FixedExtentScrollController _scrollController;
  //int _selectedItem;
  WorkerTime _currentHour;
  int _curr = 0;

  @override
  initState() {
    super.initState();
    _scrollController = FixedExtentScrollController(initialItem: _curr);
    _scrollController.addListener(_onHourChanged);
  }

  _onHourChanged() {
    _curr = _scrollController.selectedItem;
    final hour = widget.hours[_curr];
    print(hour);
    _notify(_currentHour);
  }

  _notify(WorkerTime time) {
    if (widget.callback != null) {
      widget.callback(time);
    }
    widget._isTimeSubject.add(time);
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPicker(
      scrollController: _scrollController,
      backgroundColor: Colors.white,
      diameterRatio: 80.0,
      children:
          widget.hours.map((x) => AppUtils.buildHourLabel(context, x)).toList(),
      itemExtent: 65.0,
      onSelectedItemChanged: (index) {
        setState(() {
          final t = widget.hours[index];
          _currentHour = t.isFree ? t : null;
        });
        _notify(_currentHour);
      },
    );
  }

  @override
  dispose() {
    super.dispose();
    _scrollController.removeListener(_onHourChanged);
  }
}
