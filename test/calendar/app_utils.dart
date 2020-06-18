import 'package:flutter_test/flutter_test.dart';
import 'package:timesget/services/app_utils.dart';

void main() {
  test('complete week when last day in month is Sunday and Sunday is last', () {
    final date = DateTime(2018, 9, 30);
    final days = AppUtils.daysInMonth(date, sunIsFirst: false);

    expect(days.length, 35);

    expect(days.first.day, 27);
    expect(days.first.month, 8);

    expect(days.last.day, 30);
    expect(days.last.month, 9);
  });

  test('complete week when last day in month is Sunday and Sunday is first',
      () {
    final date = DateTime(2018, 9, 30);
    final days = AppUtils.daysInMonth(date, sunIsFirst: true);

    expect(days.length, 42);

    expect(days.first.day, 26);
    expect(days.first.month, 8);

    expect(days.last.day, 6);
    expect(days.last.month, 10);
  });

  test('complete week when last day in month is not Sunday and Sunday is first',
      () {
    final date = DateTime(2018, 10, 15);
    final days = AppUtils.daysInMonth(date, sunIsFirst: true);

    expect(days.length, 35);

    expect(days.first.day, 30);
    expect(days.first.month, 9);

    expect(days.last.day, 3);
    expect(days.last.month, 11);
  });

  test('complete week when last day in month is not Sunday and Sunday is last',
      () {
    final date = DateTime(2018, 10, 15);
    final days = AppUtils.daysInMonth(date, sunIsFirst: false);

    expect(days.length, 35);

    expect(days.first.day, 1);
    expect(days.first.month, 10);

    expect(days.last.day, 4);
    expect(days.last.month, 11);
  });

  test('days after Sunday is last', () {
    final last = DateTime(2018, 10, 31);
    expect(AppUtils.daysAfter(last, sunIsFirst: false), 4);
  });

  test('days after Sunday is first', () {
    final last = DateTime(2018, 9, 30);
    expect(AppUtils.daysAfter(last, sunIsFirst: true), 6);
  });

  test('31 August', () {
    final last = DateTime(2018, 8, 31);
    expect(AppUtils.daysAfter(last, sunIsFirst: true), 1);
  });
}
