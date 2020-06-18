import 'dart:async';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:timesget/all_translations.dart';
import 'package:timesget/components/3rd/calendar_tile.dart';
import 'package:timesget/components/icons.dart';
import 'package:timesget/services/app_utils.dart';
import 'package:timesget/services/dateUtils.dart';
import 'package:timesget/services/device_info.dart';
import 'package:timesget/styles/constants.dart';
import 'package:timesget/styles/text_styles.dart';
import 'package:tuple/tuple.dart';

typedef DayBuilder(BuildContext context, DateTime day);

class Calendar extends StatefulWidget {
  final ValueChanged<DateTime> onDateSelected;
  final ValueChanged<Tuple2<DateTime, DateTime>> onSelectedRangeChange;
  final bool isExpandable = true;
  final DayBuilder dayBuilder;
  final bool showChevronsToChangeRange;
  final bool showTodayAction;
  final bool showCalendarPickerIcon;
  final bool isSunFirst;
  final DateTime initialCalendarDateOverride;

  Calendar(
      {this.onDateSelected,
      this.onSelectedRangeChange,
      // this.isExpandable: false,
      this.dayBuilder,
      this.showTodayAction: true,
      this.showChevronsToChangeRange: true,
      this.showCalendarPickerIcon: true,
      @required this.isSunFirst,
      this.initialCalendarDateOverride});

  @override
  _CalendarState createState() => _CalendarState();
}

class _CalendarState extends State<Calendar> {
  // final calendarUtils = new Utils();
  DateTime today = DateTime.now();
  List<DateTime> selectedMonthsDays;
  // Iterable<DateTime> selectedWeeksDays;
  DateTime _selectedDate;
  Tuple2<DateTime, DateTime> selectedRange;
  // String currentMonth;
  final bool isExpanded = true;
  String displayMonth;

  DateTime get selectedDate => _selectedDate;

  void initState() {
    super.initState();
    if (widget.initialCalendarDateOverride != null)
      today = widget.initialCalendarDateOverride;
    selectedMonthsDays =
        AppUtils.daysInMonth(today, sunIsFirst: widget.isSunFirst);
    // var firstDayOfCurrentWeek = Utils.firstDayOfWeek(today);
    // var lastDayOfCurrentWeek = Utils.lastDayOfWeek(today);
    // selectedWeeksDays = Utils
    //     .daysInRange(firstDayOfCurrentWeek, lastDayOfCurrentWeek)
    //     .toList()
    //     .sublist(0, 7);
    _selectedDate = today;
    displayMonth = translateMonthName(formatMonth(today));
  }

