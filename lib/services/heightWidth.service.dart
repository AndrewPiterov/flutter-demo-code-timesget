import 'package:flutter/material.dart';
import 'package:timesget/models/app_image.dart';
import 'package:timesget/styles/paddings.dart';

class HeightWidthPair {
  final double height;
  final double width;
  HeightWidthPair({@required this.height, @required this.width});
}

class HeightWidthService {
  static HeightWidthPair calculate(BuildContext context,
      {bool withPaddings = true, double height, @required AppImage image}) {
    final mq = MediaQuery.of(context);
    final padds = withPaddings ? AppPaddings.left * 2 : 0;
    final width = mq.size.width - padds;

    final wRatio = (image.width / width);
    final hRatio = height != null ? image.height / height : null;

    final h = image.height / (hRatio == null ? wRatio : hRatio);
    final w = hRatio == null ? image.width / wRatio : image.width / hRatio;

    return HeightWidthPair(height: h, width: w);
  }
}
