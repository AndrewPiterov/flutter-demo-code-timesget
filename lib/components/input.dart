import 'package:flutter/material.dart';
import 'package:timesget/styles/border_radius.dart';
import 'package:timesget/styles/colors.dart';
import 'package:timesget/styles/constants.dart';

/// Signature for [InputBox].
typedef void AppInputTextCallback(String value);

class InputBox extends StatefulWidget {
  final AppInputTextCallback callback;
  final String hint;
  final int lineCount;
  final key;

  // heigh = 126px

  InputBox({this.key, this.hint, this.callback, this.lineCount = 1});

  @override
  InputBoxState createState() => InputBoxState();
}

class InputBoxState extends State<InputBox> {
  // final inputKey = GlobalKey<_InputState>();

  final _textController = TextEditingController();

  @override
  void initState() {
    super.initState();

    if (widget.callback != null) {
      _textController.addListener(_notify);
    }
  }

  void _notify() {
    final value = _textController.text;
    if (widget.callback != null) {
      widget.callback(value);
    }
  }

  void clear() {
    setState(() {
      _textController.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.rowTitle),
        borderRadius: AppBorderRadius.rowCard,
        // color: Colors.cyan
      ),
      height: AppConstants.sizeOf(126) * widget.lineCount,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 62 / AppConstants.ration,
        ),
        child: Row(
          children: <Widget>[
            Expanded(
              child: TextField(
                // key: inputKey,
                style: TextStyle(fontSize: 18.0, color: Colors.black),
                controller: _textController,
                maxLines: widget.lineCount,
                decoration: InputDecoration(
                    border: InputBorder.none,
                    hintText: widget.hint != null ? widget.hint : null,
                    hintStyle: widget.hint != null
                        ? TextStyle(color: Colors.grey, fontSize: 16.0)
                        : null),
              ),
            ),
            // AppIcons.search,
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _textController.removeListener(_notify);
    _textController.dispose();
    super.dispose();
  }
}
