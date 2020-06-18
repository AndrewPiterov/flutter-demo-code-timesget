import 'package:flutter/material.dart';
import 'package:timesget/all_translations.dart';
import 'package:timesget/components/3rd/calendar.dart';
import 'package:timesget/components/buttons.dart';
import 'package:timesget/models/work_week.dart';
import 'package:timesget/services/app_utils.dart';
import 'package:timesget/services/device_info.dart';
import 'package:timesget/styles/colors.dart';
import 'package:timesget/styles/constants.dart';
import 'package:timesget/styles/text_styles.dart';

typedef void ChooseDateCallback(Date spec);

const _widgetName = "choose_date_widget";
String _translate(String key) {
  return allTranslations.concatText([_widgetName, key]);
}

class ChooseDateComponent extends StatefulWidget {
  final ChooseDateCallback goToBack;
  final Date initialDate;
  final List<WeekDays> disableDays;
  final bool isTodayOver;

  ChooseDateComponent(this.goToBack,
      {this.initialDate, this.disableDays, this.isTodayOver = false});

  @override
  _ChooseDateComponentState createState() {
    return new _ChooseDateComponentState(initialDate);
  }
}

class _ChooseDateComponentState extends State<ChooseDateComponent> {
  Date _initialDate;
  Date _selectedDate;

  _ChooseDateComponentState(this._initialDate) {
    _selectedDate = _initialDate ?? Date.today;
  }

  Widget _buildCalendar(BuildContext context) {
    return Calendar(
      isSunFirst: false,
      onSelectedRangeChange: (range) => print(range),
      dayBuilder: (BuildContext context, DateTime day) {
        final isDisabled = (widget.disableDays != null &&
                widget.disableDays
                    .contains(WeekDays.values[day.weekday - 1])) ||
            (day.add(Duration(days: 1)).isBefore(DateTime.now())) ||
            (Date.from(day).isToday && widget.isTodayOver);

        final isSelected = _selectedDate.isSame(Date.from(day));

        final decoration = isSelected
            ? BoxDecoration(
                color: AppColors.calendarDaySelected,
                borderRadius: BorderRadius.circular(14.0))
            : null;

        final circle = isSelected
            ? Container(
                width: 25.0,
                height: 25.0,
                decoration: decoration,
              )
            : AppConstants.nothing;

        final label = Padding(
          padding: EdgeInsets.only(top: 2),
          child: Text(
            day.day.toString(),
            style: AppTextStyles.calendarDay(
                selected: isSelected, disabled: isDisabled),
            textAlign: TextAlign.center,
          ),
        );

        final stack = Stack(
          children: [circle, label],
          alignment: Alignment.center,
        );

        // return stack;

        return InkWell(
            onTap: isDisabled
                ? null
                : () {
                    setState(() {
                      _selectedDate = Date.from(day);
                    });
                  },
            child: stack);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Text(
              DeviceInfo.isSmallWidth
                  ? _translate('date_short')
                  : _translate('date_long'),
              style: AppTextStyles.text,
            ),
            Text(AppUtils.formatDateToString(_selectedDate),
                style: AppTextStyles.date(MediaQuery.of(context)))
          ],
        ),
        Expanded(
          child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildCalendar(context),
                Center(
                  child: Text(
                    _translate('desc'),
                    style: AppTextStyles.text,
                    textAlign: TextAlign.center,
                  ),
                ),
              ]),
        ),
        AppColoredButton(
          allTranslations.text('choose.button'),
          isActive: _selectedDate != null,
          onTap: () {
            if (widget.goToBack == null) {
              return;
            }
            widget.goToBack(_selectedDate);
          },
        )
      ]),
    );
  }
}
