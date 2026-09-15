import 'package:flutter/material.dart';
import 'package:larnity/src/core/constants/app_size.dart';
import 'package:larnity/src/core/constants/app_strings.dart';
import 'package:larnity/src/core/extensions/extensions.dart';
import 'package:larnity/src/core/theme/app_colors.dart';
import 'package:larnity/src/core/theme/theme.dart';
import 'package:larnity/src/core/ui/widgets/app_button.dart';
import 'package:larnity/src/core/ui/widgets/app_dropdown.dart';

class OfferSettingsScreen extends StatelessWidget {
  const OfferSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppSizes.xs),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppSizes.xs.ph,
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(AppSizes.xs),
                decoration: BoxDecoration(
                  border: Border.all(color: AppColors.red),
                  borderRadius: BorderRadius.circular(AppSizes.xxxs),
                  color: AppColors.redContainer,
                ),
                child: Text(
                  "The previous limited-time offer expired",
                  style: AppTextStyles.overLine(color: AppColors.red),
                ),
              ),
              AppSizes.xxxlg.ph,
              Text(
                AppStrings.limiteTimeOffer,
                style: AppTextStyles.headline1(color: AppColors.white),
              ),
              AppSizes.xs.ph,
              Text(AppStrings.offerTitle, style: AppTextStyles.overLine()),
              AppSizes.xxxs.ph,
              TextFormField(
                decoration: InputDecoration(
                  filled: true,
                  fillColor: AppColors.darkBgContainer,
                  hintText: "",
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
                AppStrings.selectOfferPromoCode,
                style: AppTextStyles.overLine(),
              ),
              AppSizes.xxxs.ph,
              AppDropdown(
                button: Container(
                  padding: EdgeInsets.all(AppSizes.xs),
                  decoration: BoxDecoration(
                    color: AppColors.bgBlue,
                    border: Border.all(
                      color: AppColors.skyBlue.withValues(alpha: 0.5),
                    ),
                    borderRadius: BorderRadius.circular(AppSizes.xxxs),
                  ),
                  child: Row(
                    children: [
                      Expanded(child: Text('Offer')),
                      Icon(Icons.keyboard_arrow_down),
                    ],
                  ),
                ),
                items: [
                  AppDropdownItem(value: "PromoCode", label: "Promo Code"),
                ],
              ),
              AppSizes.xs.ph,
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(AppStrings.days, style: AppTextStyles.overLine()),
                        AppSizes.xxxs.ph,
                        TextFormField(
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: AppColors.darkBgContainer,
                            hintText: "",
                            hintStyle: AppTextStyles.button(
                              color: AppColors.skyBlue,
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(
                                AppSizes.xxxs,
                              ),
                              borderSide: BorderSide(
                                color: AppColors.skyBlue.withValues(alpha: 0.5),
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(
                                AppSizes.xxxs,
                              ),
                              borderSide: BorderSide(color: AppColors.skyBlue),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  AppSizes.xxxs.pw,
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(AppStrings.hours, style: AppTextStyles.overLine()),
                        AppSizes.xxxs.ph,
                        TextFormField(
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: AppColors.darkBgContainer,
                            hintText: "",
                            hintStyle: AppTextStyles.button(
                              color: AppColors.skyBlue,
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(
                                AppSizes.xxxs,
                              ),
                              borderSide: BorderSide(
                                color: AppColors.skyBlue.withValues(alpha: 0.5),
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(
                                AppSizes.xxxs,
                              ),
                              borderSide: BorderSide(color: AppColors.skyBlue),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  AppSizes.xxxs.pw,
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          AppStrings.minutes,
                          style: AppTextStyles.overLine(),
                        ),
                        AppSizes.xxxs.ph,
                        TextFormField(
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: AppColors.darkBgContainer,
                            hintText: "",
                            hintStyle: AppTextStyles.button(
                              color: AppColors.skyBlue,
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(
                                AppSizes.xxxs,
                              ),
                              borderSide: BorderSide(
                                color: AppColors.skyBlue.withValues(alpha: 0.5),
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(
                                AppSizes.xxxs,
                              ),
                              borderSide: BorderSide(color: AppColors.skyBlue),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              AppSizes.xs.ph,
              SwitchListTile(
                value: true,
                onChanged: (val) {},
                title: Text(
                  AppStrings.remainingPromoCode,
                  style: AppTextStyles.button(),
                ),
              ),
              AppSizes.xs.ph,
              SwitchListTile(
                value: true,
                onChanged: (val) {},
                title: Text(AppStrings.onOff, style: AppTextStyles.button()),
              ),
              AppSizes.xs.ph,

              AppButton(
                isExpanded: false,
                onPressed: () {},
                label: AppStrings.saveOffer,
                labelStyle: AppTextStyles.bodyText2(),
                bgColor: AppColors.white,
                radius: AppSizes.xxxs,
              ),
              AppSizes.xs.ph,
            ],
          ),
        ),
      ),
    );
  }
}
