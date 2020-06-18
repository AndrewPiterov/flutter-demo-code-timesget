import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:timesget/models/booking.model.dart';

class WorkWeek {
  final TimeRange mon;
  final TimeRange tue;
  final TimeRange wed;
  final TimeRange thu;
  final TimeRange fri;
  final TimeRange sat;
  final TimeRange sun;

  WorkWeek(
      {this.mon, this.tue, this.wed, this.thu, this.fri, this.sat, this.sun});

  static WorkWeek get empty => WorkWeek();

  List<WeekDays> get vocationDays {
    final res = List<WeekDays>();

    if (mon == null || mon.isEmpty) {
      res.add(WeekDays.monday);
    }

    if (tue == null || tue.isEmpty) {
      res.add(WeekDays.tue);
    }

    if (wed == null || wed.isEmpty) {
      res.add(WeekDays.wed);
    }

    if (thu == null || thu.isEmpty) {
      res.add(WeekDays.thu);
    }

    if (fri == null || fri.isEmpty) {
      res.add(WeekDays.fri);
    }

    if (sat == null || sat.isEmpty) {
      res.add(WeekDays.sat);
    }

    if (sun == null || sun.isEmpty) {
      res.add(WeekDays.sunday);
    }

    return res;
  }

  static WorkWeek fromJsonMap(dynamic json) {
    final x = json;

    return WorkWeek(
      mon: TimeRange.fromJsonMap(x, 'mon'),
      tue: TimeRange.fromJsonMap(x, 'tue'),
      wed: TimeRange.fromJsonMap(x, 'wed'),
      thu: TimeRange.fromJsonMap(x, 'thu'),
      fri: TimeRange.fromJsonMap(x, 'fri'),
      sat: TimeRange.fromJsonMap(x, 'sat'),
      sun: TimeRange.fromJsonMap(x, 'sun'),
    );
  }

  Iterable<DayTimeRange> get days {
    // Monday,Tuesday, Wednesday, Thursday, Friday, and Saturday. Sunday
    var arr = List<DayTimeRange>();
    arr.add(DayTimeRange('Monday', mon));
    arr.add(DayTimeRange('Tuesday', tue));
    arr.add(DayTimeRange('Wednesday', wed));
    arr.add(DayTimeRange('Thursday', thu));
    arr.add(DayTimeRange('Friday', fri));
    arr.add(DayTimeRange('Saturday', sat));
    arr.add(DayTimeRange('Sunday', sun));
    return arr;
  }

  TimeRange rangeOf(WeekDays day) {
    switch (day) {
      case WeekDays.monday:
        return mon;
      case WeekDays.tue:
        return tue;
      case WeekDays.wed:
        return wed;
      case WeekDays.thu:
        return thu;
      case WeekDays.fri:
        return fri;
      case WeekDays.sat:
        return sat;
      case WeekDays.sunday:
        return sun;
    }

    return null;
  }
}

enum WeekDays {
  monday,
  tue,
  wed,
  thu,
  fri,
  sat,
  sunday,
}

class DayTimeRange {
  final String dayTitle;
  final TimeRange timeRange;

  DayTimeRange(this.dayTitle, this.timeRange);
}

class TimeRange {
  Time start;
  Time end;

  String get label =>
      start == null || start == null ? "" : "${start.label}-${end.label}";

  TimeRange({this.start, this.end});

  bool get isEmpty =>
      (this.start == null || this.end == null) ||
      (this.start.isEmpty && this.end.isEmpty);

  get durationInMinutes => end.totalMinutes - start.totalMinutes;

  static TimeRange fromJsonMap(Map<dynamic, dynamic> json, String prop) {
    if (!json.containsKey(prop)) {
      return TimeRange();
    }

    final String str = json[prop];
    final arr = str.split('-');

    if (arr.length < 2) {
      return TimeRange();
    }

    return TimeRange(start: Time.fromStr(arr[0]), end: Time.fromStr(arr[1]));
  }

  @override
  bool operator ==(dynamic other) {
    if (other.runtimeType == TimeRange) {
      return start == other.start && end == other.end;
    }

    return false;
  }

  bool earlyOrSameTime(TimeRange other) {
    return start.hour < other.start.hour ||
        (start.hour == other.start.hour && start.minute <= other.start.minute);
  }

  bool isInRange(Time checkTime) {
    final inside = start <= checkTime && checkTime <= end;
    return inside;
  }

  bool isCross(dynamic other) {
    if (other is Booking) {
      return _isCross(other.range);
    }

    if (other is TimeRange) {
      return _isCross(other);
    }

    return false;
  }

  bool _isCross(TimeRange other) {
    final first =
        this.start.totalMinutes <= other.start.totalMinutes ? this : other;
    final last = first == this ? other : this;

    final aGreaterOrEqualC =
        first.start.totalMinutes <= last.start.totalMinutes;
    final cInsideFirst = last.start.totalMinutes < first.end.totalMinutes;

    return aGreaterOrEqualC && cInsideFirst;
  }

  // @override
  // bool operator >=(dynamic other) {
  //   if (other.runtimeType == TimeRange) {
  //     final res = start <= other.start && end >= other.end;
  //     return res;
  //   }
  //   return false;
  // }

