// ignore_for_file: invalid_use_of_visible_for_testing_member

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:hugeicons/hugeicons.dart'; // HugeIcons import
import 'package:larnity/src/core/constants/app_size.dart';
import 'package:larnity/src/core/constants/app_strings.dart';
import 'package:larnity/src/core/router/router.dart';
import 'package:larnity/src/core/theme/app_colors.dart';
import 'package:larnity/src/core/theme/theme.dart';
import 'package:larnity/src/core/ui/widgets/app_button.dart';
import 'package:larnity/src/core/utils/async_states.dart';
import 'package:larnity/src/features/auth/presentation/provider/auth_provider.dart';
import 'package:larnity/src/features/explore/domain/category.dart';
import 'package:larnity/src/features/group/presentation/provider/group_provider.dart';
import 'package:larnity/src/features/package/presentation/provider/package_provider.dart';
import 'package:larnity/src/features/package_subscription/presentation/providers/package_subscription_provider.dart';

class ExploreGroupsWidget extends ConsumerStatefulWidget {
  final TextEditingController? searchController;

  const ExploreGroupsWidget({super.key, this.searchController});

  @override
  ConsumerState<ExploreGroupsWidget> createState() =>
      _ExploreGroupsWidgetState();
}

class _ExploreGroupsWidgetState extends ConsumerState<ExploreGroupsWidget> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    // Watch package and group states to determine button behavior
    final packageState = ref.watch(packageProvider);
    final packageSubscriptionState = ref.watch(packageSubscriptionProvider);
    final groupState = ref.watch(groupProvider);
    final authState = ref.watch(authProvider);

    // Check if user has an active package
    final hasActivePackage =
        packageState.state == AsyncState.success &&
        packageSubscriptionState.state == AsyncState.success &&
        packageSubscriptionState.activeSubscription != null;

    // Check if user has created any groups (owns at least one group)
    final hasCreatedGroups =
        groupState.fetchState == AsyncState.success &&
        groupState.groups != null &&
        groupState.groups!.isNotEmpty &&
        groupState.groups!.any((group) => group.userId == authState.user?.id);

    // Define primary and secondary categories
    // Primary: All, Fitness, Business, Personal Development, Lifestyle & Habits (5 categories)
    // Secondary: The rest (12 categories)
    final primaryCategories = categories.take(5).toList();
    final secondaryCategories = categories.skip(5).toList();

    return LayoutBuilder(
      builder: (context, constraints) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              height: AppSizes.lg,
            ), // Add top padding to account for app bar
            Text(AppStrings.exploreGroups, style: AppTextStyles.headline1()),
            SizedBox(height: AppSizes.xxs), // Reduced spacing
            Text(
              AppStrings.exploreGroupsDesc,
              style: AppTextStyles.bodyText2(),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: AppSizes.xs), // Reduced spacing
            AppButton(
              isExpanded: false,
              label: hasActivePackage && hasCreatedGroups
                  ? "Manage your package"
                  : "Create your own group",
              labelStyle: AppTextStyles.button(),
              bgColor: AppColors.white,
              suffix: const Icon(Icons.arrow_forward),
              onPressed: () {
                if (hasActivePackage && hasCreatedGroups) {
                  // Navigate to package subscription screen to manage package
                  context.pushNamed(Routes.packageSubscription);
                } else {
                  // Navigate to package selection screen
                  context.pushNamed(Routes.package);
                }
              },
              radius: 32,
              padding: EdgeInsets.symmetric(
                horizontal: AppSizes.lg,
              ), // Reduced padding
            ),
            SizedBox(height: AppSizes.lg), // Reduced spacing
            // Simple narrow wide search bar
            Container(
              width: double.infinity,
              height: 50,
              padding: EdgeInsets.symmetric(
                horizontal: 20,
                // vertical: AppSizes.xs,
              ),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(AppSizes.sm),
                border: Border.all(
                  color: AppColors.borderBrown.withValues(alpha: 0.5),
                  width: 1,
                ),
                color: AppColors.darkBg.withValues(alpha: 0.5),
              ),
              child: Row(
                children: [
                  Icon(Icons.search, color: Colors.grey, size: 20),
                  SizedBox(width: AppSizes.xs),
                  Expanded(
                    child: TextFormField(
                      controller: widget.searchController,
                      decoration: InputDecoration(
                        hintText: "Search groups...",
                        hintStyle: AppTextStyles.overLine(
                          color: AppColors.skyBlue,
                        ),
                        border: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        contentPadding: EdgeInsets.zero,
                      ),
                      style: AppTextStyles.overLine(),
                      onChanged: (value) {
                        setState(() {});
                      },
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: AppSizes.lg),
            // Enhanced category section
            Text(
              "Search by Categories",
              style: AppTextStyles.headline5(
                color: AppColors.white,
              ).copyWith(fontWeight: AppFontWeights.bold),
            ),
            SizedBox(height: AppSizes.md),
            // Primary categories (always visible)
            Wrap(
              spacing: AppSizes.xs,
              runSpacing: AppSizes.xs,
              alignment: WrapAlignment.center,
              children: primaryCategories
                  .map((c) => _buildCategoryButton(context, ref, c, groupState))
                  .toList(),
            ),
            // Secondary categories (visible when expanded)
            if (_isExpanded) ...[
              SizedBox(height: AppSizes.xs),
              Wrap(
                spacing: AppSizes.xs,
                runSpacing: AppSizes.xs,
                alignment: WrapAlignment.center,
                children: secondaryCategories
                    .map(
                      (c) => _buildCategoryButton(context, ref, c, groupState),
                    )
                    .toList(),
              ),
            ],
            SizedBox(height: AppSizes.xs),
            // Show More/Less button
            TextButton(
              onPressed: () {
                setState(() {
                  _isExpanded = !_isExpanded;
                });
              },
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    _isExpanded ? "Show Less" : "Show More",
                    style: AppTextStyles.bodyText1(color: AppColors.white),
                  ),
                  Icon(
                    _isExpanded
                        ? Icons.keyboard_arrow_up
                        : Icons.keyboard_arrow_down,
                    color: AppColors.white,
                    size: 16,
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  // Custom category button with enhanced styling
  Widget _buildCategoryButton(
    BuildContext context,
    WidgetRef ref,
    Category category,
    dynamic groupState,
  ) {
    final groupNotifier = ref.read(groupProvider.notifier);
    final isSelected =
        groupState.selectedCategory == category ||
        (category.name == 'All' && groupState.selectedCategory == null);

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppSizes.xs),
        boxShadow: [
          if (isSelected)
            BoxShadow(
              color: AppColors.primaryOrange.withValues(alpha: 0.3),
              blurRadius: 8,
              spreadRadius: 1,
            ),
        ],
      ),
      child: AppButton(
        isExpanded: false,
        label: category.name,
        labelStyle:
            AppTextStyles.subtitle2(
              color: isSelected ? AppColors.primaryOrange : AppColors.white,
            ).copyWith(
              fontWeight: isSelected
                  ? AppFontWeights.bold
                  : AppFontWeights.regular,
            ),
        bgColor: isSelected
            ? AppColors.primaryOrange.withValues(alpha: 0.1)
            : AppColors.darkBgContainer.withValues(alpha: 0.3),
        borderColor: isSelected
            ? AppColors.primaryOrange
            : AppColors.borderBrown.withValues(alpha: 0.3),
        borderWidth: isSelected ? 1.5 : 1.0,
        prefix: HugeIcon(
          icon: category.icon,
          size: 18,
          color: isSelected ? AppColors.primaryOrange : AppColors.white,
        ),
        radius: AppSizes.xs,
        padding: EdgeInsets.symmetric(
          horizontal: AppSizes.sm,
          vertical: AppSizes.xxxs,
        ),
        onPressed: () {
          // Select the category or clear selection for "All"
          if (category.name == 'All') {
            // Clear the selected category when "All" is selected
            // ignore: invalid_use_of_protected_member
            groupNotifier.state = groupNotifier.state.copyWith(
              selectedCategory: null,
            );
          } else {
            // Select the category and ensure "All" is deselected
            groupNotifier.selectCategory(category: category);
          }
        },
      ),
    );
  }
}
