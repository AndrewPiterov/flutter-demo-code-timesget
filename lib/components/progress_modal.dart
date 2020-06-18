// Copyright 2015 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';
import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

import 'package:flutter/material.dart';
import 'package:timesget/styles/constants.dart';
import 'package:timesget/styles/gradients.dart';
import 'package:timesget/styles/text_styles.dart';
import 'package:rxdart/rxdart.dart';

enum DialogViewColors { orange, purple }

// Examples can assume:
// enum Department { treasury, state }

/// A material design dialog.
///
/// This dialog widget does not have any opinion about the contents of the
/// dialog. Rather than using this widget directly, consider using [AlertDialog]
/// or [SimpleDialog], which implement specific kinds of material design
/// dialogs.
///
/// See also:
///
///  * [AlertDialog], for dialogs that have a message and some buttons.
///  * [SimpleDialog], for dialogs that offer a variety of options.
///  * [showDialog], which actually displays the dialog and returns its result.
///  * <https://material.google.com/components/dialogs.html>
class Dialog extends StatelessWidget {
  /// Creates a dialog.
  ///
  /// Typically used in conjunction with [showDialog].
  const Dialog({
    Key key,
    this.child,
    this.insetAnimationDuration: const Duration(milliseconds: 100),
    this.insetAnimationCurve: Curves.decelerate,
  }) : super(key: key);

  /// The widget below this widget in the tree.
  ///
  /// {@macro flutter.widgets.child}
  final Widget child;

  /// The duration of the animation to show when the system keyboard intrudes
  /// into the space that the dialog is placed in.
  ///
  /// Defaults to 100 milliseconds.
  final Duration insetAnimationDuration;

  /// The curve to use for the animation shown when the system keyboard intrudes
  /// into the space that the dialog is placed in.
  ///
  /// Defaults to [Curves.fastOutSlowIn].
  final Curve insetAnimationCurve;

  Color _getColor(BuildContext context) {
    return Theme.of(context).dialogBackgroundColor;
  }

  @override
  Widget build(BuildContext context) {
    return new AnimatedPadding(
      padding: MediaQuery.of(context).viewInsets +
          const EdgeInsets.symmetric(
              horizontal: 60 / AppConstants.ration, vertical: 24.0),
      duration: insetAnimationDuration,
      curve: insetAnimationCurve,
      child: new MediaQuery.removeViewInsets(
        removeLeft: true,
        removeTop: true,
        removeRight: true,
        removeBottom: true,
        context: context,
        child: new Center(
          child: new ConstrainedBox(
            constraints: const BoxConstraints(minWidth: 9999.9), // Stub
            child: new Material(
              borderRadius: BorderRadius.all(Radius.circular(7.0)),
              elevation: 30.0,
              color: _getColor(context),
              type: MaterialType.card,
              child: child,
            ),
          ),
        ),
      ),
    );
  }
}

