import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:larnity/src/core/constants/app_size.dart';
import 'package:larnity/src/core/extensions/extensions.dart';
import 'package:larnity/src/core/theme/app_colors.dart';
import 'package:larnity/src/core/theme/theme.dart';
import 'package:larnity/src/features/explore/presentation/widgets/explore_groups_widget.dart';
import 'package:larnity/src/features/explore/presentation/widgets/group_card.dart';
import 'package:larnity/src/features/group/presentation/provider/group_provider.dart';
import 'package:larnity/src/features/group/data/models/group_model.dart';
import 'package:larnity/src/core/utils/async_states.dart';
import 'package:larnity/src/core/extensions/slugify_extension.dart';

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
    _searchController.addListener(_onSearchChanged);
  }

  void _onSearchChanged() {
    setState(() {});
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Fetch explore / public groups when the screen loads
    Future.microtask(() {
      ref.read(groupProvider.notifier).getPublicGroups();
    });
  }

  @override
  Widget build(BuildContext context) {
    final groupState = ref.watch(groupProvider);

    // Get the search text
    final searchText = _searchController.text.trim().toLowerCase();

    // Start with explore groups (fallback to all groups)
    List<GroupModel> filteredGroups =
        groupState.exploreGroups ?? groupState.groups ?? [];

    // Apply search filter first
    if (searchText.isNotEmpty) {
      filteredGroups = filteredGroups.where((group) {
        final name = group.name.toLowerCase();
        final desc = (group.description ?? '').toLowerCase();
        final cat = (group.category ?? '').toLowerCase();
        final slug = (group.slug ?? '').toLowerCase();
        return name.contains(searchText) ||
            desc.contains(searchText) ||
            cat.contains(searchText) ||
            slug.contains(searchText);
      }).toList();
    }

    // Apply category filter - works with both raw category name and slug
    if (groupState.selectedCategory != null &&
        groupState.selectedCategory!.name != 'All') {
      final selectedCategoryName =
          groupState.selectedCategory!.name.toLowerCase();
      final selectedCategorySlug = groupState.selectedCategory!.name.slugify();
      filteredGroups = filteredGroups
          .where(
            (group) {
              if (group.category == null) return false;
              final cat = group.category!.toLowerCase();
              return cat == selectedCategoryName || cat == selectedCategorySlug;
            },
          )
          .toList();
    }

    return Scaffold(
      key: widget.scaffoldKey,
      backgroundColor: AppColors.black,
      body: SafeArea(
        bottom: false,
        child: Container(
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
              SliverToBoxAdapter(
              child: Stack(
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
                  // Explore groups widget
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSizes.xs,
                      vertical: AppSizes.xs,
                    ),
                    child: ExploreGroupsWidget(
                      searchController: _searchController,
                    ),
                  ),
                ],
              ),
            ),
            // Remove the separate SliverToBoxAdapter for ExploreGroupsWidget since it's now in the app bar
            if (groupState.fetchState == AsyncState.loading && filteredGroups.isEmpty)
              const SliverToBoxAdapter(
                child: Center(
                  child: Padding(
                    padding: EdgeInsets.all(AppSizes.lg),
                    child: CircularProgressIndicator(),
                  ),
                ),
              )
            else if (groupState.fetchState == AsyncState.failure && filteredGroups.isEmpty)
              SliverToBoxAdapter(
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.all(AppSizes.lg),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          groupState.error ?? 'Failed to load groups',
                          style: AppTextStyles.bodyText1(color: AppColors.red),
                          textAlign: TextAlign.center,
                        ),
                        AppSizes.xs.ph,
                        ElevatedButton(
                          onPressed: () {
                            ref.read(groupProvider.notifier).getPublicGroups();
                          },
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  ),
                ),
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
      ),
    );
  }
}
