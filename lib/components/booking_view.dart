import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:timesget/all_translations.dart';
import 'package:timesget/components/booking_date_view.dart';
import 'package:timesget/components/booking_time_choose.dart';
import 'package:timesget/components/buttons.dart';
import 'package:timesget/components/tags/input.dart';
import 'package:timesget/components/tags/text.dart';
import 'package:timesget/models/city_provider.dart';
import 'package:timesget/models/fakes.dart';
import 'package:timesget/models/user.model.dart';
import 'package:timesget/models/worker.dart';
import 'package:timesget/models/hot_offer.model.dart';
import 'package:timesget/models/work_week.dart';
import 'package:timesget/config//app_config.dart';
import 'package:timesget/services/app_utils.dart';
import 'package:timesget/services/best_time.helper.dart';
import 'package:timesget/services/bookings/current_bookung.service.dart';
import 'package:timesget/services/device_info.dart';
import 'package:timesget/styles/border_radius.dart';
import 'package:timesget/styles/colors.dart';
import 'package:timesget/styles/constants.dart';
import 'package:timesget/styles/text_styles.dart';

const _widgetName = "booking_view";
String _translate(String key) {
  return allTranslations.concatText([_widgetName, key]);
}

class WorkerBookingFormValue {
  final String bookingId;
  WorkerBookingFormValue(this.bookingId);
}

class WorkerBookingFormView extends StatefulWidget {
  final AppUser user;
  final Worker worker;
  final HotOffer hotOffer;
  final BestTimeRangeAvailability bestTime;
  WorkerBookingFormView(this.user, this.worker, {this.hotOffer, this.bestTime});

  @override
  _WorkerBookingFormViewState createState() =>
      _WorkerBookingFormViewState(worker);
}

class _WorkerBookingFormViewState extends State<WorkerBookingFormView> {
  final Worker worker;
  final PageController pageController = PageController();

  _WorkerBookingFormViewState(this.worker);

  String _bookingType;
  String _phone;
  String _comment;

  bool freeHoursNotFound;

  @override
  void initState() {
    super.initState();

    _bookingType = AppFakes.remoteBookingType;
    pageController.addListener(_pageChanged);
  }

  var currentPage = 1;
  void _pageChanged() {}

