import 'dart:async';
import 'package:barcode_flutter/barcode_flutter.dart';
import 'package:barcode_scan/barcode_scan.dart';
import 'package:flutter/material.dart';
import 'package:timesget/all_translations.dart';
import 'package:timesget/components/alert.dart';
import 'package:timesget/components/app_bar.dart';
import 'package:timesget/components/app_bottom_bars.dart';
import 'package:timesget/components/app_drawer.dart';
import 'package:timesget/components/buttons/login.button.dart';
import 'package:timesget/components/icons.dart';
import 'package:timesget/components/row_card.dart';
import 'package:timesget/components/tags/h1.dart';
import 'package:timesget/components/tags/text.dart';
import 'package:flutter/cupertino.dart';
import 'package:timesget/models/mobile_card.dart';
import 'package:timesget/services/app_tooltip.dart';
import 'package:timesget/services/auth.service.dart';
import 'package:timesget/services/device_info.dart';
import 'package:timesget/services/dialogs/mobile_cards.dialogs.dart';
import 'package:timesget/services/heightWidth.service.dart';
import 'package:timesget/services/mobile_card.service.dart';
import 'package:timesget/services/result.dart';
import 'package:timesget/styles/border_radius.dart';
import 'package:timesget/styles/colors.dart';
import 'package:timesget/styles/constants.dart';
import 'package:timesget/styles/paddings.dart';
import 'package:timesget/styles/text_styles.dart';
import 'package:flutter/services.dart';
import 'package:page_transition/page_transition.dart';

// !!! NOT IMPLEMENTED YET !!!
// HELP https://stackoverflow.com/questions/52812081/flutter-close-a-dialog-inside-a-condition
const _pageName = "mobile_cards_page";
String _translate(String key) {
  return allTranslations.concatText([_pageName, key]);
}

class MobilCardsPage extends StatefulWidget {
  @override
  MobilCardsPageState createState() {
    return MobilCardsPageState();
  }
}

class MobilCardsPageState extends State<MobilCardsPage> {
  String _barcode = "";

  Future<String> scan() async {
    try {
      final barcode = await BarcodeScanner.scan();
      return barcode;
    } on PlatformException catch (e) {
      if (e.code == BarcodeScanner.CameraAccessDenied) {
        // setState(() {
        //   this.barcode = 'The user did not grant the camera permission!';
        // });
      } else {
        // setState(() => this.barcode = 'Unknown error: $e');
      }
      return '';
    } on FormatException {
      return '';
      // setState(() => this.barcode =
      //     'null (User returned using the "back"-button before scanning anything. Result)');
    } catch (e) {
      // setState(() => this.barcode = 'Unknown error: $e');
      return '';
    }
  }

