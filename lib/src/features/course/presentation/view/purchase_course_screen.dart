import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:hugeicons/styles/stroke_rounded.dart';
import 'package:larnity/src/core/router/router.dart';
import 'package:larnity/src/core/service/supabase/src/supabase_provider.dart';
import 'package:larnity/src/core/service/supabase/src/supabase_storage_service.dart';
import 'package:larnity/src/core/service/supabase/src/supabase_table.dart';
import 'package:larnity/src/core/theme/app_colors.dart';
import 'package:larnity/src/core/theme/theme.dart';
import 'package:larnity/src/core/utils/logger.dart';
import 'package:larnity/src/features/auth/presentation/provider/auth_provider.dart';
import 'package:larnity/src/features/group/data/models/course_model.dart';
import 'package:larnity/src/features/group/data/models/group_model.dart';
import 'package:larnity/src/features/group/presentation/provider/group_provider.dart';

/// Representation of an enrolled / accessible course paired with its parent community.
class PurchasedCourseItem {
  final CourseModel course;
  final GroupModel? group;

  const PurchasedCourseItem({
    required this.course,
    this.group,
  });
}

/// Provider that fetches courses belonging strictly to the groups the current user has joined or owns.
/// Only real purchased/enrolled courses are fetched from Supabase. No dummy or mock courses.
final purchasedCoursesProvider =
    FutureProvider.autoDispose<List<PurchasedCourseItem>>((ref) async {
  final authState = ref.watch(authProvider);
  final userId = authState.user?.id;
  if (userId == null || userId.isEmpty) {
    return [];
  }

  final groupState = ref.watch(groupProvider);
  final userGroups = groupState.groups ?? [];
  if (userGroups.isEmpty) {
    return [];
  }

  final groupIds = userGroups
      .map((g) => g.id)
      .whereType<String>()
      .where((id) => id.isNotEmpty)
      .toList();

  if (groupIds.isEmpty) {
    return [];
  }

  final groupMap = {for (final g in userGroups) if (g.id != null) g.id!: g};
  final supabase = ref.watch(supabaseClientProvider);

  try {
    final response = await supabase
        .from(SupabaseTable.course)
        .select('*, Module(count)')
        .inFilter('groupId', groupIds)
        .order('created_at', ascending: false);

    final courses = (response as List)
        .map((e) => CourseModel.fromMap(e as Map<String, dynamic>))
        .toList();

    return courses.map((course) {
      return PurchasedCourseItem(
        course: course,
        group: groupMap[course.groupId],
      );
    }).toList();
  } catch (e) {
    Log.error('Error fetching purchased courses: $e');
    try {
      final fallbackResponse = await supabase
          .from(SupabaseTable.course)
          .select()
          .inFilter('groupId', groupIds)
          .order('created_at', ascending: false);

      final courses = (fallbackResponse as List)
          .map((e) => CourseModel.fromMap(e as Map<String, dynamic>))
          .toList();

      return courses.map((course) {
        return PurchasedCourseItem(
          course: course,
          group: groupMap[course.groupId],
        );
      }).toList();
    } catch (fallbackError) {
      Log.error('Fallback course query also failed: $fallbackError');
      return [];
    }
  }
});

enum PurchaseTab { courses, groups }

class PurchaseCourseScreen extends ConsumerStatefulWidget {
  const PurchaseCourseScreen({super.key});

  @override
  ConsumerState<PurchaseCourseScreen> createState() =>
      _PurchaseCourseScreenState();
}

class _PurchaseCourseScreenState extends ConsumerState<PurchaseCourseScreen> {
  final TextEditingController _searchController = TextEditingController();
  PurchaseTab _activeTab = PurchaseTab.courses;
  String _selectedFilter = 'All'; // 'All', 'Paid', 'Free'
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(groupProvider.notifier).refreshGroupsForCurrentUser();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  String? _resolveImageUrl(String? rawUrl, {required String bucket}) {
    if (rawUrl == null || rawUrl.trim().isEmpty) return null;
    final trimmed = rawUrl.trim();
    if (trimmed.startsWith('http://') || trimmed.startsWith('https://')) {
      return trimmed;
    }
    try {
      final storage = ref.read(storageServiceProvider);
      return storage.getPublicUrl(
        bucket: bucket,
        path: trimmed,
      );
    } catch (_) {
      return null;
    }
  }

