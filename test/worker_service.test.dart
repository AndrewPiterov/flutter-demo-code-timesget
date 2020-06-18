import 'package:timesget/models/work_week.dart';
import 'package:timesget/services/workers.service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('One hour is busy', () {
    List<TimeRange> hours = List<TimeRange>()
      ..add(TimeRange(
          start: Time(hour: 8, minute: 0), end: Time(hour: 9, minute: 0)));
    List<TimeRange> bookings = List<TimeRange>()
      ..add(TimeRange(
          start: Time(hour: 8, minute: 0), end: Time(hour: 9, minute: 0)));

    final list = WorkerService.computeWorkerHours(hours, bookings);

    expect(list.length, 1);
    expect(list.first.isFree, false);
  });

  test('One hours are equal but minutes are not', () {
    List<TimeRange> hours = List<TimeRange>()
      ..add(TimeRange(
          start: Time(hour: 9, minute: 0), end: Time(hour: 10, minute: 0)));

    List<TimeRange> bookings = List<TimeRange>()
      ..add(TimeRange(
          start: Time(hour: 9, minute: 0), end: Time(hour: 9, minute: 30)));

    final list = WorkerService.computeWorkerHours(hours, bookings);

    expect(list.length, 1);
    expect(list.first.isFree, false);
  });

  test('Two hours. One is busy', () {
    List<TimeRange> hours = List<TimeRange>()
      ..add(TimeRange(
          start: Time(hour: 8, minute: 0), end: Time(hour: 9, minute: 0)))
      ..add(TimeRange(
          start: Time(hour: 9, minute: 0), end: Time(hour: 10, minute: 0)));

    List<TimeRange> bookings = List<TimeRange>()
      ..add(TimeRange(
          start: Time(hour: 8, minute: 0), end: Time(hour: 9, minute: 0)));

    final list = WorkerService.computeWorkerHours(hours, bookings);

    expect(list.length, 2);
    expect(list.first.isFree, false);
    expect(list.last.isFree, true);
  });

  test('Free range in day', () {
    final busyHours = List.of([
      TimeRange(start: Time(hour: 7, minute: 0), end: Time(hour: 7, minute: 30))
    ]);

    final dayRange = List.of([
      TimeRange(
          start: Time(hour: 7, minute: 0), end: Time(hour: 7, minute: 30)),
      TimeRange(start: Time(hour: 7, minute: 30), end: Time(hour: 8, minute: 0))
    ]);

    final res =
        WorkerService.hourStates(busyHours, dayRange).where((x) => x.isFree);

    expect(res.length, 1);
    expect(res.first.hour, 7);
    expect(res.first.minute, 30);
  });

  test('Free range in day - 2', () {
    final busyHours = List.of([
      TimeRange(
          start: Time(hour: 7, minute: 0), end: Time(hour: 7, minute: 30)),
      TimeRange(start: Time(hour: 8, minute: 0), end: Time(hour: 8, minute: 30))
    ]);

    final dayRange = List.of([
      TimeRange(
          start: Time(hour: 7, minute: 0), end: Time(hour: 7, minute: 30)),
      TimeRange(
          start: Time(hour: 7, minute: 30), end: Time(hour: 8, minute: 0)),
      TimeRange(start: Time(hour: 8, minute: 0), end: Time(hour: 8, minute: 30))
    ]);

    final res =
        WorkerService.hourStates(busyHours, dayRange).where((x) => x.isFree);

    expect(res.length, 1);
    expect(res.first.hour, 7);
    expect(res.first.minute, 30);
  });
}
