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
  @override
  void initState() {
    super.initState();
    widget.searchController?.addListener(_onSearchChanged);
  }

  @override
  void didUpdateWidget(ExploreGroupsWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.searchController != widget.searchController) {
      oldWidget.searchController?.removeListener(_onSearchChanged);
      widget.searchController?.addListener(_onSearchChanged);
    }
  }

  @override
  void dispose() {
    widget.searchController?.removeListener(_onSearchChanged);
    super.dispose();
  }

  void _onSearchChanged() {
    if (mounted) setState(() {});
  }

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

    return LayoutBuilder(
      builder: (context, constraints) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              height: AppSizes.lg,
            ), // Add top padding to account for app bar
            Center(
              child: Text(
                AppStrings.exploreGroups,
                style: AppTextStyles.headline1(),
              ),
            ),
            SizedBox(height: AppSizes.xxs),
            Center(
              child: Text(
                AppStrings.exploreGroupsDesc,
                style: AppTextStyles.bodyText2(),
                textAlign: TextAlign.center,
              ),
            ),
            SizedBox(height: AppSizes.xs),
            Center(
              child: AppButton(
                isExpanded: false,
                label: hasActivePackage && hasCreatedGroups
                    ? "Manage your package"
                    : "Create your own group",
                labelStyle: AppTextStyles.button(),
                bgColor: AppColors.white,
                suffix: const Icon(Icons.arrow_forward),
                onPressed: () {
                  if (hasActivePackage && hasCreatedGroups) {
                    context.pushNamed(Routes.packageSubscription);
                  } else {
                    context.pushNamed(Routes.package);
                  }
                },
                radius: 32,
                padding: EdgeInsets.symmetric(
                  horizontal: AppSizes.lg,
                ),
              ),
            ),
            SizedBox(height: AppSizes.lg),
            // Search bar
            Container(
              width: double.infinity,
              height: 50,
              padding: const EdgeInsets.symmetric(
                horizontal: 20,
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
                  const Icon(Icons.search, color: Colors.grey, size: 20),
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
                    ),
                  ),
                  if (widget.searchController != null &&
                      widget.searchController!.text.isNotEmpty)
                    GestureDetector(
                      onTap: () {
                        widget.searchController!.clear();
                      },
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: AppSizes.xxs),
                        child: const Icon(
                          Icons.close,
                          color: Colors.grey,
                          size: 18,
                        ),
                      ),
                    ),
                ],
              ),
            ),
            SizedBox(height: AppSizes.lg),
            // Modern horizontal categories filter section
            Text(
              "Search by Categories",
              style: AppTextStyles.headline5(
                color: AppColors.white,
              ).copyWith(fontWeight: AppFontWeights.bold),
            ),
            SizedBox(height: AppSizes.sm),
            // Horizontal scrollable categories
            SizedBox(
              height: 42,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                clipBehavior: Clip.none,
                itemCount: categories.length,
                separatorBuilder: (_, _) => SizedBox(width: AppSizes.xs),
                itemBuilder: (context, index) {
                  final category = categories[index];
                  return _buildCategoryButton(
                    context,
                    ref,
                    category,
                    groupState,
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }

  // Modern category chip button
  Widget _buildCategoryButton(
    BuildContext context,
    WidgetRef ref,
    Category category,
    dynamic groupState,
  ) {
    final groupNotifier = ref.read(groupProvider.notifier);
    final isSelected =
        (category.name == 'All' && groupState.selectedCategory == null) ||
        (groupState.selectedCategory?.name.toLowerCase() ==
            category.name.toLowerCase());

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(24),
        onTap: () {
          if (category.name == 'All') {
            groupNotifier.selectCategory(category: null);
          } else {
            if (isSelected) {
              groupNotifier.selectCategory(category: null);
            } else {
              groupNotifier.selectCategory(category: category);
            }
          }
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(
            horizontal: 14,
            vertical: 8,
          ),
          decoration: BoxDecoration(
            color: isSelected
                ? AppColors.primaryOrange.withValues(alpha: 0.15)
                : AppColors.darkBgContainer.withValues(alpha: 0.6),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: isSelected
                  ? AppColors.primaryOrange
                  : AppColors.borderBrown.withValues(alpha: 0.4),
              width: isSelected ? 1.5 : 1.0,
            ),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: AppColors.primaryOrange.withValues(alpha: 0.3),
                      blurRadius: 8,
                      spreadRadius: 1,
                    ),
                  ]
                : null,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              HugeIcon(
                icon: category.icon,
                size: 16,
                color: isSelected ? AppColors.primaryOrange : AppColors.white,
              ),
              const SizedBox(width: 6),
              Text(
                category.name,
                style: AppTextStyles.subtitle2(
                  color: isSelected ? AppColors.primaryOrange : AppColors.white,
                ).copyWith(
                  fontWeight: isSelected
                      ? AppFontWeights.bold
                      : AppFontWeights.regular,
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
