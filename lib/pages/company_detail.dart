import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_pro/carousel_pro.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:timesget/all_translations.dart';
import 'package:timesget/components/alert.dart';
import 'package:timesget/components/app_bar.dart';
import 'package:timesget/components/app_bottom_bars.dart';
import 'package:timesget/components/app_drawer.dart';
import 'package:timesget/components/app_image.dart';
import 'package:timesget/components/buttons.dart';
import 'package:timesget/components/icons.dart';
import 'package:timesget/components/tags/h1.dart';
import 'package:timesget/components/tags/p.dart';
import 'package:timesget/config/app_config.dart';
import 'package:timesget/models/app_image.dart';
import 'package:timesget/models/city_provider.dart';
import 'package:timesget/models/company.dart';
import 'package:timesget/models/work_week.dart';
import 'package:timesget/pages/about_work.dart';
import 'package:timesget/pages/contacts.dart';
import 'package:timesget/pages/map.dart';
import 'package:timesget/pages/worker_list.dart';
import 'package:timesget/pages/praise_complaint.dart';
import 'package:timesget/services/workWeek.utils.dart';
import 'package:timesget/styles/border_radius.dart';
import 'package:timesget/styles/colors.dart';
import 'package:timesget/styles/constants.dart';
import 'package:timesget/styles/text_styles.dart';

const _pageName = "company_detail_page";
String _translate(String key) {
  return allTranslations.concatText([_pageName, key]);
}

class CompanyDetailPage extends StatelessWidget {
  CompanyDetailPage();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: getAppBar(context),
      drawer: AppDrawer.of(context),
      backgroundColor: AppColors.white,
      body: StreamBuilder<Company>(
          stream: ModelProvider.of(context).company$,
          builder: (context, AsyncSnapshot<Company> snapshot) {
            if (!snapshot.hasData) {
              return Center(child: AppConstants.spinner);
            }
            final company = snapshot.data;
            // print('Company ${company.name}');
            return _CompanyInfo(company);
          }),
    );
  }
}

class _CompanyInfo extends StatefulWidget {
  final Company company;
  _CompanyInfo(this.company);

  List<Text> workWeekDays(BuildContext context, WorkWeek week) {
    final days = week.days.map((day) {
      final title = allTranslations.text('week.${day.dayTitle.toLowerCase()}');

      return Text(
        day.timeRange == null
            ? "- ($title)"
            : "${day.timeRange.label} ($title)",
        style: AppTextStyles.keyValueValue,
      );
    }).toList();
    return days;
  }

  Future<Null> showCompanyContacts(BuildContext context) async {
    var phones = List<Text>();
    for (var a in company.addresses) {
      for (var p in a.phoneNumber.split(';').map((p) => p.trim())) {
        phones.add(Text(
          p,
          style: AppTextStyles.keyValueValue,
        ));
      }
    }

    final addresses = company.addresses
        .map((x) => Text(
              x.address,
              style: AppTextStyles.keyValueValue,
            ))
        .toList();

    final spaceBetweenInfos = 13.0 * AppConstants.ration;

    final content = new SingleChildScrollView(
      child: new ListBody(
        children: <Widget>[
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                allTranslations.text('address'),
                style: AppTextStyles.keyValueKey,
              ),
            ]..addAll(addresses),
          ),
          // _buildSocialLinks(company),
          AppConstants.spaceH(spaceBetweenInfos),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                allTranslations.text('phone'),
                style: AppTextStyles.keyValueKey,
              ),
            ]..addAll(phones),
          ),
          AppConstants.spaceH(spaceBetweenInfos),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: WorkWeekUtils.getRows(context, company.workWeek),
          ),
        ],
      ),
    );

    final dialog = CustomAlertDialog(
      title: Text(
        allTranslations.text('contacts').toUpperCase(),
        style: TextStyle(
            color: AppColors.white,
            fontWeight: FontWeight.w900,
            fontSize: AppTextStyles.fontSize14),
      ),
      content: content,
      hasCloseIcon: true,
    );

    await showDialog(
        barrierDismissible: true,
        context: context,
        builder: (context) => dialog);
  }

  @override
  _State createState() => _State();
}

