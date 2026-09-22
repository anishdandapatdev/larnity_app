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
    this.fakePrice,
    required this.perUnit,
    required this.buttonLabel,
    this.description,
    required this.allowedGroupCreation,
    this.features = const [],
    this.isActive = false,
    this.onPressed,
  });

  final String planName;
  final String price;
  final String? fakePrice;
  final String perUnit;
  final String buttonLabel;
  final String? description;
  final int allowedGroupCreation;
  final List<String> features;
  final bool isActive;
  final void Function()? onPressed;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final packageSubscriptionState = ref.watch(packageSubscriptionProvider);

    final num? currentPriceNum = num.tryParse(price);
    final num? fakePriceNum = fakePrice != null ? num.tryParse(fakePrice!) : null;
    final bool hasDiscount = fakePriceNum != null &&
        currentPriceNum != null &&
        fakePriceNum > currentPriceNum;
    final int discountPercentage = hasDiscount
        ? (((fakePriceNum - currentPriceNum) / fakePriceNum) * 100).round()
        : 0;

    return Container(
      padding: const EdgeInsets.all(AppSizes.xs),
      decoration: BoxDecoration(
        color: isActive
            ? AppColors.darkBrown.withValues(alpha: 0.3)
            : AppColors.darkBgContainer.withValues(alpha: 0.4),
        border: Border.all(
          color: isActive
              ? AppColors.green
              : AppColors.skyBlue.withValues(alpha: 0.5),
          width: isActive ? 1.5 : 1.0,
        ),
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
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSizes.xxxs,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.green.withValues(alpha: 0.15),
                    border: Border.all(color: AppColors.green),
                    borderRadius: BorderRadius.circular(AppSizes.lg),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.check, color: AppColors.green, size: 14),
                      const SizedBox(width: 4),
                      Text(
                        "Active Plan",
                        style: AppTextStyles.caption2(
                          color: AppColors.green,
                        ).copyWith(fontWeight: AppFontWeights.black),
                      ),
                    ],
                  ),
                ),
            ],
          ),
          AppSizes.sm.ph,
          Wrap(
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 8,
            children: [
              RichText(
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: "₹ $price",
                      style: AppTextStyles.headline1(),
                    ),
                    TextSpan(
                      text: "/$perUnit",
                      style: AppTextStyles.headline3(
                        color: AppColors.white.withValues(alpha: 0.5),
                      ),
                    ),
                  ],
                ),
              ),
              if (hasDiscount) ...[
                Text(
                  "₹ $fakePrice",
                  style: AppTextStyles.headline4(
                    color: AppColors.white.withValues(alpha: 0.4),
                  ).copyWith(decoration: TextDecoration.lineThrough),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppColors.primaryOrange.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(color: AppColors.primaryOrange, width: 0.8),
                  ),
                  child: Text(
                    "$discountPercentage% OFF",
                    style: AppTextStyles.caption2(
                      color: AppColors.primaryOrange,
                    ).copyWith(fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ],
          ),
          AppSizes.sm.ph,
          Text(
            "Create up to $allowedGroupCreation ${allowedGroupCreation == 1 ? 'group' : 'groups'}",
            style: AppTextStyles.headline4(color: AppColors.white),
          ),
          if (description != null && description!.trim().isNotEmpty) ...[
            AppSizes.xxxs.ph,
            Text(
              description!,
              style: AppTextStyles.overLine(
                color: AppColors.white.withValues(alpha: 0.7),
              ),
            ),
          ],
          if (features.isNotEmpty) ...[
            AppSizes.sm.ph,
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: features.length,
              separatorBuilder: (context, index) => AppSizes.xxxs.ph,
              itemBuilder: (context, index) => Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(
                    Icons.check_circle_outline,
                    color: AppColors.skyBlue,
                    size: 16,
                  ),
                  AppSizes.xxxs.pw,
                  Expanded(
                    child: Text(
                      features[index],
                      style: AppTextStyles.overLine(
                        color: AppColors.white.withValues(alpha: 0.9),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
          AppSizes.md.ph,
          AppButton(
            isLoading: packageSubscriptionState.isLoading,
            onPressed: onPressed,
            label: buttonLabel,
            labelStyle: AppTextStyles.bodyText2(
              color: isActive ? AppColors.white : AppColors.darkBrown,
            ),
            bgColor: isActive ? Colors.transparent : AppColors.white,
            radius: AppSizes.xxxs,
          ),
        ],
      ),
    );
  }
}
