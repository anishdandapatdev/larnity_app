import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:larnity/src/core/constants/app_size.dart';
import 'package:larnity/src/core/constants/app_strings.dart';
import 'package:larnity/src/core/extensions/extensions.dart';
import 'package:larnity/src/core/theme/app_colors.dart';
import 'package:larnity/src/core/theme/theme.dart';
import 'package:larnity/src/core/ui/widgets/app_button.dart';
import 'package:larnity/src/core/ui/widgets/app_dropdown.dart';

class AssignPaidCourse extends StatelessWidget {
  const AssignPaidCourse({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppSizes.xs),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              IconButton(
                onPressed: () {
                  context.pop();
                },
                icon: Icon(Icons.close),
              ),
            ],
          ),
          Text(AppStrings.assignPaidCourse, style: AppTextStyles.headline4()),
          Text(
            AppStrings.assignPaidCourseDesc,
            style: AppTextStyles.overLine(color: AppColors.skyBlue),
            textAlign: TextAlign.center,
          ),
          AppSizes.lg.ph,
          Text(AppStrings.selectMember, style: AppTextStyles.overLine()),
          AppSizes.xxxs.ph,
          AppDropdown(
            button: Container(
              padding: EdgeInsets.all(AppSizes.xs),
              decoration: BoxDecoration(
                border: Border.all(
                  color: AppColors.skyBlue.withValues(alpha: 0.5),
                ),
                borderRadius: BorderRadius.circular(AppSizes.xs),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "",
                    style: AppTextStyles.bodyText2(color: AppColors.white),
                  ),
                  Icon(Icons.keyboard_arrow_down, color: AppColors.white),
                ],
              ),
            ),
            items: [
              AppDropdownItem(value: "monthly", label: "Monthly Plan"),
              AppDropdownItem(value: "yearly", label: "Yearly Plan"),
            ],
          ),
          AppSizes.lg.ph,
          Text(AppStrings.selectCourse, style: AppTextStyles.overLine()),
          AppSizes.xxxs.ph,
          AppDropdown(
            button: Container(
              padding: EdgeInsets.all(AppSizes.xs),
              decoration: BoxDecoration(
                border: Border.all(
                  color: AppColors.skyBlue.withValues(alpha: 0.5),
                ),
                borderRadius: BorderRadius.circular(AppSizes.xs),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "",
                    style: AppTextStyles.bodyText2(color: AppColors.white),
                  ),
                  Icon(Icons.keyboard_arrow_down, color: AppColors.white),
                ],
              ),
            ),
            items: [
              AppDropdownItem(value: "monthly", label: "Monthly Plan"),
              AppDropdownItem(value: "yearly", label: "Yearly Plan"),
            ],
          ),
          AppSizes.lg.ph,

          AppButton(
            onPressed: () {},
            label: AppStrings.assign,
            labelStyle: AppTextStyles.bodyText2(color: AppColors.white),
            bgColor: Colors.transparent,
            borderColor: AppColors.skyBlue.withValues(alpha: 0.5),
            radius: AppSizes.xxxs,
          ),
        ],
      ),
    );
  }
}
