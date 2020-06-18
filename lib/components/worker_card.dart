import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:timesget/all_translations.dart';
import 'package:timesget/components/booking_board.dart';
import 'package:timesget/components/icons.dart';
import 'package:timesget/components/row_card.dart';
import 'package:timesget/components/star_rate.dart';
import 'package:timesget/models/booking.model.dart';
import 'package:timesget/models/city.dart';
import 'package:timesget/models/city_provider.dart';
import 'package:timesget/models/worker.dart';
import 'package:timesget/models/hot_offer.model.dart';
import 'package:timesget/pages/worker_detail.dart';
import 'package:timesget/services/app_utils.dart';
import 'package:timesget/services/best_time.helper.dart';
import 'package:timesget/services/device_info.dart';
import 'package:timesget/styles/border_radius.dart';
import 'package:timesget/styles/colors.dart';
import 'package:timesget/styles/constants.dart';
import 'package:timesget/styles/paddings.dart';
import 'package:timesget/styles/shadows.dart';
import 'package:timesget/styles/text_styles.dart';
import 'package:cached_network_image/cached_network_image.dart';

enum WorkerCardTypes { itemList, detail, hotOffer, userBooking }

const _widgetName = "worker_card_widget";
String _translate(String key) {
  return allTranslations.concatText([_widgetName, key]);
}

class WorkerCard extends StatelessWidget {
  final Worker _worker;
  final WorkerCardTypes type;
  final HotOffer hotOffer;
  final UserBooking userBooking;
  final BestTimeRangeAvailability fromBestTime;
  get workerId => _worker.id;

  WorkerCard(this._worker,
      {this.type = WorkerCardTypes.itemList,
      this.hotOffer,
      this.userBooking,
      this.fromBestTime});

