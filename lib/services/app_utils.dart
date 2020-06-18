import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:date_format/date_format.dart';
import 'package:timesget/models/worker.dart';
import 'package:timesget/models/work_week.dart';
import 'package:timesget/services/dateUtils.dart';
import 'package:timesget/styles/text_styles.dart';

class AppUtils {
  static DateTime stringToDate(String input) {
    if (input == null || input.isEmpty) {
      return null;
    }

    final arr = input.split('-').map((x) => int.parse(x)).toList();
    return DateTime(arr[0], arr[1], arr[2]);
  }

  static String formatHttpFailResponse(Response response) =>
      'HTTP FAIL (${response.statusCode}): ${response.body}';

  static formatDateToString(Date date,
          {devider = '.', fillWithZero = false, yearFirst = false}) =>
      date == null
          ? ''
          : yearFirst
              ? formatDate(date.asDateTime, [yyyy, devider, mm, devider, dd])
              : formatDate(date.asDateTime, [dd, devider, mm, devider, yyyy]);

  static formatTimeToString(Time time) => time == null
      ? ''
      : "${time.hour}:${time.minute < 10 ? '0${time.minute}' : time.minute}";

  static datePlusTime(DateTime date, TimeOfDay time) =>
      date.add(Duration(minutes: time.hour * 60 + time.minute));

  static List<Time> generateHours({int from, int till, int step = 30}) {
    assert(from != null);
    assert(till != null);
    assert(from < till);

    var traker = from;
    final hours = List<Time>();
    while (traker < till) {
      hours.add(Time(hour: traker, minute: 0));
      traker++;
    }
    return hours;
  }

  static formatDateToStringForCollection(Date date) =>
      AppUtils.formatDateToString(date,
          devider: '-', fillWithZero: true, yearFirst: true);

  static List<TimeRange> generateHourRanges(
      {Time from, Time till, int step = 30}) {
    print('from ${from.totalMinutes} till ${till.totalMinutes}');

    assert(from != null);
    assert(till != null);

    if (from == till) {
      return List<TimeRange>();
    }

    assert(from.totalMinutes < till.totalMinutes);

    var trakerSec = from.totalMinutes;
    final tillSec = till.totalMinutes;

    final ranges = List<TimeRange>();
    while (trakerSec < tillSec) {
      final start = Time.fromMinutes(trakerSec);
      final end = Time.fromMinutes(start.totalMinutes + step);

      ranges.add(TimeRange(start: start, end: end));
      trakerSec += step;
    }
    return ranges;
  }

  static List<String> weekdays({bool sunFirst: false}) =>
      sunFirst ? weekdaysSunFirst : weekdaysSunLast;

  static const List<String> weekdaysSunFirst = const [
    "Sun",
    "Mon",
    "Tue",
    "Wed",
    "Thu",
    "Fri",
    "Sat"
  ];

  static const List<String> weekdaysSunLast = const [
    "Mon",
    "Tue",
    "Wed",
    "Thu",
    "Fri",
    "Sat",
    "Sun",
  ];

  static List<DateTime> daysInMonth(DateTime month, {bool sunIsFirst = false}) {
    var first = DateUtils.firstDayOfMonth(month);
    var daysBefore = first.weekday - (sunIsFirst ? 0 : 1);
    var firstToDisplay = first.subtract(Duration(days: daysBefore));
    var last = DateUtils.lastDayOfMonth(month);

    var daysAfter = AppUtils.daysAfter(last, sunIsFirst: sunIsFirst);

    var lastToDisplay = last.add(Duration(days: daysAfter));
    return DateUtils.daysInRange(
            firstToDisplay, lastToDisplay.add(Duration(days: 1)))
        .toList();
  }

  static Widget buildHourLabel(BuildContext context, WorkerTime time,
      {bool isSelected = false}) {
    final mq = MediaQuery.of(context);
    return Text(
      AppUtils.formatTimeToString(time.time),
      style: time.isFree
          ? AppTextStyles.hourIsFree(mq, isSelected: isSelected)
          : AppTextStyles.hourIsBusy(mq),
      textAlign: TextAlign.center,
    );
  }

  static int daysAfter(DateTime day, {sunIsFirst = true}) {
    if (!sunIsFirst) {
      return 7 - day.weekday;
    }

    var wd = day.weekday + 1;
    wd = wd > 7 ? wd - 7 : wd;

    return 7 - wd;
  }

  static bool areSameDay2(DateTime a, DateTime b) {
    if (a == null || b == null) {
      return false;
    }
    return Date.from(a).isSame(Date.from(b));
  }

  static bool timeLessThen2(TimeOfDay a, TimeOfDay b) {
    if (a == null || b == null) {
      return false;
    }

    return Time.from(a).timeLessThen(Time.from(b));
  }

  static String capitalizeFirstLetter(String s) =>
      s == null || s == '' ? '' : '${s[0].toUpperCase()}${s.substring(1)}';

  static String pluralYear(int years) {
    final str = years.toString();
    final last = str.substring(str.length - 1);

    if (years < 1 || last == "1" && years != 11) {
      return "год";
    }

    switch (last) {
      case "2":
      case "3":
      case "4":
        return "года";
      case "5":
      case "6":
      case "7":
      case "8":
      case "9":
      case "0":
        return "лет";
      default:
        return "лет";
    }
  }
}
