import 'dart:io';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:hugeicons/styles/stroke_rounded.dart';
import 'package:image_picker/image_picker.dart';
import 'package:larnity/src/core/constants/app_size.dart';
import 'package:larnity/src/core/constants/app_strings.dart';
import 'package:larnity/src/core/extensions/extensions.dart';
import 'package:larnity/src/core/service/supabase/src/supabase_storage_service.dart';
import 'package:larnity/src/core/theme/app_colors.dart';
import 'package:larnity/src/core/theme/theme.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:larnity/src/core/ui/widgets/app_button.dart';
import 'package:larnity/src/core/utils/logger.dart';
import 'package:larnity/src/core/utils/show_snackbar.dart';
import 'package:larnity/src/features/group/presentation/provider/discussion_provider.dart';
import 'package:larnity/src/features/group/data/models/post_model.dart';
import 'package:larnity/src/core/service/supabase/src/supabase_provider.dart';

class CreatePost extends ConsumerStatefulWidget {
  final String channelId;
  final String groupId;
  const CreatePost({
    super.key,
    required this.channelId,
    required this.groupId,
  });

  @override
  ConsumerState<CreatePost> createState() => _CreatePostState();
}

class _CreatePostState extends ConsumerState<CreatePost> {
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  File? _pickedImage;
  bool _isLoading = false;

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    try {
      final picker = ImagePicker();
      final picked = await picker.pickImage(source: ImageSource.gallery, imageQuality: 85);
      if (picked != null) {
        setState(() => _pickedImage = File(picked.path));
      }
    } catch (e) {
      showErrorToast(content: "Failed to pick image: $e");
    }
  }

  Future<void> _submitPost() async {
    final content = _contentController.text.trim();
    if (content.isEmpty && _pickedImage == null) {
      showErrorToast(content: "Please enter content or attach an image");
      return;
    }

    final authorId = ref.read(supabaseClientProvider).auth.currentUser?.id;
    if (authorId == null) {
      showErrorToast(content: "User not authenticated");
      return;
    }

    setState(() => _isLoading = true);

    try {
      String? imageUrl;
      if (_pickedImage != null) {
        try {
          final storage = ref.read(storageServiceProvider);
          final path = 'posts/${widget.groupId}/${DateTime.now().millisecondsSinceEpoch}.jpg';
          imageUrl = await storage.uploadFile(
            bucket: StorageBucket.postMedia,
            path: path,
            file: _pickedImage!,
          );
        } catch (e) {
          Log.error("Post image upload failed: $e");
        }
      }

      final title = _titleController.text.trim();
      final postHtml = imageUrl != null
          ? '<img src="$imageUrl" /><p>$content</p>'
          : '<p>$content</p>';

      final postModel = PostModel(
        channelId: widget.channelId,
        authorId: authorId,
        title: title.isEmpty ? null : title,
        content: content.isNotEmpty ? content : 'Photo',
        htmlContent: postHtml,
      );

      await ref.read(discussionProvider(widget.groupId).notifier).createPost(
        post: postModel,
        successCallBack: () {
          if (mounted) {
            setState(() => _isLoading = false);
            context.pop();
            showSuccessToast(content: "Post shared successfully!");
          }
        },
        failureCallBack: (err) {
          if (mounted) {
            setState(() => _isLoading = false);
            showErrorToast(content: err);
          }
        },
      );
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        showErrorToast(content: "Failed to post: $e");
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(AppSizes.sm),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Container(
                  height: 36,
                  width: 36,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.primaryOrange,
                  ),
                  child: const Center(
                    child: Icon(Icons.person, color: Colors.black, size: 20),
                  ),
                ),
                AppSizes.xs.pw,
                RichText(
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text: AppStrings.postingIn,
                        style: AppTextStyles.subtitle2(color: AppColors.skyBlue),
                      ),
                      const TextSpan(
                        text: " General",
                        style: TextStyle(color: AppColors.white, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.close, color: Colors.white),
                  onPressed: () => context.pop(),
                ),
              ],
            ),
            AppSizes.sm.ph,
            TextFormField(
              controller: _titleController,
              style: const TextStyle(color: AppColors.white),
              decoration: InputDecoration(
                hintText: AppStrings.postTitle,
                hintStyle: AppTextStyles.button(color: AppColors.skyBlue),
                filled: true,
                fillColor: AppColors.darkBg,
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: AppColors.skyBlue.withValues(alpha: 0.2)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: AppColors.primaryOrange),
                ),
              ),
            ),
            AppSizes.xs.ph,
            TextFormField(
              controller: _contentController,
              style: const TextStyle(color: AppColors.white),
              maxLines: 5,
              minLines: 3,
              decoration: InputDecoration(
                hintText: "What's on your mind?",
                hintStyle: AppTextStyles.bodyText2(color: AppColors.skyBlue),
                filled: true,
                fillColor: AppColors.darkBg,
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: AppColors.skyBlue.withValues(alpha: 0.2)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: AppColors.primaryOrange),
                ),
              ),
            ),
            if (_pickedImage != null) ...[
              AppSizes.xs.ph,
              Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.file(
                      _pickedImage!,
                      height: 120,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),
                  ),
                  Positioned(
                    top: 4,
                    right: 4,
                    child: GestureDetector(
                      onTap: () => setState(() => _pickedImage = null),
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.black54,
                        ),
                        child: const Icon(Icons.close, color: Colors.white, size: 16),
                      ),
                    ),
                  ),
                ],
              ),
            ],
            AppSizes.sm.ph,
            Row(
              children: [
                IconButton(
                  onPressed: _pickImage,
                  icon: const HugeIcon(
                    icon: HugeIconsStrokeRounded.image01,
                    color: AppColors.primaryOrange,
                    size: 22,
                  ),
                  tooltip: "Attach Image",
                ),
                const Spacer(),
                AppButton(
                  isExpanded: false,
                  onPressed: _isLoading ? null : _submitPost,
                  bgColor: AppColors.primaryOrange,
                  suffix: _isLoading
                      ? const SizedBox(
                          height: 16,
                          width: 16,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.black),
                        )
                      : const HugeIcon(
                          icon: HugeIconsStrokeRounded.plane,
                          color: AppColors.black,
                        ),
                  label: AppStrings.post,
                  labelStyle: AppTextStyles.button(color: AppColors.black),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
