import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:hugeicons/styles/stroke_rounded.dart';
import 'package:larnity/src/core/constants/app_assets.dart';
import 'package:larnity/src/core/constants/app_size.dart';
import 'package:larnity/src/core/constants/app_strings.dart';
import 'package:larnity/src/core/extensions/extensions.dart';
import 'package:larnity/src/core/extensions/screen_size_extension.dart';
import 'package:larnity/src/core/theme/app_colors.dart';
import 'package:larnity/src/core/theme/theme.dart';

class FooterWidget extends StatelessWidget {
  const FooterWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(AppSizes.xxs), // Reduced padding
      color: AppColors.darkBgContainer,
      child: Align(
        alignment: Alignment.centerLeft,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min, // Added this to minimize height
            children: [
              Text("${AppStrings.appName}.", style: AppTextStyles.headline4()),
              AppSizes.xxxs.ph, // Reduced spacing
              RichText(
                text: TextSpan(
                  text: AppStrings.termsAndConditions,
                  style: AppTextStyles.subtitle2(),
                  recognizer: TapGestureRecognizer()..onTap = () {},
                ),
              ),
              AppSizes.xxxs.ph,
              RichText(
                text: TextSpan(
                  text: AppStrings.privacyPolicy,
                  style: AppTextStyles.subtitle2(),
                  recognizer: TapGestureRecognizer()..onTap = () {},
                ),
              ),
              AppSizes.xxxs.ph,
              RichText(
                text: TextSpan(
                  text: AppStrings.refundAndCancellationPolicy,
                  style: AppTextStyles.subtitle2(),
                  recognizer: TapGestureRecognizer()..onTap = () {},
                ),
              ),
              AppSizes.xxxs.ph,
              RichText(
                text: TextSpan(
                  text: AppStrings.aboutUs,
                  style: AppTextStyles.subtitle2(),
                  recognizer: TapGestureRecognizer()..onTap = () {},
                ),
              ),
              AppSizes.xxxs.ph,
              RichText(
                text: TextSpan(
                  text: AppStrings.contactUs,
                  style: AppTextStyles.subtitle2(),
                  recognizer: TapGestureRecognizer()..onTap = () {},
                ),
              ),
              AppSizes.xxxs.ph,
              RichText(
                text: TextSpan(
                  text: AppStrings.listingChargesPlanAndTheirBenefit,
                  style: AppTextStyles.subtitle2(),
                  recognizer: TapGestureRecognizer()..onTap = () {},
                ),
              ),
              AppSizes.xs.ph, // Reduced spacing
              RichText(
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: "${AppStrings.contact}: ",
                      style: AppTextStyles.subtitle1(),
                    ),
                    TextSpan(
                      text: AppStrings.supportNumber,
                      style: AppTextStyles.subtitle2(),
                    ),
                  ],
                  recognizer: TapGestureRecognizer()..onTap = () {},
                ),
              ),
              AppSizes.xxxs.ph,
              Text("${AppStrings.address}:", style: AppTextStyles.subtitle1()),
              AppSizes.xs.ph, // Reduced spacing
              Image.asset(AppAssets.images.logoColor, width: 0.2.sw), // Reduced image size
              AppSizes.xxxs.ph,
              Row(
                children: [
                  HugeIcon(
                    icon: HugeIconsStrokeRounded.facebook02,
                    color: AppColors.white,
                    size: 20, // Reduced icon size
                  ),
                  AppSizes.xxxs.pw,
                  HugeIcon(
                    icon: HugeIconsStrokeRounded.twitter,
                    color: AppColors.white,
                    size: 20,
                  ),
                  AppSizes.xxxs.pw,
                  HugeIcon(
                    icon: HugeIconsStrokeRounded.instagram,
                    color: AppColors.white,
                    size: 20,
                  ),
                  AppSizes.xxxs.pw,
                  HugeIcon(
                    icon: HugeIconsStrokeRounded.youtube,
                    color: AppColors.white,
                    size: 20,
                  ),
                ],
              ),
              AppSizes.xxxs.ph,
              Text(AppStrings.rights, style: AppTextStyles.caption2()),
              AppSizes.xs.ph, // Reduced spacing
            ],
          ),
        ),
      ),
    );
  }
}