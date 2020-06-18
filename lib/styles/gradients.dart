import 'package:flutter/material.dart';
import 'package:timesget/styles/colors.dart';

class AppGradients {
  static get purpleSelected => LinearGradient(
      colors: [AppColors.purpleGradientEnd, AppColors.purpleGradientStart],
      begin: const FractionalOffset(0.0, 0.0),
      end: const FractionalOffset(1.0, 4.0),
      stops: [0.5, 3.5],
      tileMode: TileMode.clamp);

  static get purpleChipSelected => LinearGradient(
      colors: [AppColors.purpleGradientEnd, AppColors.purpleGradientStart],
      begin: const FractionalOffset(0.0, 0.0),
      end: const FractionalOffset(1.0, 2.8),
      stops: [0.5, 2.5],
      tileMode: TileMode.clamp);

  static get orangeSelected => LinearGradient(
      colors: [AppColors.orangeGradientEnd, AppColors.purpleGradientStart],
      begin: const FractionalOffset(0.0, 0.0),
      end: const FractionalOffset(1.0, 4.0),
      stops: [0.5, 3.5],
      tileMode: TileMode.clamp);

  static get pageContent => LinearGradient(
        begin: const FractionalOffset(0.1, 0.1),
        end: const FractionalOffset(0.0, 0.2),
        stops: [0.0, 1.0],
        colors: [
          Color(0xFFECF3FD),
          Color(0xFFAEA3E5),
        ], // whitish to gray
        tileMode: TileMode.clamp, // repeats the gradient over the canvas
      );
}