  Future<void> _onRefresh() async {
    ref.read(groupProvider.notifier).refreshGroupsForCurrentUser();
    ref.invalidate(purchasedCoursesProvider);
    await Future.delayed(const Duration(milliseconds: 300));
  }

  void _onCourseTap(PurchasedCourseItem item) {
    if (item.course.id == null) return;
    if (item.group != null) {
      ref.read(groupProvider.notifier).setSelectedGroup(item.group);
    }
    context.pushNamed(
      Routes.courseDetail,
      extra: {
        'courseId': item.course.id!,
        'courseName': item.course.title ?? 'Course',
      },
    );
  }

  void _onGroupTap(GroupModel group) {
    ref.read(groupProvider.notifier).setSelectedGroup(group);
    context.pushNamed(Routes.group);
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final user = authState.user;
    final groupState = ref.watch(groupProvider);
    final coursesAsync = ref.watch(purchasedCoursesProvider);
    final userGroups = groupState.groups ?? [];

    if (user == null || user.id == null || user.id!.isEmpty) {
      return Scaffold(
        backgroundColor: AppColors.bgBlue,
        body: SafeArea(
          child: _buildSignedOutState(),
        ),
      );
    }

    final courses = coursesAsync.value ?? [];

    final filteredCourses = courses.where((item) {
      final course = item.course;
      final group = item.group;
      final matchesSearch = _searchQuery.isEmpty ||
          (course.title?.toLowerCase().contains(_searchQuery) ?? false) ||
          (course.description?.toLowerCase().contains(_searchQuery) ?? false) ||
          (group?.name.toLowerCase().contains(_searchQuery) ?? false);

      if (!matchesSearch) return false;

      if (_selectedFilter == 'Paid') {
        return course.isPaid == true;
      } else if (_selectedFilter == 'Free') {
        return course.isPaid != true;
      }
      return true;
    }).toList();

    final filteredGroups = userGroups.where((group) {
      if (_searchQuery.isEmpty) return true;
      final name = group.name.toLowerCase();
      final desc = (group.description ?? '').toLowerCase();
      final cat = (group.category ?? '').toLowerCase();
      return name.contains(_searchQuery) ||
          desc.contains(_searchQuery) ||
          cat.contains(_searchQuery);
    }).toList();

    final isInitialLoading = coursesAsync.isLoading && courses.isEmpty;

    return Scaffold(
      backgroundColor: AppColors.bgBlue,
      body: SafeArea(
        child: RefreshIndicator(
          color: AppColors.primaryOrange,
          backgroundColor: AppColors.darkBg,
          onRefresh: _onRefresh,
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              // Header & Search section
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Badge
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.primaryOrange.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color:
                                AppColors.primaryOrange.withValues(alpha: 0.3),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            HugeIcon(
                              icon: HugeIconsStrokeRounded.mortarboard02,
                              color: AppColors.primaryOrange,
                              size: 14,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              'ENROLLED & JOINED',
                              style: AppTextStyles.caption(
                                color: AppColors.primaryOrange,
                              ).copyWith(
                                fontWeight: FontWeight.bold,
                                letterSpacing: 0.8,
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'My Learning & Communities',
                        style: AppTextStyles.headline2(
                          color: AppColors.white,
                        ).copyWith(
                          fontWeight: FontWeight.w800,
                          fontSize: 24,
                          letterSpacing: -0.5,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Access your enrolled courses and active learning communities.',
                        style: AppTextStyles.caption(
                          color: AppColors.creamWhite,
                        ).copyWith(fontSize: 13, height: 1.4),
                      ),
                      const SizedBox(height: 16),

                      // Segmented Tab Toggle (Courses vs Communities)
                      Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: AppColors.darkBg,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.08),
                          ),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: _buildSegmentButton(
                                label: 'Courses (${courses.length})',
                                icon: HugeIconsStrokeRounded.book02,
                                isSelected: _activeTab == PurchaseTab.courses,
                                onTap: () {
                                  setState(() {
                                    _activeTab = PurchaseTab.courses;
                                  });
                                },
                              ),
                            ),
                            const SizedBox(width: 6),
                            Expanded(
                              child: _buildSegmentButton(
                                label: 'Communities (${userGroups.length})',
                                icon: HugeIconsStrokeRounded.userGroup,
                                isSelected: _activeTab == PurchaseTab.groups,
                                onTap: () {
                                  setState(() {
                                    _activeTab = PurchaseTab.groups;
                                  });
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 14),

                      // Search Bar
                      Container(
                        decoration: BoxDecoration(
                          color: AppColors.darkBg,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.08),
                          ),
                        ),
                        child: TextField(
                          controller: _searchController,
                          style: const TextStyle(
                              color: AppColors.white, fontSize: 14),
                          onChanged: (val) {
                            setState(() {
                              _searchQuery = val.trim().toLowerCase();
                            });
                          },
                          decoration: InputDecoration(
                            hintText: _activeTab == PurchaseTab.courses
                                ? 'Search your enrolled courses...'
                                : 'Search your joined communities...',
                            hintStyle: TextStyle(
                              color:
                                  AppColors.creamWhite.withValues(alpha: 0.6),
                              fontSize: 14,
                            ),
                            prefixIcon: const HugeIcon(
                              icon: HugeIconsStrokeRounded.search01,
                              color: AppColors.creamWhite,
                              size: 18,
                            ),
                            suffixIcon: _searchQuery.isNotEmpty
                                ? IconButton(
                                    icon: const Icon(Icons.clear,
                                        color: AppColors.creamWhite, size: 18),
                                    onPressed: () {
                                      _searchController.clear();
                                      setState(() {
                                        _searchQuery = '';
                                      });
                                    },
                                  )
                                : null,
                            border: InputBorder.none,
                            contentPadding: const EdgeInsets.symmetric(
                                vertical: 14, horizontal: 16),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),

                      // Filter chips for Courses tab
                      if (_activeTab == PurchaseTab.courses &&
                          courses.isNotEmpty) ...[
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: [
                              _buildFilterChip('All'),
                              const SizedBox(width: 8),
                              _buildFilterChip('Paid'),
                              const SizedBox(width: 8),
                              _buildFilterChip('Free'),
                            ],
                          ),
                        ),
                        const SizedBox(height: 8),
                      ],
                    ],
                  ),
                ),
              ),

              // Content Area
              if (isInitialLoading)
                const SliverFillRemaining(
                  hasScrollBody: false,
                  child: Center(
                    child: CircularProgressIndicator(
                      color: AppColors.primaryOrange,
                    ),
                  ),
                )
              else if (_activeTab == PurchaseTab.courses)
                _buildCoursesSection(
                  courses: filteredCourses,
                  hasAnyCourses: courses.isNotEmpty,
                  hasJoinedGroups: userGroups.isNotEmpty,
                )
              else
                _buildGroupsSection(
                  groups: filteredGroups,
                  hasAnyGroups: userGroups.isNotEmpty,
                  currentUserId: user.id!,
                ),

              // Bottom padding for scroll clearance
              const SliverToBoxAdapter(
                child: SizedBox(height: 100),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSegmentButton({
    required String label,
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
              label,
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

  Widget _buildFilterChip(String label) {
    final isSelected = _selectedFilter == label;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedFilter = label;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primaryOrange
              : AppColors.darkBgContainer,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected
                ? AppColors.primaryOrange
                : Colors.white.withValues(alpha: 0.1),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.black : AppColors.creamWhite,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
            fontSize: 12,
          ),
        ),
      ),
    );
  }

  // ── COURSES SECTION ──

  Widget _buildCoursesSection({
    required List<PurchasedCourseItem> courses,
    required bool hasAnyCourses,
    required bool hasJoinedGroups,
  }) {
    if (courses.isEmpty) {
      if (!hasJoinedGroups) {
        return SliverFillRemaining(
          hasScrollBody: false,
          child: _buildEmptyState(
            icon: HugeIconsStrokeRounded.book02,
            title: 'No Enrolled Courses',
            subtitle:
                'You haven\'t joined any communities yet. Join or purchase a community on Larnity to access its curated courses, learning modules, and classroom resources.',
            actionLabel: 'Explore Communities',
            onAction: () => context.goNamed(Routes.explore),
          ),
        );
      }

      if (!hasAnyCourses) {
        return SliverFillRemaining(
          hasScrollBody: false,
          child: _buildEmptyState(
            icon: HugeIconsStrokeRounded.mortarboard02,
            title: 'No Courses in Your Communities',
            subtitle:
                'The communities you have joined haven\'t published any courses yet. You can visit your community room or explore other active learning communities.',
            actionLabel: 'View My Communities',
            onAction: () {
              setState(() {
                _activeTab = PurchaseTab.groups;
              });
            },
            secondaryActionLabel: 'Explore More',
            onSecondaryAction: () => context.goNamed(Routes.explore),
          ),
        );
      }

      return SliverFillRemaining(
        hasScrollBody: false,
        child: _buildEmptyState(
          icon: HugeIconsStrokeRounded.search01,
          title: 'No Matching Courses Found',
          subtitle:
              'No courses match "$_searchQuery". Try searching with different keywords.',
          actionLabel: 'Clear Search',
          onAction: () {
            _searchController.clear();
            setState(() {
              _searchQuery = '';
            });
          },
        ),
      );
    }

    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            final item = courses[index];
            return Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: _buildCourseCard(item),
            );
          },
          childCount: courses.length,
        ),
      ),
    );
  }

  Widget _buildCourseCard(PurchasedCourseItem item) {
    final course = item.course;
    final group = item.group;
    final imageUrl = _resolveImageUrl(course.image,
        bucket: StorageBucket.courseMedia);
    final groupName = group?.name ?? 'Community Course';
    final moduleCount = course.moduleCount ?? 0;

    return Container(
      decoration: BoxDecoration(
        color: AppColors.darkBgContainer,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.08),
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _onCourseTap(item),
          splashColor: AppColors.primaryOrange.withValues(alpha: 0.1),
          highlightColor: Colors.white.withValues(alpha: 0.05),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Course Thumbnail Banner
              SizedBox(
                height: 150,
                width: double.infinity,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    if (imageUrl != null)
                      Image.network(
                        imageUrl,
                        fit: BoxFit.cover,
                        loadingBuilder: (context, child, progress) {
                          if (progress == null) return child;
                          return Container(
                            color: AppColors.darkBg,
                            child: const Center(
                              child: SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: AppColors.primaryOrange,
                                ),
                              ),
                            ),
                          );
                        },
                        errorBuilder: (context, error, stackTrace) =>
                            _buildCoursePlaceholder(course.title ?? 'Course'),
                      )
                    else
                      _buildCoursePlaceholder(course.title ?? 'Course'),

                    // Subtle bottom gradient
                    Positioned.fill(
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.transparent,
                              Colors.black.withValues(alpha: 0.7),
                            ],
                          ),
                        ),
                      ),
                    ),

                    // Top Community Badge
                    Positioned(
                      top: 12,
                      left: 12,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.7),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.2),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const HugeIcon(
                              icon: HugeIconsStrokeRounded.userGroup,
                              color: AppColors.primaryOrange,
                              size: 13,
                            ),
                            const SizedBox(width: 5),
                            ConstrainedBox(
                              constraints: const BoxConstraints(maxWidth: 160),
                              child: Text(
                                groupName,
                                style: const TextStyle(
                                  color: AppColors.white,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    // Enrolled Status Pill
                    Positioned(
                      top: 12,
                      right: 12,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 9, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.green.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: AppColors.green,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: const [
                            Icon(Icons.check_circle,
                                color: AppColors.green, size: 12),
                            SizedBox(width: 4),
                            Text(
                              'ENROLLED',
                              style: TextStyle(
                                color: AppColors.green,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Course Details
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      course.title ?? 'Untitled Course',
                      style: AppTextStyles.headline4(
                        color: AppColors.white,
                      ).copyWith(
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (course.description != null &&
                        course.description!.isNotEmpty) ...[
                      const SizedBox(height: 6),
                      Text(
                        course.description!,
                        style: AppTextStyles.caption(
                          color: AppColors.creamWhite.withValues(alpha: 0.8),
                        ).copyWith(fontSize: 13, height: 1.35),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                    const SizedBox(height: 14),
                    const Divider(color: AppColors.borderBrown, height: 1),
                    const SizedBox(height: 12),

                    // Bottom info bar
                    Row(
                      children: [
                        // Module count
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 5),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.05),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const HugeIcon(
                                icon: HugeIconsStrokeRounded.book02,
                                color: AppColors.primaryOrange,
                                size: 14,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                moduleCount == 1
                                    ? '1 Module'
                                    : '$moduleCount Modules',
                                style: const TextStyle(
                                  color: AppColors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const Spacer(),

                        // Action button
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 7),
                          decoration: BoxDecoration(
                            color: AppColors.primaryOrange,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: const [
                              Text(
                                'Open Course',
                                style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              SizedBox(width: 4),
                              Icon(
                                Icons.arrow_forward_rounded,
                                color: Colors.black,
                                size: 14,
                              ),
                            ],
                          ),
                        ),
                      ],
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

  Widget _buildCoursePlaceholder(String title) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primaryOrange.withValues(alpha: 0.35),
            AppColors.darkBgContainer,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const HugeIcon(
              icon: HugeIconsStrokeRounded.book02,
              color: AppColors.primaryOrange,
              size: 38,
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: AppColors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── GROUPS / COMMUNITIES (GP) SECTION ──

  Widget _buildGroupsSection({
    required List<GroupModel> groups,
    required bool hasAnyGroups,
    required String currentUserId,
  }) {
    if (groups.isEmpty) {
      if (!hasAnyGroups) {
        return SliverFillRemaining(
          hasScrollBody: false,
          child: _buildEmptyState(
            icon: HugeIconsStrokeRounded.userGroup,
            title: 'No Communities Joined Yet',
            subtitle:
                'You haven\'t joined or created any communities yet. Explore verified learning communities on Larnity to unlock exclusive masterclasses and discussions.',
            actionLabel: 'Explore Communities',
            onAction: () => context.goNamed(Routes.explore),
          ),
        );
      }

      return SliverFillRemaining(
        hasScrollBody: false,
        child: _buildEmptyState(
          icon: HugeIconsStrokeRounded.search01,
          title: 'No Matching Communities',
          subtitle:
              'No joined communities match "$_searchQuery". Try a different search keyword.',
          actionLabel: 'Clear Search',
          onAction: () {
            _searchController.clear();
            setState(() {
              _searchQuery = '';
            });
          },
        ),
      );
    }

    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            final group = groups[index];
            return Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: _buildGroupCard(group, currentUserId),
            );
          },
          childCount: groups.length,
        ),
      ),
    );
  }

  Widget _buildGroupCard(GroupModel group, String currentUserId) {
    final bannerUrl = _resolveImageUrl(group.thumbnail,
            bucket: StorageBucket.groupImages) ??
        _resolveImageUrl(group.icon, bucket: StorageBucket.groupImages);
    final iconUrl = _resolveImageUrl(group.icon,
            bucket: StorageBucket.groupImages) ??
        _resolveImageUrl(group.thumbnail, bucket: StorageBucket.groupImages);

    final isOwner = group.userId == currentUserId;
    final memberCount = group.memberCount ?? 0;
    final category = group.category ?? 'Community';

    return Container(
      decoration: BoxDecoration(
        color: AppColors.darkBgContainer,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.08),
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _onGroupTap(group),
          splashColor: AppColors.primaryOrange.withValues(alpha: 0.1),
          highlightColor: Colors.white.withValues(alpha: 0.05),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Banner
              SizedBox(
                height: 120,
                width: double.infinity,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    if (bannerUrl != null)
                      Image.network(
                        bannerUrl,
                        fit: BoxFit.cover,
                        loadingBuilder: (context, child, progress) {
                          if (progress == null) return child;
                          return Container(
                            color: AppColors.darkBg,
                            child: const Center(
                              child: SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: AppColors.primaryOrange,
                                ),
                              ),
                            ),
                          );
                        },
                        errorBuilder: (context, error, stackTrace) =>
                            _buildGroupPlaceholderBanner(group.name),
                      )
                    else
                      _buildGroupPlaceholderBanner(group.name),

                    // Gradient overlay
                    Positioned.fill(
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.transparent,
                              Colors.black.withValues(alpha: 0.6),
                            ],
                          ),
                        ),
                      ),
                    ),

                    // Role Badge (Owner vs Member)
                    Positioned(
                      top: 12,
                      right: 12,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 9, vertical: 4),
                        decoration: BoxDecoration(
                          color: isOwner
                              ? AppColors.primaryOrange.withValues(alpha: 0.2)
                              : AppColors.skyBlue.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color:
                                isOwner ? AppColors.primaryOrange : AppColors.skyBlue,
                          ),
                        ),
                        child: Text(
                          isOwner ? 'CREATOR' : 'JOINED',
                          style: TextStyle(
                            color: isOwner
                                ? AppColors.primaryOrange
                                : AppColors.skyBlue,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Group Content
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        // Group Icon
                        Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: AppColors.darkBg,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.1),
                            ),
                          ),
                          clipBehavior: Clip.antiAlias,
                          child: iconUrl != null
                              ? Image.network(
                                  iconUrl,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) => const Icon(
                                    Icons.group,
                                    color: AppColors.primaryOrange,
                                    size: 22,
                                  ),
                                )
                              : const Icon(
                                  Icons.group,
                                  color: AppColors.primaryOrange,
                                  size: 22,
                                ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                group.name,
                                style: AppTextStyles.headline4(
                                  color: AppColors.white,
                                ).copyWith(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 3),
                              Text(
                                category,
                                style: AppTextStyles.caption(
                                  color: AppColors.primaryOrange,
                                ).copyWith(fontSize: 12, fontWeight: FontWeight.w600),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    if (group.description != null &&
                        group.description!.isNotEmpty) ...[
                      const SizedBox(height: 10),
                      Text(
                        group.description!,
                        style: AppTextStyles.caption(
                          color: AppColors.creamWhite.withValues(alpha: 0.8),
                        ).copyWith(fontSize: 13, height: 1.35),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                    const SizedBox(height: 14),
                    const Divider(color: AppColors.borderBrown, height: 1),
                    const SizedBox(height: 12),

                    // Bottom info bar
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 5),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.05),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const HugeIcon(
                                icon: HugeIconsStrokeRounded.userGroup,
                                color: AppColors.creamWhite,
                                size: 14,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                memberCount == 1
                                    ? '1 Member'
                                    : '$memberCount Members',
                                style: const TextStyle(
                                  color: AppColors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const Spacer(),

                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 7),
                          decoration: BoxDecoration(
                            color: AppColors.primaryOrange,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: const [
                              Text(
                                'Enter Room',
                                style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              SizedBox(width: 4),
                              Icon(
                                Icons.arrow_forward_rounded,
                                color: Colors.black,
                                size: 14,
                              ),
                            ],
                          ),
                        ),
                      ],
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

  Widget _buildGroupPlaceholderBanner(String name) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primaryOrange.withValues(alpha: 0.3),
            AppColors.darkBgContainer,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Center(
        child: Icon(
          Icons.group_work_outlined,
          size: 40,
          color: AppColors.white.withValues(alpha: 0.5),
        ),
      ),
    );
  }

  // ── EMPTY & SIGNED-OUT STATES ──

  Widget _buildSignedOutState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: AppColors.primaryOrange.withValues(alpha: 0.15),
                shape: BoxShape.circle,
                border: Border.all(
                  color: AppColors.primaryOrange.withValues(alpha: 0.3),
                ),
              ),
              child: const Center(
                child: HugeIcon(
                  icon: HugeIconsStrokeRounded.lockPassword,
                  color: AppColors.primaryOrange,
                  size: 36,
                ),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Sign In to Access Your Content',
              style: AppTextStyles.headline3(color: AppColors.white).copyWith(
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Log in with your Larnity account to access your purchased courses and joined communities.',
              style: AppTextStyles.caption(color: AppColors.creamWhite).copyWith(
                fontSize: 14,
                height: 1.4,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => context.pushNamed(Routes.auth),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryOrange,
                foregroundColor: Colors.black,
                padding:
                    const EdgeInsets.symmetric(horizontal: 28, vertical: 13),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'Sign In Now',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState({
    required List<List<dynamic>> icon,
    required String title,
    required String subtitle,
    required String actionLabel,
    required VoidCallback onAction,
    String? secondaryActionLabel,
    VoidCallback? onSecondaryAction,
  }) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 76,
              height: 76,
              decoration: BoxDecoration(
                color: AppColors.primaryOrange.withValues(alpha: 0.12),
                shape: BoxShape.circle,
                border: Border.all(
                  color: AppColors.primaryOrange.withValues(alpha: 0.25),
                ),
              ),
              child: Center(
                child: HugeIcon(
                  icon: icon,
                  color: AppColors.primaryOrange,
                  size: 34,
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              title,
              style: AppTextStyles.headline3(color: AppColors.white).copyWith(
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              style: AppTextStyles.caption(color: AppColors.creamWhite).copyWith(
                fontSize: 13,
                height: 1.4,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 22),
            ElevatedButton(
              onPressed: onAction,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryOrange,
                foregroundColor: Colors.black,
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 2,
              ),
              child: Text(
                actionLabel,
                style:
                    const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
              ),
            ),
            if (secondaryActionLabel != null && onSecondaryAction != null) ...[
              const SizedBox(height: 10),
              TextButton(
                onPressed: onSecondaryAction,
                child: Text(
                  secondaryActionLabel,
                  style: const TextStyle(
                    color: AppColors.primaryOrange,
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
