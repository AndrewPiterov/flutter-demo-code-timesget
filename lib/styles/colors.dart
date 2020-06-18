import 'package:flutter/material.dart';
import 'package:timesget/config/app_colors.dart';

abstract class TemplateColors {
  Color primaryColor;
  Color inputDecorationLabelStyle;
  Color link;

  // calendar
  Color calendarDaySelected;
  Color selectedTime;

  Color workdays;

  Color chipBadge;
  Color chipBadgeTitle;

  Color inputSelected;

  Color pageBackground;

  Color shadow;

  Color dropDown;
  Color border;

  // buttons
  Color loginButton;
  Color signupButton;

  Color buttonWorkerBooking;
  Color buttonWorkerBookingTitle;

  Color ourWorkersButtonBg;
  Color ourWorkersButtonText;

  Color buttonActive;
  Color buttonActiveText;
  Color buttonInactiveBorder;

  Color rowTitle; // blueColor

  Color workerCardPrice;

  Color mobilCardUnavailable;
  Color mobileCardGetCard;
  Color mobileCardGetCardText;

  Color hotOfferDiscount;

  Color navCancel;

  Color switchToggle;
}

class CommonAppColors {
  static const Color black = const Color(0xff020202); // #020202
  static const Color white = const Color(0xffffffff); // #ffffff

  static const Color darkGrey = const Color(0xff88969a); // #88969a
  static const Color lightGrey = const Color(0xffecf0f1); // #ecf0f1
  static const Color _yellow = const Color(0xFFffc75c); // #ffc75c

  static const Color error = const Color(0xffb84437); // #b84437

  static const Color text = black;
  static const Color greyText = darkGrey;
  static Color get link => black;

  static const Color drawerMenuShortLine = const Color(0xffc6ced8); // #c6ced8

  static const Color modalOverlay = const Color(0xFFfec400); //#fec400

  static const Color circularProgressIndicator =
      const Color(0xff1ec0e0); // #1ec0e0

  static const Color approvedBookingBorad = const Color(0xff1dcd90); // #1dcd90
  static const Color bookingBorad = bottomTabBar;

  static const Color bottomTabBar = lightGrey;

  static const Color inputNonSelected = const Color(0xff88969a); // #88969a

  static const Color hintColor = inputNonSelected;

  static const Color bookTypeBg = inputNonSelected;

  static const Color bookTimeIsBusy = const Color(0xFFFC561F); // #FC561F

  static const Color imageBg = bottomTabBar;

  static const Color disableDay = const Color(0x553c4454); // #3c4454

  static const Color emotionsBoardBg = bottomTabBar;

  static const Color scanButtonBorder = _yellow;

  static const Color radioButtonBorder = darkGrey;

  static const Color keyValueKey = darkGrey;

  static const Color imageSliderDots = lightGrey;
}

class AppColors {
  static TemplateColors _template = FitnessTemplateColors();

  static const Color white = CommonAppColors.white;
  static const Color black = CommonAppColors.black;

  static Color get imputDecorationLabelStyle =>
      _template.inputDecorationLabelStyle;
  static Color get primaryColor => _template.primaryColor;

  static const Color text = CommonAppColors.text;
  static const Color greyText = CommonAppColors.greyText;

  static Color get link => _template.link;

  static Color get rowTitle => _template.rowTitle;

  static Color get chipBadge => _template.chipBadge;
  static Color get chipBadgeTitle => _template.chipBadgeTitle;

  static const Color disableDay = CommonAppColors.disableDay;

  static Color get shadow => _template.shadow;

  static Color get drawerMenuShortLine => CommonAppColors.drawerMenuShortLine;

  static Color get imageBg => CommonAppColors.imageBg;

  static Color get workerCardPrice => _template.workerCardPrice;

  //
  static Color get pageBackground => _template.pageBackground;

  //
  static Color get error => CommonAppColors.error;

  // calendar
  static Color get calendarDaySelected => _template.calendarDaySelected;
  static Color get selectedTime => _template.selectedTime;

  // indicaators
  static const Color circularProgressIndicator =
      CommonAppColors.circularProgressIndicator;

  // Modal Popup
  static const Color modalOverlay = CommonAppColors.modalOverlay;

  // approved booking
  static const Color approvedBookingBorad =
      CommonAppColors.approvedBookingBorad;
  static const Color bookingBorad = CommonAppColors.bookingBorad;

  static const Color bottomTabBar = CommonAppColors.bottomTabBar;

  //
  static Color get workdays => _template.workdays;

  //
  static Color get emotionsBoardBg => CommonAppColors.emotionsBoardBg;

  // inputs
  static Color get inputSelected => _template.inputSelected;
  static Color get inputNonSelected => CommonAppColors.inputNonSelected;

  static Color get hintColor => CommonAppColors.hintColor;

  // Buttons
  static Color get loginButton => _template.loginButton;
  static Color get signupButton => _template.signupButton;

  static Color get ourWorkersButtonBg => _template.ourWorkersButtonBg;
  static Color get ourWorkersButtonText => _template.ourWorkersButtonText;

  static Color get buttonWorkerBooking => _template.buttonWorkerBooking;
  static Color get buttonWorkerBookingTitle =>
      _template.buttonWorkerBookingTitle;

  static const Color scanButtonBorder = CommonAppColors.scanButtonBorder;

  static Color get buttonActive => _template.buttonActive;
  static Color get buttonActiveText => _template.buttonActiveText;
  static Color get buttonInactiveBorder => _template.buttonInactiveBorder;

  static Color get navCancel => _template.navCancel;

  static const Color bookTypeBg = CommonAppColors.bookTypeBg;

  static const Color bookTimeIsBusy = CommonAppColors.bookTimeIsBusy;

  static Color get dropDown => _template.dropDown;
  static Color get border => _template.border;
  static Color get switchToggle => _template.switchToggle;

  static Color get mobilCardUnavailable => _template.mobilCardUnavailable;
  static Color get mobileCardGetCard => _template.mobileCardGetCard;
  static Color get mobileCardGetCardText => _template.mobileCardGetCardText;

  static const Color keyValueKey = CommonAppColors.keyValueKey;

  static const Color imageSliderDots = CommonAppColors.imageSliderDots;
  static const Color radioButtonBorder = CommonAppColors.radioButtonBorder;

  static Color get hotOfferDiscount => _template.hotOfferDiscount;

  static const Color textNoItems = white;
  static const Color dialogTitle = CommonAppColors.darkGrey;

  static const Color purpleGradientStart = const Color(0xffff00ff);
  static const Color purpleGradientEnd = const Color(0xff6747cd);
  static const Color orangeGradientEnd = const Color(0xffff5500);
}
