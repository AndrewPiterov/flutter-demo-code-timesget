import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:page_transition/page_transition.dart';
import 'package:timesget/all_translations.dart';
import 'package:timesget/components/app_bar.dart';
import 'package:timesget/components/app_bottom_bars.dart';
import 'package:timesget/components/app_drawer.dart';
import 'package:timesget/components/buttons.dart';
import 'package:timesget/components/icons.dart';
import 'package:timesget/components/tags/h1.dart';
import 'package:timesget/components/worker_card.dart';
import 'package:timesget/components/worker_comment_card.dart';
import 'package:timesget/models/hot_offer.model.dart';
import 'package:timesget/models/worker.dart';
import 'package:timesget/models/worker_comment.dart';
import 'package:timesget/pages/login.dart';
import 'package:timesget/services/app_tooltip.dart';
import 'package:timesget/services/auth.service.dart';
import 'package:timesget/services/best_time.helper.dart';
import 'package:timesget/services/bookings/current_bookung.service.dart';
import 'package:timesget/services/device_info.dart';
import 'package:timesget/services/worker_dialogs.dart';
import 'package:timesget/services/workers.service.dart';
import 'package:timesget/styles/colors.dart';
import 'package:timesget/styles/constants.dart';
import 'package:timesget/styles/paddings.dart';
import 'package:timesget/styles/text_styles.dart';

const _pageName = 'worker_detail_page';
String _translate(String key) {
  return allTranslations.concatText([_pageName, key]);
}

class WorkerDetailPage extends StatefulWidget {
  final Worker _worker;
  final HotOffer hotOffer;
  final BestTimeRangeAvailability bestTime;
  WorkerDetailPage(this._worker, {this.hotOffer, this.bestTime});

  @override
  WorkerDetailPageState createState() => WorkerDetailPageState(_worker.id,
      hotOffer: hotOffer, fromBestTime: bestTime);
}

