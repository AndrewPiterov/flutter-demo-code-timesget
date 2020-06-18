import 'package:flutter/material.dart';
import 'package:timesget/styles/constants.dart';

class AppPaddings {
  static EdgeInsets get pageTitle =>
      EdgeInsets.fromLTRB(AppPaddings.left, 5.0, AppPaddings.right, 5.0);

  static EdgeInsets get pageContent => EdgeInsets.fromLTRB(AppPaddings.left,
      AppConstants.sizeOf(77), AppPaddings.right, AppConstants.sizeOf(77));

  static const EdgeInsets none = EdgeInsets.zero;

  // main
  static const double left = 70 / AppConstants.ration;
  static const double right = left;

  // top - header
  static double get pageTop => AppConstants.sizeOf(22);

  // page content
  static double get pageContentTop => AppConstants.sizeOf(77);

  static double get pageHeaderBottom => AppConstants.sizeOf(101);

  static EdgeInsets get inputBoxContent =>
      EdgeInsets.fromLTRB(AppPaddings.left, 43.0, AppPaddings.left, 0.0);

  static const EdgeInsets alertContentPadding =
      const EdgeInsets.fromLTRB(AppPaddings.left, 16.0, AppPaddings.left, 30.0);

  static const dialogContentPaddingOnSmallScreen =
      const EdgeInsets.fromLTRB(AppPaddings.left, 16.0, AppPaddings.left, 28.0);
}
