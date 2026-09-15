import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:larnity/src/core/constants/app_size.dart';
import 'package:larnity/src/core/extensions/extensions.dart';
import 'package:larnity/src/core/theme/app_colors.dart';
import 'package:larnity/src/core/theme/theme.dart';
import 'package:larnity/src/core/ui/widgets/app_button.dart';
import 'package:larnity/src/features/package_subscription/presentation/providers/package_subscription_provider.dart';

class PlanCard extends ConsumerWidget {
  const PlanCard({
    super.key,
    required this.planName,
    required this.price,
    required this.perUnit,
    required this.buttonLabel,
    this.description,
    required this.allowedGroupCreation,
    this.isActive = false,
    this.onPressed,
  });

  final String planName;
  final String price;
  final String perUnit;
  final String buttonLabel;
  final String? description;
  final int allowedGroupCreation;
  final bool isActive;
  final void Function()? onPressed;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final packageSubscriptionState = ref.watch(packageSubscriptionProvider);
    return Container(
      padding: EdgeInsets.all(AppSizes.xs),
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.skyBlue.withValues(alpha: 0.5)),
        borderRadius: BorderRadius.circular(AppSizes.xxxs),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                planName,
                style: AppTextStyles.headline3(color: AppColors.white),
              ),
              if (isActive)
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: AppSizes.xxxs,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    border: Border.all(color: AppColors.green),
                    borderRadius: BorderRadius.circular(AppSizes.lg),
                  ),
                  child: Text(
                    "Active",
                    style: AppTextStyles.caption2(
                      color: AppColors.green,
                    ).copyWith(fontWeight: AppFontWeights.black),
                  ),
                ),
            ],
          ),
          AppSizes.lg.ph,
          RichText(
            text: TextSpan(
              children: [
                TextSpan(text: "₹ $price", style: AppTextStyles.headline1()),
                TextSpan(
                  text: "/$perUnit",
                  style: AppTextStyles.headline3(
                    color: AppColors.white.withValues(alpha: 0.5),
                  ),
                ),
              ],
            ),
          ),
          AppSizes.lg.ph,

          Text(
            "Create up to $allowedGroupCreation groups",
            style: AppTextStyles.headline3(color: AppColors.white),
          ),
          AppSizes.lg.ph,

          // ListView.separated(
          //   shrinkWrap: true,
          //   physics: NeverScrollableScrollPhysics(),
          //   itemBuilder: (context,index)=>Row(
          //   crossAxisAlignment: CrossAxisAlignment.start,
          //   children: [
          //     Icon(Icons.check),
          //     AppSizes.xxxs.pw,
          //     Expanded(
          //       child: Text(
          //         "Create and manage groups",
          //         style: AppTextStyles.overLine(),
          //       ),
          //     ),
          //   ],
          // ), separatorBuilder: (_,__)=> AppSizes.xs.ph, itemCount: 1,),

          // AppSizes.xs.ph,
          if (description != null)
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.check),
                AppSizes.xxxs.pw,
                Expanded(
                  child: Text(
                    description ?? "",
                    style: AppTextStyles.overLine(),
                  ),
                ),
              ],
            ),
          // AppSizes.xs.ph,
          // Row(
          //   crossAxisAlignment: CrossAxisAlignment.start,
          //   children: [
          //     Icon(Icons.check),
          //     AppSizes.xxxs.pw,
          //     Expanded(
          //       child: Text(
          //         "Create and maange channels",
          //         style: AppTextStyles.overLine(),
          //       ),
          //     ),
          //   ],
          // ),
          // AppSizes.xs.ph,
          // Row(
          //   crossAxisAlignment: CrossAxisAlignment.start,
          //   children: [
          //     Icon(Icons.check),
          //     AppSizes.xxxs.pw,
          //     Expanded(
          //       child: Text(
          //         "Manage channel members",
          //         style: AppTextStyles.overLine(),
          //       ),
          //     ),
          //   ],
          // ),
          // AppSizes.xs.ph,
          // Row(
          //   crossAxisAlignment: CrossAxisAlignment.start,
          //   children: [
          //     Icon(Icons.check),
          //     AppSizes.xxxs.pw,
          //     Expanded(
          //       child: Text(
          //         "Send and receive messages",
          //         style: AppTextStyles.overLine(),
          //       ),
          //     ),
          //   ],
          // ),
          AppSizes.lg.ph,
          AppButton(
            isLoading: packageSubscriptionState.isLoading,
            onPressed: onPressed,
            label: buttonLabel,
            labelStyle: AppTextStyles.bodyText2(),
            bgColor: AppColors.white,
            radius: AppSizes.xxxs,
          ),
        ],
      ),
    );
  }
}
