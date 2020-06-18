import 'dart:async';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:timesget/all_translations.dart';
import 'package:timesget/components/app_bar.dart';
import 'package:timesget/components/app_bottom_bars.dart';
import 'package:timesget/components/app_drawer.dart';
import 'package:timesget/components/buttons.dart';
import 'package:timesget/components/header_paragraph.dart';
import 'package:timesget/components/icons.dart';
import 'package:timesget/components/progress_modal.dart';
import 'package:timesget/components/tags/h1.dart';
import 'package:timesget/components/tags/input.dart';
import 'package:timesget/components/tags/p.dart';
import 'package:timesget/models/city_provider.dart';
import 'package:timesget/models/company.dart';
import 'package:timesget/models/firestore_endpoints.dart';
import 'package:timesget/models/praise_complain.dart';
import 'package:timesget/pages/audio_picker.dart';
import 'package:timesget/pages/photo_picker.dart';
import 'package:timesget/pages/video_recorder.dart';
import 'package:timesget/services/app_tooltip.dart';
import 'package:timesget/services/app_utils.dart';
import 'package:timesget/services/cloud_storage.service.dart';
import 'package:timesget/styles/border_radius.dart';
import 'package:timesget/styles/colors.dart';
import 'package:timesget/styles/constants.dart';
import 'package:timesget/styles/text_styles.dart';
import 'package:rxdart/rxdart.dart';

const _pageName = "praise_complaint_page";
String _translate(String key) {
  return allTranslations.concatText([_pageName, key]);
}

class PraiseComplainPage extends StatefulWidget {
  final Company company;
  PraiseComplainPage(this.company);

  @override
  _PraiseComplainPageState createState() => _PraiseComplainPageState();
}

class _PraiseComplainPageState extends State<PraiseComplainPage> {
  GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();

  final _commentEditingController = TextEditingController();
  final _phoneEditingController = TextEditingController();

  String _phoneNumber = '';
  String _comment = '';
  String _fileType = '';

  File _file;

  CloudStorageService _service;