  Widget _buildPage(BuildContext context, int pageIndex) {
    return StreamBuilder<bool>(
      stream: CurrentBookingService().isBusy$,
      builder: (BuildContext context, snap) {
        if (!snap.hasData) {
          return AppConstants.circleSpinner;
        }

        if (snap.data) {
          return AppConstants.circleSpinner;
        }

        final data = CurrentBookingService().data;

        if (data.notFoundFreeHours) {
          return text(_translate('no_free_hours'));
        }

        final date = widget.hotOffer != null
            ? Date.from(widget.hotOffer.dateTime.toDate())
            : widget.bestTime != null ? widget.bestTime.date : data.date;
        final time = widget.hotOffer != null
            ? widget.hotOffer.time
            : widget.bestTime != null &&
                    widget.bestTime.start.isAfter(data.bookHour, orSame: true)
                ? widget.bestTime.start
                : data.bookHour;

        switch (pageIndex) {
          case 1:
            return BookingDateView(
                date: date,
                disableDays: data.disableDays,
                todayIsOver: data.todayIsOver,
                goToBack: (Date date) async {
                  await pageController.animateToPage(0,
                      curve: Cubic(0.1, 0.3, 0.4, 0.5),
                      duration: Duration(milliseconds: 200));

                  setState(() {
                    CurrentBookingService().dateIs(date);
                    currentPage = 0;
                  });
                });
          case 2:
            return BookingTimeView(worker, date, time: time,
                goToBack: (time) async {
              await pageController.animateToPage(0,
                  curve: Cubic(0.1, 0.3, 0.4, 0.5),
                  duration: Duration(milliseconds: 200));

              setState(() {
                CurrentBookingService().timeIs(time);
                currentPage = 0;
              });
            });
          default:
            return BookingView(
              widget.user,
              worker,
              date: date,
              time: time,
              hotOffer: widget.hotOffer,
              bookingType: _bookingType,
              phone: _phone,
              comment: _comment,
              goToSetDate: () async {
                await pageController.animateToPage(1,
                    curve: Cubic(0.1, 0.3, 0.4, 0.5),
                    duration: Duration(milliseconds: 400));

                setState(() {
                  currentPage = 1;
                });
              },
              goToSetTime: () async {
                await pageController.animateToPage(2,
                    curve: Cubic(0.1, 0.3, 0.4, 0.5),
                    duration: Duration(milliseconds: 400));

                setState(() {
                  currentPage = 2;
                });
              },
              callback: (key, dynamic value) {
                switch (key) {
                  case 'bookingType':
                    setState(() {
                      _bookingType = value;
                    });
                    break;
                  case 'date':
                    setState(() {
                      CurrentBookingService().dateIs(value);
                    });
                    break;
                  case 'time':
                    setState(() {
                      CurrentBookingService().timeIs(value);
                    });
                    break;
                  case 'phone':
                    setState(() {
                      _phone = value;
                    });
                    break;
                  case 'comment':
                    setState(() {
                      _comment = value;
                    });
                    break;
                }
              },
            );
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: FractionalOffset.topCenter,
      children: <Widget>[
        PageView.builder(
            controller: pageController,
            physics: NeverScrollableScrollPhysics(),
            itemCount: 3,
            itemBuilder: (context, index) {
              return _buildPage(context, index);
            })
      ],
    );
  }

  @override
  void dispose() {
    pageController.removeListener(_pageChanged);
    pageController.dispose();
    super.dispose();
  }
}

class BookingView extends StatefulWidget {
  final dynamic goToSetDate;
  final dynamic goToSetTime;

  final AppUser user;
  final Worker worker;
  final Date date;
  final Time time;
  final HotOffer hotOffer;
  final String bookingType;
  final String phone;
  final String comment;
  final callback;

  BookingView(this.user, this.worker,
      {this.date,
      this.time,
      this.hotOffer,
      this.bookingType,
      this.phone,
      this.comment,
      this.goToSetDate,
      this.goToSetTime,
      this.callback});

  @override
  _BookingViewState createState() {
    return new _BookingViewState();
  }
}

class _BookingViewState extends State<BookingView> {
  String _bookingType;
  String _phone;
  String _comment;

  final _phoneEditingController = TextEditingController();
  final _commentEditingController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _bookingType = widget.bookingType;

    _phoneEditingController.addListener(_onPhoneChanged);
    _phoneEditingController.text = widget.phone;
    _phone = widget.phone;

    _commentEditingController.addListener(_onCommentChanged);
    _commentEditingController.text = widget.comment;
    _comment = widget.comment;
  }

  @override
  void dispose() {
    _phoneEditingController.removeListener(_onPhoneChanged);
    _phoneEditingController.dispose();
    _commentEditingController.removeListener(_onCommentChanged);
    _commentEditingController.dispose();
    super.dispose();
  }

  void _onPhoneChanged() {
    _phone = _phoneEditingController.text;
    widget.callback('phone', _phone);
  }

  void _onCommentChanged() {
    _comment = _commentEditingController.text;
    widget.callback('comment', _phone);
  }

  Widget _buildBookTypeButton(BuildContext context, String title, String value,
      {String position = ''}) {
    final h = 39.0;
    return Expanded(
      child: InkWell(
        onTap: () {
          _bookingType = value;
          widget.callback('bookingType', _bookingType);
        },
        child: Container(
          height: h,
          padding: DeviceInfo.isSmallWidth
              ? EdgeInsets.symmetric(vertical: 6.0)
              : EdgeInsets.symmetric(vertical: 7.0),
          decoration: BoxDecoration(
            borderRadius: position == 'left'
                ? BorderRadius.only(
                    topLeft: AppRoundCorners.half(h),
                    bottomLeft: AppRoundCorners.half(h))
                : position == 'right'
                    ? BorderRadius.only(
                        topRight: AppRoundCorners.half(h),
                        bottomRight: AppRoundCorners.half(h))
                    : null,
            border: Border.all(color: AppColors.bookTypeBg),
            color: _bookingType == value ? AppColors.bookTypeBg : Colors.white,
          ),
          child: Center(
              child: Text(
            title,
            style: TextStyle(
                color: _bookingType == value ? AppColors.white : AppColors.text,
                fontSize: AppTextStyles.fontSize15,
                fontWeight: FontWeight.w500),
          )),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context);
    return SingleChildScrollView(
      child: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: Column(children: <Widget>[
          AppConfig.template == AppTemplates.medico
              ? Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    _buildBookTypeButton(context, _translate('types.remote'),
                        AppFakes.remoteBookingType,
                        position: 'left'),
                    _buildBookTypeButton(
                        context, _translate('types.home'), 'home',
                        position: 'right')
                  ],
                )
              : Container(),
          AppConstants.spaceH(90),
          Padding(
              padding: EdgeInsets.symmetric(horizontal: 10.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Expanded(
                    flex: 60,
                    child: Text(
                      widget.hotOffer != null
                          ? _translate('book_date')
                          : _translate('choose_date'),
                      style: AppTextStyles.text,
                    ),
                  ),
                  Expanded(
                    flex: 55,
                    child: InkWell(
                      child: Text(AppUtils.formatDateToString(widget.date),
                          style: AppTextStyles.date(mq,
                              color: widget.hotOffer != null
                                  ? AppColors.black
                                  : null,
                              textDecoration: widget.hotOffer != null
                                  ? null
                                  : TextDecoration.underline)),
                      onTap: widget.hotOffer != null
                          ? null
                          : () {
                              FocusScope.of(context).unfocus();
                              if (widget.goToSetDate == null) {
                                return;
                              }
                              widget.goToSetDate();
                            },
                    ),
                  )
                ],
              )),
          AppConstants.spaceH(70),
          Padding(
              padding: EdgeInsets.symmetric(horizontal: 10.0),
              child: Row(
                // mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Expanded(
                    flex: 60,
                    child: Text(
                      widget.hotOffer != null
                          ? _translate('book_time')
                          : _translate('choose_time'),
                      style: AppTextStyles.text,
                    ),
                  ),
                  Expanded(
                    flex: 55,
                    child: InkWell(
                      child: Text(widget.time.label,
                          style: AppTextStyles.date(mq,
                              color: widget.hotOffer != null
                                  ? AppColors.black
                                  : null,
                              textDecoration: widget.hotOffer != null
                                  ? null
                                  : TextDecoration.underline)),
                      onTap: widget.hotOffer != null
                          ? null
                          : () {
                              FocusScope.of(context).unfocus();
                              if (widget.goToSetTime == null) {
                                return;
                              }
                              widget.goToSetTime();
                            },
                    ),
                  )
                ],
              )),
          AppConstants.spaceH(100),
          Container(
              child: Input(_phoneEditingController,
                  keyboardType: TextInputType.phone,
                  hintText: allTranslations.text('your_phone_number'))),
          AppConstants.spaceH(28),
          Container(
              child: Input(
            _commentEditingController,
            hintText: allTranslations.text('leave_comment'),
            maxLines: 7,
          )),
          AppConstants.spaceH(47),
          Text(
            _translate('info'),
            style: AppTextStyles.text,
            textAlign: TextAlign.center,
          ),
          AppConstants.spaceH2(45),
          AppColoredButton(
            allTranslations.text('book'),
            isActive: widget.bookingType != null &&
                widget.date != null &&
                widget.time != null &&
                widget.phone != null &&
                widget.phone != '',
            isBusy: ModelProvider.of(context).isBusyBooking,
            onTap: () async {
              final hotoffer = widget.hotOffer;
              final bookingId = await ModelProvider.of(context).book(
                  widget.user,
                  _bookingType,
                  widget.date,
                  widget.time,
                  widget.worker,
                  _phone,
                  _comment,
                  hotOffer: hotoffer);
              Navigator.pop(context, WorkerBookingFormValue(bookingId));
            },
          )
        ]),
      ),
    );
  }
}
