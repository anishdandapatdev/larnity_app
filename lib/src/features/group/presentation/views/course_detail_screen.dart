import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:hugeicons/styles/stroke_rounded.dart';
import 'package:larnity/src/core/constants/app_size.dart';
import 'package:larnity/src/core/extensions/extensions.dart';
import 'package:larnity/src/core/theme/app_colors.dart';
import 'package:larnity/src/core/theme/theme.dart';
import 'package:larnity/src/core/utils/async_states.dart';
import 'package:larnity/src/features/group/data/models/content_model.dart';
import 'package:larnity/src/features/group/data/models/module_model.dart';
import 'package:larnity/src/features/group/data/models/section_model.dart';
import 'package:larnity/src/features/group/presentation/provider/classroom_provider.dart';
import 'package:larnity/src/features/group/presentation/provider/group_provider.dart';

class CourseDetailScreen extends ConsumerStatefulWidget {
  final String courseId;
  final String courseName;

  const CourseDetailScreen({
    super.key,
    required this.courseId,
    required this.courseName,
  });

  @override
  ConsumerState<CourseDetailScreen> createState() => _CourseDetailScreenState();
}

class _CourseDetailScreenState extends ConsumerState<CourseDetailScreen> {
  @override
  void initState() {
    super.initState();
    final groupId = ref.read(groupProvider).group?.id;
    if (groupId != null) {
      Future.microtask(() {
        ref
            .read(classroomProvider(groupId).notifier)
            .fetchCourseDetail(courseId: widget.courseId);
      });
    }
  }

