import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:timesget/all_translations.dart';
import 'package:timesget/components/buttons.dart';
import 'package:timesget/components/tags/text.dart';
import 'package:timesget/components/value_picker.dart';
import 'package:timesget/models/worker.dart';
import 'package:timesget/models/work_week.dart';
import 'package:timesget/services/app_utils.dart';
import 'package:timesget/services/bookings/current_bookung.service.dart';
import 'package:timesget/styles/colors.dart';
import 'package:timesget/styles/constants.dart';
import 'package:rxdart/rxdart.dart';

const _widgetName = "booking_time_choose";
String _translate(String key) {
  return allTranslations.concatText([_widgetName, key]);
}

class BookingTimeView extends StatelessWidget {
  final Time time;
  final Worker worker;
  final Date date;
  final dynamic goToBack;

  BookingTimeView(this.worker, this.date, {this.time, this.goToBack});

  Stream<WorkerTime> get currentTime => _subj.stream.asBroadcastStream();
  final _subj = BehaviorSubject<WorkerTime>.seeded(null);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<bool>(
        stream: CurrentBookingService().isBusy$,
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return AppConstants.circleSpinner;
          }

          final data = CurrentBookingService().data;

          // choose day and range
          final weekday = WeekDays.values[date.weekday - 1];
          final range = worker.workWeek.rangeOf(weekday);
          if (range.isEmpty) {
            return Container(
                child: Center(
                    child: Text(
              _translate('worker_does_not_work'),
              textAlign: TextAlign.center,
            )));
          }

          if (data.hours.length == 0) {
            return Container(
                child: Center(
                    child: Text(
              _translate('booking_time_is_finished'),
              textAlign: TextAlign.center,
            )));
          }

          var init = data.hours.firstWhere((x) => x.isFree, orElse: () => null);

          if (time != null) {
            final maybe = data.hours.firstWhere(
                (x) => (time.hour == x.hour && time.minute == x.minute));
            if (maybe != null && maybe.isFree) {
              init = maybe;
            }
          }

          final initIndex = data.hours.indexOf(init);
          _subj.add(init);

          return Container(
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  text(_translate('booking_time')),
                  AppConstants.spaceH2(10),
                  StreamBuilder(
                      stream: currentTime,
                      builder: (context, AsyncSnapshot<WorkerTime> snap) {
                        if (!snap.hasData) {
                          return AppConstants.circleSpinner;
                        }
                        return text(
                            snap.data.isFree
                                ? _translate('free')
                                : _translate('busy'),
                            color: snap.data.isFree
                                ? AppColors.link
                                : AppColors.bookTimeIsBusy);
                      }),
                  AppConstants.spaceH(10),
                  Expanded(
                    child: Container(
                        width: 145.0,
                        child: ValuePicker<WorkerTime>(
                          data.hours,
                          mapLabel: (x, isSelected) => AppUtils.buildHourLabel(
                              context, x,
                              isSelected: isSelected),
                          onChanged: (t) {
                            _subj.add(t);
                          },
                          initialSelectedIndex: initIndex,
                        )),
                  ),
                  AppConstants.spaceH(10),
                  StreamBuilder(
                      stream: currentTime,
                      builder: (context, AsyncSnapshot<WorkerTime> snap) {
                        if (!snap.hasData) {
                          return AppConstants.circleSpinner;
                        }
                        if (snap.data.isFree) {
                          return AppColoredButton(
                            _translate('choose'),
                            isActive: true,
                            color: AppColors.buttonActive,
                            activeTitleColor: AppColors.buttonActiveText,
                            onTap: () {
                              if (goToBack == null) {
                                return;
                              }
                              goToBack(snap.data.time);
                            },
                          );
                        } else {
                          return AppColoredButton(
                            _translate('choose').toUpperCase(),
                            isActive: false,
                            color: AppColors.buttonActive,
                            activeTitleColor: AppColors.buttonActiveText,
                          );
                        }
                      })
                ]),
          );
        });
  }
}
