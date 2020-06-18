import 'package:flutter/material.dart';
import 'package:timesget/styles/colors.dart';

class AppShadows {
  static List<BoxShadow> tooltipTop = <BoxShadow>[
    BoxShadow(
        color: AppColors.shadow, blurRadius: 5.0, offset: Offset(0.0, -6.0))
  ];

  static List<BoxShadow> common = <BoxShadow>[
    BoxShadow(
        color: AppColors.shadow, blurRadius: 5.0, offset: Offset(0.0, 6.0))
  ];
}