  void _showAddModuleDialog() {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.bgBlue,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: AppColors.skyBlue.withValues(alpha: 0.2)),
        ),
        title: const Text(
          'Add Module',
          style: TextStyle(color: AppColors.white),
        ),
        content: TextField(
          controller: controller,
          style: const TextStyle(color: AppColors.white),
          decoration: InputDecoration(
            hintText: 'Module title',
            hintStyle: const TextStyle(color: AppColors.skyBlue),
            enabledBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: AppColors.skyBlue),
            ),
            focusedBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: AppColors.primaryOrange),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text(
              'Cancel',
              style: TextStyle(color: AppColors.skyBlue),
            ),
          ),
          TextButton(
            onPressed: () {
              final title = controller.text.trim();
              if (title.isEmpty) return;
              final groupId = ref.read(groupProvider).group?.id;
              if (groupId == null) return;
              ref
                  .read(classroomProvider(groupId).notifier)
                  .createModule(
                    module: ModuleModel(
                      courseId: widget.courseId,
                      title: title,
                    ),
                    successCallBack: () => Navigator.pop(ctx),
                    failureCallBack: (err) {
                      ScaffoldMessenger.of(
                        context,
                      ).showSnackBar(SnackBar(content: Text(err)));
                    },
                  );
            },
            child: const Text(
              'Add',
              style: TextStyle(color: AppColors.primaryOrange),
            ),
          ),
        ],
      ),
    );
  }

  void _showAddSectionDialog(String moduleId) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.bgBlue,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: AppColors.skyBlue.withValues(alpha: 0.2)),
        ),
        title: const Text(
          'Add Section',
          style: TextStyle(color: AppColors.white),
        ),
        content: TextField(
          controller: controller,
          style: const TextStyle(color: AppColors.white),
          decoration: InputDecoration(
            hintText: 'Section name',
            hintStyle: const TextStyle(color: AppColors.skyBlue),
            enabledBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: AppColors.skyBlue),
            ),
            focusedBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: AppColors.primaryOrange),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text(
              'Cancel',
              style: TextStyle(color: AppColors.skyBlue),
            ),
          ),
          TextButton(
            onPressed: () {
              final name = controller.text.trim();
              if (name.isEmpty) return;
              final groupId = ref.read(groupProvider).group?.id;
              if (groupId == null) return;
              ref
                  .read(classroomProvider(groupId).notifier)
                  .createSection(
                    section: SectionModel(moduleId: moduleId, name: name),
                    successCallBack: () => Navigator.pop(ctx),
                    failureCallBack: (err) {
                      ScaffoldMessenger.of(
                        context,
                      ).showSnackBar(SnackBar(content: Text(err)));
                    },
                  );
            },
            child: const Text(
              'Add',
              style: TextStyle(color: AppColors.primaryOrange),
            ),
          ),
        ],
      ),
    );
  }

  void _showAddContentDialog(String sectionId) {
    final titleController = TextEditingController();
    final contentController = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.bgBlue,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: AppColors.skyBlue.withValues(alpha: 0.2)),
        ),
        title: const Text(
          'Add Content',
          style: TextStyle(color: AppColors.white),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: titleController,
              style: const TextStyle(color: AppColors.white),
              decoration: InputDecoration(
                hintText: 'Content title',
                hintStyle: const TextStyle(color: AppColors.skyBlue),
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: AppColors.skyBlue),
                ),
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: AppColors.primaryOrange),
                ),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: contentController,
              style: const TextStyle(color: AppColors.white),
              maxLines: 5,
              minLines: 3,
              decoration: InputDecoration(
                hintText: 'Content text (optional)',
                hintStyle: const TextStyle(color: AppColors.skyBlue),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                    color: AppColors.skyBlue.withValues(alpha: 0.5),
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: AppColors.primaryOrange),
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text(
              'Cancel',
              style: TextStyle(color: AppColors.skyBlue),
            ),
          ),
          TextButton(
            onPressed: () {
              final title = titleController.text.trim();
              if (title.isEmpty) return;
              final groupId = ref.read(groupProvider).group?.id;
              if (groupId == null) return;
              ref
                  .read(classroomProvider(groupId).notifier)
                  .createContent(
                    content: ContentModel(
                      sectionId: sectionId,
                      title: title,
                      content: contentController.text.trim().isNotEmpty
                          ? contentController.text.trim()
                          : null,
                    ),
                    successCallBack: () => Navigator.pop(ctx),
                    failureCallBack: (err) {
                      ScaffoldMessenger.of(
                        context,
                      ).showSnackBar(SnackBar(content: Text(err)));
                    },
                  );
            },
            child: const Text(
              'Add',
              style: TextStyle(color: AppColors.primaryOrange),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final groupId = ref.watch(groupProvider).group?.id;
    if (groupId == null) {
      return Scaffold(
        backgroundColor: AppColors.bgBlue,
        appBar: AppBar(title: Text(widget.courseName)),
        body: const Center(
          child: Text(
            'No group selected',
            style: TextStyle(color: Colors.white),
          ),
        ),
      );
    }

    final classroomState = ref.watch(classroomProvider(groupId));
    final isLoading = classroomState.detailState == AsyncState.loading;
    final course = classroomState.selectedCourse;
    final modules = course?.modules ?? [];

    return Scaffold(
      backgroundColor: AppColors.bgBlue,
      appBar: AppBar(
        title: Text(widget.courseName),
      ),
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.primaryOrange),
            )
          : modules.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const HugeIcon(
                    icon: HugeIconsStrokeRounded.folder02,
                    color: AppColors.skyBlue,
                    size: 64,
                  ),
                  AppSizes.xs.ph,
                  Text(
                    'No modules yet',
                    style: AppTextStyles.headline3(color: AppColors.white),
                  ),
                  AppSizes.xxxs.ph,
                  GestureDetector(
                    onTap: _showAddModuleDialog,
                    child: Container(
                      margin: const EdgeInsets.only(top: AppSizes.sm),
                      padding: const EdgeInsets.symmetric(
                        vertical: 10,
                        horizontal: 16,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.primaryOrange.withValues(alpha: 0.1),
                        border: Border.all(color: AppColors.primaryOrange.withValues(alpha: 0.5)),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const HugeIcon(
                            icon: HugeIconsStrokeRounded.addCircle,
                            color: AppColors.primaryOrange,
                            size: 18,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Add your first module',
                            style: AppTextStyles.bodyText2(color: AppColors.primaryOrange),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(AppSizes.xs),
              itemCount: modules.length + 1,
              itemBuilder: (context, index) {
                if (index == modules.length) {
                  return GestureDetector(
                    onTap: _showAddModuleDialog,
                    child: Container(
                      margin: const EdgeInsets.only(top: AppSizes.xs),
                      padding: const EdgeInsets.symmetric(
                        vertical: 12,
                        horizontal: 16,
                      ),
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: AppColors.primaryOrange.withValues(alpha: 0.3),
                        ),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const HugeIcon(
                            icon: HugeIconsStrokeRounded.addCircle,
                            color: AppColors.primaryOrange,
                            size: 18,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Add Module',
                            style: AppTextStyles.bodyText1(
                              color: AppColors.primaryOrange,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }
                return _buildModuleTile(modules[index], groupId);
              },
            ),
    );
  }

  Widget _buildModuleTile(ModuleModel module, String groupId) {
    final sections = module.sections ?? [];
    return Container(
      margin: const EdgeInsets.only(bottom: AppSizes.xs),
      decoration: BoxDecoration(
        color: AppColors.darkBgContainer,
        borderRadius: BorderRadius.circular(AppSizes.xs),
        border: Border.all(color: AppColors.skyBlue.withValues(alpha: 0.15)),
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          tilePadding: const EdgeInsets.symmetric(horizontal: AppSizes.xs),
          childrenPadding: const EdgeInsets.only(
            left: AppSizes.xs,
            right: AppSizes.xs,
            bottom: AppSizes.xs,
          ),
          iconColor: AppColors.skyBlue,
          collapsedIconColor: AppColors.skyBlue,
          title: Row(
            children: [
              const HugeIcon(
                icon: HugeIconsStrokeRounded.bookOpen02,
                color: AppColors.primaryOrange,
                size: 20,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  module.title ?? 'Untitled Module',
                  style: AppTextStyles.bodyText1(color: AppColors.white),
                ),
              ),
              GestureDetector(
                onTap: () {
                  ref
                      .read(classroomProvider(groupId).notifier)
                      .deleteModule(
                        moduleId: module.id!,
                        failureCallBack: (err) {
                          ScaffoldMessenger.of(
                            context,
                          ).showSnackBar(SnackBar(content: Text(err)));
                        },
                      );
                },
                child: const HugeIcon(
                  icon: HugeIconsStrokeRounded.delete02,
                  color: AppColors.red,
                  size: 18,
                ),
              ),
            ],
          ),
          children: [
            ...sections.map((section) => _buildSectionTile(section, groupId)),
            AppSizes.xxxs.ph,
            GestureDetector(
              onTap: () => _showAddSectionDialog(module.id!),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  vertical: 10,
                  horizontal: 12,
                ),
                decoration: BoxDecoration(
                  border: Border.all(
                    color: AppColors.skyBlue.withValues(alpha: 0.3),
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const HugeIcon(
                      icon: HugeIconsStrokeRounded.addCircle,
                      color: AppColors.skyBlue,
                      size: 16,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'Add Section',
                      style: AppTextStyles.caption(color: AppColors.skyBlue),
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

  Widget _buildSectionTile(SectionModel section, String groupId) {
    final contents = section.contents ?? [];
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: AppColors.bgBlue.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.skyBlue.withValues(alpha: 0.1)),
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          tilePadding: const EdgeInsets.symmetric(horizontal: 12),
          childrenPadding: const EdgeInsets.only(
            left: 12,
            right: 12,
            bottom: 8,
          ),
          iconColor: AppColors.skyBlue,
          collapsedIconColor: AppColors.skyBlue,
          title: Row(
            children: [
              const HugeIcon(
                icon: HugeIconsStrokeRounded.file02,
                color: AppColors.blue,
                size: 18,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  section.name ?? 'Untitled Section',
                  style: AppTextStyles.bodyText2(color: AppColors.creamWhite),
                ),
              ),
              GestureDetector(
                onTap: () {
                  ref
                      .read(classroomProvider(groupId).notifier)
                      .deleteSection(
                        sectionId: section.id!,
                        failureCallBack: (err) {
                          ScaffoldMessenger.of(
                            context,
                          ).showSnackBar(SnackBar(content: Text(err)));
                        },
                      );
                },
                child: const HugeIcon(
                  icon: HugeIconsStrokeRounded.delete02,
                  color: AppColors.red,
                  size: 16,
                ),
              ),
            ],
          ),
          children: [
            ...contents.map((content) => _buildContentTile(content, groupId)),
            const SizedBox(height: 4),
            GestureDetector(
              onTap: () => _showAddContentDialog(section.id!),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  vertical: 8,
                  horizontal: 10,
                ),
                decoration: BoxDecoration(
                  border: Border.all(
                    color: AppColors.primaryOrange.withValues(alpha: 0.3),
                  ),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const HugeIcon(
                      icon: HugeIconsStrokeRounded.addCircle,
                      color: AppColors.primaryOrange,
                      size: 14,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'Add Content',
                      style: AppTextStyles.caption(
                        color: AppColors.primaryOrange,
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

  Widget _buildContentTile(ContentModel content, String groupId) {
    return Container(
      margin: const EdgeInsets.only(bottom: 6),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: AppColors.darkBgContainer,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: AppColors.skyBlue.withValues(alpha: 0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const HugeIcon(
                icon: HugeIconsStrokeRounded.textSquare,
                color: AppColors.green,
                size: 16,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  content.title ?? 'Untitled',
                  style: AppTextStyles.bodyText2(color: AppColors.white),
                ),
              ),
              GestureDetector(
                onTap: () {
                  ref
                      .read(classroomProvider(groupId).notifier)
                      .deleteContent(
                        contentId: content.id!,
                        failureCallBack: (err) {
                          ScaffoldMessenger.of(
                            context,
                          ).showSnackBar(SnackBar(content: Text(err)));
                        },
                      );
                },
                child: const HugeIcon(
                  icon: HugeIconsStrokeRounded.delete02,
                  color: AppColors.red,
                  size: 14,
                ),
              ),
            ],
          ),
          if (content.content != null && content.content!.isNotEmpty) ...[
            const SizedBox(height: 6),
            Text(
              content.content!,
              style: AppTextStyles.caption2(color: AppColors.skyBlue),
              maxLines: 5,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ],
      ),
    );
  }
}