  Widget get _monthNamesAndPrevNextIconsRow {
    var leftInnerIcon;
    var rightInnerIcon;
    var leftOuterIcon;
    var rightOuterIcon;

    rightInnerIcon = Container();

    if (widget.showChevronsToChangeRange) {
      leftOuterIcon = IconButton(
        onPressed: isExpanded ? previousMonth : previousWeek,
        icon: AppIcons.prevDate(height: 30.0),
      );
      rightOuterIcon = IconButton(
        onPressed: isExpanded ? nextMonth : nextWeek,
        icon: AppIcons.nextDate(height: 30.0),
      );
    } else {
      leftOuterIcon = Container();
      rightOuterIcon = Container();
    }

    // if (widget.showTodayAction) {
    //   leftInnerIcon = new InkWell(
    //     child: new Text('Today'),
    //     onTap: resetToToday,
    //   );
    // } else {
    //   leftInnerIcon = new Container();
    // }

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        leftOuterIcon ?? Container(),
        leftInnerIcon ?? Container(),
        Text(
          displayMonth,
          style: TextStyle(
              fontSize: AppTextStyles.fontSize22, fontWeight: FontWeight.w800),
        ),
        rightInnerIcon ?? Container(),
        rightOuterIcon ?? Container(),
      ],
    );
  }

  Widget _buildCalendarGridView(BuildContext context) {
    return Container(
      child: GestureDetector(
        onHorizontalDragStart: (gestureDetails) => beginSwipe(gestureDetails),
        onHorizontalDragUpdate: (gestureDetails) =>
            getDirection(gestureDetails),
        onHorizontalDragEnd: (gestureDetails) => endSwipe(gestureDetails),
        child: GridView.count(
          shrinkWrap: true,
          crossAxisCount: 7,
          childAspectRatio: 1.5,
          mainAxisSpacing: 2.0,
          padding: EdgeInsets.only(
            bottom: 0.0,
          ),
          children: calendarBuilder(context),
        ),
      ),
    );
  }

  String formatMonth(DateTime date) =>
      capitalize(DateFormat("MMMM").format(date));

  String capitalize(String s) => '${s[0].toUpperCase()}${s.substring(1)}';

  List<Widget> calendarBuilder(BuildContext context) {
    List<Widget> dayWidgets = [];
    List<DateTime> calendarDays = selectedMonthsDays;
    // isExpanded ? selectedMonthsDays : selectedWeeksDays;

    for (var day in AppUtils.weekdays()) {
      final tr =
          allTranslations.text('week.' + day.toLowerCase().substring(0, 3));
      dayWidgets.add(
        CalendarTile(
          isDayOfWeek: true,
          dayOfWeek: tr,
          dayOfWeekStyles: AppTextStyles.weekDay(DeviceInfo.androidSmall),
        ),
      );
    }

    bool monthStarted = false;
    bool monthEnded = false;

    calendarDays.forEach(
      (day) {
        if (monthStarted && day.day == 01) {
          monthEnded = true;
        }

        if (DateUtils.isFirstDayOfMonth(day)) {
          monthStarted = true;
        }

        if (this.widget.dayBuilder != null) {
          dayWidgets.add(
            CalendarTile(
              child: this.widget.dayBuilder(context, day),
            ),
          );
        } else {
          dayWidgets.add(
            CalendarTile(
              onDateSelected: () => handleSelectedDateAndUserCallback(day),
              date: day,
              dateStyles: configureDateStyle(monthStarted, monthEnded),
              isSelected: DateUtils.isSameDay(selectedDate, day),
            ),
          );
        }
      },
    );
    return dayWidgets;
  }

  TextStyle configureDateStyle(monthStarted, monthEnded) {
    TextStyle dateStyles;
    if (isExpanded) {
      dateStyles = monthStarted && !monthEnded
          ? new TextStyle(color: Colors.black)
          : new TextStyle(color: Colors.black38);
    } else {
      dateStyles = new TextStyle(color: Colors.black);
    }
    return dateStyles;
  }

  // Widget get expansionButtonRow {
  //   if (widget.isExpandable) {
  //     return new Row(
  //       mainAxisAlignment: MainAxisAlignment.spaceBetween,
  //       children: <Widget>[
  //         new Text(Utils.fullDayFormat(selectedDate)),
  //         new IconButton(
  //           iconSize: 20.0,
  //           padding: new EdgeInsets.all(0.0),
  //           onPressed: toggleExpanded,
  //           icon: isExpanded
  //               ? new Icon(Icons.arrow_drop_up)
  //               : new Icon(Icons.arrow_drop_down),
  //         ),
  //       ],
  //     );
  //   } else {
  //     return new Container();
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          _monthNamesAndPrevNextIconsRow,
          AppConstants.spaceH(50),
          ExpansionCrossFade(
            collapsed: _buildCalendarGridView(context),
            expanded: Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.0),
              child: _buildCalendarGridView(context),
            ),
            isExpanded: isExpanded,
          ),
          // expansionButtonRow
        ],
      ),
    );
  }

  void resetToToday() {
    today = new DateTime.now();
    // var firstDayOfCurrentWeek = Utils.firstDayOfWeek(today);
    // var lastDayOfCurrentWeek = Utils.lastDayOfWeek(today);

    setState(() {
      _selectedDate = today;
      // selectedWeeksDays = Utils
      //     .daysInRange(firstDayOfCurrentWeek, lastDayOfCurrentWeek)
      //     .toList();
      displayMonth = translateMonth(today);
    });

    _launchDateSelectionCallback(today);
  }

  void nextMonth() {
    setState(() {
      today = DateUtils.nextMonth(today);
      var firstDateOfNewMonth = DateUtils.firstDayOfMonth(today);
      var lastDateOfNewMonth = DateUtils.lastDayOfMonth(today);
      updateSelectedRange(firstDateOfNewMonth, lastDateOfNewMonth);
      selectedMonthsDays =
          AppUtils.daysInMonth(today, sunIsFirst: widget.isSunFirst);
      final daymonth =
          selectedMonthsDays[(selectedMonthsDays.length / 2).floor()];
      displayMonth = translateMonth(daymonth);
    });
  }

  void previousMonth() {
    setState(() {
      today = DateUtils.previousMonth(today);
      var firstDateOfNewMonth = DateUtils.firstDayOfMonth(today);
      var lastDateOfNewMonth = DateUtils.lastDayOfMonth(today);
      updateSelectedRange(firstDateOfNewMonth, lastDateOfNewMonth);
      selectedMonthsDays =
          AppUtils.daysInMonth(today, sunIsFirst: widget.isSunFirst);
      final daymonth =
          selectedMonthsDays[(selectedMonthsDays.length / 2).floor()];
      displayMonth = translateMonth(daymonth);
    });
  }

  String translateMonth(DateTime day) {
    final month = formatMonth(DateUtils.firstDayOfWeek(day)).toLowerCase();
    return translateMonthName(month);
  }

  String translateMonthName(String month) {
    final translations =
        allTranslations.text('calendar.${month.toLowerCase()}');
    return translations;
  }

  void nextWeek() {
    setState(() {
      today = DateUtils.nextWeek(today);
      var firstDayOfCurrentWeek = DateUtils.firstDayOfWeek(today);
      var lastDayOfCurrentWeek = DateUtils.lastDayOfWeek(today);
      updateSelectedRange(firstDayOfCurrentWeek, lastDayOfCurrentWeek);
      // selectedWeeksDays = Utils
      //     .daysInRange(firstDayOfCurrentWeek, lastDayOfCurrentWeek)
      //     .toList()
      //     .sublist(0, 7);
      displayMonth =
          translateMonthName(formatMonth(DateUtils.firstDayOfWeek(today)));
    });
  }

  void previousWeek() {
    setState(() {
      today = DateUtils.previousWeek(today);
      var firstDayOfCurrentWeek = DateUtils.firstDayOfWeek(today);
      var lastDayOfCurrentWeek = DateUtils.lastDayOfWeek(today);
      updateSelectedRange(firstDayOfCurrentWeek, lastDayOfCurrentWeek);
      // selectedWeeksDays = Utils
      //     .daysInRange(firstDayOfCurrentWeek, lastDayOfCurrentWeek)
      //     .toList()
      //     .sublist(0, 7);
      displayMonth =
          translateMonthName(formatMonth(DateUtils.firstDayOfWeek(today)));
    });
  }

  void updateSelectedRange(DateTime start, DateTime end) {
    selectedRange = Tuple2<DateTime, DateTime>(start, end);
    if (widget.onSelectedRangeChange != null) {
      widget.onSelectedRangeChange(selectedRange);
    }
  }

  Future<Null> selectDateFromPicker() async {
    DateTime selected = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime(1960),
      lastDate: DateTime(2050),
    );

    if (selected != null) {
      // var firstDayOfCurrentWeek = Utils.firstDayOfWeek(selected);
      // var lastDayOfCurrentWeek = Utils.lastDayOfWeek(selected);
      setState(() {
        _selectedDate = selected;
        // selectedWeeksDays = Utils
        //     .daysInRange(firstDayOfCurrentWeek, lastDayOfCurrentWeek)
        //     .toList();
        selectedMonthsDays =
            AppUtils.daysInMonth(selected, sunIsFirst: widget.isSunFirst);
        displayMonth = translateMonth(selected);
      });

      _launchDateSelectionCallback(selected);
    }
  }

  var gestureStart;
  var gestureDirection;
  void beginSwipe(DragStartDetails gestureDetails) {
    gestureStart = gestureDetails.globalPosition.dx;
  }

  void getDirection(DragUpdateDetails gestureDetails) {
    if (gestureDetails.globalPosition.dx < gestureStart) {
      gestureDirection = 'rightToLeft';
    } else {
      gestureDirection = 'leftToRight';
    }
  }

  void endSwipe(DragEndDetails gestureDetails) {
    if (gestureDirection == 'rightToLeft') {
      if (isExpanded) {
        nextMonth();
      } else {
        nextWeek();
      }
    } else {
      if (isExpanded) {
        previousMonth();
      } else {
        previousWeek();
      }
    }
  }

  // void toggleExpanded() {
  //   if (widget.isExpandable) {
  //     setState(() => isExpanded = !isExpanded);
  //   }
  // }

  void handleSelectedDateAndUserCallback(DateTime day) {
    // var firstDayOfCurrentWeek = Utils.firstDayOfWeek(day);
    // var lastDayOfCurrentWeek = Utils.lastDayOfWeek(day);
    setState(() {
      _selectedDate = day;
      // selectedWeeksDays = Utils
      //     .daysInRange(firstDayOfCurrentWeek, lastDayOfCurrentWeek)
      //     .toList();
      selectedMonthsDays =
          AppUtils.daysInMonth(day, sunIsFirst: widget.isSunFirst);
    });
    _launchDateSelectionCallback(day);
  }

  void _launchDateSelectionCallback(DateTime day) {
    if (widget.onDateSelected != null) {
      widget.onDateSelected(day);
    }
  }
}

class ExpansionCrossFade extends StatelessWidget {
  final Widget collapsed;
  final Widget expanded;
  final bool isExpanded;

  ExpansionCrossFade({this.collapsed, this.expanded, this.isExpanded});

  @override
  Widget build(BuildContext context) {
    return Flexible(
      flex: 1,
      child: AnimatedCrossFade(
        firstChild: collapsed,
        secondChild: expanded,
        firstCurve: const Interval(0.0, 1.0, curve: Curves.fastOutSlowIn),
        secondCurve: const Interval(0.0, 1.0, curve: Curves.fastOutSlowIn),
        sizeCurve: Curves.decelerate,
        crossFadeState:
            isExpanded ? CrossFadeState.showSecond : CrossFadeState.showFirst,
        duration: const Duration(milliseconds: 300),
      ),
    );
  }
}
