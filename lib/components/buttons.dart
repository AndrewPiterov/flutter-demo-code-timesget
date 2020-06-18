import 'dart:async';
import 'package:flutter/material.dart';
import 'package:timesget/components/icons.dart';
import 'package:timesget/styles/border_radius.dart';
import 'package:timesget/styles/colors.dart';
import 'package:timesget/styles/constants.dart';
import 'package:timesget/styles/paddings.dart';
import 'package:timesget/styles/text_styles.dart';

class ThinBorderedButton2 extends StatelessWidget {
  final bool isActive;
  final GestureDragCancelCallback onTap;
  final Widget title;
  final Color color;
  final Image icon;
  final double height;

  final Stream<bool> isBusy;

  ThinBorderedButton2(this.title,
      {this.icon,
      this.isActive,
      this.onTap,
      this.color,
      this.height = 58.0,
      this.isBusy});

  @override
  Widget build(BuildContext context) {
    final row = <Widget>[];
    var aligment = MainAxisAlignment.center;

    if (icon == null) {
      row.add(title);
    } else {
      aligment = MainAxisAlignment.spaceBetween;
      row.add(icon);
      row.add(title);
      row.add(AppConstants.spaceW(30));
    }

    return InkWell(
      onTap: onTap,
      child: Container(
          height: height,
          decoration: BoxDecoration(
            color: this.color,
            border: Border.all(
                color: this.color == null ? Colors.grey : this.color),
            borderRadius: BorderRadius.all(Radius.circular(height / 2)),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: aligment,
              children: row,
            ),
          )),
    );
  }
}

class AppColoredButton extends StatelessWidget {
  final String _title;
  final GestureDragCancelCallback onTap;
  final bool isActive;

  Color color;
  Color borderColor;

  final double w;
  final double height;
  final num borderThin;
  final Widget titleAsContent;

  final Stream<bool> isBusy;

  Color activeTitleColor;
  Color unactiveTitleColor;

  AppColoredButton(this._title,
      {this.onTap,
      this.isActive = true,
      this.titleAsContent,
      this.color,
      this.borderColor,
      this.w,
      this.height = 68.0,
      this.borderThin = 1,
      this.activeTitleColor,
      this.unactiveTitleColor,
      this.isBusy}) {
    color = color ?? AppColors.buttonActive;
    borderColor = borderColor ?? AppColors.buttonActive;
    activeTitleColor = activeTitleColor ?? AppColors.buttonActiveText;
    unactiveTitleColor = unactiveTitleColor ?? AppColors.buttonInactiveBorder;
  }

  Widget _buildTitle(MediaQueryData mq) {
    return titleAsContent == null
        ? Container(
            width: w,
            child: Center(
              child: Text(
                _title,
                style: isActive
                    ? AppTextStyles.coloredActiveButton(mq,
                        color: activeTitleColor)
                    : AppTextStyles.coloredInactiveButton(mq),
              ),
            ),
          )
        : titleAsContent;
  }

  Widget _dummyButton(BuildContext context) {
    return InkWell(
      onTap: isActive ? onTap : null,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: AppPaddings.left),
        height: height,
        decoration: BoxDecoration(
          color: isActive ? color : AppColors.white,
          border: isActive
              ? Border.all(
                  color: borderColor,
                  width: double.parse(borderThin.toString()))
              : Border.all(
                  color: borderColor,
                  width: double.parse(borderThin.toString())),
          borderRadius: BorderRadius.circular(height / 2),
        ),
        child: Center(
          child: isBusy != null
              ? StreamBuilder(
                  stream: isBusy,
                  builder: (context, snapshot) {
                    if (snapshot.hasData && snapshot.data) {
                      return Center(
                        child: AppConstants.spinner,
                      );
                    }

                    return _buildTitle(MediaQuery.of(context));
                  })
              : _buildTitle(MediaQuery.of(context)),
        ),
      ),
    );
  }

  Widget _smartButton(BuildContext context) {
    return StreamBuilder(
        stream: isBusy,
        builder: (context, AsyncSnapshot<bool> snapshot) {
          if (snapshot.hasData && snapshot.data) {
            return InkWell(
              onTap: null,
              child: Container(
                height: height,
                decoration: BoxDecoration(
                  color: isActive ? null : AppColors.white,
                  borderRadius: BorderRadius.all(Radius.circular(height / 2.0)),
                ),
                child: Center(child: AppConstants.spinner),
              ),
            );
          }

          return InkWell(
            onTap: isActive ? onTap : null,
            child: Container(
              height: height,
              decoration: BoxDecoration(
                color: isActive ? color : AppColors.white,
                border: isActive
                    ? null
                    : Border.all(
                        color: color,
                        width: double.parse(borderThin.toString())),
                borderRadius: BorderRadius.all(Radius.circular(height / 2)),
              ),
              child: Center(
                child: _buildTitle(MediaQuery.of(context)),
              ),
            ),
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    return isBusy == null ? _dummyButton(context) : _smartButton(context);
  }
}

class AppGrayButton2 extends StatelessWidget {
  final String _title;
  final GestureDragCancelCallback _onTap;

  AppGrayButton2(this._title, this._onTap);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: _onTap,
      child: Container(
        // width: 100.0,
        height: 42.0,
        decoration: BoxDecoration(
          color: const Color(0xFFD7DDED),
          // border: Border.all(color: Colors.grey, width: 2.0),
          borderRadius: AppBorderRadius.rowCard,
        ),
        child: Stack(
          children: <Widget>[
            Center(
              child: Text(
                _title,
                style: TextStyle(
                    fontSize: AppTextStyles.fontSize13,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF585961)),
              ),
            ),
            Positioned(
              right: 17.0,
              top: 13.0,
              width: 15.0,
              child: AppIcons.openWindow,
            )
          ],
        ),
      ),
    );
  }
}
