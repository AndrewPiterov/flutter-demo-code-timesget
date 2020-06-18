import 'package:flutter/material.dart';
import 'package:timesget/styles/border_radius.dart';
import 'package:timesget/styles/colors.dart';
import 'package:timesget/styles/constants.dart';
import 'package:timesget/styles/paddings.dart';
import 'package:timesget/styles/text_styles.dart';

class Input extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final TextStyle hintStyle;
  final TextInputType keyboardType;
  final int maxLines;
  final Image rightIcon;
  final bool obscure;
  final String error;

  final double iconWidth = 60.0;

  Input(this.controller,
      {this.hintText = '',
      this.hintStyle,
      this.keyboardType = TextInputType.text,
      this.maxLines = 1,
      this.rightIcon,
      this.obscure = false,
      this.error});

  @override
  Widget build(BuildContext context) {
    final isSelected = controller.selection.start > -1;
    return LayoutBuilder(
      builder: (context, constraints) {
        final w = constraints.maxWidth;
        final hasRightIcon = rightIcon != null;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Container(
              padding: hasRightIcon
                  ? EdgeInsets.only(left: AppPaddings.left)
                  : EdgeInsets.symmetric(horizontal: AppPaddings.left),
              decoration: BoxDecoration(
                  border: Border.all(
                      color: error != null
                          ? AppColors.error
                          : isSelected
                              ? AppColors.inputSelected
                              : AppColors.inputNonSelected,
                      width: error != null ? 2.0 : 1.0),
                  borderRadius: AppBorderRadius.rowCard),
              height: maxLines == 1
                  ? AppConstants.inputHeight
                  : 21.3 * maxLines + 27.0,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Container(
                    padding:
                        EdgeInsets.only(top: AppConstants.inputTopPadding2),
                    constraints: BoxConstraints(
                        maxWidth: hasRightIcon
                            ? w - AppPaddings.left - iconWidth
                            : w - AppPaddings.left * 2 - 5.0),
                    child: Theme(
                      data: ThemeData(
                        platform:
                            TargetPlatform.iOS, //  TargetPlatform.android,
                      ),
                      child: TextField(
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          hintText: hintText,
                          hintStyle: AppTextStyles.inputHint,
                        ),
                        controller: controller,
                        style: AppTextStyles.inputText,
                        keyboardType: keyboardType,
                        maxLines: maxLines,
                        obscureText: obscure,
                      ),
                    ),
                  ),
                  hasRightIcon
                      ? Container(
                          // width: iconWidth,
                          padding:
                              const EdgeInsets.fromLTRB(0.0, 10.0, 13.0, 10.0),
                          child: rightIcon,
                        )
                      : Container()
                ],
              ),
            ),
            error == null
                ? Container()
                : Container(
                    padding: EdgeInsets.fromLTRB(0.0, 5.0, 0.0, 1.0),
                    child: Text(
                      error,
                      style: TextStyle(
                          color: AppColors.error,
                          fontSize: AppTextStyles.fontSize14,
                          fontWeight: FontWeight.w500),
                    ),
                  )
          ],
        );
      },
    );
  }
}
