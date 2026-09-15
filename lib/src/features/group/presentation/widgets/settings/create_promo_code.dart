import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:larnity/src/core/constants/app_size.dart';
import 'package:larnity/src/core/constants/app_strings.dart';
import 'package:larnity/src/core/extensions/extensions.dart';
import 'package:larnity/src/core/theme/app_colors.dart';
import 'package:larnity/src/core/theme/theme.dart';
import 'package:larnity/src/core/ui/widgets/app_button.dart';
import 'package:larnity/src/core/ui/widgets/app_dropdown.dart';

class CreatePromoCode extends StatelessWidget {
  const CreatePromoCode({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
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
        Text(AppStrings.createNewPromoCode, style: AppTextStyles.headline4()),
        Text(
          AppStrings.createNewPromoCodeDesc,
          style: AppTextStyles.overLine(color: AppColors.skyBlue),
        ),
        AppSizes.lg.ph,

        Text(AppStrings.promoCode, style: AppTextStyles.overLine()),
        AppSizes.xxxs.ph,
        Row(
          children: [
            Expanded(
              child: TextFormField(
                decoration: InputDecoration(
                  filled: true,
                  fillColor: AppColors.darkBgContainer,
                  hintText: AppStrings.promoCodeHint,
                  hintStyle: AppTextStyles.button(color: AppColors.skyBlue),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppSizes.xxxs),
                    borderSide: BorderSide(
                      color: AppColors.skyBlue.withValues(alpha: 0.5),
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppSizes.xxxs),
                    borderSide: BorderSide(color: AppColors.skyBlue),
                  ),
                ),
              ),
            ),
            AppSizes.xs.pw,
            AppButton(
              isExpanded: false,
              height: 52,
              onPressed: () {},
              label: AppStrings.autoGenerate,
              labelStyle: AppTextStyles.button(color: AppColors.white),
              bgColor: Colors.transparent,
              borderColor: AppColors.skyBlue.withValues(alpha: 0.5),
            ),
          ],
        ),
        AppSizes.xs.ph,
        Text(AppStrings.planType, style: AppTextStyles.overLine()),
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
                  "Monthly Plan",
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
        AppSizes.xs.ph,
        Text(AppStrings.discountPercentage, style: AppTextStyles.overLine()),
        AppSizes.xxxs.ph,
        TextFormField(
          decoration: InputDecoration(
            filled: true,
            fillColor: AppColors.darkBgContainer,
            hintText: "10",
            hintStyle: AppTextStyles.button(color: AppColors.skyBlue),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppSizes.xxxs),
              borderSide: BorderSide(
                color: AppColors.skyBlue.withValues(alpha: 0.5),
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppSizes.xxxs),
              borderSide: BorderSide(color: AppColors.skyBlue),
            ),
          ),
        ),

        AppSizes.xs.ph,
        Text(AppStrings.maxUses, style: AppTextStyles.overLine()),
        AppSizes.xxxs.ph,
        TextFormField(
          decoration: InputDecoration(
            filled: true,
            fillColor: AppColors.darkBgContainer,
            hintText: AppStrings.maxUsesUnlimitedHint,
            hintStyle: AppTextStyles.button(color: AppColors.skyBlue),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppSizes.xxxs),
              borderSide: BorderSide(
                color: AppColors.skyBlue.withValues(alpha: 0.5),
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppSizes.xxxs),
              borderSide: BorderSide(color: AppColors.skyBlue),
            ),
          ),
        ),
        AppSizes.xs.ph,
        AppButton(
          onPressed: () {},
          label: AppStrings.generatePromoCode,
          labelStyle: AppTextStyles.button(color: AppColors.black),
          bgColor: AppColors.primaryOrange,
        ),
      ],
    );
  }
}
