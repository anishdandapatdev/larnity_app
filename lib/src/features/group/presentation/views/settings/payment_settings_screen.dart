import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:hugeicons/styles/stroke_rounded.dart';
import 'package:larnity/src/core/constants/app_assets.dart';
import 'package:larnity/src/core/constants/app_size.dart';
import 'package:larnity/src/core/constants/app_strings.dart';
import 'package:larnity/src/core/extensions/extensions.dart';
import 'package:larnity/src/core/theme/app_colors.dart';
import 'package:larnity/src/core/theme/theme.dart';
import 'package:larnity/src/core/ui/widgets/app_button.dart';

class PaymentSettingsScreen extends StatelessWidget {
  const PaymentSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.darkBg,
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppSizes.xs),
        child: Column(
          children: [
            AppSizes.xs.ph,
            Container(
              padding: EdgeInsets.all(AppSizes.xs),
              decoration: BoxDecoration(
                color: AppColors.black,
                border: Border.all(color: AppColors.borderBrown),
                borderRadius: BorderRadius.circular(AppSizes.xxxs),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        height: 40,
                        width: 40,
                        decoration: BoxDecoration(shape: BoxShape.circle),
                        child: ClipRRect(
                          borderRadius: BorderRadiusGeometry.circular(
                            AppSizes.xxxlg,
                          ),
                          child: Image.asset(AppAssets.images.paymintro),
                        ),
                      ),
                      AppSizes.xxxs.pw,
                      Text(
                        AppStrings.paymintro,
                        style: AppTextStyles.button().copyWith(
                          fontWeight: AppFontWeights.bold,
                        ),
                      ),
                    ],
                  ),
                  AppSizes.xs.ph,
                  Text(
                    AppStrings.paymintroDesc,
                    style: AppTextStyles.overLine(),
                  ),
                  AppSizes.xs.ph,

                  AppButton(
                    isExpanded: false,
                    onPressed: () {},
                    prefix: HugeIcon(
                      icon: HugeIconsStrokeRounded.cloud,
                      color: AppColors.black,
                    ),
                    label: AppStrings.connect,
                    labelStyle: AppTextStyles.bodyText2(),
                    bgColor: AppColors.primaryOrange,
                    radius: AppSizes.xxxs,
                  ),
                ],
              ),
            ),
            AppSizes.xs.ph,
            Container(
              padding: EdgeInsets.all(AppSizes.xs),
              decoration: BoxDecoration(
                color: AppColors.black,
                border: Border.all(color: AppColors.borderBrown),
                borderRadius: BorderRadius.circular(AppSizes.xxxs),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        height: 40,
                        width: 40,
                        decoration: BoxDecoration(shape: BoxShape.circle),
                        child: ClipRRect(
                          borderRadius: BorderRadiusGeometry.circular(
                            AppSizes.xxxlg,
                          ),
                          child: Image.asset(AppAssets.images.cashfree),
                        ),
                      ),
                      AppSizes.xxxs.pw,
                      Text(
                        AppStrings.cashfree,
                        style: AppTextStyles.button().copyWith(
                          fontWeight: AppFontWeights.bold,
                        ),
                      ),
                    ],
                  ),
                  AppSizes.xs.ph,
                  Text(
                    AppStrings.cashfreeDesc,
                    style: AppTextStyles.overLine(),
                  ),
                  AppSizes.xs.ph,

                  AppButton(
                    isExpanded: false,
                    onPressed: () {},
                    prefix: HugeIcon(
                      icon: HugeIconsStrokeRounded.cloud,
                      color: AppColors.primaryOrange,
                    ),
                    label: AppStrings.createVendor,
                    labelStyle: AppTextStyles.bodyText2(
                      color: AppColors.primaryOrange,
                    ),
                    bgColor: AppColors.infoCardColor,
                    borderColor: AppColors.primaryOrange,
                    radius: AppSizes.xxxs,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class AppColos {}
