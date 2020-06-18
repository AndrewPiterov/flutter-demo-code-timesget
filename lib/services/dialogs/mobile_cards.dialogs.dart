import 'package:flutter/material.dart';
import 'package:timesget/all_translations.dart';
import 'package:timesget/components/alert.dart';
import 'package:timesget/components/tags/text.dart';
import 'package:timesget/models/mobile_card.dart';
import 'package:timesget/models/user.model.dart';
import 'package:timesget/services/mobile_card.service.dart';
import 'package:timesget/styles/constants.dart';
import 'package:timesget/styles/text_styles.dart';

const _pageName = "mobile_card_dialog";
String _translate(String key) {
  return allTranslations.concatText([_pageName, key]);
}

class MobileCardsDialogs {
  Future<void> openToChooseBarcode(
      {@required MobileCard forCard,
      @required AppUser customer,
      @required context}) async {
    final content = SingleChildScrollView(
        child: StreamBuilder(
      stream: MobilCardService()
          .buildStreamForWaitSuccessChoosingNumber(forCard, customer),
      builder: (context, AsyncSnapshot<CardNumber> snap) {
        if (!snap.hasData) {
          return Column(
            children: <Widget>[
              text(_translate('choosing')),
              Padding(
                padding: EdgeInsets.only(top: 10.0, bottom: 7.0),
                child: AppConstants.circleSpinner,
              )
            ],
          );
        }

        final card = snap.data;
        print('Choosed card number: ${card.value} for ${card.uid}.');
        return text(_translate('success'));
      },
    ));

    final dialog = CustomAlertDialog(
        title: Text(
          _translate('title'),
          style: AppTextStyles.dialogTitle,
        ),
        hasCloseIcon: true,
        content: content);

    MobilCardService().requestNumber(forCard, customer).then((_) {
      print('Request for choose card number has been saved.');
    }).catchError((err) {
      print(err);
    });

    final res = await showDialog(
        barrierDismissible: false,
        context: context,
        builder: (context) => dialog);

    return res;
  }
}
