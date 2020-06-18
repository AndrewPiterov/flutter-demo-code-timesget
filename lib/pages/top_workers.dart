import 'package:flutter/material.dart';
import 'package:timesget/all_translations.dart';
import 'package:timesget/components/app_bar.dart';
import 'package:timesget/components/app_bottom_bars.dart';
import 'package:timesget/components/app_drawer.dart';
import 'package:timesget/components/icons.dart';
import 'package:timesget/components/worker_card.dart';
import 'package:timesget/components/worker_specs_view.dart';
import 'package:timesget/components/tags/h1.dart';
import 'package:timesget/components/tags/text.dart';
import 'package:timesget/models/worker.dart';
import 'package:flutter/cupertino.dart';
import 'package:timesget/models/worker_specialization.dart';
import 'package:timesget/services/workers.service.dart';
import 'package:timesget/styles/colors.dart';
import 'package:timesget/styles/constants.dart';
import 'package:timesget/styles/paddings.dart';

const _pageName = "top_page";
String _translate(String key) {
  return allTranslations.concatText([_pageName, key]);
}

class CompareWorkersPage extends StatefulWidget {
  @override
  CompareWorkersPageState createState() {
    return new CompareWorkersPageState();
  }
}

class CompareWorkersPageState extends State<CompareWorkersPage> {
  WorkerSpecialization _specType;

  @override
  Widget build(BuildContext context) {
    final dd = WorkerSpecsDropDownButton(
      _specType,
      (spec) {
        setState(() {
          _specType = spec;
        });
      },
      hintText: allTranslations.text('choose.specialty'),
    );

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
                    text(_translate('description')),
                    AppConstants.spaceH(10),
                    dd
                  ],
                ),
                _PageContent(
                  _specType,
                ),
              ])),
          AppBottomTabBars()
        ]));
  }
}

class _PageContent extends StatelessWidget {
  final WorkerSpecialization specType;
  _PageContent(this.specType);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<Worker>>(
        stream: WorkerService().workers$,
        builder: (context, snapshot) {
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

          final filtered = WorkerService().filterdBySpec(specType);

          if (filtered.isEmpty) {
            return SliverPadding(
                padding: EdgeInsets.fromLTRB(
                    AppPaddings.left, 20.0, AppPaddings.left, 20.0),
                sliver: SliverList(
                    delegate: SliverChildListDelegate(
                        [Center(child: AppImages.notFound)])));
          }

          return SliverPadding(
              padding: EdgeInsets.all(AppPaddings.left),
              sliver: SliverList(
                  delegate: SliverChildBuilderDelegate((builder, i) {
                return Column(
                  children: <Widget>[
                    WorkerCard(filtered.elementAt(i)),
                    AppConstants.betweenRowCards
                  ],
                );
              }, childCount: filtered.length)));
        });
  }
}
