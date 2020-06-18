import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:timesget/all_translations.dart';
import 'package:timesget/components/app_bar.dart';
import 'package:timesget/components/app_bottom_bars.dart';
import 'package:timesget/components/app_drawer.dart';
import 'package:timesget/components/icons.dart';
import 'package:timesget/components/tags/h1.dart';
import 'package:timesget/components/tags/text.dart';
import 'package:timesget/components/worker_card.dart';
import 'package:timesget/models/city_provider.dart';
import 'package:timesget/models/hot_offer.model.dart';
import 'package:timesget/models/worker_specialization.dart';
import 'package:timesget/styles/colors.dart';
import 'package:timesget/styles/constants.dart';
import 'package:timesget/styles/paddings.dart';

const _pageName = "hot_offer_page";
String _translate(String key) {
  return allTranslations.concatText([_pageName, key]);
}

class HotOffersPage extends StatefulWidget {
  @override
  HotOffersPageState createState() {
    return new HotOffersPageState();
  }
}

class HotOffersPageState extends State<HotOffersPage> {
  WorkerSpecialization _specialist;

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
                children: <Widget>[text(_translate('description'))],
              ),
              _PageContent(_specialist)
            ],
          )),
          AppBottomTabBars(
            page: AppPages.hotOffers,
          )
        ]));
  }
}

class _PageContent extends StatelessWidget {
  final WorkerSpecialization specialist;

  _PageContent(this.specialist);

  @override
  Widget build(BuildContext context) {
    final stream = ModelProvider.of(context).hotOffers;

    return StreamBuilder(
      stream: stream,
      builder: (context, AsyncSnapshot<List<HotOffer>> snapshot) {
        if (!snapshot.hasData) {
          return SliverPadding(
            padding: EdgeInsets.all(0.0),
            sliver: SliverList(
                delegate: SliverChildBuilderDelegate((builder, i) {
              return Container(
                child: AppConstants.circleSpinner,
                height: 100.0,
              );
            }, childCount: 1)),
          );
        }

        final filtered = snapshot.data;
        if (filtered.isEmpty) {
          return SliverPadding(
              padding: AppPaddings.pageContent,
              sliver: SliverList(
                  delegate: SliverChildListDelegate(
                      [Center(child: AppImages.notFound)])));
        }

        return SliverPadding(
            padding: EdgeInsets.all(AppPaddings.left),
            sliver: SliverList(
                delegate: SliverChildBuilderDelegate((builder, i) {
              final hotOffer = filtered[i];
              return Column(
                children: <Widget>[
                  WorkerCard(hotOffer.worker, hotOffer: hotOffer),
                  AppConstants.betweenRowCards
                ],
              );
            }, childCount: filtered.length)));
      },
    );
  }
}
