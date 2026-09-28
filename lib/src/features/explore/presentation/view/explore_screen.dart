import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:hugeicons/styles/stroke_rounded.dart';
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
  int _selectedTab = 0; // 0: Explore All, 1: My Communities (Purchased / Joined)

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
    // Fetch explore / public groups AND user joined/purchased groups when the screen loads
    Future.microtask(() {
      ref.read(groupProvider.notifier).getPublicGroups();
      ref.read(groupProvider.notifier).refreshGroupsForCurrentUser();
    });
  }

  Widget _buildHomeTabButton({
    required String label,
    required int count,
    required List<List<dynamic>> icon,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primaryOrange : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            HugeIcon(
              icon: icon,
              color: isSelected ? Colors.black : AppColors.creamWhite,
              size: 16,
            ),
            const SizedBox(width: 8),
            Text(
              count > 0 ? '$label ($count)' : label,
              style: TextStyle(
                color: isSelected ? Colors.black : AppColors.creamWhite,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final groupState = ref.watch(groupProvider);

    // Get the search text
    final searchText = _searchController.text.trim().toLowerCase();

    // Source lists
    final publicExploreGroups =
        groupState.exploreGroups ?? groupState.groups ?? [];
    final myJoinedGroups = groupState.groups ?? [];

    final totalExploreCount = publicExploreGroups.length;
    final totalMyCount = myJoinedGroups.length;

    // Pick list based on active tab
    List<GroupModel> filteredGroups = _selectedTab == 0
        ? List<GroupModel>.from(publicExploreGroups)
        : List<GroupModel>.from(myJoinedGroups);

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
          child: RefreshIndicator(
            color: AppColors.primaryOrange,
            backgroundColor: AppColors.darkBgContainer,
            onRefresh: () async {
              ref.read(groupProvider.notifier).refreshGroupsForCurrentUser();
              await ref.read(groupProvider.notifier).getPublicGroups();
            },
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
                // Home Segment Switcher: Explore All vs My Communities
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSizes.xs,
                      vertical: AppSizes.xxs,
                    ),
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: AppColors.darkBgContainer,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.08),
                        ),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: _buildHomeTabButton(
                              label: 'Explore All',
                              count: totalExploreCount,
                              icon: HugeIconsStrokeRounded.compass01,
                              isSelected: _selectedTab == 0,
                              onTap: () => setState(() => _selectedTab = 0),
                            ),
                          ),
                          const SizedBox(width: 6),
                          Expanded(
                            child: _buildHomeTabButton(
                              label: 'My Communities',
                              count: totalMyCount,
                              icon: HugeIconsStrokeRounded.shoppingBag01,
                              isSelected: _selectedTab == 1,
                              onTap: () => setState(() => _selectedTab = 1),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                if (groupState.fetchState == AsyncState.loading &&
                    filteredGroups.isEmpty)
                  const SliverToBoxAdapter(
                    child: Center(
                      child: Padding(
                        padding: EdgeInsets.all(AppSizes.lg),
                        child: CircularProgressIndicator(),
                      ),
                    ),
                  )
                else if (groupState.fetchState == AsyncState.failure &&
                    filteredGroups.isEmpty)
                  SliverToBoxAdapter(
                    child: Center(
                      child: Padding(
                        padding: const EdgeInsets.all(AppSizes.lg),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              groupState.error ?? 'Failed to load groups',
                              style: AppTextStyles.bodyText1(
                                  color: AppColors.red),
                              textAlign: TextAlign.center,
                            ),
                            AppSizes.xs.ph,
                            ElevatedButton(
                              onPressed: () {
                                ref
                                    .read(groupProvider.notifier)
                                    .getPublicGroups();
                                ref
                                    .read(groupProvider.notifier)
                                    .refreshGroupsForCurrentUser();
                              },
                              child: const Text('Retry'),
                            ),
                          ],
                        ),
                      ),
                    ),
                  )
                else if (_selectedTab == 1 && myJoinedGroups.isEmpty)
                  SliverToBoxAdapter(
                    child: Container(
                      margin: const EdgeInsets.all(AppSizes.md),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 24, vertical: 36),
                      decoration: BoxDecoration(
                        color: AppColors.darkBgContainer,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                            color: Colors.white.withValues(alpha: 0.08)),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 64,
                            height: 64,
                            decoration: BoxDecoration(
                              color: AppColors.primaryOrange
                                  .withValues(alpha: 0.15),
                              shape: BoxShape.circle,
                            ),
                            child: const Center(
                              child: HugeIcon(
                                icon: HugeIconsStrokeRounded.shoppingBag01,
                                color: AppColors.primaryOrange,
                                size: 28,
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            "No Communities Joined Yet",
                            style: AppTextStyles.headline4(
                                    color: AppColors.white)
                                .copyWith(fontWeight: FontWeight.bold),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            "You haven't joined or purchased any communities yet. Explore communities to start learning and connecting.",
                            style: AppTextStyles.bodyText2(
                              color: AppColors.creamWhite
                                  .withValues(alpha: 0.7),
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 20),
                          ElevatedButton.icon(
                            onPressed: () {
                              setState(() {
                                _selectedTab = 0;
                              });
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primaryOrange,
                              foregroundColor: Colors.black,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 20,
                                vertical: 12,
                              ),
                            ),
                            icon: const Icon(Icons.explore_outlined,
                                size: 18),
                            label: const Text(
                              "Explore Communities",
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                else if (filteredGroups.isEmpty)
                  SliverToBoxAdapter(
                    child: Center(
                      child: Padding(
                        padding: const EdgeInsets.all(AppSizes.xlg),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              _selectedTab == 1
                                  ? 'No joined communities found'
                                  : 'No groups found',
                              style: AppTextStyles.headline5(
                                  color: AppColors.white),
                            ),
                            AppSizes.xs.ph,
                            Text(
                              groupState.selectedCategory != null &&
                                      groupState.selectedCategory!.name !=
                                          'All'
                                  ? 'No communities found in category: ${groupState.selectedCategory!.name}'
                                  : 'No communities match your search',
                              style: AppTextStyles.caption2(
                                color: AppColors.creamWhite,
                              ),
                            ),
                          ],
                        ),
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
              ],
            ),
          ),
        ),
      ),
    );
  }
}
