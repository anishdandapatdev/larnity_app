import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:hugeicons/styles/stroke_rounded.dart';
import 'package:larnity/src/core/constants/app_size.dart';
import 'package:larnity/src/core/constants/app_strings.dart';
import 'package:larnity/src/core/extensions/extensions.dart';
import 'package:larnity/src/core/extensions/screen_size_extension.dart';
import 'package:larnity/src/core/theme/app_colors.dart';
import 'package:larnity/src/core/theme/theme.dart';
import 'package:larnity/src/core/ui/widgets/app_button.dart';
import 'package:syncfusion_flutter_datepicker/datepicker.dart';

class CreateChallenge extends StatelessWidget {
  const CreateChallenge({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
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
          Row(
            children: [
              Expanded(
                child: Center(
                  child: Text(
                    AppStrings.createNewChallenge,
                    style: AppTextStyles.headline4(),
                  ),
                ),
              ),
            ],
          ),
          Row(
            children: [
              Expanded(
                child: Center(
                  child: Text(
                    AppStrings.createNewChallengeDesc,
                    style: AppTextStyles.overLine(color: AppColors.creamWhite),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ],
          ),

          AppSizes.xlg.ph,
          Text(AppStrings.challengeTitle, style: AppTextStyles.overLine()),
          AppSizes.xxxs.ph,
          TextFormField(
            decoration: InputDecoration(
              filled: true,
              fillColor: AppColors.darkBgContainer,
              hintText: AppStrings.addYourChallengeTitle,
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
          Text(AppStrings.challengeDesc, style: AppTextStyles.overLine()),
          AppSizes.xxxs.ph,
          TextFormField(
            decoration: InputDecoration(
              filled: true,
              fillColor: AppColors.darkBgContainer,
              hintText: AppStrings.addDesc,
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
            minLines: 2,
            maxLines: 5,
          ),
          AppSizes.xs.ph,
          Text(AppStrings.chooseDateRange, style: AppTextStyles.overLine()),
          AppSizes.xxxs.ph,
          SizedBox(
            height: 0.3.sh,
            width: 0.8.sw,
            child: SfDateRangePicker(
              selectionMode: DateRangePickerSelectionMode.range,
            ),
          ),
          AppSizes.xs.ph,
          Text(AppStrings.maxParticipants, style: AppTextStyles.overLine()),
          AppSizes.xxxs.ph,
          TextFormField(
            decoration: InputDecoration(
              filled: true,
              fillColor: AppColors.darkBgContainer,
              hintText: "0",
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
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      AppStrings.firstPrize,
                      style: AppTextStyles.overLine(),
                    ),
                    AppSizes.xxxs.ph,
                    TextFormField(
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: AppColors.darkBgContainer,
                        hintText: "0",
                        hintStyle: AppTextStyles.button(
                          color: AppColors.skyBlue,
                        ),
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
                  ],
                ),
              ),
              AppSizes.xxxs.pw,
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      AppStrings.secondPrize,
                      style: AppTextStyles.overLine(),
                    ),
                    AppSizes.xxxs.ph,
                    TextFormField(
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: AppColors.darkBgContainer,
                        hintText: "0",
                        hintStyle: AppTextStyles.button(
                          color: AppColors.skyBlue,
                        ),
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
                  ],
                ),
              ),
              AppSizes.xxxs.pw,
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      AppStrings.thirdPrize,
                      style: AppTextStyles.overLine(),
                    ),
                    AppSizes.xxxs.ph,
                    TextFormField(
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: AppColors.darkBgContainer,
                        hintText: "0",
                        hintStyle: AppTextStyles.button(
                          color: AppColors.skyBlue,
                        ),
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
                  ],
                ),
              ),
            ],
          ),
          AppSizes.xs.ph,
          CheckboxListTile(
            value: false,
            onChanged: (val) {},
            controlAffinity: ListTileControlAffinity.leading,
            title: Text(
              AppStrings.paidChallenge,
              style: AppTextStyles.overLine().copyWith(
                fontWeight: AppFontWeights.bold,
              ),
            ),
          ),

          AppSizes.xs.ph,
          Text(AppStrings.challengeThumbnail, style: AppTextStyles.overLine()),
          AppSizes.xxxs.ph,
          Container(
            height: 0.2.sh,
            width: double.infinity,
            decoration: BoxDecoration(
              border: Border.all(
                color: AppColors.skyBlue.withValues(alpha: 0.5),
              ),
              borderRadius: BorderRadius.circular(AppSizes.xs),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                HugeIcon(
                  icon: HugeIconsStrokeRounded.image02,
                  color: AppColors.creamWhite,
                  size: 40,
                ),
                AppSizes.xs.ph,
                Text(
                  AppStrings.clickToUpload,
                  style: AppTextStyles.overLine(color: AppColors.creamWhite),
                ),
                Text(
                  "${AppStrings.fileType} (Max 5MB)",
                  style: AppTextStyles.caption2(
                    color: AppColors.white.withValues(alpha: 0.8),
                  ),
                ),
              ],
            ),
          ),
          AppSizes.xs.ph,

          AppButton(
            onPressed: () {},
            label: AppStrings.create,
            labelStyle: AppTextStyles.bodyText2(color: AppColors.white),
            bgColor: Colors.transparent,
            borderColor: AppColors.skyBlue.withValues(alpha: 0.5),
            radius: AppSizes.xxxs,
          ),
        ],
      ),
    );
  }
}
