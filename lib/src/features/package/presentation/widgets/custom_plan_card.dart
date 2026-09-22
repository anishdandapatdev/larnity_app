import 'package:flutter/material.dart';
import 'package:larnity/src/core/constants/app_size.dart';
import 'package:larnity/src/core/extensions/extensions.dart';
import 'package:larnity/src/core/theme/app_colors.dart';
import 'package:larnity/src/core/theme/theme.dart';
import 'package:larnity/src/core/ui/widgets/app_button.dart';
import 'package:larnity/src/core/utils/show_snackbar.dart';
import 'package:url_launcher/url_launcher.dart';

class CustomPlanCard extends StatelessWidget {
  const CustomPlanCard({
    super.key,
    required this.planName,
    required this.isActive,
    this.onContactSupport,
  });

  final String planName;
  final bool isActive;
  final VoidCallback? onContactSupport;

  Future<void> _handleContactSupport(BuildContext context) async {
    if (onContactSupport != null) {
      onContactSupport!();
      return;
    }

    final Uri emailLaunchUri = Uri(
      scheme: 'mailto',
      path: 'support@larnity.com',
      queryParameters: {
        'subject': 'Inquiry: Custom Larnity Enterprise Package',
        'body':
            'Hi Larnity Support,\n\nI am interested in a custom enterprise plan for my organization.\n\nOrganization/Community Name: \nEstimated number of groups: \nEstimated total members: \nSpecial requirements: \n\nThank you!',
      },
    );

    try {
      final launched = await launchUrl(
        emailLaunchUri,
        mode: LaunchMode.externalApplication,
      );
      if (!launched) {
        showInfoToast(content: "Reach us directly at support@larnity.com");
      }
    } catch (_) {
      showInfoToast(content: "Reach us directly at support@larnity.com");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSizes.xs),
      decoration: BoxDecoration(
        color: AppColors.darkBgContainer.withValues(alpha: 0.4),
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
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSizes.xxxs,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.green.withValues(alpha: 0.15),
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
          AppSizes.sm.ph,
          RichText(
            text: TextSpan(
              children: [
                TextSpan(text: "Custom", style: AppTextStyles.headline1()),
                TextSpan(
                  text: "/pricing",
                  style: AppTextStyles.headline3(
                    color: AppColors.white.withValues(alpha: 0.5),
                  ),
                ),
              ],
            ),
          ),
          AppSizes.sm.ph,
          Text(
            "Tailored package for your specific organizational needs",
            style: AppTextStyles.headline4(color: AppColors.white),
          ),
          AppSizes.sm.ph,
          _buildFeatureRow("Custom group and member limits"),
          AppSizes.xxxs.ph,
          _buildFeatureRow("White-label & enterprise branding options"),
          AppSizes.xxxs.ph,
          _buildFeatureRow("Dedicated account manager & 24/7 SLA"),
          AppSizes.xxxs.ph,
          _buildFeatureRow("Custom webhooks, APIs & automations"),
          AppSizes.md.ph,
          AppButton(
            onPressed: () => _handleContactSupport(context),
            label: "Contact Support",
            labelStyle: AppTextStyles.bodyText2(color: AppColors.darkBrown),
            bgColor: AppColors.white,
            radius: AppSizes.xxxs,
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureRow(String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Icon(Icons.check_circle_outline, color: AppColors.skyBlue, size: 16),
        AppSizes.xxxs.pw,
        Expanded(
          child: Text(
            text,
            style: AppTextStyles.overLine(
              color: AppColors.white.withValues(alpha: 0.9),
            ),
          ),
        ),
      ],
    );
  }
}