class WorkerDetailPageState extends State<WorkerDetailPage> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  final String workerId;
  HotOffer hotOffer;
  final BestTimeRangeAvailability fromBestTime;

  WorkerDetailPageState(this.workerId, {this.hotOffer, this.fromBestTime});

  Widget _workerPanel(String workerId) {
    return StreamBuilder<List<Worker>>(
      stream: WorkerService().workers$,
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Container(height: 500.0, child: AppConstants.circleSpinner);
        }

        final worker = snapshot.data.firstWhere((x) => x.id == workerId);

        return Container(
          color: AppColors.white,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              WorkerCard(worker, type: WorkerCardTypes.detail),
              AppConstants.spaceH(80),
              ThinBorderedButton2(
                  Text(
                      hotOffer == null
                          ? _translate('booking_button.title')
                          : _translate('booking_button.hot_title'),
                      style: hotOffer == null
                          ? AppTextStyles.thinButtonSelecred
                          : AppTextStyles.thinButtonSelecred.copyWith(
                              fontSize: DeviceInfo.isSmallWidth ? 15.0 : 16.0)),
                  icon: AppIcons.iconButton(1),
                  color: AppColors.buttonWorkerBooking, onTap: () async {
                final user = AuthService().profile.value;
                if (user == null) {
                  Navigator.push(
                      context,
                      PageTransition(
                          type: PageTransitionType.downToUp,
                          child: LoginPage(onSuccess: (String type) {
                            Navigator.push(
                                context,
                                PageTransition(
                                    type: PageTransitionType.upToDown,
                                    child: WorkerDetailPage(
                                      widget._worker,
                                      hotOffer: widget.hotOffer,
                                    )));
                          })));
                  return null;
                }

                CurrentBookingService().workerIs(worker);
                return WorkerDialogs.showBookingDialog(context, user, worker,
                        hotOffer: hotOffer, bestTime: fromBestTime)
                    .then((res) {
                  CurrentBookingService().reset();
                  if (res != null && res.bookingId != null) {
                    print('New booking ${res.bookingId}');
                    AppNotification().show(
                        context,
                        buildOverlay(
                            _translate('booking_button.on_success_booking')));

                    setState(() {
                      if (hotOffer != null) {
                        this.hotOffer = null;
                      }
                    });
                  } else {
                    print('There is no booking.');
                    AppNotification().show(
                        context,
                        buildOverlay(
                            _translate('booking_button.on_fail_booking.body'),
                            title: _translate(
                                'booking_button.on_fail_booking.title')),
                        duration: Duration(seconds: 14));
                  }
                });
              }),
              AppConstants.spaceBetweenThinButtons,
              ThinBorderedButton2(
                Text(_translate("about"), style: AppTextStyles.thinButton),
                icon: AppIcons.iconButton(2),
                onTap: () => WorkerDialogs.openAboutMe(context, worker),
              ),
              AppConstants.spaceBetweenThinButtons,
              ThinBorderedButton2(
                Text(_translate("schedule"), style: AppTextStyles.thinButton),
                icon: AppIcons.iconButton(3),
                onTap: () => WorkerDialogs.openWorkTime(context, worker),
              ),
              AppConstants.spaceBetweenThinButtons,
              ThinBorderedButton2(
                Text(_translate("leave_review"),
                    style: AppTextStyles.thinButton),
                icon: AppIcons.iconButton(4),
                onTap: () => WorkerDialogs.openReviewDialog(context, worker)
                    .then((onValue) {
                  print('Was comment? $onValue');
                  if (onValue) {
                    AppNotification().show(
                        context, buildOverlay(_translate('thanks_for_review')));
                  }
                }),
              ),
              Container(
                color: AppColors.white,
                padding: EdgeInsets.fromLTRB(
                    AppPaddings.left, 30.0, AppPaddings.left, 0.0),
                child: Text(
                  allTranslations.text('reviews') + ':',
                  style: AppTextStyles.workerName,
                  textAlign: TextAlign.left,
                ),
              )
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    print("Worker is $workerId");
    // WorkerService().filterById(workerId);
    return Scaffold(
      key: _scaffoldKey,
      appBar: getAppBar(context),
      backgroundColor: AppColors.pageBackground,
      drawer: AppDrawer.of(context),
      body: Column(
        children: [
          Expanded(
            child: CustomScrollView(
              physics: BouncingScrollPhysics(),
              shrinkWrap: true,
              slivers: <Widget>[
                SliverPadding(
                    padding: EdgeInsets.all(0.0),
                    sliver: HeaderBoard(
                      null,
                      children: <Widget>[
                        AppConstants.underAppBarH,
                        Container(
                          color: AppColors.white,
                          child: _workerPanel(workerId),
                        ),
                      ],
                    )),
                _CommentList(workerId)
              ],
            ),
          ),
          AppBottomTabBars()
        ],
      ),
    );
  }
}

class _CommentList extends StatelessWidget {
  final String workerId;
  _CommentList(this.workerId);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: Firestore.instance
          .collection('workers')
          .document(workerId)
          .collection('reviews')
          .orderBy('reviewDate', descending: true)
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

        final filtered = (snapshot.data.documents as Iterable)
            .map((x) => WorkerComment.fromSnapshot(x))
            .toList();

        if (filtered.isEmpty) {
          return SliverPadding(
              padding: EdgeInsets.fromLTRB(
                  AppPaddings.left, 20.0, AppPaddings.left, 20.0),
              sliver: SliverList(
                  delegate: SliverChildListDelegate([
                Center(
                    child: Text(
                  allTranslations.text('no_comments'),
                  textAlign: TextAlign.center,
                  style: AppTextStyles.textNoItems,
                ))
              ])));
        }

        return SliverPadding(
            padding: EdgeInsets.all(20.0),
            sliver: SliverList(
                delegate: SliverChildBuilderDelegate((builder, i) {
              return Column(
                children: <Widget>[
                  WorkerCommentCard(filtered[i]),
                  AppConstants.betweenRowCards
                ],
              );
            }, childCount: filtered.length)));
      },
    );
  }
}
