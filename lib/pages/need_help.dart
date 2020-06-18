import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:timesget/all_translations.dart';
import 'package:timesget/components/app_bar.dart';
import 'package:timesget/components/app_bottom_bars.dart';
import 'package:timesget/components/app_drawer.dart';
import 'package:timesget/components/buttons.dart';
import 'package:timesget/components/tags/h1.dart';
import 'package:timesget/components/worker_specs_view.dart';
import 'package:timesget/components/header_paragraph.dart';
import 'package:timesget/components/tags/input.dart';
import 'package:timesget/models/city_provider.dart';
import 'package:timesget/models/worker_specialization.dart';
import 'package:timesget/services/app_tooltip.dart';
import 'package:timesget/styles/colors.dart';
import 'package:timesget/styles/constants.dart';
import 'package:timesget/styles/text_styles.dart';

const _pageName = "need_help_page";
String _translate(String key) {
  return allTranslations.concatText([_pageName, key]);
}

final String _title = _translate('title');
final String _text = _translate('description');
final String _text2 = _translate('description2');

class NeedHelpPage extends StatefulWidget {
  @override
  NeedHelpPageState createState() {
    return new NeedHelpPageState();
  }
}

class NeedHelpPageState extends State<NeedHelpPage> {
  final _commentEditingController = TextEditingController();
  final _phoneEditingController = TextEditingController();
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  String _phone = '';
  String _comment = '';
  WorkerSpecialization _specType;

  bool isAlreadyDirty = false;

  void _onPhoneChanged() {
    setState(() {
      _phone = _phoneEditingController.text;
    });
  }

  void _onCommentChanged() {
    setState(() {
      final val = _commentEditingController.text;

      if (val == _text2) {
        _commentEditingController.clear();
        _comment = null;
        isAlreadyDirty = false;
      } else {
        _comment = val;
        isAlreadyDirty = true;
      }
    });
  }

  Widget _topText(BuildContext context) {
    return HeaderParagraph(GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Text(
        _text,
        style: AppTextStyles.text,
      ),
    ));
  }

  @override
  void initState() {
    super.initState();

    _phoneEditingController.addListener(_onPhoneChanged);
    _commentEditingController.addListener(_onCommentChanged);
  }

  @override
  void dispose() {
    _commentEditingController.removeListener(_onCommentChanged);
    _commentEditingController.dispose();
    _phoneEditingController.removeListener(_onPhoneChanged);
    _phoneEditingController.dispose();
    super.dispose();
  }

  bool get _isButtonActive =>
      _phone != null &&
      _phone != '' &&
      _comment != null &&
      _comment != '' &&
      _specType != null;

  bool alreadyInitialized = false;

  @override
  Widget build(BuildContext context) {
    final dropDown = WorkerSpecsDropDownButton(
      _specType,
      (spec) {
        setState(() {
          _specType = spec;
        });
      },
      allChoose: false,
    );

    alreadyInitialized = true;

    return Scaffold(
      key: _scaffoldKey,
      appBar: getAppBar(context, scaffold: _scaffoldKey, withCurrentCity: true),
      drawer: AppDrawer.of(context),
      backgroundColor: AppColors.white,
      body: Column(children: [
        Expanded(
          child: CustomScrollView(
            physics: BouncingScrollPhysics(),
            slivers: <Widget>[
              H1(_title),
              SliverPadding(
                padding: EdgeInsets.all(0.0),
                sliver: SliverList(
                    delegate: SliverChildListDelegate([
                  _topText(context),
                  AppConstants.spaceBetweenInputs,
                ])),
              ),
              SliverPadding(
                padding: EdgeInsets.all(0.0),
                sliver: SliverList(
                    delegate: SliverChildListDelegate([
                  HeaderParagraph(dropDown),
                  AppConstants.spaceBetweenInputs,
                  HeaderParagraph(Container(
                      child: Input(_phoneEditingController,
                          hintText: allTranslations.text('your.phone') + ' *',
                          keyboardType: TextInputType.numberWithOptions()))),
                  AppConstants.spaceBetweenInputs,
                  HeaderParagraph(
                    Container(
                        child: Input(_commentEditingController,
                            maxLines: 11,
                            hintText: _translate('description2'))),
                  ),
                  AppConstants.spaceH(50),
                  HeaderParagraph(AppColoredButton(
                    allTranslations.text('call_me'),
                    isActive: _isButtonActive,
                    isBusy: ModelProvider.of(context).isBusyAuction,
                    onTap: () async {
                      await ModelProvider.of(context)
                          .auction(_specType, _phone, _comment);

                      setState(() {
                        // clear up
                        _specType = null;
                        _commentEditingController.clear();
                        _phoneEditingController.clear();
                      });

                      final msg = _translate('thanks');
                      AppNotification().show(context, buildOverlay(msg));
                    },
                  )),
                  AppConstants.spaceH(60),
                ])),
              )
            ],
          ),
        ),
        AppBottomTabBars()
      ]),
    );
  }
}
