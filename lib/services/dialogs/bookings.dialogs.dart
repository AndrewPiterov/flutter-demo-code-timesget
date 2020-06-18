import 'package:flutter/material.dart';
import 'package:timesget/all_translations.dart';
import 'package:timesget/components/alert.dart';
import 'package:timesget/components/buttons.dart';
import 'package:timesget/models/booking.model.dart';
import 'package:timesget/models/user.model.dart';
import 'package:timesget/services/booking_cancelation.service.dart';
import 'package:timesget/styles/colors.dart';
import 'package:timesget/styles/constants.dart';
import 'package:timesget/styles/text_styles.dart';

const _pageName = "booking_dialog";
String _translate(String key) {
  return allTranslations.concatText([_pageName, key]);
}

class BookingsDialogs {
  Future<String> cancelBooking(
      {@required UserBooking booking,
      @required AppUser customer,
      @required BuildContext context}) async {
    final service = BookingCancelService();

    final content = SingleChildScrollView(
        child: Center(
      child: Column(
        children: [
          Text(
            _translate('sure_to_cancel'),
            style: AppTextStyles.text,
            textAlign: TextAlign.center,
          ),
          AppConstants.spaceH(50),
          Text(
            _translate('desc'),
            style: AppTextStyles.text.copyWith(color: AppColors.greyText),
            textAlign: TextAlign.center,
          ),
          AppConstants.spaceH(150),
          AppColoredButton(
            _translate('sure'),
            isBusy: service.isBusy$,
            onTap: () async {
              final cancelationResult =
                  await service.cancel(customer.uid, booking);
              if (!cancelationResult) {
                Navigator.pop(context, 'could not cancele!!!');
              }
              Navigator.pop(context, 'canceled');
            },
          ),
          AppConstants.spaceH(40),
          AppColoredButton(
            _translate('cancel'),
            color: AppColors.white,
            borderColor: AppColors.buttonActive,
            activeTitleColor: AppColors.text,
            onTap: () {
              Navigator.pop(context, 'none');
            },
          )
        ],
      ),
    ));

    final dialog = CustomAlertDialog(
        title: Text(
          '',
        ),
        hasCloseIcon: true,
        content: content);

    final res = await showDialog<String>(
        barrierDismissible: false,
        context: context,
        builder: (context) => dialog);

    return res;
  }
}
