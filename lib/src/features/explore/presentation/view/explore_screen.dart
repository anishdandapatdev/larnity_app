import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:larnity/src/core/constants/app_size.dart';
import 'package:larnity/src/core/extensions/extensions.dart';
import 'package:larnity/src/core/extensions/screen_size_extension.dart';
import 'package:larnity/src/core/theme/app_colors.dart';
import 'package:larnity/src/core/theme/theme.dart';
import 'package:larnity/src/features/explore/presentation/state/cubit/explore_group_provider.dart';
import 'package:larnity/src/features/explore/presentation/widgets/explore_groups_widget.dart';
import 'package:larnity/src/features/explore/presentation/widgets/group_card.dart';
import 'package:larnity/src/features/group/presentation/provider/group_provider.dart';
import 'package:larnity/src/features/group/data/models/group_model.dart';
import 'package:larnity/src/features/auth/presentation/provider/auth_provider.dart';
import 'package:larnity/src/core/utils/async_states.dart';

class ExploreScreen extends ConsumerStatefulWidget {
  ExploreScreen({super.key});

  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  ConsumerState<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends ConsumerState<ExploreScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Fetch groups for the current user when the screen loads
    Future.microtask(() {
      final userId = ref.read(authProvider).user?.id ?? "";
      if (userId.isNotEmpty) {
        ref.read(groupProvider.notifier).getGroupsByUser(userId: userId);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // Watch the explore group expanded state
    final isExpanded = ref.watch(exploreGroupExpandedProvider);

    // final packageState = ref.watch(packageProvider);
    // final packageSubscriptionState = ref.watch(packageSubscriptionProvider);
    final groupState = ref.watch(groupProvider);

    // Get the search text
    final searchText = _searchController.text.toLowerCase();

    // Start with all groups
    List<GroupModel> filteredGroups = groupState.groups ?? [];

    // Apply search filter first
    if (searchText.isNotEmpty) {
      filteredGroups = filteredGroups.where((group) {
        return group.name.toLowerCase().contains(searchText) ||
            (group.description ?? '').toLowerCase().contains(searchText) ||
            (group.category ?? '').toLowerCase().contains(searchText);
      }).toList();
    }

    // Apply category filter - this should work with the actual group categories
    if (groupState.selectedCategory != null &&
        groupState.selectedCategory!.name != 'All') {
      final selectedCategoryName = groupState.selectedCategory!.name
          .toLowerCase();
      filteredGroups = filteredGroups
          .where(
            (group) =>
                group.category != null &&
                group.category!.toLowerCase() == selectedCategoryName,
          )
          .toList();
    }

    return Scaffold(
      key: widget.scaffoldKey,
      backgroundColor: AppColors.black,
      body: Container(
        decoration: BoxDecoration(
          gradient: RadialGradient(
            colors: [
              AppColors.darkBrown.withValues(alpha: 0.3),
              AppColors.black,
            ],
            center: Alignment.topCenter,
            radius: 1.2,
          ),
        ),
        child: CustomScrollView(
          slivers: [
            SliverAppBar(
              expandedHeight: isExpanded
                  ? 1.5.sh
                  : 0.6.sh, // Even more height to ensure all content fits
              floating: false,
              pinned: true,
              backgroundColor: Colors.transparent,
              flexibleSpace: FlexibleSpaceBar(
                background: Stack(
                  children: [
                    // Spotlight effect behind the search bar
                    Positioned(
                      top: -50,
                      left: 0,
                      right: 0,
                      child: Container(
                        height: 200,
                        decoration: BoxDecoration(
                          gradient: RadialGradient(
                            colors: [
                              AppColors.primaryOrange.withValues(alpha: 0.1),
                              Colors.transparent,
                            ],
                            center: Alignment.topCenter,
                            radius: 0.8,
                          ),
                        ),
                      ),
                    ),
                    // Position the explore groups widget within the app bar
                    Positioned(
                      top: 0,
                      left: 0,
                      right: 0,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSizes.xs,
                          vertical: AppSizes.xs,
                        ),
                        child: ExploreGroupsWidget(
                          searchController: _searchController,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // Remove the separate SliverToBoxAdapter for ExploreGroupsWidget since it's now in the app bar
            if (groupState.fetchState == AsyncState.loading)
              SliverToBoxAdapter(
                child: Center(child: CircularProgressIndicator()),
              )
            else if (groupState.fetchState == AsyncState.failure)
              SliverToBoxAdapter(
                child: Center(child: Text('Failed to load groups')),
              )
            else if (filteredGroups.isEmpty)
              SliverToBoxAdapter(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      
                      Text('No groups found'),
                      AppSizes.xs.ph,
                      Text(
                        groupState.selectedCategory != null &&
                                groupState.selectedCategory!.name != 'All'
                            ? 'No groups found in category: ${groupState.selectedCategory!.name}'
                            : 'No groups match your search',
                        style: AppTextStyles.caption2(
                          color: AppColors.creamWhite,
                        ),
                      ),
                    ],
                  ),
                ),
              )
            else
              SliverList(
                delegate: SliverChildBuilderDelegate((context, index) {
                  final group = filteredGroups[index];
                  return Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSizes.xs,
                      vertical: AppSizes.xxs,
                    ),
                    child: GroupCard(group: group),
                  );
                }, childCount: filteredGroups.length),
              ),
            // SliverToBoxAdapter(
            //   child: FooterWidget(),
            // ),
          ],
        ),
      ),
    );
  }
}
