import 'package:flutter/material.dart';
import 'package:timesget/all_translations.dart';
import 'package:timesget/components/icons.dart';
import 'package:timesget/components/tags/a.dart';
import 'package:timesget/models/city_provider.dart';
import 'package:timesget/models/company.dart';
import 'package:timesget/styles/border_radius.dart';
import 'package:timesget/styles/colors.dart';
import 'package:timesget/styles/constants.dart';
import 'package:timesget/styles/text_styles.dart';

const _pageName = "accept_rule_button";
String _translate(String key) {
  return allTranslations.concatText([_pageName, key]);
}

class AcceptRulesButton extends StatelessWidget {
  final bool isActive;
  final bool onlyProcessPrivateData;

  final GestureDragCancelCallback onTap;
  AcceptRulesButton(this.isActive,
      {this.onTap, this.onlyProcessPrivateData = false});

  static final TextStyle _linkStyle = AppTextStyles.ruleLink;
  static final TextStyle _textStyle = AppTextStyles.rule;

  Widget firstText(String url) {
    return RichText(
      text: TextSpan(children: [
        TextSpan(text: 'Я ознакомлен(а) и согласен(на) с ', style: _textStyle),
        a(url, // 'http://new-doc.com/offer/',
            text: 'правилами',
            style: _linkStyle,
            unurlStyle: _textStyle),
        TextSpan(text: ' приложения.', style: _textStyle),
      ]),
    );
  }

  a _privacyLink(String url) =>
      a(url, // 'http://www.new-doc.com/agreement/ru/',
          text: 'персональных данных',
          style: _linkStyle,
          unurlStyle: _textStyle);

  Widget secondText(String privacyUrl) {
    return RichText(
      text: TextSpan(children: [
        TextSpan(
            text: 'Пользуясь приложением, я даю согласие на обработку своих ',
            style: _textStyle),
        _privacyLink(privacyUrl),
        TextSpan(
            text:
                ', согласно Федеральному закону от 27.07.2006 N 152-ФЗ "О персональных данных".',
            style: _textStyle),
      ]),
    );
  }

  Widget _processPrivateData(String privacyUrl) {
    return RichText(
      text: TextSpan(children: [
        TextSpan(text: 'Я даю согласие на обработку своих ', style: _textStyle),
        _privacyLink(privacyUrl),
        TextSpan(
            text:
                ', согласно Федеральному закону от 27.07.2006 N 152-ФЗ "О персональных данных".',
            style: _textStyle),
      ]),
    );
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<Company>(
      stream: ModelProvider.of(context).company$,
      builder: (builder, snap) {
        if (!snap.hasData) {
          return AppConstants.circleSpinner;
        }

        final company = snap.data;

        return InkWell(
          borderRadius: AppBorderRadius.rowCard,
          onTap: onTap,
          child: Container(
            decoration: BoxDecoration(
              border: Border.all(color: AppColors.border),
              borderRadius: AppBorderRadius.rowCard,
            ),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Container(
                child: Row(
                  children: <Widget>[
                    Expanded(
                      flex: 1,
                      child: Container(
                        height: 36.0,
                        child: isActive
                            ? AppIcons.checkmarkActive
                            : AppIcons.checkmarkInactive,
                      ),
                    ),
                    Expanded(
                      flex: 3,
                      child: Column(
                        children: onlyProcessPrivateData
                            ? <Widget>[_processPrivateData(company.privacyUrl)]
                            : <Widget>[
                                firstText(company.rulesUrl),
                                Container(
                                  height: 71.0 / 3,
                                ),
                                secondText(company.privacyUrl)
                              ],
                      ),
                    )
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
