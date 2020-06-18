import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:timesget/styles/text_styles.dart';
import 'package:url_launcher/url_launcher.dart';

class a extends TextSpan {
  final String url;

  // Beware!
  //
  // This class is only safe because the TapGestureRecognizer is not
  // given a deadline and therefore never allocates any resources.
  //
  // In any other situation -- setting a deadline, using any of the less trivial
  // recognizers, etc -- you would have to manage the gesture recognizer's
  // lifetime and call dispose() when the TextSpan was no longer being rendered.
  //
  // Since TextSpan itself is @immutable, this means that you would have to
  // manage the recognizer from outside the TextSpan, e.g. in the State of a
  // stateful widget that then hands the recognizer to the TextSpan.

  a(this.url, {TextStyle style, String text, TextStyle unurlStyle})
      : super(
            style: (url == null || url.isEmpty) && unurlStyle != null
                ? unurlStyle
                : style,
            text: text ?? url,
            recognizer: url == null || url.isEmpty
                ? null
                : (TapGestureRecognizer()
                  ..onTap = () {
                    launch(url, forceSafariVC: false);
                  }));
}

class a2 extends TextSpan {
  final String text;

  a2(this.text, {onClick}) :
    super(
        text: text,
        style: onClick == null ? AppTextStyles.text : AppTextStyles.link,
        recognizer: onClick == null
            ? null
            : (TapGestureRecognizer()
              ..onTap = () {
                onClick();
              }));

}
