import 'package:flutter/material.dart';
import 'package:timesget/all_translations.dart';
import 'package:timesget/models/work_week.dart';
import 'package:timesget/styles/colors.dart';
import 'package:timesget/styles/text_styles.dart';

class WorkWeekUtils {
  static List<Row> getRows(BuildContext context, WorkWeek week) {
    final days = week.days.map((day) {
      final isWorkDay = day.timeRange != null && !day.timeRange.isEmpty;
      return Row(children: [
        Container(
          width: 40.0,
          child: Text(
            allTranslations
                .text('week.${day.dayTitle.substring(0, 3).toLowerCase()}')
                .toUpperCase(),
            // '${AppTranslations.translateWeekDay(context, day.dayTitle, short: true).toUpperCase()}:',
            style: AppTextStyles.text.copyWith(color: AppColors.link),
          ),
        ),
        Text(
          isWorkDay
              ? day.timeRange.label.replaceFirst('-', ' - ')
              : allTranslations.text('week.unwork_day'),
          style: AppTextStyles.text.copyWith(height: 1.2),
        )
      ]);
    }).toList();
    return days;
  }
}
