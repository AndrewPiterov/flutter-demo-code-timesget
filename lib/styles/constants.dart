import 'package:flutter/material.dart';
import 'package:timesget/components/icons.dart';
import 'package:timesget/services/device_info.dart';
import 'package:timesget/styles/colors.dart';
import 'package:timesget/styles/shadows.dart';

class AppConstants {
  static const double ration = 3.6;

  static const inputTopPadding = 14.0;
  static const inputTopPadding2 = 7.0;

  static get betweenRowCards =>
      AppConstants.spaceH(62, color: Colors.white.withAlpha(0));

  static get underAppBar => AppConstants.sizeOf(85);

  static Widget get underAppBarH =>
      AppConstants.spaceH(115, color: AppColors.white);

  static Widget get circleSpinner =>
      Container(child: Center(child: CircularProgressIndicator()));

  static get circleSpinnerSlivered => SliverPadding(
        padding: EdgeInsets.all(0.0),
        sliver: SliverList(
            delegate: SliverChildBuilderDelegate((builder, i) {
          return Container(
            child: circleSpinner,
            height: 100.0,
          );
        }, childCount: 1)),
      );

  static const CircularProgressIndicator spinner = CircularProgressIndicator(
      valueColor:
          AlwaysStoppedAnimation<Color>(AppColors.circularProgressIndicator));

  static Widget close({@required VoidCallback onTap, bool dark = false}) =>
      InkWell(
        onTap: onTap,
        child: Padding(
            padding: EdgeInsets.fromLTRB(0.0, 16.0, 20.0, 14.0),
            child: Container(
              height: DeviceInfo.isSmallWidth ? 20.0 : 24.0,
              child: dark ? AppIcons.closeWindowDark : AppIcons.closeWindow,
            )),
      );

  static double sizeOf(num pixels) => pixels / AppConstants.ration;

  static Container spaceH(num pixels, {color}) => Container(
      color: color == null ? AppColors.white.withAlpha(0) : color,
      height: AppConstants.sizeOf(pixels));

  static Container get spaceBetweenInputs => spaceH(30);

  static double get inputHeight => 58.0;

  static Container get spaceBetweenThinButtons => spaceH(20);

  static Container spaceH2(num pixels, {color}) => Container(
      color: color == null ? AppColors.white.withAlpha(0) : color,
      height: double.parse(pixels.toString()));

  static SizedBox spaceH3(num pixels) =>
      SizedBox(height: double.parse(pixels.toString()));

  static Container spaceW(num pixels) =>
      Container(width: AppConstants.sizeOf(pixels));

  static const String noValue = '-';

  static String nullableText(dynamic s) =>
      s == null ? AppConstants.noValue : s.toString();

  static Widget bottomShadow({num height = 20.0, Color color}) {
    color = color ?? AppColors.white;
    return Container(
      height: double.parse(height.toString()),
      decoration: BoxDecoration(color: color, boxShadow: AppShadows.common),
      child: Center(),
    );
  }

  static spaceInSliver(num height) => SliverPadding(
      padding: const EdgeInsets.all(0.0),
      sliver: SliverList(
        delegate: SliverChildListDelegate([
          Container(
              color: AppColors.white,
              child: Container(
                height: double.parse(height.toString()),
                child: Center(),
              ))
        ]),
      ));

  static Widget get nothing => Container();
}
