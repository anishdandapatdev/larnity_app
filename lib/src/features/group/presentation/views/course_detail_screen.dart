import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:hugeicons/styles/stroke_rounded.dart';
import 'package:image_picker/image_picker.dart';
import 'package:larnity/src/core/constants/app_size.dart';
import 'package:larnity/src/core/extensions/extensions.dart';
import 'package:larnity/src/core/service/supabase/src/supabase_storage_service.dart';
import 'package:larnity/src/core/theme/app_colors.dart';
import 'package:larnity/src/core/theme/theme.dart';
import 'package:larnity/src/core/utils/async_states.dart';
import 'package:larnity/src/core/utils/logger.dart';
import 'package:larnity/src/core/utils/show_snackbar.dart';
import 'package:larnity/src/features/group/data/models/content_model.dart';
import 'package:larnity/src/features/group/data/models/module_model.dart';
import 'package:larnity/src/features/group/data/models/section_model.dart';
import 'package:larnity/src/features/group/presentation/provider/classroom_provider.dart';
import 'package:larnity/src/features/group/presentation/provider/group_provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

class ContentMediaHelper {
  static String? extractVideoUrl(String? html) {
    if (html == null) return null;
    final iframeMatch = RegExp(r'<iframe[^>]+src="([^">]+)"').firstMatch(html);
    if (iframeMatch != null) return iframeMatch.group(1);
    final videoMatch = RegExp(r'<video[^>]+src="([^">]+)"').firstMatch(html);
    if (videoMatch != null) return videoMatch.group(1);
    final urlMatch = RegExp(r'(https?://(?:www\.)?(?:youtube\.com|youtu\.be|vimeo\.com)[^\s<"&]+)').firstMatch(html);
    if (urlMatch != null) return urlMatch.group(1);
    return null;
  }

  static String? extractYoutubeId(String? urlOrHtml) {
    if (urlOrHtml == null) return null;
    final videoUrl = extractVideoUrl(urlOrHtml) ?? urlOrHtml;
    return YoutubePlayer.convertUrlToId(videoUrl);
  }

  static List<String> extractImageUrls(String? html) {
    if (html == null) return [];
    final matches = RegExp(r'<img[^>]+src="([^">]+)"').allMatches(html);
    return matches.map((m) => m.group(1)!).where((s) => s.isNotEmpty).toList();
  }

  static String cleanText(String? html) {
    if (html == null) return '';
    var text = html
        .replaceAll(RegExp(r'<iframe[^>]*>.*?</iframe>', dotAll: true), '')
        .replaceAll(RegExp(r'<video[^>]*>.*?</video>', dotAll: true), '')
        .replaceAll(RegExp(r'<img[^>]*>', dotAll: true), '')
        .replaceAll(RegExp(r'<br\s*/?>'), '\n')
        .replaceAll(RegExp(r'</p>'), '\n')
        .replaceAll(RegExp(r'<[^>]*>'), '')
        .replaceAll('&nbsp;', ' ')
        .replaceAll('&amp;', '&')
        .replaceAll('&quot;', '"')
        .replaceAll('&#39;', "'")
        .replaceAll('&lt;', '<')
        .replaceAll('&gt;', '>')
        .trim();
    return text;
  }

  static String buildHtmlContent({
    required String text,
    String? videoUrl,
    String? imageUrl,
  }) {
    final sb = StringBuffer();
    if (videoUrl != null && videoUrl.trim().isNotEmpty) {
      final trimmed = videoUrl.trim();
      final ytId = YoutubePlayer.convertUrlToId(trimmed);
      if (ytId != null) {
        sb.write('<iframe class="ql-video" frameborder="0" allowfullscreen="true" src="https://www.youtube.com/embed/$ytId?showinfo=0"></iframe><p><br></p>');
      } else if (trimmed.contains('vimeo.com')) {
        final vimeoMatch = RegExp(r'vimeo\.com/(?:video/)?(\d+)').firstMatch(trimmed);
        final vimeoId = vimeoMatch?.group(1) ?? trimmed;
        sb.write('<iframe class="ql-video" frameborder="0" allowfullscreen="true" src="https://player.vimeo.com/video/$vimeoId"></iframe><p><br></p>');
      } else {
        sb.write('<iframe class="ql-video" frameborder="0" allowfullscreen="true" src="$trimmed"></iframe><p><br></p>');
      }
    }
    if (imageUrl != null && imageUrl.trim().isNotEmpty) {
      sb.write('<img src="${imageUrl.trim()}" /><p><br></p>');
    }
    if (text.trim().isNotEmpty) {
      final lines = text.trim().split('\n');
      for (final line in lines) {
        if (line.trim().isEmpty) {
          sb.write('<p><br></p>');
        } else {
          sb.write('<p>${line.trim()}</p>');
        }
      }
    }
    return sb.toString();
  }
}

