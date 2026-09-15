import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:larnity/src/core/constants/app_size.dart';
import 'package:larnity/src/core/constants/app_strings.dart';
import 'package:larnity/src/core/extensions/extensions.dart';
import 'package:larnity/src/core/theme/app_colors.dart';
import 'package:larnity/src/core/theme/theme.dart';
import 'package:larnity/src/core/ui/widgets/app_button.dart';
import 'package:larnity/src/core/ui/widgets/app_dropdown.dart';
import 'package:larnity/src/core/ui/widgets/phone_number_input.dart';
import 'package:larnity/src/features/group/data/datasource/country_list_with_code.dart';
import 'package:larnity/src/features/group/data/models/country_model.dart';

class FreeChallengeAccess extends StatelessWidget {
  const FreeChallengeAccess({super.key});

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
            AppStrings.grantFreeChallengeAccess,
            style: AppTextStyles.headline4(),
          ),
          Text(
            AppStrings.grantFreeChallengeAccessDesc,
            style: AppTextStyles.overLine(color: AppColors.skyBlue),
            textAlign: TextAlign.center,
          ),
          AppSizes.lg.ph,
          Text(AppStrings.selectMember, style: AppTextStyles.overLine()),
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
                    "",
                    style: AppTextStyles.bodyText2(color: AppColors.white),
                  ),
                  Icon(Icons.keyboard_arrow_down, color: AppColors.white),
                ],
              ),
            ),
            items: [
              AppDropdownItem(value: "monthly", label: "Monthly Plan"),
              AppDropdownItem(value: "yearly", label: "Yearly Plan"),
            ],
          ),
          AppSizes.lg.ph,
          Text(AppStrings.selectChallenge, style: AppTextStyles.overLine()),
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
                    "",
                    style: AppTextStyles.bodyText2(color: AppColors.white),
                  ),
                  Icon(Icons.keyboard_arrow_down, color: AppColors.white),
                ],
              ),
            ),
            items: [
              AppDropdownItem(value: "monthly", label: "Monthly Plan"),
              AppDropdownItem(value: "yearly", label: "Yearly Plan"),
            ],
          ),
          AppSizes.lg.ph,
          PhoneNumberInput(
            countries: CountryListWithCode.countries,
            initialCountry: CountryModel(
              name: "India",
              code: "+91",
              flag: '🇮🇳',
              codeAbbreviation: 'IN',
              states: [
                'Andaman and Nicobar Islands',
                'Andhra Pradesh',
                'Arunachal Pradesh',
                'Assam',
                'Bihar',
                'Chandigarh',
                'Chhattisgarh',
                'Dadra and Nagar Haveli and Daman and Diu',
                'Delhi',
                'Goa',
                'Gujarat',
                'Haryana',
                'Himachal Pradesh',
                'Jammu and Kashmir',
                'Jharkhand',
                'Karnataka',
                'Kerala',
                'Ladakh',
                'Lakshadweep',
                'Madhya Pradesh',
                'Maharashtra',
                'Manipur',
                'Meghalaya',
                'Mizoram',
                'Nagaland',
                'Odisha',
                'Puducherry',
                'Punjab',
                'Rajasthan',
                'Sikkim',
                'Tamil Nadu',
                'Telangana',
                'Tripura',
                'Uttar Pradesh',
                'Uttarakhand',
                'West Bengal',
              ],
            ),
            countryDropdownHint: "Country",
            hintText: "00000-00000",
            textStyle: AppTextStyles.overLine(color: AppColors.white),
          ),
          AppSizes.xs.ph,
          AppButton(
            onPressed: () {},
            label: AppStrings.grantAccess,
            labelStyle: AppTextStyles.bodyText2(color: AppColors.black),
            bgColor: AppColors.primaryOrange,
            radius: AppSizes.xxxs,
          ),
        ],
      ),
    );
  }
}
