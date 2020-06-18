import 'package:flutter/material.dart';
import 'package:timesget/all_translations.dart';
import 'package:timesget/components/alert.dart';
import 'package:timesget/components/buttons.dart';
import 'package:timesget/components/tags/text.dart';
import 'package:timesget/services/mobile_users.service.dart';
import 'package:timesget/styles/constants.dart';
import 'package:timesget/styles/text_styles.dart';

class AppDialogs {
  static Future<bool> requestResetPasswordOnEmail(
    String email,
    BuildContext context,
  ) async {
    final content = SingleChildScrollView(
        child: FutureBuilder(
      future: MobileUsersService().doesEmailExist(email),
      builder: (context, AsyncSnapshot<bool> snap) {
        if (!snap.hasData) {
          return Center(
            child: AppConstants.circleSpinner,
          );
        }

        if (!snap.data) {
          return text(allTranslations
              .concatText(['password_recovery', 'not_found_email']));
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            // dialog top
            text(allTranslations.concatText(['password_recovery', 'sure'])),
            AppConstants.spaceH3(10),
            Text(
              email,
              style: AppTextStyles.text.copyWith(
                  fontSize: AppTextStyles.fontSize18,
                  fontWeight: FontWeight.w900),
            ),

            AppConstants.spaceH3(25),

            AppColoredButton(
              allTranslations.concatText(['password_recovery', 'send']),
              isBusy: MobileUsersService().loading,
              onTap: () async {
                // Send email
                await MobileUsersService().sendResetPasswordEmail(email);
                Navigator.of(context).pop(true);
              },
            )
          ],
        );
      },
    ));

    final dialog = CustomAlertDialog(
        title: Text(
          allTranslations.concatText(['password_recovery', 'title']),
          style: AppTextStyles.dialogTitle,
        ),
        hasCloseIcon: true,
        content: content);

    final res = await showDialog(
        barrierDismissible: false,
        context: context,
        builder: (context) => dialog);

    return res;
  }
}
