import 'package:flutter/material.dart';
import 'package:timesget/styles/colors.dart';

class FitnessTemplateColors implements TemplateColors {
  static const Color orange = const Color(0xFFFC561F); // #FC561F
  static const Color yellow = const Color(0xFFfbbb00); // #fbbb00
  static const Color green = const Color(0xff1dcd90); // #1dcd90
  static const Color red = const Color(0xffb84437); // #b84437
  static const Color blue = const Color(0xff00359e); // #00359e
  static const Color lightGrey = const Color(0xffecf0f1); // #ecf0f1
  static const Color darkGrey = const Color(0xff88969a); // #88969a

  @override
  Color inputDecorationLabelStyle = blue;

  @override
  Color primaryColor = blue;

  @override
  Color calendarDaySelected = blue;

  @override
  Color chipBadge = blue;

  @override
  Color chipBadgeTitle = CommonAppColors.white;

  @override
  Color inputSelected = blue;

  @override
  Color link = blue;

  @override
  Color pageBackground = yellow;

  @override
  Color selectedTime = yellow;

  @override
  Color workdays = yellow;

  @override
  Color shadow = const Color(0x30af7300); // #af7300

  @override
  Color loginButton = yellow;

  @override
  Color signupButton = yellow;

  @override
  Color buttonActive = yellow;

  @override
  Color buttonActiveText = CommonAppColors.white;

  @override
  Color buttonInactiveBorder = CommonAppColors.lightGrey;

  @override
  Color rowTitle = blue;

  @override
  Color border = CommonAppColors.darkGrey;

  @override
  Color dropDown = blue;

  @override
  Color workerCardPrice = blue;

  @override
  Color buttonWorkerBooking = blue;

  @override
  Color buttonWorkerBookingTitle = CommonAppColors.white;

  @override
  Color mobilCardUnavailable = CommonAppColors.white;

  @override
  Color mobileCardGetCard = blue;

  @override
  Color mobileCardGetCardText = CommonAppColors.white;

  @override
  Color ourWorkersButtonBg = blue;

  @override
  Color hotOfferDiscount = yellow;

  @override
  Color navCancel = yellow;

  @override
  Color ourWorkersButtonText = CommonAppColors.white;

  @override
  Color switchToggle = yellow;
}
