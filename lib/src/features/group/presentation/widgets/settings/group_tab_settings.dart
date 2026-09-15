import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hugeicons/styles/stroke_rounded.dart';
import 'package:larnity/src/core/constants/app_size.dart';
import 'package:larnity/src/core/constants/app_strings.dart';
import 'package:larnity/src/core/extensions/extensions.dart';
import 'package:larnity/src/core/extensions/screen_size_extension.dart';
import 'package:larnity/src/core/theme/app_colors.dart';
import 'package:larnity/src/core/theme/theme.dart';
import 'package:larnity/src/core/ui/widgets/app_button.dart';
import 'package:larnity/src/features/group/presentation/widgets/settings/manage_group_tab_card.dart';

class GroupTabSettings extends StatelessWidget {
  const GroupTabSettings({super.key});

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
          Text(AppStrings.manageGroupTabs, style: AppTextStyles.headline4()),
          Text(
            AppStrings.manageGroupTabsDesc,
            style: AppTextStyles.overLine(color: AppColors.skyBlue),
          ),
          AppSizes.lg.ph,
          SizedBox(
            height: 0.5.sh,
            child: SingleChildScrollView(
              child: Column(
                children: [
                  ManageGroupTabCard(
                    icon: HugeIconsStrokeRounded.home03,
                    onSwitch: (p0) {},
                    title: AppStrings.discussionRoom,
                  ),
                  AppSizes.xs.ph,
                  ManageGroupTabCard(
                    icon: HugeIconsStrokeRounded.geometricShapes01,
                    onSwitch: (p0) {},
                    title: AppStrings.discussionRoom,
                  ),
                  AppSizes.xs.ph,
                  ManageGroupTabCard(
                    icon: HugeIconsStrokeRounded.computerVideo,
                    onSwitch: (p0) {},
                    title: AppStrings.discussionRoom,
                  ),
                  AppSizes.xs.ph,
                  ManageGroupTabCard(
                    icon: HugeIconsStrokeRounded.calendar03,
                    onSwitch: (p0) {},
                    title: AppStrings.discussionRoom,
                  ),
                  AppSizes.xs.ph,
                  ManageGroupTabCard(
                    icon: HugeIconsStrokeRounded.userMultiple,
                    onSwitch: (p0) {},
                    title: AppStrings.discussionRoom,
                  ),
                  AppSizes.xs.ph,
                  ManageGroupTabCard(
                    icon: HugeIconsStrokeRounded.sourceCodeSquare,
                    onSwitch: (p0) {},
                    title: AppStrings.discussionRoom,
                  ),
                  AppSizes.xs.ph,
                  ManageGroupTabCard(
                    icon: HugeIconsStrokeRounded.adventure,
                    onSwitch: (p0) {},
                    title: AppStrings.discussionRoom,
                  ),
                  AppSizes.xs.ph,
                  ManageGroupTabCard(
                    icon: HugeIconsStrokeRounded.notebook02,
                    onSwitch: (p0) {},
                    title: AppStrings.discussionRoom,
                  ),
                  AppSizes.xs.ph,
                  ManageGroupTabCard(
                    icon: HugeIconsStrokeRounded.shoppingBag01,
                    onSwitch: (p0) {},
                    title: AppStrings.discussionRoom,
                  ),
                  AppSizes.xs.ph,
                  ManageGroupTabCard(
                    icon: HugeIconsStrokeRounded.documentValidation,
                    onSwitch: (p0) {},
                    title: AppStrings.discussionRoom,
                  ),
                  AppSizes.xs.ph,
                  ManageGroupTabCard(
                    icon: HugeIconsStrokeRounded.id,
                    onSwitch: (p0) {},
                    title: AppStrings.discussionRoom,
                  ),
                  AppSizes.xs.ph,

                  AppButton(
                    onPressed: () {},
                    label: AppStrings.resetAllToDefault,
                    labelStyle: AppTextStyles.bodyText2(color: AppColors.white),
                    bgColor: AppColors.darkBrown,
                    radius: AppSizes.xxxs,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
