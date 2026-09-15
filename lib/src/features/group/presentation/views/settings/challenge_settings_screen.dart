import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:hugeicons/styles/stroke_rounded.dart';
import 'package:larnity/src/core/constants/app_size.dart';
import 'package:larnity/src/core/constants/app_strings.dart';
import 'package:larnity/src/core/extensions/extensions.dart';
import 'package:larnity/src/core/theme/app_colors.dart';
import 'package:larnity/src/core/theme/theme.dart';
import 'package:larnity/src/core/ui/widgets/app_button.dart';
import 'package:larnity/src/features/group/presentation/widgets/settings/create_challenge.dart';

class ChallengeSettingsScreen extends StatelessWidget {
  const ChallengeSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppSizes.xs),
        child: Column(
          children: [
            AppSizes.xs.ph,
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      AppStrings.challenges,
                      style: AppTextStyles.headline2(color: AppColors.white),
                    ),

                    Text(
                      AppStrings.challengesAvailable,
                      style: AppTextStyles.overLine(),
                    ),
                  ],
                ),

                AppButton(
                  isExpanded: false,
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (context) =>
                          AlertDialog(content: CreateChallenge()),
                    );
                  },
                  prefix: HugeIcon(
                    icon: HugeIconsStrokeRounded.addCircle,
                    color: AppColors.black,
                  ),
                  label: AppStrings.createChallenge,
                  labelStyle: AppTextStyles.bodyText2(color: AppColors.black),
                  bgColor: AppColors.primaryOrange,
                  radius: AppSizes.xxxs,
                ),
              ],
            ),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  HugeIcon(
                    icon: HugeIconsStrokeRounded.champion,
                    color: AppColors.creamWhite,
                    size: 50,
                  ),
                  AppSizes.lg.ph,
                  Text(
                    AppStrings.noChallengeYet,
                    style: AppTextStyles.headline3(),
                  ),
                  Text(
                    AppStrings.noChallengeDesc,
                    style: AppTextStyles.overLine(),
                    textAlign: TextAlign.center,
                  ),
                  AppSizes.xs.ph,

                  AppButton(
                    isExpanded: false,
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (context) =>
                            AlertDialog(content: CreateChallenge()),
                      );
                    },
                    prefix: HugeIcon(
                      icon: HugeIconsStrokeRounded.addCircle,
                      color: AppColors.black,
                    ),
                    label: AppStrings.createFirstChallenge,
                    labelStyle: AppTextStyles.bodyText2(color: AppColors.black),
                    bgColor: AppColors.primaryOrange,
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
