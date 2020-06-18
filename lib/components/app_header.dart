import 'package:flutter/material.dart';
import 'package:timesget/components/current_city.dart';
import 'package:timesget/components/icons.dart';
import 'package:timesget/components/iphonex_padding.dart';
import 'package:timesget/styles/paddings.dart';
import 'package:timesget/styles/shadows.dart';

class AppHeader extends StatelessWidget {
  final canBack;
  final withShadow;
  AppHeader({this.canBack = false, this.withShadow = false});

  @override
  Widget build(BuildContext context) {
    final isIPhoneX = IPhoneXPadding.isIPhoneX(MediaQuery.of(context));

    return SliverPersistentHeader(
        pinned: true,
        delegate: isIPhoneX
            ? _AppHeaderIPhoneXDelegate(
                canBack: canBack, withShadow: withShadow)
            : _AppHeaderDelegate(canBack: canBack, withShadow: withShadow));
  }
}

class _AppHeaderIPhoneXDelegate extends SliverPersistentHeaderDelegate {
  final canBack;
  final withShadow;
  double _heigh;

  final color = Colors.white;

  _AppHeaderIPhoneXDelegate({this.canBack = false, this.withShadow = false}) {
    this._heigh = 95 + (withShadow ? 0.0 : 20.0);
  }

  Row getRow(BuildContext context) {
    return canBack
        ? Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            InkWell(
                child: AppIcons.arrowBack(height: 20.0),
                onTap: () {
                  if (Navigator.canPop(context)) {
                    Navigator.pop(context);
                  } else {
                    print('There is no way to back.');
                  }
                }),
            CurrentCityView()
          ])
        : Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: <Widget>[CurrentCityView()],
          );
  }

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return IPhoneXPadding(
      child: Container(
          height: _heigh,
          decoration: BoxDecoration(
              color: color, boxShadow: withShadow ? AppShadows.common : null),
          child: Padding(
              padding: EdgeInsets.fromLTRB(
                  AppPaddings.left, 59.0, AppPaddings.left, 7.0),
              child: getRow(context))),
    );
  }

  @override
  double get maxExtent => _heigh;

  @override
  double get minExtent => _heigh;

  @override
  bool shouldRebuild(SliverPersistentHeaderDelegate oldDelegate) {
    return true;
  }
}

class _AppHeaderDelegate extends SliverPersistentHeaderDelegate {
  final canBack;
  final withShadow;
  double _height;

  final color = Colors.white;

  _AppHeaderDelegate({this.canBack = false, this.withShadow}) {
    this._height = 60.0 + (withShadow ? 0.0 : 20.0);
  }

  Row getRow(BuildContext context) {
    return canBack
        ? Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            InkWell(
                child: AppIcons.arrowBack(height: 20.0),
                onTap: () {
                  if (Navigator.canPop(context)) {
                    Navigator.pop(context);
                  } else {
                    print('There is no way to back.');
                  }
                }),
            CurrentCityView()
          ])
        : Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: <Widget>[CurrentCityView()],
          );
  }

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return IPhoneXPadding(
      child: Container(
          height: _height,
          decoration: BoxDecoration(
              color: color, boxShadow: withShadow ? AppShadows.common : null),
          child: Padding(
              padding: EdgeInsets.fromLTRB(
                  AppPaddings.left, 33.0, AppPaddings.left, 0.0),
              child: getRow(context))),
    );
  }

  @override
  double get maxExtent => _height;

  @override
  double get minExtent => _height;

  @override
  bool shouldRebuild(SliverPersistentHeaderDelegate oldDelegate) {
    return true;
  }
}
