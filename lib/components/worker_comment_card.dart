import 'package:flutter/material.dart';
import 'package:timesget/components/row_card.dart';
import 'package:timesget/components/star_rate.dart';
import 'package:timesget/models/worker_comment.dart';
import 'package:timesget/styles/constants.dart';
import 'package:timesget/styles/text_styles.dart';

class WorkerCommentCard extends StatelessWidget {
  final WorkerComment comment;
  WorkerCommentCard(this.comment);

  @override
  Widget build(BuildContext context) {
    return RowCardComponent(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              StarsRate(comment.stars),
              Text(
                StarsRateUtil.labelOf(comment.stars),
                style: AppTextStyles.commentStarsRateLabel,
              )
            ],
          ),
          AppConstants.spaceH(41),
          Text(
            comment.customerFullName,
            style: AppTextStyles.commentCustomerFullName,
          ),
          AppConstants.spaceH(37),
          Text(
            comment.text,
            style: AppTextStyles.text,
          )
        ],
      ),
    );
  }
}
