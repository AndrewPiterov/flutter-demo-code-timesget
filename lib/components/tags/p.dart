import 'package:flutter/material.dart';
import 'package:timesget/styles/colors.dart';
import 'package:timesget/styles/paddings.dart';
import 'package:timesget/styles/text_styles.dart';

const _padding =
    EdgeInsets.symmetric(horizontal: AppPaddings.left, vertical: 5.0);

class p extends StatelessWidget {
  final String text;

  p(this.text);

  @override
  Widget build(BuildContext context) {
    return SliverPadding(
        padding: const EdgeInsets.all(0.0),
        sliver: SliverList(
          delegate: SliverChildListDelegate([
            Container(
                color: AppColors.white,
                padding: _padding,
                child: Text(text, style: AppTextStyles.text))
          ]),
        ));
  }
}

class p2 extends StatelessWidget {
  final Widget child;
  final EdgeInsets padding;
  Color color;

  p2(this.child, {this.padding = const EdgeInsets.all(0.0), this.color}) {
    color = color ?? AppColors.white;
  }

  @override
  Widget build(BuildContext context) {
    return SliverPadding(
        padding: padding,
        sliver: SliverList(
          delegate: SliverChildListDelegate(
              [Container(color: color, padding: _padding, child: child)]),
        ));
  }
}
