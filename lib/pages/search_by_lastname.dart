import 'package:flutter/material.dart';
import 'package:timesget/all_translations.dart';
import 'package:timesget/components/app_bar.dart';
import 'package:timesget/components/app_bottom_bars.dart';
import 'package:timesget/components/app_drawer.dart';
import 'package:timesget/components/worker_card.dart';
import 'package:timesget/components/icons.dart';
import 'package:timesget/components/tags/h1.dart';
import 'package:timesget/components/tags/input.dart';
import 'package:timesget/components/tags/text.dart';
import 'package:timesget/models/worker.dart';
import 'package:flutter/cupertino.dart';
import 'package:timesget/models/fullname.model.dart';
import 'package:timesget/services/workers.service.dart';
import 'package:timesget/styles/colors.dart';
import 'package:timesget/styles/constants.dart';
import 'package:timesget/styles/paddings.dart';

const _pageName = "search_by_name_page";
String _translate(String key) {
  return allTranslations.concatText([_pageName, key]);
}

class SearchByLastName extends StatefulWidget {
  @override
  SearchByLastNameState createState() {
    return new SearchByLastNameState();
  }
}

class SearchByLastNameState extends State<SearchByLastName> {
  String searchStr;

  final _lastnameEditingController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _lastnameEditingController.addListener(_onLastNameChanged);
  }

  @override
  void dispose() {
    _lastnameEditingController.removeListener(_onLastNameChanged);
    _lastnameEditingController.dispose();
    super.dispose();
  }

  void _onLastNameChanged() {
    setState(() {
      searchStr = _lastnameEditingController.text;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: getAppBar(
          context,
        ),
        drawer: AppDrawer.of(context),
        backgroundColor: AppColors.pageBackground,
        body: GestureDetector(
          onTap: () {
            FocusScope.of(context).unfocus();
          },
          child: Column(children: [
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
                    Input(_lastnameEditingController,
                        hintText: _translate('search_placeholder'),
                        rightIcon: AppIcons.search)
                  ],
                ),
                _PageContent(
                  FullName(fio: searchStr),
                )
              ],
            )),
            AppBottomTabBars()
          ]),
        ));
  }
}

class _PageContent extends StatelessWidget {
  final FullName fio;
  final double topPad;
  _PageContent(this.fio, {this.topPad = 10.0});

  @override
  Widget build(BuildContext context) {
    WorkerService().filterByName(fio);

    return StreamBuilder(
      stream: WorkerService().filteredByLastName$,
      builder: (context, AsyncSnapshot<List<Worker>> snapshot) {
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

        final workers = snapshot.data;
        if (workers.isEmpty) {
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
                  WorkerCard(workers[i]),
                  AppConstants.betweenRowCards
                ],
              );
            }, childCount: workers.length)));
      },
    );
  }
}
