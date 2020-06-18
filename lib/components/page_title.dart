import 'package:flutter/material.dart';
import 'package:timesget/styles/paddings.dart';
import 'package:timesget/styles/shadows.dart';
import 'package:timesget/styles/text_styles.dart';

class PageTitle extends StatelessWidget {
  final String _title;
  final String topText;

  PageTitle(this._title, {this.topText});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
          color: Colors.white, boxShadow: AppShadows.common),
      width: double.infinity,
      child: Padding(
          padding: AppPaddings.pageTitle,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              topText == null ? Container() : Text(topText),
              topText == null
                  ? Container()
                  : Container(
                      height: 10.0,
                    ),
              // Text(topText == null ? '' : topText),
              Text(
                _title,
                style: AppTextStyles.pageTitle,
              ),
              Container(
                height: 10.0,
              )
            ],
          )),
    );
  }
}

class PageTitle2 extends StatelessWidget {
  final Widget child;
  PageTitle2(this.child, {Key key})
      : assert(child != null),
        super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
          color: Colors.white, boxShadow: AppShadows.common),
      width: double.infinity,
      child: Padding(
          padding: AppPaddings.pageTitle,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              child,
              Container(
                height: 10.0,
              )
            ],
          )),
    );
  }
}