class CourseDetailScreen extends ConsumerStatefulWidget {
  final String courseId;
  final String courseName;
  final String? groupId;

  const CourseDetailScreen({
    super.key,
    required this.courseId,
    required this.courseName,
    this.groupId,
  });

  @override
  ConsumerState<CourseDetailScreen> createState() => _CourseDetailScreenState();
}

class _CourseDetailScreenState extends ConsumerState<CourseDetailScreen> {
  @override
  void initState() {
    super.initState();
    final groupId = widget.groupId ?? ref.read(groupProvider).group?.id;
    if (groupId != null) {
      Future.microtask(() {
        ref
            .read(classroomProvider(groupId).notifier)
            .fetchCourseDetail(courseId: widget.courseId);
      });
    }
  }

  void _showAddModuleDialog(String groupId, bool isOwnerOrAdmin) {
    if (!isOwnerOrAdmin) return;
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

  void _showAddSectionDialog(String moduleId, String groupId, bool isOwnerOrAdmin) {
    if (!isOwnerOrAdmin) return;
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

  void _showAddContentDialog(String sectionId, String groupId, bool isOwnerOrAdmin) {
    if (!isOwnerOrAdmin) return;
    _showAddOrEditContentDialog(
      context,
      sectionId: sectionId,
      groupId: groupId,
      isOwnerOrAdmin: isOwnerOrAdmin,
    );
  }

  void _showAddOrEditContentDialog(
    BuildContext context, {
    required String sectionId,
    required String groupId,
    required bool isOwnerOrAdmin,
    ContentModel? existing,
  }) {
    if (!isOwnerOrAdmin) return;
    showDialog(
      context: context,
      builder: (ctx) => _AddOrEditContentDialog(
        sectionId: sectionId,
        groupId: groupId,
        existing: existing,
      ),
    );
  }

  void _openContentViewer(ContentModel content, String groupId, bool isOwnerOrAdmin) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _ContentViewerModal(
        content: content,
        groupId: groupId,
        isOwnerOrAdmin: isOwnerOrAdmin,
        onEdit: () {
          Navigator.pop(ctx);
          _showAddOrEditContentDialog(
            context,
            sectionId: content.sectionId,
            groupId: groupId,
            isOwnerOrAdmin: isOwnerOrAdmin,
            existing: content,
          );
        },
        onDelete: () {
          Navigator.pop(ctx);
          ref
              .read(classroomProvider(groupId).notifier)
              .deleteContent(
                contentId: content.id!,
                successCallBack: () => showSuccessToast(content: "Content deleted"),
                failureCallBack: (err) => showErrorToast(content: err),
              );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final effectiveGroupId = widget.groupId ??
        ref.watch(groupProvider).group?.id;
    if (effectiveGroupId == null) {
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

    final isOwnerOrAdmin =
        ref.watch(isGroupAdminOrOwnerForGroupProvider(effectiveGroupId));
    final classroomState = ref.watch(classroomProvider(effectiveGroupId));
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
                  if (isOwnerOrAdmin)
                    GestureDetector(
                      onTap: () => _showAddModuleDialog(effectiveGroupId, isOwnerOrAdmin),
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
                    )
                  else
                    Padding(
                      padding: const EdgeInsets.only(top: AppSizes.xxs),
                      child: Text(
                        'No modules have been published for this course yet.',
                        style: AppTextStyles.caption(color: AppColors.skyBlue),
                        textAlign: TextAlign.center,
                      ),
                    ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(AppSizes.xs),
              itemCount: isOwnerOrAdmin ? modules.length + 1 : modules.length,
              itemBuilder: (context, index) {
                if (index == modules.length) {
                  return GestureDetector(
                    onTap: () => _showAddModuleDialog(effectiveGroupId, isOwnerOrAdmin),
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
                return _buildModuleTile(modules[index], effectiveGroupId, isOwnerOrAdmin);
              },
            ),
    );
  }

  Widget _buildModuleTile(ModuleModel module, String groupId, bool isOwnerOrAdmin) {
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
              if (isOwnerOrAdmin)
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
            ...sections.map((section) => _buildSectionTile(section, groupId, isOwnerOrAdmin)),
            if (isOwnerOrAdmin) ...[
              AppSizes.xxxs.ph,
              GestureDetector(
                onTap: () => _showAddSectionDialog(module.id!, groupId, isOwnerOrAdmin),
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
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTile(SectionModel section, String groupId, bool isOwnerOrAdmin) {
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
              if (isOwnerOrAdmin)
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
            ...contents.map((content) => _buildContentTile(content, groupId, isOwnerOrAdmin)),
            if (isOwnerOrAdmin) ...[
              const SizedBox(height: 4),
              GestureDetector(
                onTap: () => _showAddContentDialog(section.id!, groupId, isOwnerOrAdmin),
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
          ],
        ),
      ),
    );
  }

  Widget _buildContentTile(ContentModel content, String groupId, bool isOwnerOrAdmin) {
    final hasVideo = ContentMediaHelper.extractVideoUrl(content.content) != null ||
        ContentMediaHelper.extractYoutubeId(content.content) != null;
    final hasImages = ContentMediaHelper.extractImageUrls(content.content).isNotEmpty;
    final cleanDesc = ContentMediaHelper.cleanText(content.content);

    final dynamic typeIcon;
    final Color typeColor;
    final String typeLabel;

    if (hasVideo) {
      typeIcon = HugeIconsStrokeRounded.playCircle02;
      typeColor = AppColors.primaryOrange;
      typeLabel = "VIDEO";
    } else if (hasImages) {
      typeIcon = HugeIconsStrokeRounded.image01;
      typeColor = AppColors.purple;
      typeLabel = "IMAGE";
    } else {
      typeIcon = HugeIconsStrokeRounded.file02;
      typeColor = AppColors.green;
      typeLabel = "ARTICLE";
    }

    return GestureDetector(
      onTap: () => _openContentViewer(content, groupId, isOwnerOrAdmin),
      child: Container(
        margin: const EdgeInsets.only(bottom: 6),
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: AppColors.darkBgContainer,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppColors.skyBlue.withValues(alpha: 0.15)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                HugeIcon(
                  icon: typeIcon,
                  color: typeColor,
                  size: 18,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    content.title ?? 'Untitled Content',
                    style: AppTextStyles.bodyText2(color: AppColors.white),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: typeColor.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    typeLabel,
                    style: TextStyle(
                      color: typeColor,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                if (isOwnerOrAdmin) ...[
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: () {
                      _showAddOrEditContentDialog(
                        context,
                        sectionId: content.sectionId,
                        groupId: groupId,
                        isOwnerOrAdmin: isOwnerOrAdmin,
                        existing: content,
                      );
                    },
                    child: const HugeIcon(
                      icon: HugeIconsStrokeRounded.edit02,
                      color: AppColors.skyBlue,
                      size: 16,
                    ),
                  ),
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: () {
                      showDialog(
                        context: context,
                        builder: (ctx) => AlertDialog(
                          backgroundColor: AppColors.darkBgContainer,
                          title: const Text("Delete Content", style: TextStyle(color: Colors.white)),
                          content: Text("Are you sure you want to delete '${content.title}'?", style: const TextStyle(color: AppColors.creamWhite)),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(ctx),
                              child: const Text("Cancel", style: TextStyle(color: AppColors.skyBlue)),
                            ),
                            TextButton(
                              onPressed: () {
                                Navigator.pop(ctx);
                                ref
                                    .read(classroomProvider(groupId).notifier)
                                    .deleteContent(
                                      contentId: content.id!,
                                      successCallBack: () => showSuccessToast(content: "Content deleted"),
                                      failureCallBack: (err) => showErrorToast(content: err),
                                    );
                              },
                              child: const Text("Delete", style: TextStyle(color: AppColors.red)),
                            ),
                          ],
                        ),
                      );
                    },
                    child: const HugeIcon(
                      icon: HugeIconsStrokeRounded.delete02,
                      color: AppColors.red,
                      size: 16,
                    ),
                  ),
                ],
              ],
            ),
            if (cleanDesc.isNotEmpty) ...[
              const SizedBox(height: 6),
              Text(
                cleanDesc,
                style: AppTextStyles.caption2(color: AppColors.skyBlue),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _AddOrEditContentDialog extends ConsumerStatefulWidget {
  final String sectionId;
  final String groupId;
  final ContentModel? existing;

  const _AddOrEditContentDialog({
    required this.sectionId,
    required this.groupId,
    this.existing,
  });

  @override
  ConsumerState<_AddOrEditContentDialog> createState() => _AddOrEditContentDialogState();
}

class _AddOrEditContentDialogState extends ConsumerState<_AddOrEditContentDialog> {
  late final TextEditingController _titleController;
  late final TextEditingController _videoUrlController;
  late final TextEditingController _imageUrlController;
  late final TextEditingController _descriptionController;

  String _selectedType = 'TEXT'; // 'TEXT', 'VIDEO', 'IMAGE'
  File? _pickedImage;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.existing?.title ?? '');

    final existingHtml = widget.existing?.content;
    final existingVideo = ContentMediaHelper.extractVideoUrl(existingHtml);
    final existingImages = ContentMediaHelper.extractImageUrls(existingHtml);
    final cleanDesc = ContentMediaHelper.cleanText(existingHtml);

    _videoUrlController = TextEditingController(text: existingVideo ?? '');
    _imageUrlController = TextEditingController(text: existingImages.isNotEmpty ? existingImages.first : '');
    _descriptionController = TextEditingController(text: cleanDesc);

    if (existingVideo != null && existingVideo.isNotEmpty) {
      _selectedType = 'VIDEO';
    } else if (existingImages.isNotEmpty) {
      _selectedType = 'IMAGE';
    } else {
      _selectedType = 'TEXT';
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _videoUrlController.dispose();
    _imageUrlController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    try {
      final picker = ImagePicker();
      final picked = await picker.pickImage(source: ImageSource.gallery, imageQuality: 85);
      if (picked != null) {
        setState(() {
          _pickedImage = File(picked.path);
        });
      }
    } catch (e) {
      showErrorToast(content: "Failed to pick image: $e");
    }
  }

  Future<void> _submit() async {
    final title = _titleController.text.trim();
    if (title.isEmpty) {
      showErrorToast(content: "Please enter content title");
      return;
    }

    setState(() => _isLoading = true);

    try {
      String? imageUrl = _imageUrlController.text.trim().isNotEmpty ? _imageUrlController.text.trim() : null;
      if (_pickedImage != null) {
        try {
          final storage = ref.read(storageServiceProvider);
          final path = 'course_content/${widget.groupId}/${DateTime.now().millisecondsSinceEpoch}.jpg';
          imageUrl = await storage.uploadFile(
            bucket: StorageBucket.courseMedia,
            path: path,
            file: _pickedImage!,
          );
        } catch (e) {
          Log.error("Image upload failed: $e");
        }
      }

      final videoUrl = _selectedType == 'VIDEO' && _videoUrlController.text.trim().isNotEmpty
          ? _videoUrlController.text.trim()
          : null;

      final finalImageUrl = _selectedType == 'IMAGE' ? imageUrl : null;
      final desc = _descriptionController.text.trim();

      final html = ContentMediaHelper.buildHtmlContent(
        text: desc,
        videoUrl: videoUrl,
        imageUrl: finalImageUrl,
      );

      final notifier = ref.read(classroomProvider(widget.groupId).notifier);

      if (widget.existing != null) {
        final updated = widget.existing!.copyWith(
          title: title,
          content: html.isNotEmpty ? html : null,
        );
        await notifier.updateContent(
          content: updated,
          successCallBack: () {
            if (mounted) {
              setState(() => _isLoading = false);
              Navigator.pop(context);
              showSuccessToast(content: "Content updated successfully!");
            }
          },
          failureCallBack: (err) {
            if (mounted) {
              setState(() => _isLoading = false);
              showErrorToast(content: err);
            }
          },
        );
      } else {
        final newContent = ContentModel(
          sectionId: widget.sectionId,
          title: title,
          content: html.isNotEmpty ? html : null,
        );
        await notifier.createContent(
          content: newContent,
          successCallBack: () {
            if (mounted) {
              setState(() => _isLoading = false);
              Navigator.pop(context);
              showSuccessToast(content: "Content added successfully!");
            }
          },
          failureCallBack: (err) {
            if (mounted) {
              setState(() => _isLoading = false);
              showErrorToast(content: err);
            }
          },
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        showErrorToast(content: "Failed to save content: $e");
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: AppColors.bgBlue,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: AppColors.skyBlue.withValues(alpha: 0.2)),
      ),
      title: Text(
        widget.existing != null ? 'Edit Content' : 'Add Content',
        style: const TextStyle(color: AppColors.white),
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title
            TextField(
              controller: _titleController,
              style: const TextStyle(color: AppColors.white),
              decoration: InputDecoration(
                hintText: 'Content title (required)',
                hintStyle: const TextStyle(color: AppColors.skyBlue),
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: AppColors.skyBlue),
                ),
                focusedBorder: const UnderlineInputBorder(
                  borderSide: BorderSide(color: AppColors.primaryOrange),
                ),
              ),
            ),
            const SizedBox(height: 16),
            // Type Selector
            const Text(
              "Content Type",
              style: TextStyle(color: AppColors.creamWhite, fontSize: 13, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                _buildTypeChip("TEXT", "Article / Text", HugeIconsStrokeRounded.file02),
                const SizedBox(width: 8),
                _buildTypeChip("VIDEO", "Video", HugeIconsStrokeRounded.playCircle02),
                const SizedBox(width: 8),
                _buildTypeChip("IMAGE", "Image", HugeIconsStrokeRounded.image01),
              ],
            ),
            const SizedBox(height: 16),
            // Video Input
            if (_selectedType == 'VIDEO') ...[
              TextField(
                controller: _videoUrlController,
                style: const TextStyle(color: AppColors.white),
                decoration: InputDecoration(
                  hintText: 'YouTube or Vimeo URL (e.g. youtu.be/...)',
                  hintStyle: const TextStyle(color: AppColors.skyBlue, fontSize: 12),
                  prefixIcon: const Icon(Icons.video_collection_outlined, color: AppColors.primaryOrange, size: 20),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: AppColors.skyBlue.withValues(alpha: 0.5)),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: const BorderSide(color: AppColors.primaryOrange),
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
              const SizedBox(height: 12),
            ],
            // Image Input
            if (_selectedType == 'IMAGE') ...[
              Row(
                children: [
                  ElevatedButton.icon(
                    onPressed: _pickImage,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.purple,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    icon: const Icon(Icons.photo_library, size: 18),
                    label: const Text("Pick Image"),
                  ),
                  const SizedBox(width: 12),
                  if (_pickedImage != null)
                    ClipRRect(
                      borderRadius: BorderRadius.circular(6),
                      child: Image.file(_pickedImage!, height: 40, width: 40, fit: BoxFit.cover),
                    ),
                ],
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _imageUrlController,
                style: const TextStyle(color: AppColors.white),
                decoration: InputDecoration(
                  hintText: 'Or enter image URL (https://...)',
                  hintStyle: const TextStyle(color: AppColors.skyBlue, fontSize: 12),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: AppColors.skyBlue.withValues(alpha: 0.5)),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: const BorderSide(color: AppColors.primaryOrange),
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
              const SizedBox(height: 12),
            ],
            // Description / Text
            TextField(
              controller: _descriptionController,
              style: const TextStyle(color: AppColors.white),
              maxLines: 4,
              minLines: 2,
              decoration: InputDecoration(
                hintText: _selectedType == 'TEXT' ? 'Article / Notes content' : 'Description / Notes (optional)',
                hintStyle: const TextStyle(color: AppColors.skyBlue, fontSize: 12),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: AppColors.skyBlue.withValues(alpha: 0.5)),
                  borderRadius: BorderRadius.circular(8),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: const BorderSide(color: AppColors.primaryOrange),
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isLoading ? null : () => Navigator.pop(context),
          child: const Text('Cancel', style: TextStyle(color: AppColors.skyBlue)),
        ),
        ElevatedButton(
          onPressed: _isLoading ? null : _submit,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primaryOrange,
            foregroundColor: Colors.black,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
          child: _isLoading
              ? const SizedBox(
                  height: 16,
                  width: 16,
                  child: CircularProgressIndicator(strokeWidth: 2, color: Colors.black),
                )
              : Text(widget.existing != null ? 'Update' : 'Add'),
        ),
      ],
    );
  }

  Widget _buildTypeChip(String type, String label, dynamic icon) {
    final isSelected = _selectedType == type;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedType = type),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primaryOrange : AppColors.darkBgContainer,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: isSelected ? AppColors.primaryOrange : AppColors.skyBlue.withValues(alpha: 0.3),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              HugeIcon(
                icon: icon,
                color: isSelected ? Colors.black : Colors.white,
                size: 16,
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  color: isSelected ? Colors.black : Colors.white,
                  fontSize: 10,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ContentViewerModal extends StatefulWidget {
  final ContentModel content;
  final String groupId;
  final bool isOwnerOrAdmin;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const _ContentViewerModal({
    required this.content,
    required this.groupId,
    required this.isOwnerOrAdmin,
    this.onEdit,
    this.onDelete,
  });

  @override
  State<_ContentViewerModal> createState() => _ContentViewerModalState();
}

class _ContentViewerModalState extends State<_ContentViewerModal> {
  YoutubePlayerController? _youtubeController;
  String? _youtubeId;
  String? _videoUrl;
  List<String> _imageUrls = [];
  String _cleanText = '';

  @override
  void initState() {
    super.initState();
    final html = widget.content.content;
    _youtubeId = ContentMediaHelper.extractYoutubeId(html);
    _videoUrl = ContentMediaHelper.extractVideoUrl(html);
    _imageUrls = ContentMediaHelper.extractImageUrls(html);
    _cleanText = ContentMediaHelper.cleanText(html);

    if (_youtubeId != null) {
      _youtubeController = YoutubePlayerController(
        initialVideoId: _youtubeId!,
        flags: const YoutubePlayerFlags(
          autoPlay: false,
          mute: false,
          enableCaption: true,
        ),
      );
    }
  }

  @override
  void dispose() {
    _youtubeController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.85,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (ctx, scrollController) => Container(
        decoration: const BoxDecoration(
          color: AppColors.bgBlue,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: ListView(
          controller: scrollController,
          padding: const EdgeInsets.all(AppSizes.sm),
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.white24,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            AppSizes.xs.ph,
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    widget.content.title ?? 'Content',
                    style: AppTextStyles.headline3(color: Colors.white),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close, color: Colors.white),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            if (widget.isOwnerOrAdmin) ...[
              Row(
                children: [
                  TextButton.icon(
                    onPressed: widget.onEdit,
                    icon: const Icon(Icons.edit, size: 16, color: AppColors.skyBlue),
                    label: const Text("Edit", style: TextStyle(color: AppColors.skyBlue)),
                  ),
                  TextButton.icon(
                    onPressed: widget.onDelete,
                    icon: const Icon(Icons.delete, size: 16, color: AppColors.red),
                    label: const Text("Delete", style: TextStyle(color: AppColors.red)),
                  ),
                ],
              ),
              const Divider(color: Colors.white12),
            ],
            // Embedded YouTube Video
            if (_youtubeController != null) ...[
              AppSizes.xs.ph,
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: YoutubePlayer(
                  controller: _youtubeController!,
                  showVideoProgressIndicator: true,
                  progressIndicatorColor: AppColors.primaryOrange,
                  progressColors: const ProgressBarColors(
                    playedColor: AppColors.primaryOrange,
                    handleColor: AppColors.primaryOrange,
                  ),
                ),
              ),
              AppSizes.sm.ph,
            ] else if (_videoUrl != null && _videoUrl!.isNotEmpty) ...[
              AppSizes.xs.ph,
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.darkBgContainer,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.primaryOrange.withValues(alpha: 0.3)),
                ),
                child: Column(
                  children: [
                    const Icon(Icons.play_circle_fill, size: 48, color: AppColors.primaryOrange),
                    const SizedBox(height: 8),
                    Text(
                      _videoUrl!,
                      style: const TextStyle(color: AppColors.skyBlue, fontSize: 12),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 12),
                    ElevatedButton.icon(
                      onPressed: () async {
                        final uri = Uri.tryParse(_videoUrl!);
                        if (uri != null && await canLaunchUrl(uri)) {
                          await launchUrl(uri, mode: LaunchMode.externalApplication);
                        } else {
                          showErrorToast(content: "Could not open video URL");
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryOrange,
                        foregroundColor: Colors.black,
                      ),
                      icon: const Icon(Icons.open_in_new, size: 18),
                      label: const Text("Watch Video"),
                    ),
                  ],
                ),
              ),
              AppSizes.sm.ph,
            ],
            // Images
            if (_imageUrls.isNotEmpty) ...[
              for (final imgUrl in _imageUrls) ...[
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.network(
                    imgUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      height: 120,
                      color: AppColors.darkBgContainer,
                      child: const Center(
                        child: Icon(Icons.broken_image, color: AppColors.skyBlue),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
              ],
            ],
            // Text Notes
            if (_cleanText.isNotEmpty) ...[
              AppSizes.xs.ph,
              Text(
                "Notes & Content",
                style: AppTextStyles.subtitle2(color: AppColors.skyBlue),
              ),
              AppSizes.xxs.ph,
              SelectableText(
                _cleanText,
                style: AppTextStyles.bodyText1(color: AppColors.creamWhite),
              ),
            ],
            AppSizes.lg.ph,
          ],
        ),
      ),
    );
  }
}
