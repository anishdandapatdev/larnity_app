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
import 'package:larnity/src/core/ui/widgets/app_dropdown.dart';

class InvitationLink extends StatelessWidget {
  const InvitationLink({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppSizes.xs),
      child: SingleChildScrollView(
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
              AppStrings.createInvitationLink,
              style: AppTextStyles.headline4(),
            ),
            Text(
              AppStrings.createInvitationLinkDesc,
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
                crossAxisAlignment: CrossAxisAlignment.start,
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
                            icon: HugeIconsStrokeRounded.userMultiple02,
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
                              AppStrings.singleInvitation,
                              style: AppTextStyles.headline4(),
                            ),
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    AppStrings.createInvitationLinkDesc,
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
                  AppSizes.xs.ph,

                  AppSizes.xs.ph,
                  Text(
                    AppStrings.emailAddress,
                    style: AppTextStyles.overLine(),
                  ),
                  AppSizes.xxxs.ph,
                  TextFormField(
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: AppColors.darkBgContainer,
                      hintText: AppStrings.emailAddressHint,
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
                  Text(
                    AppStrings.nameOptional,
                    style: AppTextStyles.overLine(),
                  ),
                  AppSizes.xxxs.ph,
                  TextFormField(
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: AppColors.darkBgContainer,
                      hintText: AppStrings.nameHint,
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
                  Text(
                    AppStrings.expirationTimeInHours,
                    style: AppTextStyles.overLine(),
                  ),
                  AppSizes.xxxs.ph,
                  TextFormField(
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: AppColors.darkBgContainer,
                      hintText: AppStrings.expirationTimeInHoursHint,
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
                  Text(
                    AppStrings.subscriptionPlan,
                    style: AppTextStyles.overLine(),
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
                            "Monthly Plan",
                            style: AppTextStyles.bodyText2(
                              color: AppColors.white,
                            ),
                          ),
                          Icon(
                            Icons.keyboard_arrow_down,
                            color: AppColors.white,
                          ),
                        ],
                      ),
                    ),
                    items: [
                      AppDropdownItem(value: "monthly", label: "Monthly Plan"),
                      AppDropdownItem(value: "yearly", label: "Yearly Plan"),
                    ],
                  ),
                ],
              ),
            ),
            AppSizes.xs.ph,
            AppButton(
              onPressed: () {},
              label: AppStrings.createInvitationLink,
              labelStyle: AppTextStyles.button(color: AppColors.black),
              bgColor: AppColors.primaryOrange,
            ),
          ],
        ),
      ),
    );
  }
}
