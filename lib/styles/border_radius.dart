import 'package:flutter/material.dart';

class AppRoundCorners {
  static const double radius = 7.0;
  static const double radiusX2 = radius * 2;

  static Radius rounded = Radius.circular(AppRoundCorners.radius);

  static Radius half(double h) => Radius.circular(h / 2);
}

class AppBorderRadius {
  static BorderRadius rowCard =
      BorderRadius.all(Radius.circular(AppRoundCorners.radius));
}
