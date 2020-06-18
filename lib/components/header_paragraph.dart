import 'package:flutter/material.dart';
import 'package:timesget/styles/colors.dart';
import 'package:timesget/styles/constants.dart';
import 'package:timesget/styles/paddings.dart';
import 'package:timesget/styles/shadows.dart';

class HeaderParagraph extends StatelessWidget {
  final Widget child;
  final EdgeInsets padding;
  HeaderParagraph(this.child,
      {this.padding = const EdgeInsets.fromLTRB(
          AppPaddings.left, 0.0, AppPaddings.right, 0.0)});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
      ),
      padding: padding,
      child: child,
    );
  }
}

class HeaderBottomShadow extends StatelessWidget {
  Color color;
  HeaderBottomShadow({this.color}) {
    color = color ?? AppColors.white;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(color: color, boxShadow: AppShadows.common),
      height: 6.0,
    );
  }
}

class HeaderBottomSpace extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return AppConstants.spaceH(50);
  }
}
