import 'package:flutter/material.dart';
import 'package:timesget/styles/colors.dart';
import 'package:timesget/styles/text_styles.dart';

class text extends StatelessWidget {
  final String str;
  final Color color;
  final double size;

  text(this.str, {this.color, this.size}) : assert(str != null);

  @override
  Widget build(BuildContext context) {
    var style = AppTextStyles.text;

    style = style.copyWith(color: color != null ? color : AppColors.text);

    style = style.copyWith(
        fontSize: size != null ? size : AppTextStyles.textFontSize);

    return Text(str, style: style);
  }
}
