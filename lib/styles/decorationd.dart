import 'package:flutter/material.dart';
import 'package:timesget/styles/border_radius.dart';
import 'package:timesget/styles/colors.dart';
import 'package:timesget/styles/gradients.dart';
import 'package:timesget/styles/shadows.dart';

class AppDecorations {
  static BoxDecoration selectedChipDecoration = new BoxDecoration(
    borderRadius: BorderRadius.all(Radius.circular(15.0)),
    gradient: AppGradients.purpleChipSelected,
  );

  static BoxDecoration get myBookingToCancelStatus =>
      myBookingCanceledStatus.copyWith(color: AppColors.black);

  static BoxDecoration get myBookingCanceledStatus => BoxDecoration(
      // border: Border.all(color: AppColors.black),
      color: AppColors.white,
      borderRadius: BorderRadius.all(Radius.circular(35.0)));

  static get borderedDrawerItem => BoxDecoration(
      border: Border.all(color: AppColors.black),
      borderRadius: BorderRadius.all(Radius.circular(15.0)));

  static BoxDecoration image(provider,
          {fit = BoxFit.contain, colorFilter, withoutShadow = false}) =>
      BoxDecoration(
          color: AppColors.imageBg,
          image: DecorationImage(
              image: provider, fit: fit, colorFilter: colorFilter),
          borderRadius: AppBorderRadius.rowCard,
          boxShadow: withoutShadow ? null : AppShadows.common);
}
