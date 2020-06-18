import 'dart:async';
import 'package:flutter/material.dart';
import 'package:timesget/components/alert.dart';
import 'package:timesget/components/icons.dart';
import 'package:timesget/services/device_info.dart';
import 'package:timesget/styles/border_radius.dart';
import 'package:timesget/styles/colors.dart';
import 'package:timesget/styles/constants.dart';
import 'package:timesget/styles/paddings.dart';
import 'package:timesget/styles/text_styles.dart';
import 'package:rxdart/rxdart.dart';

typedef String GetTitleDelegate(dynamic item);
typedef void DropDownCallback(dynamic item);

enum AppDropDownButtonType { underline, bordered }

Future<T> openDialog<T>(BuildContext context, String title,
    Stream<List<T>> stream, GetTitleDelegate getTitleDelegate) async {
  final content = StreamBuilder<List<T>>(
      stream: stream,
      builder: (context, AsyncSnapshot<List<T>> snapshot) {
        if (!snapshot.hasData) {
          return AppConstants.circleSpinner;
        }

        final screenH = MediaQuery.of(context).size.height;
        final maxHeight = screenH * 0.6;
        final itemCount = snapshot.data.length;
        final itemHeight = itemCount * 35.0;
        final height = itemHeight > maxHeight ? maxHeight : itemHeight;

        return Container(
            height: height,
            child: CustomScrollView(slivers: [
              SliverFixedExtentList(
                itemExtent: 35.0,
                delegate: SliverChildBuilderDelegate(
                    (BuildContext context, int index) {
                  final item = snapshot.data[index];
                  final label = getTitleDelegate(item);
                  return InkWell(
                    onTap: () {
                      Navigator.pop(context, item);
                    },
                    child: Container(
                      padding: EdgeInsets.fromLTRB(0.0, 4.0, 0.0, 4.0),
                      child:
                          Text(label ?? '???', style: AppTextStyles.listItem),
                    ),
                  );
                }, childCount: snapshot.data.length),
              ),
            ]));
      });

  final dialog = CustomAlertDialog(
      title: Text(
        title,
        style: AppTextStyles.dialogTitle,
      ),
      content: content,
      hasCloseIcon: true);

  final res = await showDialog(
      barrierDismissible: true, context: context, builder: (context) => dialog);

  return res;
}

class AppDropDownButton<T> extends StatefulWidget {
  final AppDropDownButtonType type;
  final Stream<List<T>> stream;
  final Stream<T> initialValueStream;
  final String title;
  final String hint;
  final T initialValue;
  final GetTitleDelegate getTitleDelegate;
  final DropDownCallback onChange;
  final bool isHintCentered;
  final bool isActive;

  AppDropDownButton(this.type,
      {this.stream,
      this.title,
      this.hint,
      this.isHintCentered = false,
      this.initialValue,
      this.initialValueStream,
      this.getTitleDelegate,
      this.onChange,
      this.isActive = true});

  @override
  AppDropDownButtonState<T> createState() =>
      type == AppDropDownButtonType.underline
          ? _UnderlinedDropDownButtonState<T>()
          : _BorderedDropDownButtonState<T>();
}

abstract class AppDropDownButtonState<T> extends State<AppDropDownButton> {
  BehaviorSubject<T> selected;

  @override
  void initState() {
    super.initState();

    selected = BehaviorSubject<T>.seeded(widget.initialValue);

    if (widget.initialValueStream != null) {
      widget.initialValueStream.listen((item) {
        selected.add(item);
      });
    } else {}
  }

  @override
  Widget build(BuildContext context) => Container();
}

class _UnderlinedDropDownButtonState<T> extends AppDropDownButtonState<T> {
  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: InkWell(
        onTap: widget.isActive
            ? () async {
                final se = await openDialog(context, widget.title,
                    widget.stream, widget.getTitleDelegate);
                if (se != null) {
                  setState(() {
                    selected.add(se);
                    widget.onChange(se);
                  });
                }
              }
            : null,
        child: Container(
            height: 37.0,
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  StreamBuilder(
                      stream: selected,
                      builder: (context, AsyncSnapshot<T> snapshot) {
                        return Text(
                          snapshot.hasData && snapshot.data != null
                              ? widget.getTitleDelegate(snapshot.data)
                              : widget.hint,
                          textAlign: TextAlign.left,
                          style: AppTextStyles.dropDownValue,
                        );
                      }),
                  AppConstants.spaceH(10),
                  Container(
                    height: 1.5,
                    decoration: BoxDecoration(color: AppColors.border),
                  )
                ])),
      ),
    );
  }
}

class _BorderedDropDownButtonState<T> extends AppDropDownButtonState<T> {
  Widget get _arrowDown => Container(
        width: 26.0,
        // height: 40.0,
        child: widget.isActive ? AppIcons.arrowDown : Container(),
      );

  Widget _getHint(BuildContext context) {
    final String label = widget.hint;

    if (widget.isHintCentered) {
      final mq = MediaQuery.of(context).size;
      final left = mq.width / 2 -
          label.length * 7 / 2 -
          40; // 40 = pad left + pad border
      return Padding(
        padding: EdgeInsets.only(left: left),
        child: Text(
          label,
          style: AppTextStyles.inputHint,
        ),
      );
    } else {
      return Text(
        label,
        style: TextStyle(
            color: AppColors.border,
            fontWeight: FontWeight.w500,
            fontSize: DeviceInfo.isSmallWidth
                ? AppTextStyles.textFontSize
                : AppTextStyles.textFontSize),
      );
    }
  }

  Widget _buildValue(String value) {
    if (widget.isHintCentered) {
      return Container(
        child: Text(value,
            textAlign: TextAlign.center,
            style: AppTextStyles.text.copyWith(color: AppColors.dropDown)),
      );
    } else {
      return Text(value,
          style: AppTextStyles.text.copyWith(
              color: AppColors.dropDown, fontSize: AppTextStyles.dropDown));
    }
  }

  @override
  Widget build(BuildContext context) {
    final q = MediaQuery.of(context);
    final w = q.size.width;
    return InkWell(
      onTap: widget.isActive
          ? () async {
              final se = await openDialog(context, widget.title, widget.stream,
                  widget.getTitleDelegate);
              if (se != null) {
                setState(() {
                  selected.add(se);
                  widget.onChange(se as T);
                });
              }
            }
          : null,
      child: Container(
        height: AppConstants.inputHeight,
        width: w - AppPaddings.left * 2,
        decoration: BoxDecoration(
            border: Border.all(color: AppColors.border),
            borderRadius: AppBorderRadius.rowCard),
        padding: EdgeInsets.fromLTRB(20.0, 5.0, 10.0, 0.0),
        child: Stack(children: [
          Positioned(right: 5.0, top: 19.0, child: _arrowDown),
          Container(
              width: w - 83.0,
              padding: EdgeInsets.only(top: AppConstants.inputTopPadding),
              child: StreamBuilder(
                  stream: selected,
                  builder: (context, AsyncSnapshot<T> snapshot) {
                    return snapshot.hasData && snapshot.data != null
                        ? _buildValue(widget.getTitleDelegate(snapshot.data))
                        : _getHint(context);
                  })),
        ]),
      ),
    );
  }
}
