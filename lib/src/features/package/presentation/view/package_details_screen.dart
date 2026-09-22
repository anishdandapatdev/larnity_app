import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:larnity/src/core/constants/app_size.dart';
import 'package:larnity/src/core/extensions/extensions.dart';
import 'package:larnity/src/core/router/router.dart';
import 'package:larnity/src/core/service/supabase/src/supabase_provider.dart';
import 'package:larnity/src/core/theme/app_colors.dart';
import 'package:larnity/src/core/theme/theme.dart';
import 'package:larnity/src/core/ui/widgets/app_button.dart';
import 'package:larnity/src/core/utils/show_snackbar.dart';
import 'package:larnity/src/features/auth/presentation/provider/auth_provider.dart';
import 'package:larnity/src/features/package/data/model/package_model.dart';
import 'package:larnity/src/features/package_subscription/data/model/package_subscription_model.dart';
import 'package:larnity/src/features/package_subscription/presentation/providers/package_subscription_provider.dart';

class PackageDetailsScreen extends ConsumerStatefulWidget {
  final PackageModel package;
  const PackageDetailsScreen({required this.package, super.key});

  @override
  ConsumerState<PackageDetailsScreen> createState() =>
      _PackageDetailsScreenState();
}

class _PackageDetailsScreenState extends ConsumerState<PackageDetailsScreen> {
  String _selectedPaymentMethod = 'UPI';
  final TextEditingController _promoCodeController = TextEditingController();
  bool _isVerifyingPromo = false;
  Map<String, dynamic>? _appliedPromo;
  String? _promoError;
  bool _isSubmitting = false;

  final List<PaymentMethod> _paymentMethods = [
    PaymentMethod(name: 'UPI', icon: Icons.phone_android),
    PaymentMethod(name: 'Cards', icon: Icons.credit_card),
    PaymentMethod(name: 'Netbanking', icon: Icons.account_balance),
    PaymentMethod(name: 'Wallets', icon: Icons.account_balance_wallet_outlined),
    PaymentMethod(name: 'Bank Transfer', icon: Icons.receipt_long_outlined),
  ];

  @override
  void dispose() {
    _promoCodeController.dispose();
    super.dispose();
  }

  Future<void> _applyPromoCode() async {
    final code = _promoCodeController.text.trim();
    if (code.isEmpty) {
      setState(() => _promoError = "Please enter a promo code");
      return;
    }

    setState(() {
      _isVerifyingPromo = true;
      _promoError = null;
    });

    try {
      final client = ref.read(supabaseClientProvider);
      final response = await client
          .from('PromoCode')
          .select()
          .ilike('code', code)
          .eq('isActive', true)
          .maybeSingle();

      if (response == null) {
        setState(() {
          _promoError = "Invalid or expired promo code";
          _isVerifyingPromo = false;
        });
        showErrorToast(content: "Invalid or expired promo code");
        return;
      }

      final maxUses = (response['maxUses'] as num?)?.toInt() ?? 0;
      final currentUses = (response['currentUses'] as num?)?.toInt() ?? 0;

      if (maxUses > 0 && currentUses >= maxUses) {
        setState(() {
          _promoError = "Promo code usage limit has been reached";
          _isVerifyingPromo = false;
        });
        showErrorToast(content: "Promo code limit reached");
        return;
      }

      final discountRate = (response['discountRate'] as num?)?.toInt() ?? 0;

      setState(() {
        _appliedPromo = response;
        _isVerifyingPromo = false;
        _promoError = null;
      });

      showSuccessToast(
        content: "Promo '$code' applied! $discountRate% discount saved.",
      );
    } catch (e) {
      setState(() {
        _promoError = "Error verifying promo code";
        _isVerifyingPromo = false;
      });
      showErrorToast(content: "Failed to apply promo code");
    }
  }

  void _removePromoCode() {
    setState(() {
      _appliedPromo = null;
      _promoCodeController.clear();
      _promoError = null;
    });
    showInfoToast(content: "Promo code removed");
  }

  int get _calculatedDiscount {
    if (_appliedPromo == null) return 0;
    final discountRate =
        (_appliedPromo!['discountRate'] as num?)?.toInt() ?? 0;
    return ((widget.package.monthlyPrice * discountRate) / 100).round();
  }

  int get _finalPrice {
    final price = widget.package.monthlyPrice - _calculatedDiscount;
    return price < 0 ? 0 : price;
  }

