import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:hugeicons/styles/stroke_rounded.dart';
import 'package:larnity/src/core/constants/app_size.dart';
import 'package:larnity/src/core/constants/app_strings.dart';
import 'package:larnity/src/core/extensions/extensions.dart';
import 'package:larnity/src/core/theme/app_colors.dart';
import 'package:larnity/src/core/theme/theme.dart';
import 'package:larnity/src/core/ui/widgets/app_dropdown.dart';

class ChallengeRoomScreen extends StatelessWidget {
  const ChallengeRoomScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Challenges Room")),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppSizes.xs),
        child: SingleChildScrollView(
          child: Column(
            children: [
              AppSizes.lg.ph,
              Text(
                AppStrings.currentChallenges,
                style: AppTextStyles.headline4(),
              ),
              Text(
                AppStrings.currentChallengesDesc,
                style: AppTextStyles.overLine(color: AppColors.skyBlue),
                textAlign: TextAlign.center,
              ),
              AppSizes.lg.ph,
              Container(
                padding: EdgeInsets.all(AppSizes.xs),
                decoration: BoxDecoration(
                  border: Border.all(color: AppColors.skyBlue),
                  borderRadius: BorderRadius.circular(AppSizes.xs),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: AppColors.blue,
                        borderRadius: BorderRadius.circular(AppSizes.xxxs),
                      ),
                      child: Center(
                        child: HugeIcon(
                          icon: HugeIconsStrokeRounded.champion,
                          color: AppColors.white,
                        ),
                      ),
                    ),
                    AppSizes.xs.pw,
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          AppStrings.totalChallenges,
                          style: AppTextStyles.overLine(color: AppColors.blue),
                        ),
                        Text(
                          "0",
                          style: AppTextStyles.headline2(color: AppColors.blue),
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
                  border: Border.all(color: AppColors.green),
                  borderRadius: BorderRadius.circular(AppSizes.xs),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: AppColors.green,
                        borderRadius: BorderRadius.circular(AppSizes.xxxs),
                      ),
                      child: Center(
                        child: HugeIcon(
                          icon: HugeIconsStrokeRounded.calendar04,
                          color: AppColors.white,
                        ),
                      ),
                    ),
                    AppSizes.xs.pw,
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          AppStrings.active,
                          style: AppTextStyles.overLine(color: AppColors.green),
                        ),
                        Text(
                          "0",
                          style: AppTextStyles.headline2(
                            color: AppColors.green,
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
                  border: Border.all(color: AppColors.purple),
                  borderRadius: BorderRadius.circular(AppSizes.xs),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: AppColors.purple,
                        borderRadius: BorderRadius.circular(AppSizes.xxxs),
                      ),
                      child: Center(
                        child: HugeIcon(
                          icon: HugeIconsStrokeRounded.stars,
                          color: AppColors.white,
                        ),
                      ),
                    ),
                    AppSizes.xs.pw,
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          AppStrings.liveNow,
                          style: AppTextStyles.overLine(),
                        ),
                        Text(
                          "0",
                          style: AppTextStyles.headline2(
                            color: AppColors.white,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              AppSizes.xs.ph,
              TextFormField(
                decoration: InputDecoration(
                  filled: true,
                  fillColor: AppColors.darkBgContainer,
                  hintText: AppStrings.searchChallenges,
                  prefixIcon: HugeIcon(
                    icon: HugeIconsStrokeRounded.search01,
                    color: AppColors.white,
                  ),
                  hintStyle: AppTextStyles.button(color: AppColors.skyBlue),
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

              AppDropdown(
                button: Container(
                  padding: EdgeInsets.all(AppSizes.xs),
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: AppColors.skyBlue.withValues(alpha: 0.5),
                    ),
                    borderRadius: BorderRadius.circular(AppSizes.xs),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      HugeIcon(
                        icon: HugeIconsStrokeRounded.filter,
                        color: AppColors.white,
                      ),
                      Text(
                        AppStrings.allStatus,
                        style: AppTextStyles.bodyText2(color: AppColors.white),
                      ),
                      Icon(Icons.keyboard_arrow_down, color: AppColors.white),
                    ],
                  ),
                ),
                items: [
                  AppDropdownItem(
                    value: AppStrings.allStatus,
                    label: AppStrings.allStatus,
                  ),
                  AppDropdownItem(
                    value: AppStrings.registrationOpen,
                    label: AppStrings.registrationOpen,
                  ),
                  AppDropdownItem(
                    value: AppStrings.live,
                    label: AppStrings.live,
                  ),
                  AppDropdownItem(
                    value: AppStrings.finished,
                    label: AppStrings.finished,
                  ),
                  AppDropdownItem(
                    value: AppStrings.resultsDeclared,
                    label: AppStrings.resultsDeclared,
                  ),
                ],
              ),
              AppSizes.xs.ph,

              AppDropdown(
                button: Container(
                  padding: EdgeInsets.all(AppSizes.xs),
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: AppColors.skyBlue.withValues(alpha: 0.5),
                    ),
                    borderRadius: BorderRadius.circular(AppSizes.xs),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      HugeIcon(
                        icon: HugeIconsStrokeRounded.userMultiple02,
                        color: AppColors.white,
                      ),
                      Text(
                        AppStrings.allTypes,
                        style: AppTextStyles.bodyText2(color: AppColors.white),
                      ),
                      Icon(Icons.keyboard_arrow_down, color: AppColors.white),
                    ],
                  ),
                ),
                items: [
                  AppDropdownItem(
                    value: AppStrings.allTypes,
                    label: AppStrings.allTypes,
                  ),
                  AppDropdownItem(
                    value: AppStrings.free,
                    label: AppStrings.free,
                  ),
                  AppDropdownItem(
                    value: AppStrings.paid,
                    label: AppStrings.paid,
                  ),
                ],
              ),
              AppSizes.xxxlg.ph,
              Container(
                height: 100,
                width: 100,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.skyBlue.withValues(alpha: 0.2),
                ),
                child: HugeIcon(
                  icon: HugeIconsStrokeRounded.champion,
                  color: AppColors.skyBlue,
                  size: 40,
                ),
              ),
              AppSizes.lg.ph,

              Text(
                AppStrings.noChallengesAvailable,
                style: AppTextStyles.headline2(),
              ),
              AppSizes.xs.ph,
              Text(
                AppStrings.noChallengesAvailableDesc,
                style: AppTextStyles.overLine(color: AppColors.skyBlue),
                textAlign: TextAlign.center,
              ),
              AppSizes.lg.ph,
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  HugeIcon(
                    icon: HugeIconsStrokeRounded.calendar04,
                    color: AppColors.skyBlue,
                  ),
                  AppSizes.xs.pw,

                  Text(
                    AppStrings.newChallengesComingSoon,
                    style: AppTextStyles.overLine(color: AppColors.skyBlue),
                  ),
                ],
              ),
              AppSizes.xxxlg.ph,
            ],
          ),
        ),
      ),
    );
  }
}
