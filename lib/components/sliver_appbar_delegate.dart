import 'package:flutter/material.dart';
import 'package:timesget/services/device_info.dart';
import 'package:timesget/styles/colors.dart';
import 'package:timesget/styles/constants.dart';
import 'package:timesget/styles/paddings.dart';
import 'package:timesget/styles/text_styles.dart';

class SliverAppBarHandleBottomDelegate extends SliverPersistentHeaderDelegate {
  final double height;
  SliverAppBarHandleBottomDelegate({this.height = 20.0});

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return AppConstants.bottomShadow();
  }

  @override
  double get maxExtent => height;

  @override
  double get minExtent => height;

  @override
  bool shouldRebuild(SliverPersistentHeaderDelegate oldDelegate) => true;
}

class SliverAppBarDelegate extends SliverPersistentHeaderDelegate {
  final String _title;
  final Widget child;

  SliverAppBarDelegate(this._title,
      {this.child, this.heigh1 = 66.0, this.heigh2 = 72.0})
      : assert(_title != null);

  final heigh1;
  final heigh2;

  // static const _hBottom = 71 / AppConstants.ration;

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
        height: child == null ? heigh1 : heigh2,
        decoration: BoxDecoration(color: Colors.white),
        child: Padding(
            padding: EdgeInsets.fromLTRB(AppPaddings.left,
                child == null ? 20.0 : 0.0, AppPaddings.right, 10.0),
            child: child == null ? _asTitle(context) : child));
  }

  Widget _asTitle(BuildContext context) {
    return Text('$_title',
        style: TextStyle(
            color: AppColors.text,
            fontWeight: FontWeight.w900,
            fontSize: DeviceInfo.isSmallWidth
                ? AppTextStyles.textFontSize
                : AppTextStyles.fontSize30));
  }

  @override
  double get maxExtent => child == null ? heigh1 : heigh2;

  @override
  double get minExtent => child == null ? heigh1 : heigh2;

  @override
  bool shouldRebuild(SliverPersistentHeaderDelegate oldDelegate) {
    return true;
  }
}
