import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:larnity/src/core/constants/app_size.dart';
import 'package:larnity/src/core/constants/app_strings.dart';
import 'package:larnity/src/core/extensions/extensions.dart';
import 'package:larnity/src/core/theme/app_colors.dart';
import 'package:larnity/src/core/theme/theme.dart';
import 'package:larnity/src/core/ui/widgets/app_button.dart';
import 'package:larnity/src/core/ui/widgets/app_dropdown.dart';

class AddManager extends StatelessWidget {
  const AddManager({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppSizes.xs),
      child: Column(
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
          Text(
            AppStrings.sendManagerInvitation,
            style: AppTextStyles.headline4(),
          ),
          Text(
            AppStrings.sendManagerInvitationDesc,
            style: AppTextStyles.overLine(color: AppColors.skyBlue),
            textAlign: TextAlign.center,
          ),
          AppSizes.lg.ph,
          Text(AppStrings.selectManager, style: AppTextStyles.overLine()),
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
                    "Manager",
                    style: AppTextStyles.bodyText2(color: AppColors.white),
                  ),
                  Icon(Icons.keyboard_arrow_down, color: AppColors.white),
                ],
              ),
            ),
            items: [
              AppDropdownItem(value: "manager01", label: "Manager 01"),
              AppDropdownItem(value: "manager02", label: "Manager 02"),
            ],
          ),
          AppSizes.xs.ph,
          AppButton(
            onPressed: () {},
            label: AppStrings.sendInvitation,
            labelStyle: AppTextStyles.button(color: AppColors.white),
            bgColor: Colors.transparent,
            borderColor: AppColors.skyBlue.withValues(alpha: 0.5),
          ),
        ],
      ),
    );
  }
}
