import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:hugeicons/styles/stroke_rounded.dart';
import 'package:larnity/src/core/theme/app_colors.dart';
import 'package:larnity/src/core/theme/theme.dart';
import 'package:larnity/src/features/group/data/datasource/classroom_datasource.dart';
import 'package:larnity/src/features/group/data/models/course_model.dart';

final allCoursesProvider = FutureProvider.autoDispose<List<CourseModel>>((ref) async {
  final dataSource = ref.watch(classroomDataSourceProvider);
  final result = await dataSource.getAllCourses();
  return result.fold(
    (failure) => <CourseModel>[],
    (courses) => courses,
  );
});

class PurchaseCourseScreen extends ConsumerStatefulWidget {
  const PurchaseCourseScreen({super.key});

  @override
  ConsumerState<PurchaseCourseScreen> createState() => _PurchaseCourseScreenState();
}

class _PurchaseCourseScreenState extends ConsumerState<PurchaseCourseScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _selectedFilter = 'All'; // 'All', 'Paid', 'Free'
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // Fallback curated courses if database has 0 courses
  static const List<CourseModel> _curatedCourses = [
    CourseModel(
      id: 'flutter_mastery',
      groupId: 'tech_hub',
      title: 'Full-Stack Flutter & AI Engineering',
      description: 'Build enterprise-grade cross-platform apps with Riverpod, Clean Architecture, and AI API integrations.',
      image: 'https://images.unsplash.com/photo-1551288049-bebda4e38f71?w=800&auto=format&fit=crop&q=60',
      isPaid: true,
      price: 1499,
      currency: 'INR',
      moduleCount: 14,
    ),
    CourseModel(
      id: 'ui_ux_masterclass',
      groupId: 'design_academy',
      title: 'Modern UI/UX Design & Micro-Interactions',
      description: 'Master Figma design systems, dark mode glassmorphism, animations, and high-fidelity mobile prototyping.',
      image: 'https://images.unsplash.com/photo-1507238691740-187a5b1d37b8?w=800&auto=format&fit=crop&q=60',
      isPaid: true,
      price: 999,
      currency: 'INR',
      moduleCount: 8,
    ),
    CourseModel(
      id: 'system_design_zero_to_hero',
      groupId: 'tech_hub',
      title: 'Distributed Systems & Cloud Architecture',
      description: 'Deep dive into microservices, PostgreSQL scaling, Redis caching, event queues, and high availability.',
      image: 'https://images.unsplash.com/photo-1451187580459-43490279c0fa?w=800&auto=format&fit=crop&q=60',
      isPaid: true,
      price: 1999,
      currency: 'INR',
      moduleCount: 18,
    ),
    CourseModel(
      id: 'supabase_foundations',
      groupId: 'tech_hub',
      title: 'Supabase & Backend-as-a-Service Fundamentals',
      description: 'Learn PostgreSQL Row-Level Security, Edge Functions, real-time broadcasts, and auth workflows from scratch.',
      image: 'https://images.unsplash.com/photo-1526374965328-7f61d4dc18c5?w=800&auto=format&fit=crop&q=60',
      isPaid: false,
      price: 0,
      currency: 'INR',
      moduleCount: 6,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final coursesAsync = ref.watch(allCoursesProvider);

    return Scaffold(
      backgroundColor: AppColors.bgBlue,
      body: SafeArea(
        child: RefreshIndicator(
          color: AppColors.primaryOrange,
          backgroundColor: AppColors.darkBg,
          onRefresh: () async {
            ref.invalidate(allCoursesProvider);
          },
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              // Hero Header & Search Section
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Badge
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.primaryOrange.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: AppColors.primaryOrange.withValues(alpha: 0.3),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            HugeIcon(
                              icon: HugeIconsStrokeRounded.book02,
                              color: AppColors.primaryOrange,
                              size: 14,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              'LEARNING MARKETPLACE',
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
                        'Purchase Courses',
                        style: AppTextStyles.headline2(
                          color: AppColors.white,
                        ).copyWith(
                          fontWeight: FontWeight.w800,
                          fontSize: 26,
                          letterSpacing: -0.5,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Level up your skills with curated masterclasses and expert-led curriculum.',
                        style: AppTextStyles.caption(
                          color: AppColors.creamWhite,
                        ).copyWith(fontSize: 13, height: 1.4),
                      ),
                      const SizedBox(height: 16),

                      // Stylish Search Bar
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
                          style: const TextStyle(color: AppColors.white, fontSize: 14),
                          onChanged: (val) {
                            setState(() {
                              _searchQuery = val.trim().toLowerCase();
                            });
                          },
                          decoration: InputDecoration(
                            hintText: 'Search courses, topics, skills...',
                            hintStyle: TextStyle(
                              color: AppColors.creamWhite.withValues(alpha: 0.6),
                              fontSize: 14,
                            ),
                            prefixIcon: const HugeIcon(
                              icon: HugeIconsStrokeRounded.search01,
                              color: AppColors.creamWhite,
                              size: 18,
                            ),
                            suffixIcon: _searchQuery.isNotEmpty
                                ? IconButton(
                                    icon: const Icon(Icons.clear, color: AppColors.creamWhite, size: 18),
                                    onPressed: () {
                                      _searchController.clear();
                                      setState(() {
                                        _searchQuery = '';
                                      });
                                    },
                                  )
                                : null,
                            border: InputBorder.none,
                            contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
                          ),
                        ),
                      ),
                      const SizedBox(height: 14),

                      // Filter Chips
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
                    ],
                  ),
                ),
              ),

              // Courses List
              coursesAsync.when(
                data: (courses) {
                  final combinedList = courses.isNotEmpty ? courses : _curatedCourses;
                  final filteredList = combinedList.where((course) {
                    final title = (course.title ?? '').toLowerCase();
                    final desc = (course.description ?? '').toLowerCase();
                    final matchesSearch = _searchQuery.isEmpty ||
                        title.contains(_searchQuery) ||
                        desc.contains(_searchQuery);

                    if (!matchesSearch) return false;

                    if (_selectedFilter == 'Paid') {
                      return course.isPaid == true;
                    } else if (_selectedFilter == 'Free') {
                      return course.isPaid != true;
                    }
                    return true;
                  }).toList();

                  if (filteredList.isEmpty) {
                    return SliverFillRemaining(
                      hasScrollBody: false,
                      child: Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            HugeIcon(
                              icon: HugeIconsStrokeRounded.search01,
                              color: AppColors.creamWhite.withValues(alpha: 0.4),
                              size: 48,
                            ),
                            const SizedBox(height: 12),
                            Text(
                              'No courses match your filter',
                              style: AppTextStyles.subtitle1(color: AppColors.white),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Try searching with a different keyword.',
                              style: AppTextStyles.caption(color: AppColors.creamWhite),
                            ),
                          ],
                        ),
                      ),
                    );
                  }

                  return SliverPadding(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 96),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          final course = filteredList[index];
                          return _buildCourseCard(course);
                        },
                        childCount: filteredList.length,
                      ),
                    ),
                  );
                },
                loading: () => const SliverFillRemaining(
                  hasScrollBody: false,
                  child: Center(
                    child: CircularProgressIndicator(
                      color: AppColors.primaryOrange,
                    ),
                  ),
                ),
                error: (error, _) => SliverFillRemaining(
                  hasScrollBody: false,
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.error_outline, color: AppColors.red, size: 40),
                        const SizedBox(height: 12),
                        Text(
                          'Failed to load courses',
                          style: AppTextStyles.subtitle1(color: AppColors.white),
                        ),
                        const SizedBox(height: 8),
                        TextButton(
                          onPressed: () => ref.invalidate(allCoursesProvider),
                          child: const Text('Try Again', style: TextStyle(color: AppColors.primaryOrange)),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
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
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primaryOrange : AppColors.darkBg,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected
                ? AppColors.primaryOrange
                : Colors.white.withValues(alpha: 0.1),
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppColors.primaryOrange.withValues(alpha: 0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.black : AppColors.white,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            fontSize: 13,
          ),
        ),
      ),
    );
  }

  Widget _buildCourseCard(CourseModel course) {
    final hasImage = course.image != null && course.image!.isNotEmpty;
    final isPaid = course.isPaid ?? false;
    final priceText = isPaid
        ? (course.price != null ? '₹${course.price}' : 'PAID')
        : 'FREE';

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: AppColors.darkBg,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.08),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.25),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Course Banner / Thumbnail
            Stack(
              children: [
                Container(
                  height: 140,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: AppColors.darkBgContainer,
                    image: hasImage
                        ? DecorationImage(
                            image: NetworkImage(course.image!),
                            fit: BoxFit.cover,
                          )
                        : null,
                  ),
                  child: !hasImage
                      ? Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                AppColors.primaryOrange.withValues(alpha: 0.3),
                                AppColors.bgBlue,
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                          ),
                          child: const Center(
                            child: HugeIcon(
                              icon: HugeIconsStrokeRounded.book02,
                              color: AppColors.white,
                              size: 40,
                            ),
                          ),
                        )
                      : null,
                ),
                // Gradient shade overlay for text readability
                Positioned.fill(
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.transparent,
                          Colors.black.withValues(alpha: 0.7),
                        ],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                  ),
                ),
                // Price Pill Badge on top-right
                Positioned(
                  top: 12,
                  right: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: isPaid
                          ? AppColors.primaryOrange
                          : AppColors.green,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: (isPaid ? AppColors.primaryOrange : AppColors.green)
                              .withValues(alpha: 0.4),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Text(
                      priceText,
                      style: const TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.w800,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ),
                // Module count on bottom-left
                Positioned(
                  bottom: 10,
                  left: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.6),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.2),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const HugeIcon(
                          icon: HugeIconsStrokeRounded.book02,
                          color: AppColors.white,
                          size: 13,
                        ),
                        const SizedBox(width: 5),
                        Text(
                          '${course.moduleCount ?? 1} Modules',
                          style: const TextStyle(
                            color: AppColors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),

            // Card Content
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    course.title ?? 'Untitled Course',
                    style: AppTextStyles.subtitle1(
                      color: AppColors.white,
                    ).copyWith(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      height: 1.3,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    course.description ?? 'No course description available.',
                    style: AppTextStyles.caption(
                      color: AppColors.creamWhite,
                    ).copyWith(
                      fontSize: 13,
                      height: 1.4,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 16),

                  // Actions Row: Price info + Purchase/Enroll Button
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Course Fee',
                            style: AppTextStyles.caption2(
                              color: AppColors.creamWhite.withValues(alpha: 0.6),
                            ),
                          ),
                          Text(
                            priceText,
                            style: TextStyle(
                              color: isPaid ? AppColors.primaryOrange : AppColors.green,
                              fontWeight: FontWeight.w800,
                              fontSize: 18,
                            ),
                          ),
                        ],
                      ),
                      ElevatedButton(
                        onPressed: () {
                          _showPurchaseBottomSheet(context, course);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryOrange,
                          foregroundColor: Colors.black,
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 2,
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            HugeIcon(
                              icon: isPaid
                                  ? HugeIconsStrokeRounded.shoppingBag01
                                  : HugeIconsStrokeRounded.play,
                              color: Colors.black,
                              size: 16,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              isPaid ? 'Purchase' : 'Enroll Free',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                              ),
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
    );
  }

  void _showPurchaseBottomSheet(BuildContext context, CourseModel course) {
    final isPaid = course.isPaid ?? false;
    final priceText = isPaid
        ? (course.price != null ? '₹${course.price}' : 'PAID')
        : 'FREE';

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) {
        return Container(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
          decoration: const BoxDecoration(
            color: AppColors.darkBg,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            border: Border(
              top: BorderSide(color: AppColors.borderBrown, width: 1),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top drag indicator
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Title & Price
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          isPaid ? 'Purchase Course' : 'Enroll in Course',
                          style: AppTextStyles.subtitle2(
                            color: AppColors.primaryOrange,
                          ).copyWith(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          course.title ?? 'Course Details',
                          style: AppTextStyles.headline4(
                            color: AppColors.white,
                          ).copyWith(fontSize: 18),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: (isPaid ? AppColors.primaryOrange : AppColors.green)
                          .withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isPaid ? AppColors.primaryOrange : AppColors.green,
                      ),
                    ),
                    child: Text(
                      priceText,
                      style: TextStyle(
                        color: isPaid ? AppColors.primaryOrange : AppColors.green,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              const Divider(color: AppColors.borderBrown),
              const SizedBox(height: 12),

              // Features included
              Text(
                "What's Included:",
                style: AppTextStyles.subtitle1(color: AppColors.white).copyWith(fontSize: 14),
              ),
              const SizedBox(height: 10),
              _buildFeatureRow(HugeIconsStrokeRounded.checkmarkCircle01, 'Full lifetime access to all lessons & modules'),
              _buildFeatureRow(HugeIconsStrokeRounded.book02, '${course.moduleCount ?? 1} structured modules & downloadable resources'),
              _buildFeatureRow(HugeIconsStrokeRounded.userGroup, 'Access to private community & discussion channels'),
              _buildFeatureRow(HugeIconsStrokeRounded.certificate01, 'Verifiable Certificate of Completion'),
              const SizedBox(height: 20),

              // Action button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(ctx);
                    _handleEnrollSuccess(context, course);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryOrange,
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    elevation: 4,
                  ),
                  child: Text(
                    isPaid ? 'Confirm & Pay $priceText' : 'Confirm Free Enrollment',
                    style: const TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 15,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildFeatureRow(List<List<dynamic>> icon, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          HugeIcon(icon: icon, color: AppColors.primaryOrange, size: 16),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: AppTextStyles.caption(color: AppColors.creamWhite).copyWith(fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }

  void _handleEnrollSuccess(BuildContext context, CourseModel course) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.darkBg,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(color: AppColors.primaryOrange.withValues(alpha: 0.3)),
        ),
        title: Row(
          children: const [
            Icon(Icons.check_circle, color: AppColors.green, size: 28),
            SizedBox(width: 10),
            Text('Enrolled Successfully!', style: TextStyle(color: AppColors.white, fontSize: 18)),
          ],
        ),
        content: Text(
          'You are now enrolled in "${course.title}". Start learning right away!',
          style: const TextStyle(color: AppColors.creamWhite, fontSize: 14),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Great!', style: TextStyle(color: AppColors.primaryOrange, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}
