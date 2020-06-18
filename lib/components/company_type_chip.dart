import 'package:flutter/material.dart';
import 'package:timesget/models/company_type.dart';
import 'package:timesget/styles/colors.dart';
import 'package:timesget/styles/decorationd.dart';
import 'package:timesget/styles/text_styles.dart';

class CompanyTypeChip extends StatelessWidget {
  final CompanyType companyType;
  final bool isActive;
  final GestureTapCallback onTap;

  CompanyTypeChip(this.companyType, {this.isActive = false, this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      child: Container(
          padding: EdgeInsets.fromLTRB(12.0, 6.0, 12.0, 4.0),
          decoration: isActive ? AppDecorations.selectedChipDecoration : null,
          child: Text(
            companyType.title,
            style: TextStyle(
                fontSize: AppTextStyles.fontSize14,
                fontWeight: FontWeight.w700,
                color: isActive ? AppColors.white : AppColors.text),
          )),
      onTap: onTap,
    );
  }
}
