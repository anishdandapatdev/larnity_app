import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:larnity/src/core/constants/app_size.dart';
import 'package:larnity/src/core/extensions/extensions.dart';
import 'package:larnity/src/core/theme/app_colors.dart';
import 'package:larnity/src/core/theme/theme.dart';
import 'package:larnity/src/core/ui/widgets/app_button.dart';

class IntegrationCard extends StatelessWidget {
  const IntegrationCard({
    super.key,
    required this.icon,
    required this.title,
    required this.description,
    required this.buttonLabel,
    required this.onTap,
  });

  final List<List<dynamic>> icon;
  final String title;
  final String description;
  final String buttonLabel;
  final void Function() onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(AppSizes.xs),
      decoration: BoxDecoration(
        color: AppColors.darkBrown.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(AppSizes.xxxs),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          HugeIcon(icon: icon, color: AppColors.primaryOrange),
          AppSizes.xs.ph,
          Text(title, style: AppTextStyles.headline4()),
          Text(description, style: AppTextStyles.overLine()),
          AppSizes.xs.ph,
          AppButton(
            onPressed: onTap,
            label: buttonLabel,
            labelStyle: AppTextStyles.bodyText2(color: AppColors.black),
            bgColor: AppColors.primaryOrange,
            radius: AppSizes.xxxs,
          ),
        ],
      ),
    );
  }
}
