import 'package:rxdart/rxdart.dart';
import 'package:timesget/models/booking.model.dart';
import 'package:timesget/models/work_week.dart';
import 'package:timesget/models/worker.dart';
import 'package:timesget/services/bookings/booking_data_request.dart';
import 'package:timesget/services/bookings/booking_data_result.dart';
import 'package:timesget/services/company_service.dart';
import 'package:timesget/services/user.services.dart';
import 'package:timesget/services/workers.service.dart';

class CurrentBookingService {
  BookingDataResult data;
  Stream<BookingDataResult> data$;
  BehaviorSubject<BookingDataResult> _data;

  BehaviorSubject<bool> _isBusy;
  Stream<bool> isBusy$;

  BehaviorSubject<Worker> _worker;
  BehaviorSubject<Date> _date;
  BehaviorSubject<Time> _time;

  BookingDataRequest _lastRequest;

  CurrentBookingService._() {
    _worker = BehaviorSubject<Worker>.seeded(null);
    _date = BehaviorSubject<Date>.seeded(null);
    _time = BehaviorSubject<Time>.seeded(null);

    _isBusy = BehaviorSubject.seeded(false);
    _data = BehaviorSubject.seeded(null);

    isBusy$ = _isBusy.stream;
    data$ = _data.stream;

    Observable.combineLatest4(
        _worker, _date, _time, UserService().futuredBookings$, (w, d, t, f) {
      return [
        BookingDataRequest(
            worker: w, date: d ?? Date.today, time: t ?? Time.now),
        f
      ];
    }).listen((data) async {
      _lastRequest = data[0];
      print('Booking data $_lastRequest');
      await _findNearestHour(_lastRequest, data[1]);
    });
  }

  Future<BookingDataResult> _findNearestHour(BookingDataRequest requestData,
      List<UserBooking> userFutureBookings) async {
    _isBusy.add(true);
    if (requestData.worker == null) {
      _isBusy.add(false);
      return null;
    }

    final ti = CompanyDataService().timeCuttingMinutes;

    final hours = await WorkerService.nearestFreeHours(
        requestData.worker, requestData.date, userFutureBookings, ti);

    final result = BookingDataResult(requestData, hours);

    data = result;
    _data.add(result);
    _isBusy.add(false);

    return result;
  }

  workerIs(Worker worker) {
    _worker.add(worker);
  }

  dateIs(Date date) {
    _date.add(date);
  }

  timeIs(Time time) {
    _time.add(time);
  }

  reset() {
    _worker.add(null);
    _date.add(null);
    _time.add(null);
  }

  static final CurrentBookingService _singleton = CurrentBookingService._();

  factory CurrentBookingService() {
    return _singleton;
  }
}