/// A material design alert dialog.
///
/// An alert dialog informs the user about situations that require
/// acknowledgement. An alert dialog has an optional title and an optional list
/// of actions. The title is displayed above the content and the actions are
/// displayed below the content.
///
/// If the content is too large to fit on the screen vertically, the dialog will
/// display the title and the actions and let the content overflow. Consider
/// using a scrolling widget, such as [ListView], for [content] to avoid
/// overflow.
///
/// For dialogs that offer the user a choice between several options, consider
/// using a [SimpleDialog].
///
/// Typically passed as the child widget to [showDialog], which displays the
/// dialog.
///
/// ## Sample code
///
/// This snippet shows a method in a [State] which, when called, displays a dialog box
/// and returns a [Future] that completes when the dialog is dismissed.
///
/// ```dart
/// Future<Null> _neverSatisfied() async {
///   return showDialog<Null>(
///     context: context,
///     barrierDismissible: false, // user must tap button!
///     builder: (BuildContext context) {
///       return new AlertDialog(
///         title: new Text('Rewind and remember'),
///         content: new SingleChildScrollView(
///           child: new ListBody(
///             children: <Widget>[
///               new Text('You will never be satisfied.'),
///               new Text('You\’re like me. I’m never satisfied.'),
///             ],
///           ),
///         ),
///         actions: <Widget>[
///           new FlatButton(
///             child: new Text('Regret'),
///             onPressed: () {
///               Navigator.of(context).pop();
///             },
///           ),
///         ],
///       );
///     },
///   );
/// }
/// ```
///
/// See also:
///
///  * [SimpleDialog], which handles the scrolling of the contents but has no [actions].
///  * [Dialog], on which [AlertDialog] and [SimpleDialog] are based.
///  * [showDialog], which actually displays the dialog and returns its result.
///  * <https://material.google.com/components/dialogs.html#dialogs-alerts>
class CustomProgessDialog extends StatelessWidget {
  /// Creates an alert dialog.
  ///
  /// Typically used in conjunction with [showDialog].
  ///
  /// The [contentPadding] must not be null. The [titlePadding] defaults to
  /// null, which implies a default that depends on the values of the other
  /// properties. See the documentation of [titlePadding] for details.
  const CustomProgessDialog({
    Key key,
    this.content,
    this.contentPadding: const EdgeInsets.fromLTRB(24.0, 16.0, 24.0, 20.0),
    this.progressTitle,
    this.progress,
  }) : super(key: key);

  /// Padding around the content.
  ///
  /// If there is no content, no padding will be provided. Otherwise, padding of
  /// 20 pixels is provided above the content to separate the content from the
  /// title, and padding of 24 pixels is provided on the left, right, and bottom
  /// to separate the content from the other edges of the dialog.
  final EdgeInsetsGeometry contentPadding;

  /// The (optional) content of the dialog is displayed in the center of the
  /// dialog in a lighter font.
  ///
  /// Typically, this is a [ListView] containing the contents of the dialog.
  /// Using a [ListView] ensures that the contents can scroll if they are too
  /// big to fit on the display.
  final Widget content;

  final Observable<int> progress;
  final Observable<String> progressTitle;

  @override
  Widget build(BuildContext context) {
    final List<Widget> children = <Widget>[];

    final width =
        MediaQuery.of(context).size.width - 60 / AppConstants.ration - 58;

    final progressBar = Container(
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.all(Radius.circular(2.5)),
      ),
      height: 5.0,
      width: width,
      child: StreamBuilder(
          stream: progress,
          builder: (context, AsyncSnapshot<int> snap) {
            if (!snap.hasData) {
              return Text("0%");
            }
            final p = snap.data;
            final w = width * p / 100;
            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Container(
                  decoration: BoxDecoration(
                    gradient: AppGradients.purpleSelected,
                    borderRadius: BorderRadius.all(Radius.circular(2.5)),
                  ),
                  height: 5.0,
                  width: w > 0 ? w : 3.0,
                  child: Container(),
                )
              ],
            );
          }),
    );

    if (content != null) {
      children.add(new Flexible(
        child: new Padding(
          padding: EdgeInsets.all(0.0), // contentPadding,
          child: DefaultTextStyle(
            style: Theme.of(context).textTheme.subhead,
            child: Container(
                decoration: BoxDecoration(
                  // color: Colors.amber,
                  borderRadius: BorderRadius.all(Radius.circular(7.0)),
                ),
                height: 50.0,
                child: Padding(
                    padding:
                        EdgeInsets.symmetric(horizontal: 7.0, vertical: 4.0),
                    child: Center(
                        child: Column(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                          progressBar,
                          StreamBuilder(
                              stream: progressTitle,
                              builder: (context, AsyncSnapshot<String> snap) {
                                if (!snap.hasData) {
                                  return Text('');
                                }
                                return Text(
                                  snap.data,
                                  style: AppTextStyles.text,
                                );
                              })
                        ])))),
          ),
        ),
      ));
    }

    Widget dialogChild = new IntrinsicWidth(
      child: Container(
        height: 50.0,
        child: new Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: children,
        ),
      ),
    );

    return new Dialog(child: dialogChild);
  }
}
