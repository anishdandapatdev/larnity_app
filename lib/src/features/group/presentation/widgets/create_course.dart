import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:larnity/src/core/constants/app_size.dart';
import 'package:larnity/src/core/constants/app_strings.dart';
import 'package:larnity/src/core/extensions/extensions.dart';
import 'package:larnity/src/core/theme/app_colors.dart';
import 'package:larnity/src/core/theme/theme.dart';
import 'package:larnity/src/core/ui/widgets/app_button.dart';
import 'package:larnity/src/core/ui/widgets/dialog_header.dart';
import 'package:larnity/src/features/group/data/models/course_model.dart';
import 'package:larnity/src/features/group/presentation/provider/classroom_provider.dart';
import 'package:larnity/src/features/group/presentation/provider/group_provider.dart';

class CreateCourse extends ConsumerStatefulWidget {
  const CreateCourse({super.key});

  @override
  ConsumerState<CreateCourse> createState() => _CreateCourseState();
}

class _CreateCourseState extends ConsumerState<CreateCourse> {
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _priceController = TextEditingController();

  bool _isPaid = false; // Default public
  bool _isSaving = false;

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  Future<void> _saveCourse() async {
    final title = _nameController.text.trim();
    final description = _descriptionController.text.trim();

    if (title.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Course name is required")));
      return;
    }

    if (description.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Course description is required")),
      );
      return;
    }

    int? price;
    if (_isPaid) {
      final priceStr = _priceController.text.trim();
      if (priceStr.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Price is required for paid courses")),
        );
        return;
      }
      price = int.tryParse(priceStr);
      if (price == null || price <= 0) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Please enter a valid price (whole number)"),
          ),
        );
        return;
      }
    }

    final group = ref.read(groupProvider).group;
    final groupId = group?.id;
    if (groupId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("No group selected. Please select a group first."),
        ),
      );
      return;
    }

    setState(() => _isSaving = true);

    try {
      // 1. Construct CourseModel
      final course = CourseModel(
        groupId: groupId,
        title: title,
        description: description,
        image: null,
        isPaid: _isPaid,
        price: _isPaid ? price : 0,
        isPublished: true,
      );

      // 3. Call Provider
      await ref
          .read(classroomProvider(groupId).notifier)
          .createCourse(
            course: course,
            successCallBack: () {
              if (!mounted) return;
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Course created successfully")),
              );
            },
            failureCallBack: (error) {
              if (!mounted) return;
              setState(() => _isSaving = false);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text("Failed to create course: $error")),
              );
            },
          );
    } catch (e) {
      if (!mounted) return;
      setState(() => _isSaving = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error: $e")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppSizes.xs),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            DialogHeader(
              title: AppStrings.createNewCourse,
              description: AppStrings.createNewCourseDesc,
            ),
            Text(AppStrings.courseName, style: AppTextStyles.overLine()),
            AppSizes.xxxs.ph,
            TextFormField(
              controller: _nameController,
              style: AppTextStyles.bodyText2(color: AppColors.white),
              decoration: InputDecoration(
                filled: true,
                fillColor: AppColors.darkBgContainer,
                hintText: AppStrings.courseNameHint,
                hintStyle: AppTextStyles.button(color: AppColors.skyBlue),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppSizes.xxxs),
                  borderSide: BorderSide(
                    color: AppColors.skyBlue.withValues(alpha: 0.5),
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppSizes.xxxs),
                  borderSide: BorderSide(color: AppColors.skyBlue),
                ),
              ),
            ),

            AppSizes.xs.ph,
            Text(AppStrings.courseDescription, style: AppTextStyles.overLine()),
            AppSizes.xxxs.ph,
            TextFormField(
              controller: _descriptionController,
              style: AppTextStyles.bodyText2(color: AppColors.white),
              decoration: InputDecoration(
                filled: true,
                fillColor: AppColors.darkBgContainer,
                hintText: AppStrings.courseDescriptionHint,
                hintStyle: AppTextStyles.button(color: AppColors.skyBlue),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppSizes.xxxs),
                  borderSide: BorderSide(
                    color: AppColors.skyBlue.withValues(alpha: 0.5),
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppSizes.xxxs),
                  borderSide: BorderSide(color: AppColors.skyBlue),
                ),
              ),
              maxLines: 5,
              minLines: 2,
            ),
            AppSizes.xs.ph,
            Text(AppStrings.courseAccess, style: AppTextStyles.overLine()),
            AppSizes.xxxs.ph,
            Row(
              children: [
                Expanded(
                  child: AppButton(
                    onPressed: () => setState(() => _isPaid = false),
                    bgColor: !_isPaid
                        ? AppColors.primaryOrange
                        : AppColors.white.withValues(alpha: 0.1),
                    label: AppStrings.public,
                    labelStyle: AppTextStyles.bodyText2(
                      color: !_isPaid ? AppColors.black : AppColors.white,
                    ),
                  ),
                ),
                AppSizes.xs.pw,
                Expanded(
                  child: AppButton(
                    onPressed: () => setState(() => _isPaid = true),
                    bgColor: _isPaid
                        ? AppColors.primaryOrange
                        : AppColors.white.withValues(alpha: 0.1),
                    label: AppStrings.paid,
                    labelStyle: AppTextStyles.bodyText2(
                      color: _isPaid ? AppColors.black : AppColors.white,
                    ),
                  ),
                ),
              ],
            ),

            if (_isPaid) ...[
              AppSizes.xs.ph,
              Text(AppStrings.coursePrice, style: AppTextStyles.overLine()),
              AppSizes.xxxs.ph,
              TextFormField(
                controller: _priceController,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                style: AppTextStyles.bodyText2(color: AppColors.white),
                decoration: InputDecoration(
                  filled: true,
                  fillColor: AppColors.darkBgContainer,
                  hintText: AppStrings.coursePriceHint,
                  hintStyle: AppTextStyles.button(color: AppColors.skyBlue),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppSizes.xxxs),
                    borderSide: BorderSide(
                      color: AppColors.skyBlue.withValues(alpha: 0.5),
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppSizes.xxxs),
                    borderSide: BorderSide(color: AppColors.skyBlue),
                  ),
                ),
              ),
            ],

            AppSizes.xs.ph,

            AppButton(
              onPressed: _saveCourse,
              isLoading: _isSaving,
              loadingWidget: const CircularProgressIndicator(
                color: AppColors.white,
              ),
              label: AppStrings.create,
              labelStyle: AppTextStyles.bodyText2(color: AppColors.white),
              bgColor: Colors.transparent,
              borderColor: AppColors.skyBlue.withValues(alpha: 0.5),
              radius: AppSizes.xxxs,
            ),
          ],
        ),
      ),
    );
  }
}
