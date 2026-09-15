import 'package:flutter/material.dart';
import 'package:larnity/src/core/constants/app_size.dart';
import 'package:larnity/src/core/constants/app_strings.dart';
import 'package:larnity/src/core/extensions/extensions.dart';
import 'package:larnity/src/core/extensions/screen_size_extension.dart';
import 'package:larnity/src/core/theme/app_colors.dart';
import 'package:larnity/src/core/theme/theme.dart';
import 'package:larnity/src/core/ui/widgets/app_button.dart';
import 'package:larnity/src/core/ui/widgets/app_dropdown.dart';
import 'package:larnity/src/core/ui/widgets/app_dropdown_slash_editor.dart';

class GeneralSettingsScreen extends StatelessWidget {
  const GeneralSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.darkBg,
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppSizes.xs),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppSizes.xs.ph,
              Text(
                AppStrings.groupSettings,
                style: AppTextStyles.headline1(color: AppColors.white),
              ),
              AppSizes.xxxs.ph,
              Text(AppStrings.groupSettingsDesc),
              AppSizes.xxxlg.ph,
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: AppSizes.xxs,
                  vertical: AppSizes.xxxs,
                ),
                decoration: BoxDecoration(
                  border: Border.all(
                    color: AppColors.skyBlue.withValues(alpha: 0.5),
                  ),
                  borderRadius: BorderRadius.circular(AppSizes.xxxs),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        "https://www.larnity.com/about/canva-capsul-class",
                        style: AppTextStyles.overLine(),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    AppSizes.xs.pw,

                    AppButton(
                      height: 40,
                      isExpanded: false,
                      onPressed: () {},
                      label: "Share",

                      labelStyle: AppTextStyles.bodyText2(
                        color: AppColors.white,
                      ),
                      borderColor: AppColors.skyBlue.withValues(alpha: 0.5),
                      bgColor: Colors.transparent,
                      radius: AppSizes.xxxs,
                    ),
                  ],
                ),
              ),
              AppSizes.xxxlg.ph,
              Text(
                AppStrings.groupThumbnail,
                style: AppTextStyles.headline4(color: AppColors.white),
              ),
              AppSizes.xxlg.ph,
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Expanded(
                    child: Container(
                      height: 0.2.sh,

                      decoration: BoxDecoration(
                        color: AppColors.primaryOrange,
                        borderRadius: BorderRadius.circular(AppSizes.xxxs),
                      ),
                    ),
                  ),
                ],
              ),
              AppSizes.xxlg.ph,
              AppButton(
                onPressed: () {},
                bgColor: AppColors.darkBgContainer,
                label: AppStrings.changeThumbnail,
                labelStyle: AppTextStyles.button(color: AppColors.white),
              ),
              AppSizes.xxxlg.ph,
              Text(
                AppStrings.groupPrivacy,
                style: AppTextStyles.headline5(color: AppColors.white),
              ),
              AppSizes.xxxs.ph,
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
                      Text(
                        "PRIVATE",
                        style: AppTextStyles.bodyText2(color: AppColors.white),
                      ),
                      Icon(Icons.keyboard_arrow_down, color: AppColors.white),
                    ],
                  ),
                ),
                items: [
                  AppDropdownItem(value: "private", label: "PRIVATE"),
                  AppDropdownItem(value: "private", label: "PUBLIC"),
                ],
              ),
              AppSizes.lg.ph,
              Text(
                AppStrings.groupPrivacy,
                style: AppTextStyles.headline5(color: AppColors.white),
              ),
              AppSizes.lg.ph,
              Container(
                height: 0.2.sh,
                width: 0.2.sh,
                decoration: BoxDecoration(
                  color: AppColors.primaryOrange,
                  borderRadius: BorderRadius.circular(AppSizes.xs),
                ),
              ),
              AppSizes.xs.ph,
              AppButton(
                isExpanded: false,
                onPressed: () {},
                bgColor: AppColors.darkBgContainer,
                label: AppStrings.changeThumbnail,
                labelStyle: AppTextStyles.button(color: AppColors.white),
              ),
              AppSizes.xxlg.ph,
              Text(
                AppStrings.groupName,
                style: AppTextStyles.headline5(color: AppColors.white),
              ),
              AppSizes.xxxs.ph,
              TextFormField(
                decoration: InputDecoration(
                  filled: true,
                  fillColor: AppColors.darkBgContainer,
                  hintText: "Sifat",
                  hintStyle: AppTextStyles.button(color: AppColors.skyBlue),
                  border: OutlineInputBorder(borderSide: BorderSide.none),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppSizes.xxxs),
                    borderSide: BorderSide(color: AppColors.skyBlue),
                  ),
                ),
              ),
              AppSizes.lg.ph,
              Text(
                AppStrings.groupSlug,
                style: AppTextStyles.headline5(color: AppColors.white),
              ),
              AppSizes.xxxs.ph,
              TextFormField(
                decoration: InputDecoration(
                  filled: true,
                  fillColor: AppColors.darkBgContainer,
                  hintText: "Sifat",
                  hintStyle: AppTextStyles.button(color: AppColors.skyBlue),
                  border: OutlineInputBorder(borderSide: BorderSide.none),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppSizes.xxxs),
                    borderSide: BorderSide(color: AppColors.skyBlue),
                  ),
                ),
              ),
              AppSizes.xxlg.ph,
              Text(
                AppStrings.groupDesc,
                style: AppTextStyles.headline5(color: AppColors.white),
              ),
              AppSizes.xxxs.ph,
              AppDropdownSlashEditor(),
              AppSizes.xxlg.ph,
              SwitchListTile(
                controlAffinity: ListTileControlAffinity.leading,
                value: true,
                onChanged: (val) {},
                title: Text(AppStrings.groupNameShown),
              ),
              AppSizes.lg.ph,
              AppButton(
                onPressed: () {},
                bgColor: AppColors.primaryOrange,
                label: AppStrings.saveChanges,
                labelStyle: AppTextStyles.button(color: AppColors.black),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
