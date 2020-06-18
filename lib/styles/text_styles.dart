import 'package:flutter/material.dart';
import 'package:timesget/services/device_info.dart';
import 'package:timesget/styles/colors.dart';

class AppTextStyles {
  static const fontSize10 = 10.0;
  static const fontSize11 = 11.0;
  static const fontSize12 = 12.0;
  static const fontSize13 = 13.0;
  static const fontSize14 = 14.0;
  static const fontSize15 = 15.0;
  static const fontSize16 = 16.0; // 44.53 px
  static const fontSize17 = 17.0;
  static const fontSize18 = 18.0;
  static const fontSize19 = 19.0;
  static const fontSize20 = 20.0;
  static const fontSize22 = 22.0;
  static const fontSize28 = 28.0;
  static const fontSize30 = 30.0;
  static const fontSize34 = 34.0;
  static const fontSize36 = 36.0;
  static const fontSize46 = 46.0;
  static const fontSize48 = 48.0;

  static const double imputDecorationLabelStyle = fontSize12;
  static const double textFontSize = fontSize15;

  static const FontWeight textFontWidth = FontWeight.w500;

  static const TextStyle h1 = TextStyle(
      color: AppColors.black,
      fontSize: AppTextStyles.fontSize28,
      fontWeight: FontWeight.w900);

  static TextStyle get h1Small =>
      h1.copyWith(fontSize: AppTextStyles.fontSize28);

  static TextStyle get hello => h1.copyWith(fontSize: AppTextStyles.fontSize34);
  static TextStyle get helloSubtitle => TextStyle(
      color: AppColors.text,
      fontWeight: FontWeight.w500,
      fontSize: AppTextStyles.fontSize20);

  static const TextStyle currentLocationLabel = TextStyle(
      color: AppColors.greyText,
      fontSize: AppTextStyles.fontSize14,
      fontWeight: FontWeight.w500);

  static const TextStyle currentCity = TextStyle(
      color: AppColors.black,
      fontSize: AppTextStyles.textFontSize,
      fontWeight: FontWeight.w900);

  static const TextStyle topBarText =
      TextStyle(color: AppColors.text, fontSize: AppTextStyles.fontSize12);

  static const TextStyle button = TextStyle(
      color: AppColors.text,
      fontSize: AppTextStyles.textFontSize,
      fontWeight: FontWeight.w500);

  static const TextStyle thinButton = TextStyle(
      color: AppColors.text,
      fontSize: AppTextStyles.fontSize18,
      fontWeight: FontWeight.w500);

  static TextStyle thinButtonSelecred =
      TextStyle(fontSize: AppTextStyles.fontSize20, fontWeight: FontWeight.w500)
          .copyWith(color: AppColors.buttonWorkerBookingTitle);

  static TextStyle bottomTabBarLabel =
      TextStyle(fontSize: fontSize13, fontWeight: FontWeight.w500)
          .copyWith(color: AppColors.black);

  static TextStyle pageTitle =
      TextStyle(fontSize: AppTextStyles.fontSize15, fontWeight: FontWeight.w500)
          .copyWith(color: AppColors.rowTitle);

  static TextStyle get drawerLink => text;

  static TextStyle get link => text.copyWith(
        color: AppColors.link,
      );

  static TextStyle get ruleLink =>
      TextStyle(color: AppColors.link, fontSize: AppTextStyles.textFontSize);

  static TextStyle get rule =>
      TextStyle(color: AppColors.text, fontSize: AppTextStyles.textFontSize);

  static TextStyle get navCancel => TextStyle(
      color: AppColors.navCancel,
      fontSize: AppTextStyles.fontSize15,
      fontWeight: FontWeight.w500);

  static get schedule => TextStyle(
      color: AppColors.text,
      fontSize: textFontSize,
      fontWeight: FontWeight.w500);

  static TextStyle calendarDay({bool selected, bool disabled}) => TextStyle(
      color: selected
          ? AppColors.chipBadgeTitle
          : disabled ? AppColors.disableDay : AppColors.text,
      fontSize: textFontSize,
      fontWeight: textFontWidth);

  static TextStyle date(MediaQueryData mq,
          {TextDecoration textDecoration, Color color}) =>
      TextStyle(
          fontSize: DeviceInfo.isSmallWidth ? fontSize18 : fontSize20,
          color: color == null ? AppColors.link : color,
          fontWeight: FontWeight.w500,
          decoration: textDecoration);

  static TextStyle get dialogTitle => TextStyle(
      color: AppColors.dialogTitle,
      fontWeight: FontWeight.w500,
      fontSize: AppTextStyles.fontSize14);

