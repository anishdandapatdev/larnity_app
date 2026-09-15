import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:hugeicons/styles/stroke_rounded.dart';
import 'package:larnity/src/core/router/router.dart';
import 'package:larnity/src/core/extensions/path_extension.dart';
import 'package:larnity/src/core/constants/app_size.dart';
import 'package:larnity/src/core/constants/app_strings.dart';
import 'package:larnity/src/core/extensions/extensions.dart';
import 'package:larnity/src/core/theme/app_colors.dart';
import 'package:larnity/src/core/theme/theme.dart';
import 'package:larnity/src/core/ui/widgets/app_button.dart';
import 'package:larnity/src/features/group/presentation/widgets/create_course.dart';
import 'package:larnity/src/features/group/presentation/provider/group_provider.dart';
import 'package:larnity/src/features/group/presentation/provider/classroom_provider.dart';
import 'package:larnity/src/features/group/data/models/course_model.dart';
import 'package:larnity/src/core/utils/async_states.dart';

class ClassRoomScreen extends ConsumerWidget {
  const ClassRoomScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final groupState = ref.watch(groupProvider);
    final groupId = groupState.group?.id;

    if (groupId == null || groupId.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text("Class Room")),
        backgroundColor: AppColors.bgBlue,
        body: const Center(
          child: Text(
            "Please select a group first",
            style: TextStyle(color: Colors.white, fontSize: 16),
          ),
        ),
      );
    }

    final classroomState = ref.watch(classroomProvider(groupId));
    final isLoading = classroomState.fetchState == AsyncState.loading;
    final courses = classroomState.courses ?? [];

    return Scaffold(
      appBar: AppBar(title: const Text("Class Room")),
      body: Padding(
        padding: const EdgeInsets.all(AppSizes.xs),
        child: Column(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      AppStrings.courses,
                      style: AppTextStyles.headline2(color: AppColors.white),
                    ),
                    Text(
                      "${courses.length.toString().padLeft(2, '0')} ${AppStrings.coursesAvailable}",
                      style: AppTextStyles.overLine(),
                    ),
                  ],
                ),
                AppButton(
                  isExpanded: false,
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (context) => const Dialog(
                        backgroundColor: AppColors.bgBlue,
                        child: CreateCourse(),
                      ),
                    );
                  },
                  prefix: const HugeIcon(
                    icon: HugeIconsStrokeRounded.addCircle,
                    color: AppColors.black,
                  ),
                  label: AppStrings.createCourse,
                  labelStyle: AppTextStyles.bodyText2(color: AppColors.black),
                  bgColor: AppColors.primaryOrange,
                  radius: AppSizes.xxxs,
                ),
              ],
            ),
            AppSizes.xs.ph,
            if (isLoading)
              const Expanded(
                child: Center(
                  child: CircularProgressIndicator(
                    color: AppColors.primaryOrange,
                  ),
                ),
              )
            else if (courses.isEmpty)
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const HugeIcon(
                      icon: HugeIconsStrokeRounded.bookOpen02,
                      color: AppColors.skyBlue,
                      size: 64,
                    ),
                    AppSizes.xs.ph,
                    Text(
                      "No courses available yet",
                      style: AppTextStyles.headline3(color: AppColors.white),
                    ),
                    AppSizes.xxxs.ph,
                    Text(
                      "Create your first course to start sharing knowledge!",
                      style: AppTextStyles.caption2(color: AppColors.skyBlue),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              )
            else
              Expanded(
                child: ListView.separated(
                  itemCount: courses.length,
                  separatorBuilder: (context, index) => AppSizes.xs.ph,
                  itemBuilder: (context, index) {
                    final course = courses[index];
                    return GestureDetector(
                      onTap: () {
                        context.push(
                          Routes.courseDetail.p,
                          extra: {
                            'courseId': course.id!,
                            'courseName': course.title ?? 'Course',
                          },
                        );
                      },
                      child: _buildCourseCard(context, course),
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildCourseCard(BuildContext context, CourseModel course) {
    final hasImage = course.image != null && course.image!.isNotEmpty;
    final isPaid = course.isPaid ?? false;

    return Container(
      decoration: BoxDecoration(
        color: AppColors.darkBgContainer,
        borderRadius: BorderRadius.circular(AppSizes.xs),
        border: Border.all(color: AppColors.skyBlue.withValues(alpha: 0.15)),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppSizes.xs),
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Course Thumbnail Banner
              Container(
                width: 100,
                decoration: BoxDecoration(
                  color: AppColors.iconColor,
                  image: hasImage
                      ? DecorationImage(
                          image: NetworkImage(course.image!),
                          fit: BoxFit.cover,
                        )
                      : null,
                ),
                child: !hasImage
                    ? const Center(
                        child: HugeIcon(
                          icon: HugeIconsStrokeRounded.book02,
                          color: AppColors.creamWhite,
                          size: 32,
                        ),
                      )
                    : null,
              ),
              // Course details
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(AppSizes.xs),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            course.title ?? 'Untitled Course',
                            style: AppTextStyles.bodyText1(
                              color: AppColors.white,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          AppSizes.xxxs.ph,
                          Text(
                            course.description ?? 'No description provided.',
                            style: AppTextStyles.caption2(
                              color: AppColors.skyBlue,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                      AppSizes.xxxs.ph,
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // Free vs Paid badge
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: isPaid
                                  ? AppColors.primaryOrange.withValues(
                                      alpha: 0.2,
                                    )
                                  : AppColors.green.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: isPaid
                                    ? AppColors.primaryOrange
                                    : AppColors.green,
                                width: 1,
                              ),
                            ),
                            child: Text(
                              isPaid
                                  ? "₹${course.price?.toStringAsFixed(0)}"
                                  : "FREE",
                              style: AppTextStyles.caption(
                                color: isPaid
                                    ? AppColors.primaryOrange
                                    : AppColors.green,
                              ),
                            ),
                          ),
                          // Subtle button or text for course entry
                          Text(
                            "View Modules",
                            style: AppTextStyles.caption(
                              color: AppColors.skyBlue,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
