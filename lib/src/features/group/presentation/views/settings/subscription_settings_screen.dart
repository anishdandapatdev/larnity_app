import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:hugeicons/styles/stroke_rounded.dart';
import 'package:larnity/src/core/constants/app_size.dart';
import 'package:larnity/src/core/constants/app_strings.dart';
import 'package:larnity/src/core/extensions/extensions.dart';
import 'package:larnity/src/core/theme/app_colors.dart';
import 'package:larnity/src/core/theme/theme.dart';
import 'package:larnity/src/core/ui/widgets/app_button.dart';

class SubscriptionSettingsScreen extends StatelessWidget {
  const SubscriptionSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.darkBg,
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppSizes.xs),
        child: SingleChildScrollView(
          child: Column(
            children: [
              AppSizes.xs.ph,
              Text(
                AppStrings.groupSubscriptions,
                style: AppTextStyles.headline1(color: AppColors.white),
              ),
              AppSizes.xxxs.ph,
              Container(
                padding: EdgeInsets.all(AppSizes.xs),
                decoration: BoxDecoration(
                  color: AppColors.bgBlue,
                  border: Border.all(
                    color: AppColors.skyBlue.withValues(alpha: 0.5),
                  ),
                  borderRadius: BorderRadius.circular(AppSizes.xxxs),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      AppStrings.setSubscriptionPrices,
                      style: AppTextStyles.headline4().copyWith(
                        fontWeight: AppFontWeights.bold,
                      ),
                    ),
                    AppSizes.lg.ph,
                    Text(
                      AppStrings.monthlyPrice,
                      style: AppTextStyles.overLine(),
                    ),
                    TextFormField(
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: AppColors.darkBgContainer,
                        hintText: "0",
                        hintStyle: AppTextStyles.button(
                          color: AppColors.skyBlue,
                        ),
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
                    Text(
                      AppStrings.yearlyPrice,
                      style: AppTextStyles.overLine(),
                    ),
                    TextFormField(
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: AppColors.darkBgContainer,
                        hintText: "0",
                        hintStyle: AppTextStyles.button(
                          color: AppColors.skyBlue,
                        ),
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
                    Text(
                      AppStrings.lifetimePrice,
                      style: AppTextStyles.overLine(),
                    ),
                    TextFormField(
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: AppColors.darkBgContainer,
                        hintText: "0",
                        hintStyle: AppTextStyles.button(
                          color: AppColors.skyBlue,
                        ),
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
                      label: AppStrings.updatePrices,
                      labelStyle: AppTextStyles.bodyText2(),
                      bgColor: AppColors.white,
                      radius: AppSizes.xxxs,
                    ),
                  ],
                ),
              ),
              AppSizes.lg.ph,
              Container(
                padding: EdgeInsets.all(AppSizes.xs),
                decoration: BoxDecoration(
                  color: AppColors.bgBlue,
                  border: Border.all(
                    color: AppColors.skyBlue.withValues(alpha: 0.5),
                  ),
                  borderRadius: BorderRadius.circular(AppSizes.xxxs),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(AppStrings.monthly, style: AppTextStyles.headline4()),
                    Text(
                      AppStrings.billedEveryMonth,
                      style: AppTextStyles.overLine(
                        color: AppColors.white.withValues(alpha: 0.8),
                      ),
                    ),
                    AppSizes.xs.ph,
                    Text("₹--", style: AppTextStyles.headline1()),
                    AppSizes.xs.ph,
                    Row(
                      children: [
                        HugeIcon(
                          icon: HugeIconsStrokeRounded.user,
                          color: AppColors.white,
                        ),
                        AppSizes.xxxs.pw,
                        Text("0 members", style: AppTextStyles.overLine()),
                      ],
                    ),
                  ],
                ),
              ),
              AppSizes.lg.ph,
              Container(
                padding: EdgeInsets.all(AppSizes.xs),
                decoration: BoxDecoration(
                  color: AppColors.bgBlue,
                  border: Border.all(
                    color: AppColors.skyBlue.withValues(alpha: 0.8),
                  ),
                  borderRadius: BorderRadius.circular(AppSizes.xxxs),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(AppStrings.yearly, style: AppTextStyles.headline4()),
                    Text(
                      AppStrings.billedEveryYear,
                      style: AppTextStyles.overLine(
                        color: AppColors.white.withValues(alpha: 0.8),
                      ),
                    ),
                    AppSizes.xs.ph,
                    Text("₹--", style: AppTextStyles.headline1()),
                    Text(
                      "₹0.00/mo",
                      style: AppTextStyles.overLine(
                        color: AppColors.white.withValues(alpha: 0.8),
                      ),
                    ),
                    AppSizes.xs.ph,
                    Row(
                      children: [
                        HugeIcon(
                          icon: HugeIconsStrokeRounded.user,
                          color: AppColors.white,
                        ),
                        AppSizes.xxxs.pw,
                        Text("0 members", style: AppTextStyles.overLine()),
                      ],
                    ),
                  ],
                ),
              ),
              AppSizes.lg.ph,
              Container(
                padding: EdgeInsets.all(AppSizes.xs),
                decoration: BoxDecoration(
                  color: AppColors.bgBlue,
                  border: Border.all(
                    color: AppColors.skyBlue.withValues(alpha: 0.5),
                  ),
                  borderRadius: BorderRadius.circular(AppSizes.xxxs),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(AppStrings.lifetime, style: AppTextStyles.headline4()),
                    Text(
                      AppStrings.oneTimePayment,
                      style: AppTextStyles.overLine(
                        color: AppColors.white.withValues(alpha: 0.8),
                      ),
                    ),
                    AppSizes.xs.ph,
                    Text("₹--", style: AppTextStyles.headline1()),
                    AppSizes.xs.ph,
                    Row(
                      children: [
                        HugeIcon(
                          icon: HugeIconsStrokeRounded.user,
                          color: AppColors.white,
                        ),
                        AppSizes.xxxs.pw,
                        Text("1 members", style: AppTextStyles.overLine()),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