  @override
  void initState() {
    super.initState();
    _service = CloudStorageService();
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

  _onPhoneChanged() {
    setState(() {
      _phoneNumber = _phoneEditingController.text;
      _tryActivateButton();
    });
  }

  _onCommentChanged() {
    setState(() {
      _comment = _commentEditingController.text;
      _tryActivateButton();
    });
  }

  bool _btnActive = false;

  void _tryActivateButton() {
    _btnActive = _phoneNumber != null &&
        _comment != null &&
        _phoneNumber != '' &&
        _comment != '';
  }

  final BehaviorSubject<String> progressTitle =
      BehaviorSubject<String>.seeded('');

  Future<Null> _showSendComplaintProgressDialog(BuildContext context) async {
    final dialog = CustomProgessDialog(
      content: Container(),
      progress: _service.progress,
      progressTitle: progressTitle,
    );

    showDialog(
        barrierDismissible: false,
        context: context,
        builder: (context) => dialog);

    var uploadedFilePath = '';
    if (_file != null) {
      progressTitle.add(allTranslations.text('loading.file'));
      uploadedFilePath = await _service.upload(_file, _fileType);

      if (uploadedFilePath == null) {
        Navigator.pop(context);

        AppNotification().show(context,
            buildOverlay(allTranslations.text('loading.error_try_again')),
            duration: Duration(seconds: 13));
      }
    }

    progressTitle.add(allTranslations.text('sending.message'));

    final pc = PraiseComplaint(
        _fileType, uploadedFilePath, _emotionType, _phoneNumber, _comment);

    final snapshot = await Firestore.instance
        .collection(FirestoreEndpoints.praiseComplaints)
        .add(pc.map);

    print('New praise/complaint is ${snapshot.documentID}.');

    if (_file != null && await _file.exists()) {
      await _file.delete();
    }

    setState(() {
      _phoneEditingController.clear();
      _commentEditingController.clear();
      _file = null;
      _emotionType = null;
      _fileType = null;
      _file = null;
    });

    Timer(Duration(milliseconds: 300), () {
      Navigator.pop(context);

      AppNotification().show(context, buildOverlay(_translate('thanks')),
          duration: Duration(seconds: 5));
    });
  }

  Widget _buildButton() {
    return AppColoredButton(
      _translate('button'),
      isActive: _btnActive,
      isBusy: _service.isUpload,
      onTap: () async {
        await _showSendComplaintProgressDialog(context);
      },
    );
  }

  Widget _fileTypeButton(String buttonName) {
    final title = buttonName == 'photo'
        ? allTranslations.text('photo')
        : buttonName == 'video'
            ? allTranslations.text('video')
            : buttonName == 'audio' ? allTranslations.text('audio') : '-';
    Image image = buttonName == 'photo'
        ? AppIcons.photoPraiseComplain
        : buttonName == 'video'
            ? AppIcons.videoPraiseComplain
            : buttonName == 'audio' ? AppIcons.audioPraiseComplain : null;

    if (buttonName == _fileType) {
      image = AppIcons.praiseComplainSelected(
          AppUtils.capitalizeFirstLetter(buttonName));
    }

    final onTap = () async {
      FocusScope.of(context).unfocus();
      if (buttonName == 'audio') {
        final audio = await Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => AudioRecordPage(),
                settings: RouteSettings(name: 'AudioRecordPage')));

        setState(() {
          _fileType = audio != null ? buttonName : null;
          _file = audio;
          print('File type is $buttonName');
        });
      }

      if (buttonName == 'photo') {
        final tempImage = // await ImagePicker.pickImage(source: ImageSource.camera);
            await Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) =>
                        PhotoPickerPage(ModelProvider.of(context).cameras),
                    settings: RouteSettings(name: 'PhotoPickerPage')));

        setState(() {
          _fileType = tempImage != null ? buttonName : null;
          _file = tempImage;
          print('File type is $buttonName');
        });
      }

      if (buttonName == 'video') {
        final video = await Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) =>
                    VideoRecorderPage(ModelProvider.of(context).cameras),
                settings: RouteSettings(name: 'VideoRecorderPage')));
        setState(() {
          _fileType = video != null ? buttonName : null;
          _file = video;
          print('File type is $buttonName');
        });
      }
    };

    return InkWell(
      onTap: onTap,
      child: Column(children: [
        Container(child: image, height: 60.0),
        Text(title,
            style:
                TextStyle(fontWeight: FontWeight.w700, color: AppColors.black))
      ]),
    );
  }

  Widget _buildFilteTypeButtonsBoard() {
    return Container(
      padding: EdgeInsets.only(top: 10.0, bottom: 15.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Expanded(flex: 1, child: Container()),
          _fileTypeButton("photo"),
          Expanded(flex: 3, child: Container()),
          _fileTypeButton("video"),
          Expanded(flex: 3, child: Container()),
          _fileTypeButton("audio"),
          Expanded(flex: 1, child: Container()),
        ],
      ),
    );
  }

  String _emotionType = '';

  Widget _buildEmotionButton(String emotion) {
    Widget icon;
    if (_emotionType != null && _emotionType != '') {
      if (emotion == 'good' && _emotionType == emotion) {
        icon = AppIcons.emotionGoodSelected;
      } else if (emotion == 'sat' && _emotionType == emotion) {
        icon = AppIcons.emotionSatisfiedSelected;
      } else if (emotion == 'bad' && _emotionType == emotion) {
        icon = AppIcons.emotionBadlySelected;
      }
    }

    if (icon == null) {
      icon = emotion == 'good'
          ? AppIcons.emotionGood
          : emotion == 'sat'
              ? AppIcons.emotionSatisfied
              : emotion == 'bad' ? AppIcons.emotionBadly : null;
    }

    return InkWell(
      onTap: () {
        FocusScope.of(context).unfocus();
        if (_emotionType == emotion) {
          return;
        }
        setState(() {
          _emotionType = emotion;
          print('Emotion is $_emotionType');
        });
      },
      child: Container(height: 60.0, child: icon),
    );
  }

  Widget _buildEmotionsButtonsBoard() {
    return Container(
        padding: EdgeInsets.only(top: 25.0, bottom: 25.0),
        decoration: BoxDecoration(
            color: AppColors.emotionsBoardBg,
            borderRadius:
                BorderRadius.all(Radius.circular(AppRoundCorners.radius))),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Container(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Expanded(flex: 2, child: Container()),
                  _buildEmotionButton('good'),
                  Expanded(child: Container()),
                  _buildEmotionButton('sat'),
                  Expanded(child: Container()),
                  _buildEmotionButton('bad'),
                  Expanded(flex: 2, child: Container()),
                ],
              ),
            ),
            AppConstants.spaceH(50.0),
            Text(
              _translate('your_emotions'),
              style: TextStyle(
                  fontWeight: FontWeight.w900,
                  fontSize: AppTextStyles.fontSize15),
            )
          ],
        ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: AppColors.white,
        key: scaffoldKey,
        drawer: AppDrawer.of(context),
        appBar: getAppBar(
          context,
        ),
        body: GestureDetector(
          onTap: () {
            FocusScope.of(context).unfocus();
          },
          child: Column(children: [
            Flexible(
              child: CustomScrollView(
                physics: BouncingScrollPhysics(),
                slivers: <Widget>[
                  H1(_translate('h1')),
                  p2(GestureDetector(
                      onTap: () {
                        FocusScope.of(context).unfocus();
                      },
                      child: Text(
                        _translate('content_type'),
                        style: AppTextStyles.text,
                      ))),
                  SliverPadding(
                      padding: EdgeInsets.only(top: 10.0),
                      sliver: SliverList(
                          delegate: SliverChildListDelegate([
                        HeaderParagraph(_buildFilteTypeButtonsBoard()),
                        AppConstants.spaceH(55),
                        HeaderParagraph(_buildEmotionsButtonsBoard()),
                        AppConstants.spaceH(105),
                        HeaderParagraph(
                          Input(_phoneEditingController,
                              hintText:
                                  allTranslations.text('your.phone_number') +
                                      ' *',
                              keyboardType: TextInputType.numberWithOptions()),
                        ),
                        AppConstants.spaceBetweenInputs,
                        HeaderParagraph(
                          Container(
                              // padding: new EdgeInsets.only(
                              //   bottom: mediaQuery
                              //       .viewInsets.bottom, // stay clear of the keyboard
                              // ),
                              child: Input(
                            _commentEditingController,
                            hintText: _translate('comment_description'),
                            maxLines: 12,
                          )),
                        ),
                        AppConstants.spaceH(80),
                        HeaderParagraph(_buildButton()),
                        AppConstants.spaceH(80)
                      ])))
                ],
              ),
            ),
            AppBottomTabBars()
          ]),
        ));
  }
}
