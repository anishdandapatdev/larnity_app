import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:hugeicons/styles/stroke_rounded.dart';
import 'package:larnity/src/core/constants/app_size.dart';
import 'package:larnity/src/core/constants/app_strings.dart';
import 'package:larnity/src/core/extensions/extensions.dart';
import 'package:larnity/src/core/extensions/screen_size_extension.dart';
import 'package:larnity/src/core/theme/app_colors.dart';
import 'package:larnity/src/core/theme/theme.dart';

class ChattingScreen extends StatelessWidget {
  const ChattingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: SizedBox.shrink(),
        title: Text(AppStrings.messages, style: AppTextStyles.button()),
      ),
      endDrawer: Drawer(
        child: Padding(
          padding: const EdgeInsets.all(AppSizes.xs),
          child: ListView(
            children: [
              Text(AppStrings.groupMembers, style: AppTextStyles.headline4()),
              Text(
                AppStrings.selectMemberToChat,
                style: AppTextStyles.overLine(color: AppColors.skyBlue),
              ),
              AppSizes.xs.ph,
              Divider(color: AppColors.skyBlue.withValues(alpha: 0.5)),
            ],
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppSizes.xs),

        child: Column(
          children: [
            AppSizes.xs.ph,
            Text(AppStrings.noChatSelected, style: AppTextStyles.headline2()),
            AppSizes.lg.ph,
            Text(
              AppStrings.noChatSelectedDesc,
              style: AppTextStyles.overLine(),
              textAlign: TextAlign.center,
            ),
            AppSizes.xxlg.ph,
            Container(
              width: 0.7.sw,
              padding: EdgeInsets.all(AppSizes.xs),
              decoration: BoxDecoration(
                border: Border.all(color: AppColors.skyBlue),
                borderRadius: BorderRadius.circular(AppSizes.xxxlg),
              ),
              child: Row(
                children: [
                  HugeIcon(
                    icon: HugeIconsStrokeRounded.zeroCircle,
                    color: AppColors.white,
                  ),
                  AppSizes.xs.pw,
                  Expanded(child: Text(AppStrings.messageAppearHere)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