  Widget _buildKeyValue(String key, String value,
      {bool dashIfEmpty = false, bool valueOnNewLine = false}) {
    final keytext = '$key: ';
    final valueText = value == null ? AppConstants.noValue : value;

    if (valueOnNewLine && type == WorkerCardTypes.detail) {
      return Column(
        children: [
          Text(
            keytext,
            style: AppTextStyles.keyValueKey,
          ),
          Text(
            valueText,
            style: AppTextStyles.keyValueValue,
          )
        ],
      );
    }

    return type == WorkerCardTypes.detail
        ? RichText(
            maxLines: 5,
            textAlign: TextAlign.center,
            text: TextSpan(children: [
              TextSpan(
                text: keytext,
                style: AppTextStyles.keyValueKey,
              ),
              TextSpan(
                text: valueText,
                style: AppTextStyles.keyValueValue,
              )
            ]),
          )
        : Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              AppConstants.spaceH(10),
              Text(
                keytext,
                style: AppTextStyles.keyValueKey,
              ),
              AppConstants.spaceH(8),
              Text(
                  (valueText == null || valueText == '' && dashIfEmpty)
                      ? '-'
                      : valueText,
                  style: AppTextStyles.keyValueValue)
            ],
          );
  }

  Widget _fullName(Worker doc) {
    final arr = doc.fullName.split(' ');

    final name = arr.length > 0
        ? (arr[0] +
            '\n' +
            (arr.length > 1
                ? (arr[1] + (arr.length > 2 ? ' ' + arr[2] : ''))
                : ''))
        : 'no name';

    return Text(
      name,
      textAlign:
          type == WorkerCardTypes.detail ? TextAlign.center : TextAlign.left,
      style: type == WorkerCardTypes.detail
          ? AppTextStyles.workerName
          : AppTextStyles.workerNameInCard,
      maxLines: 3,
    );
  }

  Widget _workerCard(Worker worker) {
    return Container(
      child: Column(
          crossAxisAlignment: type == WorkerCardTypes.detail
              ? CrossAxisAlignment.center
              : CrossAxisAlignment.start,
          children: <Widget>[
            _buildKeyValue(
                _translate('specialty'), worker.specializationsDescription,
                dashIfEmpty: true),
            _buildKeyValue(
                _translate('work_age'),
                worker.workYears == null
                    ? AppConstants.noValue
                    : "${worker.workYears} ${AppUtils.pluralYear(worker.workYears)}",
                dashIfEmpty: true),
            worker.address.isEmpty
                ? Container()
                : _buildKeyValue(
                    worker.address.length > 1
                        ? _translate('addresses')
                        : _translate('address'),
                    worker.workYears == null
                        ? AppConstants.noValue
                        : worker.address.map((x) => x.address).join('\r\n'),
                    dashIfEmpty: true),
          ]),
    );
  }

  Widget _workerThumbnail(Worker doc) {
    final height = type == WorkerCardTypes.detail ? 410 : 308;
    return Container(
      decoration: BoxDecoration(
          image: DecorationImage(
              image: doc.image == null
                  ? ExactAssetImage(AppImages.workerPlaceholder)
                  : CachedNetworkImageProvider(
                      doc.image,
                    ),
              fit: BoxFit.cover),
          borderRadius: BorderRadius.all(
              Radius.circular(height / (AppConstants.ration * 2)))),
      height: AppConstants.sizeOf(height),
      width: AppConstants.sizeOf(height),
    );
  }

  Widget _workerStars(BuildContext context, double stars, int commentsCount,
      {bool withLabel = false}) {
    final commentsLabel = DeviceInfo.isSmallWidth
        ? ''
        : withLabel ? " " + _translate('comments') : '';
    return Row(children: [
      StarsRate(stars == null ? 0.0 : stars),
      AppConstants.spaceW(15),
      Text(
        commentsCount == null
            ? '(0$commentsLabel)'
            : '($commentsCount$commentsLabel)',
        style: AppTextStyles.keyValueKey,
      )
    ]);
  }

  Widget _workerPrice(BuildContext context, double price) {
    if (price == null || price == 0.0) {
      return Container();
    }

    final style = TextStyle(
        color: AppColors.workerCardPrice,
        fontSize: DeviceInfo.androidSmall
            ? AppTextStyles.fontSize14
            : AppTextStyles.textFontSize,
        fontWeight: FontWeight.w900);

    final row = Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        Text(
          _translate('from'),
          style: style,
        ),
        AppConstants.spaceW(20),
        Text(
          '${price.toStringAsFixed(price.truncateToDouble() == price ? 0 : 2)}',
          style: style,
        ),
        AppConstants.spaceW(10),
        Text(
          allTranslations.concatText(['currency', 'short']),
          style: style,
        )
      ],
    );

    return Container(child: row);
  }

  Widget _rateAndPrice(BuildContext context, Worker worker) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        _workerStars(context, worker.rating, worker.commentCount,
            withLabel: type == WorkerCardTypes.detail),
        _workerPrice(context, worker.hourRateSalary)
      ],
    );
  }

  Widget _buildDetailed(BuildContext context) {
    return StreamBuilder(
        stream: ModelProvider.of(context).nextCity,
        builder: (context, AsyncSnapshot<City> snapshot) {
          if (!snapshot.hasData) {
            return AppConstants.circleSpinner;
          }

          return StreamBuilder(
            stream: Firestore.instance
                .collection('workers')
                .document(workerId.toString())
                .snapshots()
                .map((snapshot) => Worker.fromSnapshot(snapshot)),
            builder: (context, AsyncSnapshot<Worker> snapshot) {
              if (!snapshot.hasData) {
                return AppConstants.circleSpinner;
              }

              final worker = snapshot.data;

              return Container(
                color: AppColors.white,
                // padding:  EdgeInsets.fromLTRB(AppPaddings.left, 0.0, AppPaddings.right, 0.0),
                child: Column(
                  children: <Widget>[
                    _workerThumbnail(worker),
                    AppConstants.spaceH(70),
                    _fullName(worker),
                    AppConstants.spaceH(30),
                    _workerCard(worker),
                    AppConstants.spaceH(65),
                    _rateAndPrice(context, worker),
                  ],
                ),
              );
            },
          );
        });
  }

  Widget _buildAsListItem(BuildContext context, Worker worker,
      {HotOffer hotOffer, BestTimeRangeAvailability bestTime}) {
    final content = Container(
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius:
              BorderRadius.all(Radius.circular(AppRoundCorners.radius)),
          boxShadow: AppShadows.common),
      child: Column(
        children: <Widget>[
          Container(
              padding: EdgeInsets.fromLTRB(AppPaddings.left, 15.0,
                  AppPaddings.left, AppConstants.sizeOf(50)),
              child: Column(children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          AppConstants.spaceH(45),
                          _fullName(worker),
                          AppConstants.spaceH(18),
                          _workerCard(worker)
                        ],
                      ),
                    ),
                    AppConstants.spaceW(30),
                    _workerThumbnail(worker),
                  ],
                ),
                AppConstants.spaceH(50),
                _rateAndPrice(context, worker),
              ])),
          hotOffer == null && userBooking == null
              ? Container()
              : BookingBoard(
                  offer: hotOffer,
                  userBooking: userBooking,
                ),
        ],
      ),
    );

    return RowCardComponent(
      child: content,
      paddings: EdgeInsets.all(0.0),
      onTap: () {
        print("Go to worker ${worker.fullName}");
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => WorkerDetailPage(worker,
                    hotOffer: hotOffer, bestTime: fromBestTime),
                settings: RouteSettings(name: 'WorkerDetailPage')));
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return type == WorkerCardTypes.detail
        ? _buildDetailed(context)
        : _buildAsListItem(context, _worker,
            hotOffer: hotOffer, bestTime: fromBestTime);
  }
}
