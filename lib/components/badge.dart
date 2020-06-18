import 'package:flutter/material.dart';
import 'package:timesget/styles/text_styles.dart';

class AppBadge extends StatelessWidget {
  final int count;
  final Color color;
  AppBadge(this.count, {this.color = Colors.red});

  @override
  Widget build(BuildContext context) {
    final val = (count + 0);

    final decoration = BoxDecoration(
      color: color,
      borderRadius: BorderRadius.circular(12.0),
      // border: Border.all(color: AppColors.white, width: 1)
    );

    // new BoxDecoration(
    //     color: color,
    //     shape: BoxShape.circle,
    //   )

    final circle = Container(
      width: val > 99 ? 33.0 : 22.0,
      height: 22.0,
      decoration: decoration,
    );

    final label = Padding(
      padding: EdgeInsets.only(top: 2),
      child: Text(val.toString(), style: AppTextStyles.badge),
    );

    final stack = Stack(
      children: [circle, label],
      alignment: Alignment.center,
    );

    return stack;
  }
}
