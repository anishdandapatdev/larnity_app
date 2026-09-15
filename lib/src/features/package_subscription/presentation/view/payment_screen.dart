import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:larnity/src/core/constants/app_size.dart';
import 'package:larnity/src/core/theme/app_colors.dart';
import 'package:larnity/src/core/theme/theme.dart';

class PaymentScreen extends ConsumerStatefulWidget {
  const PaymentScreen({super.key});

  @override
  ConsumerState<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends ConsumerState<PaymentScreen> {
  int _selectedPaymentMethod = 0; // 0 for Paymintro, 1 for Cashfree
  final TextEditingController _promoCodeController = TextEditingController();

  @override
  void dispose() {
    _promoCodeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Container(
        color: Colors.black54, // Dark overlay
        child: Stack(
          children: [
            // Blurred background
            BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 5.0, sigmaY: 5.0),
              child: Container(
                color: Colors.black.withValues(alpha: 0.5),
              ),
            ),
            // Center card
            Center(
              child: Container(
                margin: const EdgeInsets.all(AppSizes.lg),
                padding: const EdgeInsets.all(AppSizes.lg),
                decoration: BoxDecoration(
                  color: const Color(0xFF0C0F17), // Very dark navy background
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: AppColors.skyBlue.withValues(alpha: 0.3),
                  ),
                ),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header with close button
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Spacer(),
                          IconButton(
                            icon: const Icon(
                              Icons.close,
                              color: Colors.white,
                            ),
                            onPressed: () {
                              context.pop();
                            },
                          ),
                        ],
                      ),
                      // Title
                      Text(
                        "Payment",
                        style: AppTextStyles.headline1().copyWith(
                          color: AppColors.white,
                        ),
                      ),
                      const SizedBox(height: AppSizes.xs),
                      // Subtitle
                      Text(
                        "Complete your payment to join",
                        style: AppTextStyles.bodyText1().copyWith(
                          color: AppColors.skyBlue,
                        ),
                      ),
                      const SizedBox(height: AppSizes.xlg),
                      // Plan box
                      Container(
                        padding: const EdgeInsets.all(AppSizes.lg),
                        decoration: BoxDecoration(
                          color: AppColors.darkBgContainer,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: AppColors.skyBlue.withValues(alpha: 0.5),
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Lifetime Plan",
                              style: AppTextStyles.headline2().copyWith(
                                color: AppColors.white,
                              ),
                            ),
                            const SizedBox(height: AppSizes.xxxs),
                            Text(
                              "₹999 for Lifetime",
                              style: AppTextStyles.bodyText1().copyWith(
                                color: AppColors.skyBlue,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: AppSizes.lg),
                      // Promo code input
                      Text(
                        "Promo Code",
                        style: AppTextStyles.bodyText1().copyWith(
                          color: AppColors.white,
                        ),
                      ),
                      const SizedBox(height: AppSizes.xxxs),
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _promoCodeController,
                              style: AppTextStyles.bodyText1().copyWith(
                                color: AppColors.white,
                              ),
                              decoration: InputDecoration(
                                filled: true,
                                fillColor: AppColors.darkBgContainer,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide(
                                    color: AppColors.skyBlue.withValues(alpha: 0.5),
                                  ),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide(
                                    color: AppColors.skyBlue.withValues(alpha: 0.5),
                                  ),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide(
                                    color: AppColors.skyBlue,
                                  ),
                                ),
                                hintText: "Enter promo code",
                                hintStyle: AppTextStyles.bodyText1().copyWith(
                                  color: AppColors.skyBlue.withValues(alpha: 0.7),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: AppSizes.xs),
                          FilledButton(
                            onPressed: () {
                              // Apply promo code logic
                            },
                            style: FilledButton.styleFrom(
                              backgroundColor: AppColors.primaryOrange,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              padding: const EdgeInsets.symmetric(
                                horizontal: AppSizes.lg,
                                vertical: AppSizes.sm,
                              ),
                            ),
                            child: Text(
                              "Apply",
                              style: AppTextStyles.button().copyWith(
                                color: AppColors.black,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSizes.lg),
                      // Payment method tabs
                      Text(
                        "Payment Method",
                        style: AppTextStyles.bodyText1().copyWith(
                          color: AppColors.white,
                        ),
                      ),
                      const SizedBox(height: AppSizes.xxxs),
                      Row(
                        children: [
                          // Paymintro tab
                          Expanded(
                            child: GestureDetector(
                              onTap: () {
                                setState(() {
                                  _selectedPaymentMethod = 0;
                                });
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  vertical: AppSizes.sm,
                                ),
                                decoration: BoxDecoration(
                                  color: _selectedPaymentMethod == 0
                                      ? AppColors.purple
                                      : AppColors.darkBgContainer,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: AppColors.skyBlue.withValues(alpha: 0.5),
                                  ),
                                ),
                                child: Center(
                                  child: Text(
                                    "Paymintro",
                                    style: AppTextStyles.button().copyWith(
                                      color: AppColors.white,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: AppSizes.xs),
                          // Cashfree tab
                          Expanded(
                            child: GestureDetector(
                              onTap: () {
                                setState(() {
                                  _selectedPaymentMethod = 1;
                                });
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  vertical: AppSizes.sm,
                                ),
                                decoration: BoxDecoration(
                                  color: _selectedPaymentMethod == 1
                                      ? AppColors.purple
                                      : AppColors.darkBgContainer,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: AppColors.skyBlue.withValues(alpha: 0.5),
                                  ),
                                ),
                                child: Center(
                                  child: Text(
                                    "Cashfree",
                                    style: AppTextStyles.button().copyWith(
                                      color: AppColors.white,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSizes.lg),
                      // Total amount
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "Total Amount:",
                            style: AppTextStyles.headline2().copyWith(
                              color: AppColors.white,
                            ),
                          ),
                          Text(
                            "₹999.00",
                            style: AppTextStyles.headline2().copyWith(
                              color: AppColors.white,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSizes.xlg),
                      // Pay button
                      SizedBox(
                        width: double.infinity,
                        child: FilledButton(
                          onPressed: () {
                            // Payment logic
                          },
                          style: FilledButton.styleFrom(
                            backgroundColor: AppColors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            padding: const EdgeInsets.symmetric(
                              vertical: AppSizes.lg,
                            ),
                          ),
                          child: Text(
                            "Pay Securely with ${_selectedPaymentMethod == 0 ? "Paymintro" : "Cashfree"}",
                            style: AppTextStyles.button().copyWith(
                              color: AppColors.black,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: AppSizes.sm),
                      // Back button
                      Center(
                        child: TextButton(
                          onPressed: () {
                            context.pop();
                          },
                          child: Text(
                            "Back",
                            style: AppTextStyles.button().copyWith(
                              color: AppColors.skyBlue,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}