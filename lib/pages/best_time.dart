import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:timesget/all_translations.dart';
import 'package:timesget/components/alert.dart';
import 'package:timesget/components/app_bar.dart';
import 'package:timesget/components/app_bottom_bars.dart';
import 'package:timesget/components/app_drawer.dart';
import 'package:timesget/components/best_time_time_form.dart';
import 'package:timesget/components/choose_date_component.dart';
import 'package:timesget/components/worker_card.dart';
import 'package:timesget/components/worker_specs_view.dart';
import 'package:timesget/components/row_card.dart';
import 'package:timesget/components/tags/h1.dart';
import 'package:timesget/components/tags/text.dart';
import 'package:timesget/models/worker.dart';
import 'package:timesget/models/worker_specialization.dart';
import 'package:timesget/models/work_week.dart';
import 'package:timesget/services/app_utils.dart';
import 'package:timesget/services/best_time.helper.dart';
import 'package:timesget/services/device_info.dart';
import 'package:timesget/services/workers.service.dart';
import 'package:timesget/styles/colors.dart';
import 'package:timesget/styles/constants.dart';
import 'package:timesget/styles/paddings.dart';
import 'package:timesget/styles/text_styles.dart';

const _pageName = "best_time_page";
String _translate(String key) {
  return allTranslations.concatText([_pageName, key]);
}

class BestTimePage extends StatefulWidget {
  @override
  _BestTimePageState createState() => _BestTimePageState();
}

class _BestTimePageState extends State<BestTimePage> {
  WorkerSpecialization _specialist;

  // Date _date;
  // Time _startAt;
  // Time _endAt;

  BestTimeRangeAvailability _availability;

  _BestTimePageState() {
    _availability = BestTimeRangeAvailability.init();
  }

  Future<Date> _selectDate(BuildContext context) async {
    final dialog = CustomAlertDialog(
      title: Text(
        DeviceInfo.androidSmall
            ? allTranslations.text('choose.date')
            : allTranslations.text('choose.date_long'),
        style: AppTextStyles.dialogTitle,
      ),
      content: Container(
        height: 520.0,
        child: ChooseDateComponent(
          (date) {
            Navigator.of(context).pop(date);
          },
          initialDate: _availability.date,
          isTodayOver: BestTimeRangeAvailability.isTodayOver,
        ),
      ),
      hasCloseIcon: true,
    );

    final res = await showDialog(
        barrierDismissible: true,
        context: context,
        builder: (context) => dialog);

    return res == null ? _availability.date : res;
  }

  Future<BestTimeRangeAvailability> _selectTime(
      BuildContext context, BestTimeRangeAvailability ava) async {
    final dialog = CustomAlertDialog(
      title: Text(
        _translate('best_time'),
        style: AppTextStyles.dialogTitle,
      ),
      content: BestTimeTimeFormOCmponent(availability: ava),
      hasCloseIcon: true,
    );

    final res = await showDialog(
        barrierDismissible: true,
        context: context,
        builder: (context) => dialog);

    return res == null ? ava : res;
  }

  String _formatTimeRange(Time a, Time b, {bool verbose: false}) {
    final start = a.label;
    final end = b.label;

    return !verbose
        ? '$start - $end'
        : allTranslations.text('choose.from') +
            ' $start ' +
            allTranslations.text('choose.till') +
            ' $end';
  }

  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context);
    return Scaffold(
        appBar: getAppBar(context),
        drawer: AppDrawer.of(context),
        backgroundColor: AppColors.pageBackground,
        body: Column(children: [
          Expanded(
              child: CustomScrollView(
            physics: BouncingScrollPhysics(),
            shrinkWrap: true,
            slivers: <Widget>[
              HeaderBoard(
                _translate('title'),
                children: <Widget>[
                  text(_translate('description')),
                  AppConstants.spaceH(20),
                  WorkerSpecsDropDownButton(
                    _specialist,
                    (value) async {
                      setState(() {
                        _specialist = value;
                      });
                    },
                    hintText: allTranslations.text('choose.specialty'),
                    allChoose: false,
                  ),
                  AppConstants.spaceH(30),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      text(allTranslations.text('choose.date') + ':'),
                      InkWell(
                          onTap: () async {
                            final date = await _selectDate(context);
                            setState(() {
                              _availability =
                                  _availability.updateOn(newDate: date);
                            });
                          },
                          child: Text(
                            AppUtils.formatDateToString(_availability.date,
                                devider: '.'),
                            style: AppTextStyles.date(mq,
                                textDecoration: TextDecoration.underline),
                          ))
                    ],
                  ),
                  AppConstants.spaceH(10),
                  Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        text(allTranslations.text('choose.time') + ':'),
                        InkWell(
                          onTap: () async {
                            final ava =
                                await _selectTime(context, _availability);
                            setState(() {
                              _availability = ava;
                            });
                          },
                          child: Text(
                            _formatTimeRange(
                                _availability.start, _availability.end),
                            style: AppTextStyles.date(mq,
                                textDecoration: TextDecoration.underline),
                          ),
                        )
                      ])
                ],
              ),
              _PageContent(spec: _specialist, availability: _availability)
            ],
          )),
          AppBottomTabBars()
        ]));
  }
}

class _PageContent extends StatelessWidget {
  // final Date date;
  // final TimeRange range;
  final BestTimeRangeAvailability availability;
  final WorkerSpecialization spec;

  _PageContent({@required this.spec, @required this.availability});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: WorkerService().fetchAvailableWorkers(
            WorkerSpecialization(spec?.id, 'best_time'),
            availability.date,
            availability.range),
        builder: (context, AsyncSnapshot<List<Worker>> snapshot) {
          if (!snapshot.hasData) {
            return AppConstants.circleSpinnerSlivered;
          }

          final docs = snapshot.data;

          if (docs.isEmpty) {
            return SliverPadding(
                padding: EdgeInsets.fromLTRB(
                    AppPaddings.left, 20.0, AppPaddings.left, 20.0),
                sliver:
                    SliverList(delegate: SliverChildListDelegate([_noItems])));
          }

          return SliverPadding(
              padding: EdgeInsets.all(AppPaddings.left),
              sliver: SliverList(
                  delegate: SliverChildBuilderDelegate((builder, i) {
                return Column(
                  children: <Widget>[
                    WorkerCard(docs[i], fromBestTime: availability),
                    AppConstants.betweenRowCards
                  ],
                );
              }, childCount: docs.length)));
        });
  }

  Widget get _noItems {
    final text1 = Text(
      _translate('sorry_no_workers'),
      style: AppTextStyles.text,
    );

    return RowCardComponent(child: text1);
  }
}
