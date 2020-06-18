import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:timesget/all_translations.dart';
import 'package:timesget/components/app_bar.dart';
import 'package:timesget/components/app_bottom_bars.dart';
import 'package:timesget/components/app_drawer.dart';
import 'package:timesget/components/icons.dart';
import 'package:timesget/components/worker_card.dart';
import 'package:timesget/components/worker_specs_view.dart';
import 'package:timesget/components/header_paragraph.dart';
import 'package:timesget/components/sliver_appbar_delegate.dart';
import 'package:timesget/models/city_provider.dart';
import 'package:timesget/models/worker.dart';
import 'package:timesget/models/worker_specialization.dart';
import 'package:timesget/styles/colors.dart';
import 'package:timesget/styles/constants.dart';
import 'package:timesget/styles/paddings.dart';
import 'package:timesget/styles/text_styles.dart';
import 'package:latlong/latlong.dart';

const _pageName = "nearest_workers_page";
String _translate(String key) {
  return allTranslations.concatText([_pageName, key]);
}

final String _text = _translate('description');
final String _noPermissionText = _translate('ask_permission');

class NearestWorkersPage extends StatefulWidget {
  @override
  _NearestWorkersPageState createState() => _NearestWorkersPageState();
}

class _NearestWorkersPageState extends State<NearestWorkersPage> {
  final Widget topText = Text(
    _text,
    style: AppTextStyles.topBarText,
  );

  // Location _location;
  // bool _hasPermission;

  // @override
  // void initState() {
  //   super.initState();
  //   _location = new Location();

  //   _location.hasPermission().then((hasPermission) {
  //     if (!hasPermission) {
  //       print('There is no location permission');
  //       setState(() {
  //         _hasPermission = hasPermission;
  //       });
  //     }
  //   });
  // }

  WorkerSpecialization _specType;

  @override
  Widget build(BuildContext context) {
    final dd = WorkerSpecsDropDownButton(_specType, (spec) {
      setState(() {
        _specType = spec;
      });
    });

    return Scaffold(
        appBar: getAppBar(
          context,
        ),
        drawer: AppDrawer.of(context),
        backgroundColor: AppColors.pageBackground,
        body: Column(children: [
          Expanded(
              child: CustomScrollView(
            physics: ClampingScrollPhysics(),
            slivers: <Widget>[
              SliverPadding(
                padding: EdgeInsets.all(0.0),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    Container(
                        padding: EdgeInsets.fromLTRB(
                            AppPaddings.left, 0.0, AppPaddings.right, 0.0),
                        color: AppColors.white,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            AppConstants.underAppBarH,
                            topText,
                            AppConstants.spaceH(52),
                            HeaderParagraph(
                              dd,
                              padding: EdgeInsets.all(0.0),
                            )
                          ],
                        ))
                  ]),
                ),
              ),
              SliverPersistentHeader(
                // pinned: true,
                delegate: SliverAppBarHandleBottomDelegate(),
              ),
              _PageContent(_specType)
            ],
          )),
          AppBottomTabBars()
        ]));
  }
}

class _PageContent extends StatelessWidget {
  final WorkerSpecialization spec;
  _PageContent(this.spec);

  List<dynamic> sortByNearest(BuildContext context, List<Worker> workers) {
    final myLoc = ModelProvider.of(context).lastLocation;

    if (myLoc == null) {
      return List<Worker>();
    }

    final Distance distance = new Distance();

    final myLocation = LatLng(myLoc.latitude, myLoc.longitude);

    List<dynamic> list = List<dynamic>();

    for (var doc in workers.where((x) => x.address.isNotEmpty)) {
      final dist =
          distance.as(LengthUnit.Kilometer, myLocation, doc.address.first.loc);
      list.add({'dist': dist, 'doc': doc});
    }

    list.sort((a, b) => a['dist'].compareTo(b['dist']));
    return list.map((x) => x['doc']).toList();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
        stream: ModelProvider.of(context).hasLocationPermission,
        builder: (context, snapshot) {
          if (!snapshot.hasData || !snapshot.data) {
            return SliverPadding(
              padding: EdgeInsets.all(0.0),
              sliver: SliverList(
                  delegate: SliverChildBuilderDelegate((builder, i) {
                return Container(
                  padding: EdgeInsets.fromLTRB(AppPaddings.left,
                      AppPaddings.left, AppPaddings.left, AppPaddings.left),
                  child: Text(
                    _noPermissionText,
                    textAlign: TextAlign.center,
                  ),
                  height: 100.0,
                );
              }, childCount: 1)),
            );
          }

          return StreamBuilder(
              stream: Firestore.instance
                  .collection('workers')
                  .orderBy('rating', descending: true)
                  .snapshots(),
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

                final workers = (snapshot.data.documents as Iterable)
                    .map((x) => Worker.fromSnapshot(x))
                    .toList();

                final nearest = sortByNearest(context, workers);

                final filtered = nearest
                    .where((x) =>
                        spec == null ||
                        x.specializations.any((y) => y.id == spec.id))
                    .toList();

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
                          WorkerCard(filtered[i]),
                          AppConstants.betweenRowCards
                        ],
                      );
                    }, childCount: filtered.length)));
              });
        });
  }
}
