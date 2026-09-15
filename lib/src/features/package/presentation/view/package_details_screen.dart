import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:larnity/src/core/constants/app_size.dart';
import 'package:larnity/src/core/extensions/extensions.dart';
import 'package:larnity/src/core/theme/app_colors.dart';
import 'package:larnity/src/core/theme/theme.dart';
import 'package:larnity/src/core/ui/widgets/app_button.dart';
import 'package:larnity/src/core/router/router.dart';
import 'package:larnity/src/features/auth/presentation/provider/auth_provider.dart';
import 'package:larnity/src/features/package/data/model/package_model.dart';
import 'package:larnity/src/features/package_subscription/data/model/package_subscription_model.dart';
import 'package:larnity/src/features/package_subscription/presentation/providers/package_subscription_provider.dart';

class PackageDetailsScreen extends ConsumerWidget {
  final PackageModel package;
  PackageDetailsScreen({required this.package, super.key});

  final String selectedPaymentMethod = 'UPI';

  final List<PaymentMethod> _paymentMethods = [
    PaymentMethod(name: 'UPI', icon: Icons.phone_android),
    PaymentMethod(name: 'Cards', icon: Icons.credit_card),
    PaymentMethod(name: 'Netbanking'),
    PaymentMethod(name: 'Wallets', icon: Icons.wallet),
    PaymentMethod(name: 'Bank Transfer', icon: Icons.account_balance_wallet),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final packageSubscriptionNotifier = ref.watch(
      packageSubscriptionProvider.notifier,
    );
    final user = ref.watch(authProvider).user;
    return Scaffold(
      body: Padding(
        padding: EdgeInsetsGeometry.symmetric(horizontal: AppSizes.xs),
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
                decoration: BoxDecoration(
                  border: Border.all(
                    color: AppColors.skyBlue.withValues(alpha: 0.5),
                  ),
                  borderRadius: BorderRadius.circular(AppSizes.xxxs),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(AppSizes.xs),
                      child: GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTap: () {
                          context.pop();
                        },
                        child: Row(
                          children: [
                            Icon(Icons.arrow_back_ios, size: 16),
                            Text(
                              "Change Package",
                              style: AppTextStyles.subtitle2(),
                            ),
                          ],
                        ),
                      ),
                    ),
                    // Selected Package Section
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: AppColors.skyBlue.withValues(alpha: 0.5),
                        ),
                        borderRadius: BorderRadius.circular(AppSizes.xxxs),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Selected Package: ${package.name}',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 8),
                          Text(
                            '${package.maxGroups} groups • ₹${package.monthlyPrice}/month',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                    AppSizes.xs.ph,

                    Container(
                      padding: EdgeInsets.all(AppSizes.xs),
                      decoration: BoxDecoration(
                        color: AppColors.bgBlue,
                        border: Border.all(
                          color: AppColors.skyBlue.withValues(alpha: 0.5),
                        ),
                        borderRadius: BorderRadius.circular(AppSizes.xxxs),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Select Payment Method',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 8),
                          Text(
                            'Choose your preferred payment method to complete your subscription charge ₹${package.monthlyPrice}',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[600],
                            ),
                          ),
                          AppSizes.xxxs.ph,
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: AppSizes.xxs,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.blue.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: AppColors.blue),
                            ),
                            child: Text(
                              "${package.isFree ? package.freeTrialDays : "30"} days validity",
                              style: AppTextStyles.bodyText1(
                                color: AppColors.blue,
                              ).copyWith(fontWeight: AppFontWeights.regular),
                            ),
                          ),
                          AppSizes.xs.ph,
                          Row(
                            children: [
                              Expanded(
                                child: TextField(
                                  decoration: InputDecoration(
                                    hintText: 'Enter promo code',
                                    border: OutlineInputBorder(
                                      borderSide: BorderSide.none,
                                      borderRadius: BorderRadius.circular(
                                        AppSizes.xxxs,
                                      ),
                                    ),
                                    fillColor: AppColors.creamWhite.withValues(
                                      alpha: 0.4,
                                    ),
                                    filled: true,
                                    hintStyle: TextStyle(
                                      color: Colors.grey[500],
                                    ),
                                  ),
                                ),
                              ),
                              AppSizes.xs.pw,
                              AppButton(
                                isExpanded: false,
                                onPressed: () {},
                                label: "Apply",
                                labelStyle: AppTextStyles.button(
                                  color: AppColors.bgBlue,
                                ),
                                bgColor: AppColors.creamWhite,
                              ),
                            ],
                          ),
                          AppSizes.xs.ph,
                          Container(
                            padding: EdgeInsets.all(AppSizes.xs),
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: AppColors.skyBlue.withValues(alpha: 0.5),
                              ),
                              borderRadius: BorderRadius.circular(
                                AppSizes.xxxs,
                              ),
                            ),
                            child: Column(
                              children: [
                                Row(
                                  children: [
                                    Icon(Icons.location_city_outlined),
                                    AppSizes.xs.pw,
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            "Cashfree Secure Payment",
                                            style: AppTextStyles.headline4(),
                                          ),
                                          Text(
                                            "Pay using UPI, cards, netbanking, wallets, or bank transfer",
                                            style: AppTextStyles.overLine(),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                AppSizes.xs.ph,
                                Wrap(
                                  spacing: AppSizes.xxxs,
                                  runSpacing: AppSizes.xxxs,
                                  children: _paymentMethods
                                      .map(
                                        (method) =>
                                            _buildPaymentMethodCard(method),
                                      )
                                      .toList(),
                                ),
                                AppSizes.xs.ph,
                                AppButton(
                                  onPressed: () {
                                    packageSubscriptionNotifier
                                        .createPackageSubscription(
                                          subscription: PackageSubscriptionModel(
                                            userId: user?.id ?? "",
                                            packageId: package.id,
                                            subscriptionStartDate:
                                                DateTime.now(),
                                            subscriptionEndDate: package.isFree
                                                ? DateTime.now().add(
                                                    Duration(
                                                      days:
                                                          package
                                                              .freeTrialDays ??
                                                          0,
                                                    ),
                                                  )
                                                : DateTime.now().add(
                                                    Duration(days: 30),
                                                  ),
                                            isActive: true,
                                          ),
                                          successCallBack: () {
                                            context.goNamed(
                                              Routes.packageSubscription,
                                            );
                                          },
                                        );
                                  },
                                  label: package.isFree
                                      ? "Enjoy without Payment"
                                      : "Pay & Enjoy",
                                  bgColor: AppColors.white,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPaymentMethodCard(PaymentMethod method) {
    return GestureDetector(
      onTap: () {},
      child: Container(
        height: 50,
        padding: EdgeInsets.symmetric(
          horizontal: AppSizes.xs,
          vertical: AppSizes.xxxs,
        ),
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.skyBlue, width: 1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (method.icon != null) ...[
              Icon(method.icon, size: 32),
              SizedBox(height: 4),
            ],

            Text(
              method.name,
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
            ),
          ],
        ),
      ),
    );
  }
}

class PaymentMethod {
  final String name;
  final IconData? icon;

  PaymentMethod({required this.name, this.icon});
}
