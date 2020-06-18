// This is a basic Flutter widget test.
// To perform an interaction with a widget in your test, use the WidgetTester utility that Flutter
// provides. For example, you can send tap and scroll gestures. You can also use WidgetTester to
// find child widgets in the widget tree, read text, and verify that the values of widget properties
// are correct.

import 'package:flutter_test/flutter_test.dart';
import 'package:timesget/models/work_week.dart';

void main() {
  test('TimeRange is empty', () {
    final json = Map<String, dynamic>();
    json['fri'] = "8:00-20:00";

    final tr = TimeRange.fromJsonMap(json, 'mon');
    expect(tr, isNotNull);
  });

  test('TimeRange is full', () {
    final json = Map<String, dynamic>();
    json['mon'] = "8:00-20:00";

    final tr = TimeRange.fromJsonMap(json, 'mon');
    expect(tr.start, isNotNull);
  });

  // Compearing
  test('TimeRange inside another TimeRange', () {
    final outer = TimeRange(start: Time(hour: 11), end: Time(hour: 14));
    final inner = TimeRange(start: Time(hour: 12), end: Time(hour: 13));

    final res = outer.isCross(inner);
    expect(res, true);
  });

  test('TimeRange cross start', () {
    final outer = TimeRange(start: Time(hour: 11), end: Time(hour: 14));
    final inner = TimeRange(start: Time(hour: 10), end: Time(hour: 13));

    final res = outer.isCross(inner);
    expect(res, true);
  });

  test('TimeRange cross end', () {
    final outer = TimeRange(start: Time(hour: 11), end: Time(hour: 14));
    final inner = TimeRange(start: Time(hour: 12), end: Time(hour: 15));

    final res = outer.isCross(inner);
    expect(res, true);
  });

  test('TimeRanges are equal', () {
    final outer = TimeRange(start: Time(hour: 11), end: Time(hour: 14));
    final inner = TimeRange(start: Time(hour: 11), end: Time(hour: 14));

    final res = outer.isCross(inner);
    expect(res, true);
  });

  test('TimeRanges inside', () {
    final outer = TimeRange(start: Time(hour: 9), end: Time(hour: 15));
    final inner = TimeRange(start: Time(hour: 11), end: Time(hour: 14));

    final res = inner.isCross(outer);
    expect(res, true);
  });

  test('TimeRanges 1', () {
    final outer = TimeRange(start: Time(hour: 9), end: Time(hour: 10));
    final inner = TimeRange(start: Time(hour: 11), end: Time(hour: 12));

    final res = inner.isCross(outer);
    expect(res, false);
  });

  test('TimeRanges 2', () {
    final outer = TimeRange(start: Time(hour: 9), end: Time(hour: 10));
    final inner = TimeRange(start: Time(hour: 11), end: Time(hour: 12));

    final res = outer.isCross(inner);
    expect(res, false);
  });

  test('TimeRanges are not crossing', () {
    final first = TimeRange(start: Time(hour: 9), end: Time(hour: 10));
    final seccond = TimeRange(start: Time(hour: 10), end: Time(hour: 11));

    final res = first.isCross(seccond);
    expect(res, false);

    final res1 = seccond.isCross(first);
    expect(res1, false);
  });
}
