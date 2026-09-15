import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:larnity/src/core/constants/app_size.dart';
import 'package:larnity/src/core/router/router.dart';
import 'package:larnity/src/core/theme/app_colors.dart';
import 'package:larnity/src/core/theme/theme.dart';

class ChoosePlanScreen extends ConsumerWidget {
  const ChoosePlanScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Container(
        color: Colors.black54, // Dark overlay
        child: Stack(
          children: [
            // Blurred background
            BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 5.0, sigmaY: 5.0),
              child: Container(color: Colors.black.withValues(alpha: 0.5)),
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
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Header with close button
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Spacer(),
                        IconButton(
                          icon: const Icon(Icons.close, color: Colors.white),
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text("Coming Soon!"),
                                behavior: SnackBarBehavior.floating,
                                backgroundColor: AppColors.primaryOrange,
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                    // Title
                    Text(
                      "Choose a plan",
                      style: AppTextStyles.headline1().copyWith(
                        color: AppColors.white,
                      ),
                    ),
                    const SizedBox(height: AppSizes.xs),
                    // Subtitle
                    Text(
                      "Select a plan to join this community",
                      style: AppTextStyles.bodyText1().copyWith(
                        color: AppColors.skyBlue,
                      ),
                    ),
                    const SizedBox(height: AppSizes.xlg),
                    // Pricing box
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
                        children: [
                          Text(
                            "Lifetime",
                            style: AppTextStyles.headline2().copyWith(
                              color: AppColors.white,
                            ),
                          ),
                          const SizedBox(height: AppSizes.xs),
                          Text(
                            "₹999",
                            style: AppTextStyles.headline1().copyWith(
                              color: AppColors.white,
                            ),
                          ),
                          const SizedBox(height: AppSizes.xxxs),
                          Text(
                            "One-time payment, access forever",
                            style: AppTextStyles.caption().copyWith(
                              color: AppColors.skyBlue,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: AppSizes.xlg),
                    // Continue button
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton(
                        onPressed: () {
                          // Navigate to payment screen
                          context.pushNamed(Routes.payment);
                        },
                        style: FilledButton.styleFrom(
                          backgroundColor: AppColors.primaryOrange,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          padding: const EdgeInsets.symmetric(
                            vertical: AppSizes.lg,
                          ),
                        ),
                        child: Text(
                          "Continue",
                          style: AppTextStyles.button().copyWith(
                            color: AppColors.black,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