class _State extends State<_CompanyInfo> {
  @override
  Widget build(BuildContext context) {
    return Column(children: [
      Expanded(
          child: CustomScrollView(
        physics: BouncingScrollPhysics(),
        slivers: <Widget>[
          H1(widget.company.name),
          p2(Text(
            widget.company.shortDescription ?? '',
            style: AppTextStyles.text,
          )),
          p2(AppConstants.spaceH(10)),
          p2(_photoSlider(widget.company.preview)),
          p2(AppConstants.spaceH(10)),
          p2(_buttons())
        ],
      )),
      AppBottomTabBars()
    ]);
  }

  Widget _buttons() {
    return Container(
      color: Colors.white,
      child: Column(
        children: <Widget>[
          ThinBorderedButton2(
            Text(_translate('our_workers'),
                style: AppTextStyles.thinButton
                    .copyWith(color: AppColors.ourWorkersButtonText)),
            icon: AppIcons.iconButton(5),
            color: AppColors.ourWorkersButtonBg,
            onTap: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => WorkerListPage(),
                      settings: RouteSettings(name: 'WorkerListPage')));
            },
          ),
          AppConstants.spaceBetweenThinButtons,
          ThinBorderedButton2(
            Text(_translate('contacts'), style: AppTextStyles.thinButton),
            icon: AppIcons.iconButton(6),
            onTap: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => ContactsPage(),
                      settings: RouteSettings(name: 'ContactsPage')));
            },
          ),
          AppConstants.spaceBetweenThinButtons,
          ThinBorderedButton2(
            Text(_translate('about_our_work'), style: AppTextStyles.thinButton),
            icon: AppIcons.iconButton(7),
            onTap: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => AboutWorkPage(),
                      settings: RouteSettings(name: 'AboutWorkPage')));
            },
          ),
          AppConstants.spaceBetweenThinButtons,
          ThinBorderedButton2(
            Text(_translate('praise_or_complain'),
                style: AppTextStyles.thinButton),
            icon: AppIcons.iconButton(4),
            onTap: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => PraiseComplainPage(widget.company),
                      settings: RouteSettings(name: 'PraiseComplainPage')));
            },
          ),
          AppConfig.isProduction
              ? AppConstants.spaceH(1)
              : Column(
                  children: <Widget>[
                    AppConstants.spaceBetweenThinButtons,
                    ThinBorderedButton2(
                      Text(allTranslations.concatText(['map', 'title']),
                          style: AppTextStyles.thinButton),
                      icon: AppIcons.iconButton(4),
                      onTap: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => MapPage(),
                                settings: RouteSettings(name: 'MapPage')));
                      },
                    )
                  ],
                )
        ],
      ),
    );
  }

  Widget _photoSlider(AppImage preview) {
    return SizedBox(
      height: AppConstants.sizeOf(850),
      child: StreamBuilder(
          stream: Firestore.instance.collection('photos').snapshots(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return Center(child: AppConstants.spinner);
            }

            final images = snapshot.data.documents
                .map((doc) => AppImage.fromSnapshot(doc))
                .where((image) => image.url != preview.url)
                .toList();

            if (images.length == 0) {
              return Image(
                image: AppImages.noCompany,
                fit: BoxFit.fitHeight,
              );
            }

            final arr = images
                .map((image) => CachedNetworkImageProvider(image.url))
                .toList();

            if (arr.length == 0) {
              arr.add(
                  AppImageWidget(Image.asset(AppImages.companyMain.assetName)));
            }

            return Carousel(
              indicatorBgPadding: 5.0,
              dotColor: AppColors.imageSliderDots,
              showIndicator: arr.length > 1,
              dotBgColor: Colors.white.withOpacity(0.0),
              images: arr,
              dotIncreaseSize: 1.5,
              borderRadius: true,
              radius: AppRoundCorners.rounded,
            );
          }),
    );
  }
}