  Widget _scanButton(BuildContext context) {
    return InkWell(
      onTap: () async {
        // Navigator.of(context).pushNamed('/barcode-scanner');
        final barcode = await scan();
        setState(() => _barcode = barcode);

        if (barcode != null && barcode != '') {
          print('There is barcode $barcode to verify!');
        }

        final res = await MobilCardService()
            .bindScannedBarcodeToUser(AuthService().profile.value, barcode);

        if (res.isFail) {
          print('Scanned barcode is not valid: ${res.message}');
          switch (res.error) {
            case Errors.NotFound:
              AppNotification().show(
                  context, buildOverlay(_translate('invalid_card')),
                  duration: Duration(seconds: 3));
              break;
            case Errors.CardNumberHasOwner:
              AppNotification().show(
                  context, buildOverlay(_translate('already_taken')),
                  duration: Duration(seconds: 3));
              break;

            case Errors.YouHaveAlreadyThisCardNumber:
              AppNotification().show(
                  context, buildOverlay(_translate('already_yours')),
                  duration: Duration(seconds: 3));
              break;
            case Errors.AlreadyHasNumberInGroup:
              AppNotification().show(
                  context, buildOverlay(_translate('already_have_one')),
                  duration: Duration(seconds: 3));
              break;
            default:
              AppNotification().show(
                  context,
                  buildOverlay(
                      _translate('error_happened') + ': ${res.message}',
                      title: 'Error'),
                  duration: Duration(seconds: 12));
              break;
          }
        } else {
          AppNotification().show(context, buildOverlay(_translate('congrat')),
              duration: Duration(seconds: 3));
        }
      },
      child: Container(
        decoration: BoxDecoration(
            border: Border.all(color: AppColors.scanButtonBorder, width: 3.0),
            borderRadius: BorderRadius.circular(40.0)),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 20.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: <Widget>[
              AppIcons.barcodeScan(h: DeviceInfo.isSmallWidth ? 30.0 : 40.0),
              Padding(
                padding: EdgeInsets.only(right: 10),
                child: text(_translate('scan_button'),
                    size: DeviceInfo.isSmallWidth
                        ? AppTextStyles.textFontSize
                        : AppTextStyles.fontSize18),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _addExistedPlasticCardButton(BuildContext context) {
    return StreamBuilder(
      stream: AuthService().profile,
      builder: (context, snap) {
        if (!snap.hasData) {
          return LoginButton(
            onSuccess: (String type) {
              Navigator.push(
                  context,
                  PageTransition(
                      type: PageTransitionType.upToDown,
                      child: MobilCardsPage()));

              Timer(Duration(milliseconds: 350), () {
                AppNotification().show(
                    context,
                    buildOverlay(_translate(
                        type == 'login' ? 'success_login' : 'success_signup')),
                    duration: Duration(seconds: 7));
              });
            },
          );
        }

        return _scanButton(context);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: getAppBar(
          context,
        ),
        drawer: AppDrawer.of(context),
        backgroundColor: AppColors.pageBackground,
        body: Column(children: [
          Expanded(
              child: CustomScrollView(
            physics: BouncingScrollPhysics(),
            shrinkWrap: true,
            slivers: <Widget>[
              HeaderBoard(
                _translate('title'),
                children: <Widget>[
                  text(_translate('scan_desc')),
                  AppConstants.spaceH3(3),
                  _addExistedPlasticCardButton(context),
                  AppConstants.spaceH3(10),
                  Text(
                    _translate('your_cards'),
                    style: AppTextStyles.h1,
                  ),
                  AppConstants.spaceH3(3),
                  text(_translate('description'))
                ],
              ),
              _MobilCardList(),
            ],
          )),
          AppBottomTabBars()
        ]));
  }
}

class _MobilCardList extends StatefulWidget {
  final AppDialog dialog = AppDialog();

  @override
  _MobilCardListState createState() => _MobilCardListState();
}

class _MobilCardListState extends State<_MobilCardList> {
  CustomerCard mcard;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // print('!!!DID CHANGE DEPENDENCIES!!!');
    // Future.delayed(Duration(milliseconds: 50)).then((_) {
    //   widget.dialog
    //       .barcodeOpened(context, LoginStateProvider.of(context).mcard);
    // });
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: MobilCardService().cards,
      builder: (context, AsyncSnapshot<List<CustomerCard>> snapshot) {
        if (!snapshot.hasData) {
          return AppConstants.circleSpinnerSlivered;
        }

        if (snapshot.data.isEmpty) {
          return SliverPadding(
              padding: EdgeInsets.fromLTRB(
                  AppPaddings.left, 20.0, AppPaddings.left, 20.0),
              sliver: SliverList(
                  delegate: SliverChildListDelegate([
                Center(
                    child: Text(
                  _translate('no_item'),
                  textAlign: TextAlign.center,
                  style: AppTextStyles.textNoItems,
                ))
              ])));
        }

        MobilCardService().mobilcardsHasBeenOpened.add(DateTime.now());

        final user = AuthService().profile.value;
        return SliverPadding(
            padding: EdgeInsets.all(20.0),
            sliver: SliverList(
                delegate: SliverChildBuilderDelegate((builder, i) {
              final mcard = snapshot.data[i];
              final barcode = mcard.barcode;

              final size = HeightWidthService.calculate(context,
                  image: mcard.card.mainImage);

              return Column(
                children: <Widget>[
                  InkWell(
                      child: Stack(
                        children: <Widget>[
                          RowCardComponent(
                              child: ImageRowCardComponent(
                                size: size,
                                image: mcard.card.mainImage,
                                fit: BoxFit.fitHeight,
                                colorFilter: mcard.barcode == null
                                    ? ColorFilter.mode(
                                        AppColors.mobilCardUnavailable
                                            .withOpacity(0.5),
                                        BlendMode.srcOver)
                                    : null,
                              ),
                              paddings: EdgeInsets.all(0.0)),
                          user == null
                              ? Container()
                              : Positioned(
                                  right: AppPaddings.left,
                                  top: size.height / 2 - 30.0,
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: AppColors.mobileCardGetCard,
                                      borderRadius: BorderRadius.all(
                                          Radius.circular(
                                              AppRoundCorners.radiusX2)),
                                    ),
                                    padding: EdgeInsets.fromLTRB(
                                        22.0, 12.0, 5.0, 0.0),
                                    height: 62.0,
                                    width: 120.0,
                                    child: text(
                                      barcode == null
                                          ? _translate('get')
                                          : _translate('show'),
                                      color: AppColors.mobileCardGetCardText,
                                    ),
                                  ),
                                ),
                          user == null
                              ? Container()
                              : Positioned(
                                  right: 120.0,
                                  top: size.height / 2 - 19.0,
                                  child: Image.asset(
                                    barcode != null
                                        ? 'assets/img/OpenCard.png'
                                        : 'assets/img/AddCard.png',
                                    height: 37.0,
                                  ),
                                ),
                        ],
                      ),
                      onTap: user == null
                          ? null
                          : () async {
                              if (barcode == null) {
                                await MobileCardsDialogs().openToChooseBarcode(
                                    forCard: mcard.card,
                                    customer: AuthService().profile.value,
                                    context: context);
                                return;
                              }
                              print('Show barcode: ${barcode.value}');
                              final dialog = AppDialog();
                              setState(() {
                                this.mcard = mcard;
                              });

                              dialog.barcodeOpened(context, mcard);
                            }),
                  AppConstants.betweenRowCards
                ],
              );
            }, childCount: snapshot.data.length)));
      },
    );
  }
}

class LoginStateProvider extends InheritedWidget {
  final MobileCard mcard;

  LoginStateProvider(Widget child, this.mcard) : super(child: child);

  @override
  bool updateShouldNotify(LoginStateProvider old) {
    return mcard.hashCode != old.hashCode;
  }

  static LoginStateProvider of(BuildContext context) =>
      context.inheritFromWidgetOfExactType(LoginStateProvider);
}

class AppDialog {
  Widget _barcode(CardNumber barcode, {bool isSmall = false}) {
    final barcodeType = barcode.type == 'EAN-13'
        ? BarCodeType.CodeEAN13
        : barcode.type == 'EAN-8'
            ? BarCodeType.CodeEAN8
            : barcode.type == 'Code-128' ? BarCodeType.Code128 : null;

    if (barcodeType == null) {
      throw ('Unknown barcode type: ${barcode.type}');
    }

    return Center(
        child: Container(
      child: BarCodeImage(
        data: barcode.value,
        codeType: barcodeType,
        lineWidth:
            barcode.type == 'Code-128' && isSmall ? 1.1 : isSmall ? 2.0 : 2.5,
        barHeight: 100.0,
        hasText: true,
        onError: (error) {
          print("Generate barcode failed. error msg: $error");
        },
      ),
    ));
  }

  barcodeOpened(BuildContext context, CustomerCard mcard) async {
    final content = SingleChildScrollView(
        child: Material(
      child: Container(
        color: AppColors.white,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              mcard.card.title,
              style: TextStyle(
                  fontSize: AppTextStyles.fontSize18,
                  color: AppColors.text,
                  fontWeight: FontWeight.w500),
            ),
            AppConstants.spaceH(160),
            _barcode(mcard.barcode, isSmall: DeviceInfo.isSmallWidth)
          ],
        ),
      ),
    ));

    final dialog = CustomAlertDialog(
        title: Text(
          _translate('scan_code'),
          style: AppTextStyles.dialogTitle,
        ),
        hasCloseIcon: true,
        content: Container(
          child: content,
        ));

    final res = await showDialog(
        barrierDismissible: false,
        context: context,
        builder: (context) => dialog);

    return res;
  }
}
