import 'package:flutter/material.dart';
import 'package:larnity/src/core/constants/app_size.dart';
import 'package:larnity/src/core/extensions/extensions.dart';
import 'package:larnity/src/core/theme/app_colors.dart';
import 'package:larnity/src/core/theme/theme.dart';
import 'package:larnity/src/core/ui/widgets/app_button.dart';

class CustomPlanCard extends StatelessWidget {
  const CustomPlanCard({
    super.key,
    required this.planName,
    required this.isActive,
  });

  final String planName;
  final bool isActive;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(AppSizes.xs),
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.skyBlue.withValues(alpha: 0.5)),
        borderRadius: BorderRadius.circular(AppSizes.xxxs),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                planName,
                style: AppTextStyles.headline3(color: AppColors.white),
              ),
              if (isActive)
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: AppSizes.xxxs,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    border: Border.all(color: AppColors.green),
                    borderRadius: BorderRadius.circular(AppSizes.lg),
                  ),
                  child: Text(
                    "Active",
                    style: AppTextStyles.caption2(
                      color: AppColors.green,
                    ).copyWith(fontWeight: AppFontWeights.black),
                  ),
                ),
            ],
          ),
          AppSizes.lg.ph,
          RichText(
            text: TextSpan(
              children: [
                TextSpan(text: "Custom", style: AppTextStyles.headline1()),
              ],
            ),
          ),
          AppSizes.lg.ph,

          Text(
            "Tailored package for your specific needs",
            style: AppTextStyles.headline3(color: AppColors.white),
          ),
          AppSizes.lg.ph,
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.check),
              AppSizes.xxxs.pw,
              Expanded(
                child: Text(
                  "Custom group limits",
                  style: AppTextStyles.overLine(),
                ),
              ),
            ],
          ),
          AppSizes.xs.ph,
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.check),
              AppSizes.xxxs.pw,
              Expanded(
                child: Text(
                  "Enterprise features",
                  style: AppTextStyles.overLine(),
                ),
              ),
            ],
          ),
          AppSizes.xs.ph,
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.check),
              AppSizes.xxxs.pw,
              Expanded(
                child: Text(
                  "Dedicated support",
                  style: AppTextStyles.overLine(),
                ),
              ),
            ],
          ),
          AppSizes.lg.ph,
          AppButton(
            onPressed: () {},
            label: "Contact Support",
            labelStyle: AppTextStyles.bodyText2(),
            bgColor: AppColors.white,
            radius: AppSizes.xxxs,
          ),
        ],
      ),
    );
  }
}