  // // @override
  // bool operator <=(dynamic other) {
  //   if (other.runtimeType == TimeRange) {
  //     return start <= other.start && end <= other.end;
  //   }
  //   return false;
  // }

  // Override hashCode using strategy from Effective Java,
  // Chapter 11.
  @override
  int get hashCode {
    int result = 17;
    result = 37 * result + start.hashCode;
    result = 37 * result + end.hashCode;
    return result;
  }
}

class Date {
  final year;
  final month;
  final day;

  get weekday => DateTime(year, month, day).weekday;

  DateTime get asDateTime => DateTime(year, month, day);

  Date({@required this.year, @required this.month, @required this.day});

  Date add(Duration duration) {
    final t = asDateTime.add(duration);
    return Date(year: t.year, month: t.month, day: t.day);
  }

  bool isSame(Date date) {
    if (date == null) {
      throw 'Date to compare is null!';
    }

    return year == date.year && month == date.month && day == date.day;
  }

  bool isAfter(Date after, {bool orSame = false}) {
    if (after == null) {
      throw 'Date to compare is null!';
    }

    if (year < after.year) {
      return false;
    }

    if (year > after.year) {
      return true;
    }

    // years are equal - comapre month
    if (month < after.month) {
      return false;
    }

    if (month > after.month) {
      return true;
    }

    // months are equal - comapre days
    if (day < after.day) {
      return false;
    }

    if (day > after.day) {
      return true;
    }

    return orSame;
  }

  bool get isToday {
    return year == today.year && month == today.month && day == today.day;
  }

  static Date get today => from(DateTime.now());

  static Date from(DateTime dt) {
    if (dt == null) {
      throw 'DateTime is null';
    }

    return Date(year: dt.year, month: dt.month, day: dt.day);
  }

  @override
  String toString() {
    return '$year/$month/$day';
  }
}

class Time {
  final int hour;
  final int minute;

  int get totalMinutes => hour * 60 + minute;

  get isEmpty => label.isEmpty;

  get label => hour == null || minute == null
      ? ""
      : "$hour:${minute < 10 ? '0$minute' : minute}";

  Time({@required this.hour, this.minute = 0});
  static Time corrected({@required int hour}) {
    if (hour < 0) {
      return Time(hour: 0);
    }

    if (hour < 24) {
      return Time(hour: hour);
    }

    if (hour == 24) {
      return Time(hour: 0);
    }

    final r = hour % 24;
    return Time(hour: r);
  }

  TimeOfDay get asDayOfTime => TimeOfDay(hour: hour, minute: minute);

  static Time fromStr(String str) {
    if (str == null || str.isEmpty) {
      return Time(hour: null);
    }

    final arr = str.split(':');

    final h = arr[0];
    final m = arr.length > 1 ? arr[1] : 0;

    return Time(hour: int.parse(h), minute: int.parse(m));
  }

  Time add(String timePart, int amount) {
    if (timePart != 'hours' && timePart != 'minutes') {
      // throw Error(`Unknown time's part as '${part}'`)
    }

    final me = hour * 60 + minute;
    final additional = timePart == 'hours' ? amount * 60 : amount;
    final totalMinutes = me + additional;

    return Time.fromMinutes(totalMinutes);
  }

  bool isAfter(Time time, {bool orSame = false}) {
    if (time == null) {
      throw 'You could not compare null with Time!';
    }

    if (hour > time.hour) {
      return true;
    }

    if (hour < time.hour) {
      return false;
    }

    // hours are same - compare minutes
    if (minute > time.minute) {
      return true;
    }

    if (minute < time.minute) {
      return false;
    }

    return orSame;
  }

  bool timeLessThen(Time b) {
    if (b == null) {
      return false;
    }

    return hour < b.hour || (hour == b.hour && minute < b.minute);
  }

  bool timeGreaterThen(Time b) {
    if (b == null) {
      return false;
    }

    return b.timeLessThen(this);
  }

  static Time get now =>
      Time(hour: DateTime.now().hour, minute: DateTime.now().minute);

  static Time from(TimeOfDay time) =>
      Time(hour: time.hour, minute: time.minute);

  static Time fromMinutes(int amount) {
    var h = (amount / 60).floor();

    if (h == 24) {
      h = 0;
    }

    if (h > 24) {
      var x = (h / 24).floor();
      h = x;
    }

    final m = amount % 60;
    return Time(hour: h, minute: m);
  }

  @override
  bool operator ==(dynamic other) {
    return (other.runtimeType == Time) &&
        hour == other.hour &&
        minute == other.minute;
  }

  // @override
  bool operator >=(dynamic other) {
    if (other.runtimeType == Time) {
      return totalMinutes >= other.totalMinutes;
    }
    return false;
  }

  // @override
  bool operator <=(dynamic other) {
    if (other.runtimeType == Time) {
      return totalMinutes <= other.totalMinutes;
    }
    return false;
  }

  // Override hashCode using strategy from Effective Java,
  // Chapter 11.
  @override
  int get hashCode {
    int result = 17;
    result = 37 * result + hour.hashCode;
    result = 37 * result + minute.hashCode;
    return result;
  }

  @override
  String toString() {
    return '$hour:$minute';
  }
}