  static const TextStyle text = TextStyle(
      color: AppColors.text,
      fontSize: textFontSize,
      fontWeight: FontWeight.w500);

  static TextStyle textNoItems = TextStyle(
      color: AppColors.textNoItems,
      fontSize: textFontSize,
      fontWeight: FontWeight.w500);

  static TextStyle listItem = TextStyle(
      color: AppColors.text,
      fontSize: AppTextStyles.dropDown,
      fontWeight: FontWeight.w500);

  static const TextStyle postTitle = TextStyle(
      color: AppColors.black,
      fontSize: AppTextStyles.fontSize20,
      fontWeight: FontWeight.w900);

  static const TextStyle keyValueKey = TextStyle(
      fontSize: AppTextStyles.textFontSize - 1,
      color: AppColors.keyValueKey,
      fontWeight: FontWeight.w500);

  static TextStyle get keyValueValue => keyValueKey.copyWith(
        color: AppColors.text,
      );

  static get workerName => TextStyle(
      fontSize: AppTextStyles.fontSize19, fontWeight: FontWeight.w900);

  static const TextStyle workerNameInCard = TextStyle(
      fontSize: fontSize17, color: AppColors.text, fontWeight: FontWeight.w900);

  static get praiseComplaintType => TextStyle(
      color: AppColors.text, fontSize: fontSize12, fontWeight: FontWeight.w500);

  static get topBarTitle =>
      TextStyle(color: AppColors.text, fontSize: fontSize18);

  static get inputHint => inputText.copyWith(
        color: AppColors.border,
      );

  static const TextStyle inputText = TextStyle(
    color: AppColors.text,
    fontSize: AppTextStyles.textFontSize,
    fontWeight: FontWeight.w500,
  );

  // Hot offer

  static TextStyle get hotOfferDiscount =>
      h1.copyWith(color: AppColors.hotOfferDiscount);

  // comment
  static get commentStarsRateLabel => TextStyle(
      color: AppColors.link,
      fontSize: AppTextStyles.textFontSize,
      fontWeight: FontWeight.w500);
  static get commentCustomerFullName => thinButton;

  static coloredActiveButton(MediaQueryData mq, {Color color}) => TextStyle(
      fontSize: DeviceInfo.androidSmall
          ? AppTextStyles.fontSize19
          : AppTextStyles.fontSize19,
      fontWeight: FontWeight.w500,
      color: color ?? AppColors.white);

  static coloredInactiveButton(MediaQueryData mq, {Color color}) => TextStyle(
      fontSize: DeviceInfo.androidSmall
          ? AppTextStyles.fontSize19
          : AppTextStyles.fontSize19,
      fontWeight: FontWeight.w500,
      color: color ?? AppColors.buttonInactiveBorder);

  static get settingsLabel => TextStyle(
      color: AppColors.text,
      fontSize: AppTextStyles.fontSize18,
      fontWeight: FontWeight.w500);

// Drop-Down

  static double get dropDown => AppTextStyles.fontSize16;

  static TextStyle get dropDownValue => TextStyle(
      fontSize: dropDown,
      color: AppColors.dropDown,
      fontWeight: FontWeight.w500);

  // hours
  static hourIsBusy(MediaQueryData mq) => TextStyle(
      fontSize: DeviceInfo.androidSmall ? fontSize36 : fontSize48,
      color: AppColors.bookTimeIsBusy,
      fontWeight: FontWeight.w100);

  static hourIsFree(MediaQueryData mq, {bool isSelected = false}) => TextStyle(
      fontSize: DeviceInfo.androidSmall ? fontSize34 : fontSize46,
      color: isSelected ? AppColors.selectedTime : AppColors.text,
      fontWeight: isSelected ? FontWeight.w900 : FontWeight.w100);

  static TextStyle get timePicker => TextStyle(
      fontSize: 40.0, color: AppColors.text, fontWeight: FontWeight.w100);

  static get selectedTimePicker => timePicker.copyWith(
      color: AppColors.selectedTime, fontWeight: FontWeight.w900);

  static TextStyle tooltipBody(MediaQueryData mq) {
    return TextStyle(
        fontSize: DeviceInfo.isSmallWidth
            ? AppTextStyles.fontSize12
            : AppTextStyles.fontSize13,
        color: AppColors.text);
  }

  static TextStyle get badge =>
      TextStyle(fontSize: AppTextStyles.fontSize14, fontWeight: FontWeight.w500)
          .copyWith(color: AppColors.chipBadgeTitle);

  static weekDay(bool isAndroidSmall) {
    return TextStyle(
        fontSize: isAndroidSmall ? fontSize12 : textFontSize,
        fontWeight: FontWeight.w900,
        color: AppColors.text);
  }
}
