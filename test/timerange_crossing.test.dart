import 'package:flutter_test/flutter_test.dart';
import 'package:timesget/models/work_week.dart';

void main() {
  test('Hour after hour - is not cross', () {
    final a = TimeRange(
        start: Time(hour: 8, minute: 0), end: Time(hour: 9, minute: 0));
    final b = TimeRange(
        start: Time(hour: 9, minute: 0), end: Time(hour: 10, minute: 0));
    expect(a.isCross(b), isFalse);
  });
}
