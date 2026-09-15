import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:larnity/src/core/constants/app_size.dart';
import 'package:larnity/src/core/constants/app_strings.dart';
import 'package:larnity/src/core/extensions/extensions.dart';
import 'package:larnity/src/core/theme/app_colors.dart';
import 'package:larnity/src/core/theme/theme.dart';
import 'package:larnity/src/core/ui/widgets/app_button.dart';
import 'package:larnity/src/core/utils/async_states.dart';
import 'package:larnity/src/features/group/presentation/provider/discussion_provider.dart';
import 'package:larnity/src/features/group/presentation/provider/group_provider.dart';
import 'package:larnity/src/features/group/presentation/widgets/create_post.dart';

class DiscussionRoomScreen extends ConsumerStatefulWidget {
  const DiscussionRoomScreen({super.key});

  @override
  ConsumerState<DiscussionRoomScreen> createState() =>
      _DiscussionRoomScreenState();
}

class _DiscussionRoomScreenState extends ConsumerState<DiscussionRoomScreen> {
  @override
  Widget build(BuildContext context) {
    final groupId = ref.watch(groupProvider).group?.id;
    if (groupId == null) {
      return Scaffold(
        appBar: AppBar(title: const Text("Discussion Room")),
        backgroundColor: AppColors.bgBlue,
        body: const Center(
          child: Text(
            "No group selected",
            style: TextStyle(color: Colors.white),
          ),
        ),
      );
    }

    final state = ref.watch(discussionProvider(groupId));
    final posts = state.posts ?? [];
    final isLoading = state.fetchState == AsyncState.loading && posts.isEmpty;
    final channelId = state.channelId;

    return Scaffold(
      backgroundColor: AppColors.bgBlue,
      appBar: AppBar(title: const Text("Discussion Room")),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSizes.xs),
            child: Column(
              children: [
                AppSizes.xs.ph,
                AppButton(
                  onPressed: () {
                    if (channelId == null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            state.error ?? "Channel not ready yet.",
                          ),
                        ),
                      );
                      return;
                    }
                    showDialog(
                      context: context,
                      builder: (context) => Dialog(
                        backgroundColor: AppColors.iconColor,
                        child: CreatePost(channelId: channelId),
                      ),
                    );
                  },
                  bgColor: AppColors.iconColor,
                  padding: const EdgeInsets.symmetric(
                    vertical: AppSizes.xs,
                    horizontal: AppSizes.xs,
                  ),
                  child: Row(
                    children: [
                      Container(
                        height: 40,
                        width: 40,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.primaryOrange,
                        ),
                      ),
                      AppSizes.xxxs.pw,
                      Expanded(
                        child: Text(
                          AppStrings.postButtonText,
                          style: AppTextStyles.subtitle2(
                            color: AppColors.white.withValues(alpha: 0.8),
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
                AppSizes.xs.ph,
              ],
            ),
          ),
          Expanded(
            child: isLoading
                ? const Center(
                    child: CircularProgressIndicator(
                      color: AppColors.primaryOrange,
                    ),
                  )
                : posts.isEmpty
                ? const Center(
                    child: Text(
                      "No posts yet. Be the first to start a discussion!",
                      style: TextStyle(color: AppColors.skyBlue),
                    ),
                  )
                : ListView.builder(
                    itemCount: posts.length,
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSizes.xs,
                    ),
                    itemBuilder: (context, index) {
                      final post = posts[index];
                      return Container(
                        margin: const EdgeInsets.only(bottom: AppSizes.xs),
                        padding: const EdgeInsets.all(AppSizes.sm),
                        decoration: BoxDecoration(
                          color: AppColors.darkBgContainer,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                CircleAvatar(
                                  radius: 16,
                                  backgroundColor: AppColors.skyBlue,
                                  backgroundImage: post.authorImage != null
                                      ? NetworkImage(post.authorImage!)
                                      : null,
                                  child: post.authorImage == null
                                      ? const Icon(
                                          Icons.person,
                                          size: 16,
                                          color: Colors.white,
                                        )
                                      : null,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  post.authorName,
                                  style: AppTextStyles.subtitle2(
                                    color: AppColors.white,
                                  ),
                                ),
                                const Spacer(),
                                if (post.createdAt != null)
                                  Text(
                                    "${post.createdAt!.day}/${post.createdAt!.month}/${post.createdAt!.year}",
                                    style: AppTextStyles.caption2(
                                      color: AppColors.skyBlue,
                                    ),
                                  ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            if (post.title != null &&
                                post.title!.isNotEmpty) ...[
                              Text(
                                post.title!,
                                style: AppTextStyles.subtitle1(
                                  color: AppColors.white,
                                ),
                              ),
                              const SizedBox(height: 4),
                            ],
                            Text(
                              post.content,
                              style: AppTextStyles.bodyText2(
                                color: AppColors.creamWhite,
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
