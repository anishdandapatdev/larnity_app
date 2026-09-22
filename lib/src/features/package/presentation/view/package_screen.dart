import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:larnity/src/core/constants/app_size.dart';
import 'package:larnity/src/core/extensions/extensions.dart';
import 'package:larnity/src/core/router/router.dart';
import 'package:larnity/src/core/theme/app_colors.dart';
import 'package:larnity/src/core/theme/theme.dart';
import 'package:larnity/src/core/utils/async_states.dart';
import 'package:larnity/src/features/package/presentation/provider/package_provider.dart';
import 'package:larnity/src/features/package/presentation/widgets/custom_plan_card.dart';
import 'package:larnity/src/features/package/presentation/widgets/plan_card.dart';
import 'package:larnity/src/features/package_subscription/presentation/providers/package_subscription_provider.dart';

class PackageScreen extends ConsumerWidget {
  const PackageScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final packageState = ref.watch(packageProvider);
    final packageSubscriptionState = ref.watch(packageSubscriptionProvider);
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.black,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.white),
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.goNamed(Routes.explore);
            }
          },
        ),
        title: const Text(
          'Packages',
          style: TextStyle(
            color: AppColors.white,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(AppSizes.xs),
        child: SingleChildScrollView(
          child: Column(
            children: [
              AppSizes.xlg.ph,
              Text(
                "Select plan. Pay. Done",
                style: AppTextStyles.headline1(),
                textAlign: TextAlign.center,
              ),
              AppSizes.xs.ph,
              Text(
                "Cancel anytime. All features. Unlimited everything. No hidden fees.",
                style: AppTextStyles.bodyText1(),
                textAlign: TextAlign.center,
              ),
              AppSizes.lg.ph,
              Container(
                padding: EdgeInsets.all(AppSizes.xs),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [AppColors.darkBrown, AppColors.darkBgContainer],
                  ),
                  borderRadius: BorderRadius.circular(AppSizes.xs),
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Text(
                          "Choose Your Package",
                          style: AppTextStyles.headline2(
                            color: AppColors.white,
                          ),
                        ),
                      ],
                    ),
                    AppSizes.xxxs.ph,
                    Text(
                      "Select the package that fits your needs. Upgrade anytime.",
                      style: AppTextStyles.overLine(color: AppColors.white),
                    ),
                    AppSizes.xxxlg.ph,
                    Builder(
                      builder: (context) {
                        if (packageState.state == AsyncState.loading) {
                          return Center(child: CircularProgressIndicator());
                        } else if (packageState.state == AsyncState.failure) {
                          return Center(
                            child: Text(
                              packageState.error ?? "Something went wrong",
                            ),
                          );
                        } else if (packageState.state == AsyncState.success &&
                            packageState.packages != null &&
                            packageState.packages!.isNotEmpty) {
                          return ListView.separated(
                            shrinkWrap: true,
                            physics: NeverScrollableScrollPhysics(),
                            itemBuilder: (context, index) {
                              final package = packageState.packages![index];
                              return PlanCard(
                                planName: package.name,
                                allowedGroupCreation: package.maxGroups,
                                perUnit: package.isFreeTrialPack
                                    ? "${package.freeTrialDays}"
                                    : "month",
                                price: package.monthlyPrice.toString(),
                                fakePrice: package.fakePrice?.toString(),
                                features: package.featureList,
                                buttonLabel:
                                    packageSubscriptionState
                                            .activeSubscription
                                            ?.packageId ==
                                        package.id
                                    ? "Current Plan"
                                    : "Get Started",
                                description: package.description,
                                isActive:
                                    packageSubscriptionState
                                        .activeSubscription
                                        ?.packageId ==
                                    package.id,
                                onPressed:
                                    packageSubscriptionState
                                            .activeSubscription
                                            ?.packageId !=
                                        package.id
                                    ? () {
                                        context.pushNamed(
                                          Routes.packageDetails,
                                          extra: package,
                                        );
                                      }
                                    : () {
                                        context.pushNamed(
                                          Routes.packageSubscription,
                                        );
                                      },
                              );
                            },
                            separatorBuilder: (context, index) =>
                                AppSizes.xs.ph,
                            itemCount: packageState.packages!.length,
                          );
                        } else {
                          return Center(child: Text("No package available"));
                        }
                      },
                    ),
                    AppSizes.xs.ph,
                    CustomPlanCard(
                      planName: "Need Custom Solution?",
                      isActive: false,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 60),
            ],
          ),
        ),
      ),
    );
  }
}
