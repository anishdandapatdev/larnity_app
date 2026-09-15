import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:hugeicons/styles/stroke_rounded.dart';
import 'package:larnity/src/core/constants/app_size.dart';
import 'package:larnity/src/core/constants/app_strings.dart';
import 'package:larnity/src/core/extensions/extensions.dart';
import 'package:larnity/src/core/theme/app_colors.dart';
import 'package:larnity/src/core/theme/theme.dart';
import 'package:larnity/src/core/ui/widgets/app_button.dart';

class GoogleSheetIntegration extends StatelessWidget {
  const GoogleSheetIntegration({super.key});

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
          Text(
            AppStrings.googleSheetIntegration,
            style: AppTextStyles.headline4(),
          ),
          Text(
            AppStrings.googleSheetIntegrationDialogDesc,
            style: AppTextStyles.overLine(color: AppColors.skyBlue),
          ),
          AppSizes.lg.ph,
          Container(
            padding: EdgeInsets.all(AppSizes.xs),
            decoration: BoxDecoration(
              color: AppColors.borderBrown,
              borderRadius: BorderRadius.circular(AppSizes.xxxs),
            ),
            child: Column(
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: EdgeInsets.all(AppSizes.xxxs),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(4),
                        color: AppColors.white.withValues(alpha: 0.1),
                      ),
                      child: Center(
                        child: HugeIcon(
                          icon: HugeIconsStrokeRounded.googleSheet,
                          color: AppColors.primaryOrange,
                        ),
                      ),
                    ),
                    AppSizes.xxxs.pw,
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            AppStrings.notConnected,
                            style: AppTextStyles.headline4(),
                          ),
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  AppStrings.notConnectedDesc,
                                  style: AppTextStyles.overLine(
                                    color: AppColors.skyBlue,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          AppSizes.xs.ph,
          Container(
            padding: EdgeInsets.all(AppSizes.xs),
            decoration: BoxDecoration(
              color: AppColors.borderBrown,
              borderRadius: BorderRadius.circular(AppSizes.xxxs),
            ),
            child: CheckboxListTile(
              contentPadding: EdgeInsets.zero,
              value: false,
              onChanged: (val) {},
              title: Text(AppStrings.enableGoogleSheetSync),
              subtitle: Text(AppStrings.enableGoogleSheetSyncDesc),
            ),
          ),
          AppSizes.xs.ph,

          AppButton(
            onPressed: () {},
            label: AppStrings.saveSettings,
            labelStyle: AppTextStyles.bodyText2(color: AppColors.black),
            bgColor: AppColors.primaryOrange,
            radius: AppSizes.xxxs,
          ),
        ],
      ),
    );
  }
}
