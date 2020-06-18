import 'package:timesget/models/work_week.dart';
import 'package:timesget/models/worker.dart';
import 'package:timesget/services/bookings/booking_data_request.dart';
import 'package:timesget/services/workers.service.dart';

class BookingDataResult {
  final BookingDataRequest request;

  Worker get worker => request.worker;

  final FreeHoursOfDay _freeHours;

  bool get tryBookToday => date.isSame(Date.today);
  bool get nextDay => !tryBookToday;

  Date get date => _freeHours.date;
  Time get bookHour {
    final isFree = _freeHours.contain(request.time);

    final against = request.time;

    if (!isFree) {
      if (nextDay) {
        return firstFreeHour;
      }

      // same day
      final correct = freeHours.firstWhere((x) => x.isAfter(request.time));

      return correct;
    }

    if (against.timeLessThen(firstFreeHour)) {
      return firstFreeHour;
    } else if (lastFreeHour.timeLessThen(against)) {
      return nextDay ? firstFreeHour : lastFreeHour;
    } else {
      return against;
    }
  }

  List<WorkerTime> get hours {
    final res = tryBookToday
        ? _freeHours.workerHours.where((x) => x.time.isAfter(Time.now)).toList()
        : _freeHours.workerHours.toList();

    return res;
  }

  List<Time> get freeHours => hours.isEmpty
      ? List<Time>()
      : hours.where((x) => x.isFree).map((x) => x.time).toList();

  Time get firstFreeHour =>
      freeHours.firstWhere((x) => true, orElse: () => null);

  Time get lastFreeHour => freeHours.lastWhere((x) => true, orElse: () => null);

  bool get notFoundFreeHours => firstFreeHour == null;

  List<WeekDays> get disableDays => worker.workWeek?.vocationDays;
  bool get todayIsOver {
    final less = hours.last.time.isAfter(Time.now);
    return date.isAfter(Date.today) || (date.isToday && !less);
  }

  BookingDataResult(this.request, this._freeHours);

  @override
  String toString() {
    return '($worker) on $date at $firstFreeHour';
  }
}
