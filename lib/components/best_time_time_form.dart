import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:timesget/all_translations.dart';
import 'package:timesget/components/buttons.dart';
import 'package:timesget/models/work_week.dart';
import 'package:timesget/services/app_utils.dart';
import 'package:timesget/services/best_time.helper.dart';
import 'package:timesget/services/device_info.dart';
import 'package:timesget/styles/colors.dart';
import 'package:timesget/styles/text_styles.dart';

const _widgetName = "best_time_time_form";
String _translate(String key) {
  return allTranslations.concatText([_widgetName, key]);
}

class BestTimeTimeFormOCmponent extends StatefulWidget {
  final BestTimeRangeAvailability availability;
  BestTimeTimeFormOCmponent({@required this.availability});

  @override
  _BestTimeTimeFormOCmponentState createState() =>
      _BestTimeTimeFormOCmponentState();
}

class _BestTimeTimeFormOCmponentState extends State<BestTimeTimeFormOCmponent> {
  Time _start;
  Time _end;

  FixedExtentScrollController _endScrollController;

  List<Time> _hours;

  @override
  void initState() {
    super.initState();
    this._start = widget.availability.start;
    this._end = widget.availability.end;
    _hours = AppUtils.generateHours(from: _start.hour + 1, till: 25);
    _endScrollController = FixedExtentScrollController(
        initialItem:
            _hours.where((x) => x.isAfter(_start)).toList().indexOf(_end));
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isToday = widget.availability.date.isToday;
    return SingleChildScrollView(
      child: Column(children: [
        Text(
          _translate('choose'),
          style: AppTextStyles.text,
          textAlign: TextAlign.center,
        ),
        ConstrainedBox(
          constraints:
              BoxConstraints(maxWidth: DeviceInfo().width, maxHeight: 300.0),
          child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: AppTimePicker(
                      init: _start,
                      isTill: true,
                      isToday: isToday,
                      callback: (time) {
                        final isGreaterOrEqual =
                            time.isAfter(_end, orSame: true);
                        final newEnds = AppUtils.generateHours(
                            from: time.hour + 1, till: 25);
                        final newEnd =
                            isGreaterOrEqual ? Time(hour: time.hour + 1) : _end;

                        setState(() {
                          _hours = newEnds;
                          _start = time;
                          if (newEnd != _end) {
                            _end = newEnd;
                          }
                          // print(_hours.map((x) => x.hour).join(" "));
                          final jumpTo = _hours.indexOf(newEnd);
                          // print('Jump to ${jumpTo + 1} of ${_hours.length}');
                          _endScrollController.jumpToItem(jumpTo);
                        });
                      }),
                ),
                Container(
                  height: 8.0,
                  width: 18.0,
                  color: AppColors.selectedTime,
                ),
                Expanded(
                    child: CupertinoPicker(
                        scrollController: _endScrollController,
                        backgroundColor: Colors.white,
                        diameterRatio: 180.0,
                        looping: false,
                        children: _hours.map((item) {
                          final isSelected = item == _end;
                          return Center(
                              child: Text(item.label,
                                  style: isSelected
                                      ? AppTextStyles.selectedTimePicker
                                      : AppTextStyles.timePicker,
                                  softWrap: false));
                        }).toList(),
                        itemExtent: 65.0,
                        onSelectedItemChanged: (index) {
                          // print('Start $_start. End: $_end. On $index.');
                          if (index > 0 && _end == Time(hour: 24)) {
                            return;
                          }
                          if (_hours[index] != _end) {
                            setState(() {
                              _end = _hours[index];
                            });
                          }
                        }))
              ]),
        ),
        AppColoredButton(
          _translate('button'),
          isActive: _start != null && _end != null,
          onTap: () {
            final wa = widget.availability;
            final start = _start == null ? wa.start : _start;
            final end = _end == null ? wa.end : _end;
            final availability = BestTimeRangeAvailability(
                date: wa.date,
                start: start,
                end: start.isAfter(end) ? Time(hour: 24) : end);
            Navigator.pop(context, availability);
          },
        )
      ]),
    );
  }
}

class AppTimePicker extends StatefulWidget {
  final callback;
  final bool isTill;
  final Time init;
  final bool isToday;
  final bool isEnd;
  final Time min;

  AppTimePicker(
      {@required this.init,
      this.isTill = false,
      this.isToday = false,
      this.isEnd = false,
      this.min,
      this.callback});

  @override
  _AppTimePickerState createState() => _AppTimePickerState();
}

class _AppTimePickerState extends State<AppTimePicker> {
  Widget _build(BuildContext context) {
    final isToday = widget.isToday;
    var start = isToday ? DateTime.now().hour + 1 : 0;
    start = widget.isEnd ? start + 1 : start;
    start = widget.min == null
        ? start
        : start >= widget.min.hour ? start : widget.min.hour;
    final end = widget.isEnd ? 25 : 24;
    final _hours = AppUtils.generateHours(from: start, till: end);

    final initHour = widget.init.hour;
    final correctHour = initHour >= start && initHour <= end
        ? initHour
        : initHour < start ? start : end;

    final i = _hours.indexOf(Time(hour: correctHour));

    // if (widget.min != null) {
    //   final x = initHour;
    //   print('Init hour: $initHour and correct: $correctHour and index: $i');
    // }

    final arr = _hours.map((item) {
      final isSelected = item == Time(hour: correctHour);
      return Center(
          child: Text(item.label,
              style: isSelected
                  ? AppTextStyles.selectedTimePicker
                  : AppTextStyles.timePicker,
              softWrap: false));
    }).toList();

    return CupertinoPicker(
        scrollController: FixedExtentScrollController(initialItem: i),
        backgroundColor: Colors.white,
        diameterRatio: 180.0,
        looping: false,
        children: arr,
        itemExtent: 65.0,
        onSelectedItemChanged: (index) {
          setState(() {
            if (widget.callback != null) {
              widget.callback(_hours[index]);
            }
          });
        });
  }

  @override
  Widget build(BuildContext context) {
    return _build(context);
  }
}
