import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:hugeicons/styles/stroke_rounded.dart';
import 'package:larnity/src/core/constants/app_size.dart';
import 'package:larnity/src/core/constants/app_strings.dart';
import 'package:larnity/src/core/extensions/extensions.dart';
import 'package:larnity/src/core/theme/app_colors.dart';
import 'package:larnity/src/core/theme/theme.dart';
import 'package:larnity/src/core/ui/widgets/app_button.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:larnity/src/features/group/presentation/provider/discussion_provider.dart';
import 'package:larnity/src/features/group/data/models/post_model.dart';
import 'package:larnity/src/core/service/supabase/src/supabase_provider.dart';

class CreatePost extends ConsumerStatefulWidget {
  final String channelId;
  const CreatePost({super.key, required this.channelId});

  @override
  ConsumerState<CreatePost> createState() => _CreatePostState();
}

class _CreatePostState extends ConsumerState<CreatePost> {
  final _titleController = TextEditingController();
  final _contentController =
      TextEditingController(); // Assuming we use this for now instead of slash editor

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppSizes.xs),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Container(
                height: 40,
                width: 40,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.primaryOrange,
                ),
              ),
              AppSizes.xs.pw,
              RichText(
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: AppStrings.postingIn,
                      style: AppTextStyles.subtitle2(color: AppColors.white),
                    ),
                    TextSpan(
                      text: "General",
                      style: AppTextStyles.subtitle1(color: AppColors.white),
                    ),
                  ],
                ),
              ),
            ],
          ),
          AppSizes.lg.ph,
          TextFormField(
            controller: _titleController,
            style: const TextStyle(color: AppColors.white),
            decoration: InputDecoration(
              hintText: AppStrings.postTitle,
              hintStyle: AppTextStyles.button(color: AppColors.skyBlue),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppSizes.xxxs),
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppSizes.xxxs),
                borderSide: BorderSide.none,
              ),
            ),
          ),
          AppSizes.xs.ph,
          // Temporary standard text field for content instead of slash editor for simplicity
          TextFormField(
            controller: _contentController,
            style: const TextStyle(color: AppColors.white),
            maxLines: 5,
            decoration: InputDecoration(
              hintText: "What's on your mind?",
              hintStyle: AppTextStyles.bodyText2(color: AppColors.skyBlue),
              border: OutlineInputBorder(
                borderSide: BorderSide(
                  color: AppColors.skyBlue.withValues(alpha: 0.3),
                ),
              ),
            ),
          ),
          AppSizes.lg.ph,
          Row(
            children: [
              TextButton(
                onPressed: () {},
                child: Text(
                  AppStrings.shareWithGroup,
                  style: AppTextStyles.subtitle2(),
                ),
              ),
              Spacer(),
              AppButton(
                onPressed: () {
                  context.pop();
                },
                isExpanded: false,
                bgColor: Colors.transparent,
                label: AppStrings.close,
                labelStyle: AppTextStyles.button(color: AppColors.white),
              ),
            ],
          ),
          AppSizes.xs.ph,
          AppButton(
            onPressed: () {
              final content = _contentController.text.trim();
              if (content.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Content cannot be empty")),
                );
                return;
              }
              final title = _titleController.text.trim();
              final authorId = ref.read(supabaseClientProvider).auth.currentUser?.id;
              if (authorId == null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("User not authenticated")),
                );
                return;
              }

              ref
                  .read(discussionProvider(widget.channelId).notifier)
                  .createPost(
                    post: PostModel(
                      channelId: widget.channelId,
                      authorId: authorId,
                      title: title.isEmpty ? null : title,
                      content: content,
                    ),
                    successCallBack: () {
                      context.pop();
                    },
                    failureCallBack: (err) {
                      ScaffoldMessenger.of(
                        context,
                      ).showSnackBar(SnackBar(content: Text(err)));
                    },
                  );
            },
            bgColor: AppColors.white,
            suffix: const HugeIcon(
              icon: HugeIconsStrokeRounded.plane,
              color: AppColors.black,
            ),
            label: AppStrings.post,
            labelStyle: AppTextStyles.button(color: AppColors.black),
          ),
        ],
      ),
    );
  }
}
