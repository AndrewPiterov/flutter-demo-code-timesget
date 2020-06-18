import 'package:flutter/material.dart';
import 'package:timesget/all_translations.dart';
import 'package:timesget/components/app_bar.dart';
import 'package:timesget/components/app_bottom_bars.dart';
import 'package:timesget/components/app_drawer.dart';
import 'package:timesget/components/icons.dart';
import 'package:timesget/components/tags/h1.dart';
import 'package:flutter/cupertino.dart';
import 'package:timesget/components/tags/text.dart';
import 'package:timesget/components/worker_card.dart';
import 'package:timesget/models/booking.model.dart';
import 'package:timesget/services/auth.service.dart';
import 'package:timesget/services/device_info.dart';
import 'package:timesget/services/user.services.dart';
import 'package:timesget/styles/colors.dart';
import 'package:timesget/styles/constants.dart';
import 'package:timesget/styles/paddings.dart';

const _pageName = "account_bookings";
String _translate(String key) {
  return allTranslations.concatText([_pageName, key]);
}

class AccountBookingsPage extends StatelessWidget {
  final ScrollController _scrollController = ScrollController();

  AccountBookingsPage() {
    print('Account bookings page');

    final user = AuthService().profile.value;
    if (user != null) {
      UserService().getPassedBookings(user);

      _scrollController.addListener(() {
        final maxScroll = _scrollController.position.maxScrollExtent;
        final current = _scrollController.position.pixels;
        final delta = DeviceInfo().height * .25;

        if (maxScroll - current <= delta) {
          UserService().getMorePassedBookings(user);
        }
      });
    }
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
                  controller: _scrollController,
                  slivers: <Widget>[
                HeaderBoard(
                  _translate('title'),
                  children: [text(_translate('subtitle'))],
                ),
                _PageContent(),
              ])),
          AppBottomTabBars(
            page: AppPages.myBookings,
          )
        ]));
  }
}

class _PageContent extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<UserBooking>>(
      stream: UserService().bookings$,
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return AppConstants.circleSpinnerSlivered;
        }

        final bookings = snapshot.data;

        if (bookings.isEmpty) {
          return SliverPadding(
            padding: AppPaddings.pageContent,
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                Center(
                  child: AppImages.notFound,
                )
              ]),
            ),
          );
        }

        return SliverPadding(
          padding: AppPaddings.pageContent,
          sliver: SliverList(
            delegate: SliverChildBuilderDelegate((context, i) {
              final booking = bookings[i];
              final worker = booking.worker;
              return Column(
                children: <Widget>[
                  WorkerCard(
                    worker,
                    type: WorkerCardTypes.userBooking,
                    userBooking: booking,
                  ),
                  AppConstants.betweenRowCards
                ],
              );
            }, childCount: bookings.length),
          ),
        );
      },
    );
  }
}