  Future<void> _handleSubscription() async {
    final user = ref.read(authProvider).user;
    final userId = user?.id;
    if (userId == null || userId.isEmpty) {
      showErrorToast(content: "Please sign in to proceed with subscription");
      return;
    }

    if (_isSubmitting) return;

    setState(() => _isSubmitting = true);

    final notifier = ref.read(packageSubscriptionProvider.notifier);

    final now = DateTime.now();
    final endDate = widget.package.isFree
        ? now.add(Duration(days: widget.package.freeTrialDays ?? 30))
        : now.add(const Duration(days: 30));

    await notifier.createPackageSubscription(
      subscription: PackageSubscriptionModel(
        userId: userId,
        packageId: widget.package.id,
        subscriptionStartDate: now,
        subscriptionEndDate: endDate,
        isActive: true,
        totalGroupsCreated: 0,
      ),
      successCallBack: () async {
        if (_appliedPromo != null && _appliedPromo!['id'] != null) {
          try {
            final client = ref.read(supabaseClientProvider);
            final currentUses =
                (_appliedPromo!['currentUses'] as num?)?.toInt() ?? 0;
            await client
                .from('PromoCode')
                .update({'currentUses': currentUses + 1})
                .eq('id', _appliedPromo!['id']);
          } catch (_) {}
        }

        if (mounted) {
          setState(() => _isSubmitting = false);
          showSuccessToast(
            content: "${widget.package.name} activated successfully!",
          );
          context.goNamed(Routes.packageSubscription);
        }
      },
      failureCallBack: (error) {
        if (mounted) {
          setState(() => _isSubmitting = false);
          showErrorToast(content: error);
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final packageSubscriptionState = ref.watch(packageSubscriptionProvider);
    final isLoading = _isSubmitting || packageSubscriptionState.isLoading;

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppSizes.xs),
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
                        onTap: () => context.pop(),
                        child: Row(
                          children: [
                            const Icon(Icons.arrow_back_ios, size: 16),
                            const SizedBox(width: 4),
                            Text(
                              "Change Package",
                              style: AppTextStyles.subtitle2(),
                            ),
                          ],
                        ),
                      ),
                    ),
                    // Selected Package Summary Card
                    Container(
                      width: double.infinity,
                      margin: const EdgeInsets.symmetric(
                        horizontal: AppSizes.xs,
                      ),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.darkBrown.withValues(alpha: 0.2),
                        border: Border.all(
                          color: AppColors.skyBlue.withValues(alpha: 0.5),
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
                                widget.package.name,
                                style: AppTextStyles.headline3(
                                  color: AppColors.white,
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: AppSizes.xxs,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.blue.withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(color: AppColors.blue),
                                ),
                                child: Text(
                                  "${widget.package.isFree ? widget.package.freeTrialDays : "30"} days validity",
                                  style: AppTextStyles.caption2(
                                    color: AppColors.blue,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '${widget.package.maxGroups} ${widget.package.maxGroups == 1 ? 'group' : 'groups'} allowed • ₹${widget.package.monthlyPrice}/month',
                            style: AppTextStyles.bodyText2(
                              color: AppColors.white.withValues(alpha: 0.7),
                            ),
                          ),
                        ],
                      ),
                    ),
                    AppSizes.xs.ph,

                    // Payment & Checkout Container
                    Container(
                      margin: const EdgeInsets.all(AppSizes.xs),
                      padding: const EdgeInsets.all(AppSizes.xs),
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
                            'Payment Details',
                            style: AppTextStyles.headline2(
                              color: AppColors.white,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'Complete your subscription securely via Cashfree.',
                            style: AppTextStyles.bodyText2(
                              color: AppColors.white.withValues(alpha: 0.7),
                            ),
                          ),
                          AppSizes.sm.ph,

                          // Promo Code Input / Applied Card
                          if (_appliedPromo == null) ...[
                            Row(
                              children: [
                                Expanded(
                                  child: TextField(
                                    controller: _promoCodeController,
                                    textCapitalization:
                                        TextCapitalization.characters,
                                    style: const TextStyle(
                                      color: AppColors.white,
                                    ),
                                    decoration: InputDecoration(
                                      hintText: 'Enter promo code',
                                      border: OutlineInputBorder(
                                        borderSide: BorderSide.none,
                                        borderRadius: BorderRadius.circular(
                                          AppSizes.xxxs,
                                        ),
                                      ),
                                      fillColor: AppColors.darkBgContainer
                                          .withValues(alpha: 0.8),
                                      filled: true,
                                      hintStyle: TextStyle(
                                        color: Colors.grey[400],
                                      ),
                                      contentPadding:
                                          const EdgeInsets.symmetric(
                                            horizontal: 12,
                                            vertical: 10,
                                          ),
                                    ),
                                  ),
                                ),
                                AppSizes.xs.pw,
                                AppButton(
                                  isExpanded: false,
                                  isLoading: _isVerifyingPromo,
                                  onPressed: _applyPromoCode,
                                  label: "Apply",
                                  labelStyle: AppTextStyles.button(
                                    color: AppColors.bgBlue,
                                  ),
                                  bgColor: AppColors.creamWhite,
                                ),
                              ],
                            ),
                            if (_promoError != null) ...[
                              const SizedBox(height: 6),
                              Text(
                                _promoError!,
                                style: const TextStyle(
                                  color: AppColors.red,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ] else ...[
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 10,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.green.withValues(alpha: 0.15),
                                border: Border.all(color: AppColors.green),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                children: [
                                  const Icon(
                                    Icons.verified,
                                    color: AppColors.green,
                                    size: 20,
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      "Code '${_appliedPromo!['code']}': ${_appliedPromo!['discountRate']}% discount applied",
                                      style: AppTextStyles.bodyText2(
                                        color: AppColors.green,
                                      ),
                                    ),
                                  ),
                                  IconButton(
                                    icon: const Icon(
                                      Icons.close,
                                      color: AppColors.white,
                                      size: 18,
                                    ),
                                    onPressed: _removePromoCode,
                                    visualDensity: VisualDensity.compact,
                                  ),
                                ],
                              ),
                            ),
                          ],
                          AppSizes.md.ph,

                          // Payment Methods Selector
                          Text(
                            "Select Payment Method",
                            style: AppTextStyles.headline4(
                              color: AppColors.white,
                            ),
                          ),
                          AppSizes.xxxs.ph,
                          Text(
                            "UPI, Credit/Debit Cards, Netbanking, or Wallets",
                            style: AppTextStyles.overLine(
                              color: AppColors.white.withValues(alpha: 0.6),
                            ),
                          ),
                          AppSizes.xs.ph,
                          Wrap(
                            spacing: AppSizes.xxxs,
                            runSpacing: AppSizes.xxxs,
                            children: _paymentMethods
                                .map(
                                  (method) => _buildPaymentMethodCard(method),
                                )
                                .toList(),
                          ),
                          AppSizes.md.ph,

                          // Price Breakdown Card
                          Container(
                            padding: const EdgeInsets.all(AppSizes.xs),
                            decoration: BoxDecoration(
                              color: AppColors.darkBgContainer.withValues(
                                alpha: 0.5,
                              ),
                              borderRadius: BorderRadius.circular(
                                AppSizes.xxxs,
                              ),
                              border: Border.all(
                                color: AppColors.skyBlue.withValues(alpha: 0.3),
                              ),
                            ),
                            child: Column(
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      "Plan Price",
                                      style: AppTextStyles.bodyText2(
                                        color: AppColors.white.withValues(
                                          alpha: 0.8,
                                        ),
                                      ),
                                    ),
                                    Text(
                                      "₹${widget.package.monthlyPrice}",
                                      style: AppTextStyles.bodyText2(
                                        color: AppColors.white,
                                      ),
                                    ),
                                  ],
                                ),
                                if (_appliedPromo != null) ...[
                                  const SizedBox(height: 6),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        "Promo Discount (${_appliedPromo!['discountRate']}%)",
                                        style: AppTextStyles.bodyText2(
                                          color: AppColors.green,
                                        ),
                                      ),
                                      Text(
                                        "- ₹$_calculatedDiscount",
                                        style: AppTextStyles.bodyText2(
                                          color: AppColors.green,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                                const Divider(
                                  color: AppColors.skyBlue,
                                  thickness: 0.5,
                                  height: 16,
                                ),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      "Total Payable",
                                      style: AppTextStyles.headline3(
                                        color: AppColors.white,
                                      ),
                                    ),
                                    Text(
                                      "₹$_finalPrice",
                                      style: AppTextStyles.headline2(
                                        color: AppColors.white,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          AppSizes.md.ph,

                          // Action Checkout Button
                          AppButton(
                            isLoading: isLoading,
                            onPressed: _handleSubscription,
                            label: widget.package.isFree || _finalPrice == 0
                                ? "Activate Free Subscription"
                                : "Pay ₹$_finalPrice with $_selectedPaymentMethod",
                            labelStyle: AppTextStyles.button(
                              color: AppColors.darkBrown,
                            ),
                            bgColor: AppColors.white,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              AppSizes.xlg.ph,
              const SizedBox(height: 60),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPaymentMethodCard(PaymentMethod method) {
    final isSelected = _selectedPaymentMethod == method.name;
    return GestureDetector(
      onTap: () => setState(() => _selectedPaymentMethod = method.name),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        height: 48,
        padding: const EdgeInsets.symmetric(
          horizontal: AppSizes.xs,
          vertical: AppSizes.xxxs,
        ),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.skyBlue.withValues(alpha: 0.25)
              : AppColors.darkBgContainer.withValues(alpha: 0.3),
          border: Border.all(
            color: isSelected ? AppColors.skyBlue : Colors.transparent,
            width: 1.5,
          ),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (method.icon != null) ...[
              Icon(
                method.icon,
                size: 22,
                color: isSelected ? AppColors.skyBlue : AppColors.white,
              ),
              const SizedBox(width: 8),
            ],
            Text(
              method.name,
              style: TextStyle(
                fontSize: 13,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                color: isSelected ? AppColors.skyBlue : AppColors.white,
              ),
            ),
            if (isSelected) ...[
              const SizedBox(width: 6),
              const Icon(Icons.check_circle, color: AppColors.skyBlue, size: 14),
            ],
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
