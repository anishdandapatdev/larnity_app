import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:hugeicons/styles/stroke_rounded.dart';
import 'package:larnity/src/core/constants/app_size.dart';
import 'package:larnity/src/core/constants/app_strings.dart';
import 'package:larnity/src/core/extensions/extensions.dart';
import 'package:larnity/src/core/router/router.dart';
import 'package:larnity/src/core/service/supabase/src/supabase_provider.dart';
import 'package:larnity/src/core/service/supabase/src/supabase_storage_service.dart';
import 'package:larnity/src/core/theme/app_colors.dart';
import 'package:larnity/src/core/theme/theme.dart';
import 'package:larnity/src/core/ui/widgets/app_button.dart';
import 'package:larnity/src/core/utils/show_snackbar.dart';
import 'package:larnity/src/core/utils/async_states.dart';
import 'package:larnity/src/features/auth/presentation/provider/auth_provider.dart';
import 'package:larnity/src/features/group/data/models/comment_model.dart';
import 'package:larnity/src/features/group/data/models/post_model.dart';
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
  String? _resolveImageUrl(String? url) {
    if (url == null || url.trim().isEmpty) return null;
    final trimmed = url.trim();
    if (trimmed.startsWith('http://') || trimmed.startsWith('https://')) {
      return trimmed;
    }
    try {
      final supabase = ref.read(supabaseClientProvider);
      return supabase.storage.from(StorageBucket.postMedia).getPublicUrl(trimmed);
    } catch (_) {
      return null;
    }
  }

  String _formatTimeAgo(DateTime? date) {
    if (date == null) return '';
    final now = DateTime.now();
    final diff = now.difference(date);

    if (diff.inSeconds < 60) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    return '${date.day}/${date.month}/${date.year}';
  }

  void _showFullImage(BuildContext context, String imageUrl) {
    showDialog(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.9),
      builder: (ctx) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.all(8),
        child: Stack(
          alignment: Alignment.center,
          children: [
            InteractiveViewer(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(
                  imageUrl,
                  fit: BoxFit.contain,
                  loadingBuilder: (c, child, progress) {
                    if (progress == null) return child;
                    return const Center(
                      child: CircularProgressIndicator(
                        color: AppColors.primaryOrange,
                      ),
                    );
                  },
                  errorBuilder: (c, e, s) => const Icon(
                    Icons.broken_image,
                    color: Colors.white,
                    size: 60,
                  ),
                ),
              ),
            ),
            Positioned(
              top: 10,
              right: 10,
              child: CircleAvatar(
                backgroundColor: Colors.black54,
                child: IconButton(
                  icon: const Icon(Icons.close, color: Colors.white),
                  onPressed: () => Navigator.of(ctx).pop(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _confirmDeletePost(BuildContext context, String groupId, String postId) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.darkBgContainer,
        title: const Text(
          "Delete Post",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        content: const Text(
          "Are you sure you want to delete this post? This action cannot be undone.",
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text("Cancel", style: TextStyle(color: Colors.white54)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              Navigator.of(ctx).pop();
              ref
                  .read(discussionProvider(groupId).notifier)
                  .deletePost(
                    postId: postId,
                    successCallBack: () {
                      showSuccessToast(content: "Post deleted successfully");
                    },
                    failureCallBack: (err) {
                      showErrorToast(content: err);
                    },
                  );
            },
            child: const Text("Delete", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _openCommentsBottomSheet(
    BuildContext context,
    String groupId,
    PostModel post,
    String? currentUserId,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.darkBgContainer,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => _CommentsBottomSheet(
        groupId: groupId,
        post: post,
        currentUserId: currentUserId,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final groupId = ref.watch(groupProvider).group?.id;
    if (groupId == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text("Discussion Room"),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              if (context.canPop()) {
                context.pop();
              } else {
                context.goNamed(Routes.group);
              }
            },
          ),
        ),
        backgroundColor: AppColors.bgBlue,
        body: const Center(
          child: Text(
            "No group selected",
            style: TextStyle(color: Colors.white),
          ),
        ),
      );
    }

    final currentUserId = ref.watch(authProvider).user?.id;
    final isOwnerOrAdmin = ref.watch(isGroupAdminOrOwnerProvider);
    final state = ref.watch(discussionProvider(groupId));
    final posts = state.posts ?? [];
    final isLoading = state.fetchState == AsyncState.loading && posts.isEmpty;
    final channelId = state.channelId;

    return Scaffold(
      backgroundColor: AppColors.bgBlue,
      appBar: AppBar(
        title: const Text("Discussion Room"),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.goNamed(Routes.group);
            }
          },
        ),
      ),
      body: RefreshIndicator(
        color: AppColors.primaryOrange,
        backgroundColor: AppColors.darkBgContainer,
        onRefresh: () async {
          await ref.read(discussionProvider(groupId).notifier).fetchPosts();
        },
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            // Create post action bar
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(AppSizes.sm),
                child: AppButton(
                  onPressed: () {
                    if (channelId == null) {
                      showErrorToast(
                        content: state.error ?? "Channel not ready yet.",
                      );
                      return;
                    }
                    showDialog(
                      context: context,
                      builder: (context) => Dialog(
                        backgroundColor: AppColors.iconColor,
                        child: CreatePost(
                          channelId: channelId,
                          groupId: groupId,
                        ),
                      ),
                    );
                  },
                  bgColor: AppColors.iconColor,
                  padding: const EdgeInsets.symmetric(
                    vertical: AppSizes.xs,
                    horizontal: AppSizes.sm,
                  ),
                  child: Row(
                    children: [
                      Container(
                        height: 38,
                        width: 38,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.primaryOrange.withValues(alpha: 0.2),
                        ),
                        child: const Icon(
                          Icons.edit_outlined,
                          color: AppColors.primaryOrange,
                          size: 20,
                        ),
                      ),
                      AppSizes.xs.pw,
                      Expanded(
                        child: Text(
                          AppStrings.postButtonText,
                          style: AppTextStyles.subtitle2(
                            color: AppColors.white.withValues(alpha: 0.8),
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const Icon(
                        Icons.add_photo_alternate_outlined,
                        color: AppColors.skyBlue,
                        size: 22,
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Content area
            if (isLoading)
              const SliverFillRemaining(
                child: Center(
                  child: CircularProgressIndicator(
                    color: AppColors.primaryOrange,
                  ),
                ),
              )
            else if (posts.isEmpty)
              SliverFillRemaining(
                hasScrollBody: false,
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.all(AppSizes.lg),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: AppColors.iconColor.withValues(alpha: 0.4),
                          ),
                          child: const HugeIcon(
                            icon: HugeIconsStrokeRounded.bubbleChat,
                            color: AppColors.skyBlue,
                            size: 40,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          "No discussions yet",
                          style: AppTextStyles.headline4(color: AppColors.white),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          "Be the first to share an update, ask a question, or post a discussion in this group!",
                          textAlign: TextAlign.center,
                          style: AppTextStyles.bodyText2(
                            color: AppColors.skyBlue.withValues(alpha: 0.8),
                          ),
                        ),
                        const SizedBox(height: 20),
                        ElevatedButton.icon(
                          onPressed: () {
                            if (channelId == null) {
                              showErrorToast(
                                content: state.error ?? "Channel not ready yet.",
                              );
                              return;
                            }
                            showDialog(
                              context: context,
                              builder: (context) => Dialog(
                                backgroundColor: AppColors.iconColor,
                                child: CreatePost(
                                  channelId: channelId,
                                  groupId: groupId,
                                ),
                              ),
                            );
                          },
                          icon: const Icon(Icons.add, color: Colors.black),
                          label: const Text(
                            "Start Discussion",
                            style: TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primaryOrange,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 24,
                              vertical: 12,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              )
            else
              SliverPadding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSizes.xs,
                  vertical: AppSizes.xxs,
                ),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final post = posts[index];
                      final authorImg = _resolveImageUrl(post.authorImage);
                      final postImg = _resolveImageUrl(post.imageUrl);
                      final isAuthor = post.authorId == currentUserId;
                      final canDelete = isAuthor || isOwnerOrAdmin;
                      final isLiked = post.isLikedByMe ?? false;
                      final likeCount = post.likeCount ?? 0;
                      final commentCount = post.commentCount ?? 0;
                      final displayContent = post.cleanContent.isNotEmpty
                          ? post.cleanContent
                          : post.content;

                      return Container(
                        margin: const EdgeInsets.only(bottom: AppSizes.xs),
                        padding: const EdgeInsets.all(AppSizes.sm),
                        decoration: BoxDecoration(
                          color: AppColors.darkBgContainer,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: AppColors.iconColor.withValues(alpha: 0.3),
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Author Header
                            Row(
                              children: [
                                CircleAvatar(
                                  radius: 18,
                                  backgroundColor: AppColors.primaryOrange
                                      .withValues(alpha: 0.3),
                                  backgroundImage: authorImg != null
                                      ? NetworkImage(authorImg)
                                      : null,
                                  child: authorImg == null
                                      ? Text(
                                          post.authorName.isNotEmpty
                                              ? post.authorName[0].toUpperCase()
                                              : '?',
                                          style: const TextStyle(
                                            color: AppColors.primaryOrange,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        )
                                      : null,
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        post.authorName,
                                        style: AppTextStyles.subtitle2(
                                          color: AppColors.white,
                                        ),
                                      ),
                                      if (post.createdAt != null)
                                        Text(
                                          _formatTimeAgo(post.createdAt),
                                          style: AppTextStyles.caption2(
                                            color: AppColors.skyBlue.withValues(
                                              alpha: 0.7,
                                            ),
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                                if (canDelete && post.id != null)
                                  PopupMenuButton<String>(
                                    icon: const Icon(
                                      Icons.more_vert,
                                      color: Colors.white54,
                                      size: 20,
                                    ),
                                    color: AppColors.iconColor,
                                    onSelected: (val) {
                                      if (val == 'delete') {
                                        _confirmDeletePost(
                                          context,
                                          groupId,
                                          post.id!,
                                        );
                                      }
                                    },
                                    itemBuilder: (ctx) => [
                                      const PopupMenuItem(
                                        value: 'delete',
                                        child: Row(
                                          children: [
                                            Icon(
                                              Icons.delete_outline,
                                              color: Colors.redAccent,
                                              size: 18,
                                            ),
                                            SizedBox(width: 8),
                                            Text(
                                              "Delete",
                                              style: TextStyle(
                                                color: Colors.redAccent,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                              ],
                            ),

                            // Post Title (if available)
                            if (post.title != null &&
                                post.title!.trim().isNotEmpty) ...[
                              const SizedBox(height: 10),
                              Text(
                                post.title!.trim(),
                                style: AppTextStyles.subtitle1(
                                  color: AppColors.white,
                                ).copyWith(fontWeight: FontWeight.bold),
                              ),
                            ],

                            // Post Content Text
                            if (displayContent.trim().isNotEmpty) ...[
                              const SizedBox(height: 8),
                              Text(
                                displayContent.trim(),
                                style: AppTextStyles.bodyText2(
                                  color: AppColors.creamWhite,
                                ),
                              ),
                            ],

                            // Attached Image (if present)
                            if (postImg != null) ...[
                              const SizedBox(height: 12),
                              GestureDetector(
                                onTap: () => _showFullImage(context, postImg),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(10),
                                  child: Container(
                                    constraints: const BoxConstraints(
                                      maxHeight: 280,
                                    ),
                                    width: double.infinity,
                                    color: Colors.black26,
                                    child: Image.network(
                                      postImg,
                                      fit: BoxFit.cover,
                                      loadingBuilder: (c, child, progress) {
                                        if (progress == null) return child;
                                        return Container(
                                          height: 160,
                                          alignment: Alignment.center,
                                          child: const CircularProgressIndicator(
                                            color: AppColors.primaryOrange,
                                            strokeWidth: 2,
                                          ),
                                        );
                                      },
                                      errorBuilder: (c, e, s) => Container(
                                        height: 120,
                                        alignment: Alignment.center,
                                        color: AppColors.iconColor.withValues(
                                          alpha: 0.3,
                                        ),
                                        child: const Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Icon(
                                              Icons.image_not_supported_outlined,
                                              color: Colors.white54,
                                            ),
                                            SizedBox(width: 8),
                                            Text(
                                              "Image preview unavailable",
                                              style: TextStyle(
                                                color: Colors.white54,
                                                fontSize: 12,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],

                            // Divider
                            const SizedBox(height: 12),
                            Divider(
                              color: AppColors.iconColor.withValues(alpha: 0.3),
                              height: 1,
                            ),
                            const SizedBox(height: 8),

                            // Actions Bar: Like and Comment
                            Row(
                              children: [
                                // Like Button
                                InkWell(
                                  borderRadius: BorderRadius.circular(20),
                                  onTap: () {
                                    if (currentUserId == null) {
                                      showErrorToast(
                                        content: "Please sign in to like",
                                      );
                                      return;
                                    }
                                    if (post.id != null) {
                                      ref
                                          .read(
                                            discussionProvider(groupId).notifier,
                                          )
                                          .toggleLike(
                                            postId: post.id!,
                                            userId: currentUserId,
                                          );
                                    }
                                  },
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 10,
                                      vertical: 6,
                                    ),
                                    child: Row(
                                      children: [
                                        Icon(
                                          isLiked
                                              ? Icons.favorite
                                              : Icons.favorite_border,
                                          color: isLiked
                                              ? Colors.redAccent
                                              : Colors.white70,
                                          size: 18,
                                        ),
                                        const SizedBox(width: 6),
                                        Text(
                                          likeCount > 0 ? "$likeCount" : "Like",
                                          style: TextStyle(
                                            color: isLiked
                                              ? Colors.redAccent
                                              : Colors.white70,
                                            fontSize: 13,
                                            fontWeight: isLiked
                                                ? FontWeight.bold
                                                : FontWeight.normal,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),

                                const SizedBox(width: 12),

                                // Comment Button
                                InkWell(
                                  borderRadius: BorderRadius.circular(20),
                                  onTap: () {
                                    _openCommentsBottomSheet(
                                      context,
                                      groupId,
                                      post,
                                      currentUserId,
                                    );
                                  },
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 10,
                                      vertical: 6,
                                    ),
                                    child: Row(
                                      children: [
                                        const Icon(
                                          Icons.chat_bubble_outline,
                                          color: Colors.white70,
                                          size: 18,
                                        ),
                                        const SizedBox(width: 6),
                                        Text(
                                          commentCount > 0
                                              ? "$commentCount Comments"
                                              : "Comment",
                                          style: const TextStyle(
                                            color: Colors.white70,
                                            fontSize: 13,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      );
                    },
                    childCount: posts.length,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// Comments Bottom Sheet
// ─────────────────────────────────────────────────────────────

class _CommentsBottomSheet extends ConsumerStatefulWidget {
  final String groupId;
  final PostModel post;
  final String? currentUserId;

  const _CommentsBottomSheet({
    required this.groupId,
    required this.post,
    required this.currentUserId,
  });

  @override
  ConsumerState<_CommentsBottomSheet> createState() =>
      _CommentsBottomSheetState();
}

class _CommentsBottomSheetState extends ConsumerState<_CommentsBottomSheet> {
  final TextEditingController _commentController = TextEditingController();
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    if (widget.post.id != null) {
      Future.microtask(() {
        ref
            .read(discussionProvider(widget.groupId).notifier)
            .fetchComments(postId: widget.post.id!);
      });
    }
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  Future<void> _submitComment() async {
    final text = _commentController.text.trim();
    if (text.isEmpty) return;

    if (widget.currentUserId == null) {
      showErrorToast(content: "Please sign in to comment");
      return;
    }

    if (widget.post.id == null) return;

    setState(() => _isSubmitting = true);

    final comment = CommentModel(
      postId: widget.post.id!,
      userId: widget.currentUserId!,
      content: text,
    );

    await ref
        .read(discussionProvider(widget.groupId).notifier)
        .createComment(
          comment: comment,
          successCallBack: () {
            if (mounted) {
              setState(() => _isSubmitting = false);
              _commentController.clear();
            }
          },
          failureCallBack: (err) {
            if (mounted) {
              setState(() => _isSubmitting = false);
              showErrorToast(content: err);
            }
          },
        );
  }

  String _formatTimeAgo(DateTime? date) {
    if (date == null) return '';
    final now = DateTime.now();
    final diff = now.difference(date);

    if (diff.inSeconds < 60) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    return '${date.day}/${date.month}';
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(discussionProvider(widget.groupId));
    final comments = state.comments?[widget.post.id] ?? [];
    final isLoading = state.commentFetchState == AsyncState.loading && comments.isEmpty;

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Container(
        height: MediaQuery.of(context).size.height * 0.75,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Column(
          children: [
            // Handle bar
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.white24,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 12),

            // Sheet Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Text(
                      "Comments",
                      style: AppTextStyles.headline4(color: Colors.white),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.primaryOrange.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        "${comments.length}",
                        style: const TextStyle(
                          color: AppColors.primaryOrange,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                IconButton(
                  icon: const Icon(Icons.close, color: Colors.white54),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
            const Divider(color: Colors.white12),

            // Comments List
            Expanded(
              child: isLoading
                  ? const Center(
                      child: CircularProgressIndicator(
                        color: AppColors.primaryOrange,
                      ),
                    )
                  : comments.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.chat_bubble_outline,
                            size: 40,
                            color: Colors.white24,
                          ),
                          const SizedBox(height: 12),
                          Text(
                            "No comments yet",
                            style: AppTextStyles.subtitle1(
                              color: Colors.white70,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            "Be the first to share your thoughts!",
                            style: AppTextStyles.caption1(
                              color: Colors.white38,
                            ),
                          ),
                        ],
                      ),
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      itemCount: comments.length,
                      separatorBuilder: (c, i) => const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        final comment = comments[index];
                        final authorImg = comment.authorImage;

                        return Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            CircleAvatar(
                              radius: 16,
                              backgroundColor: AppColors.primaryOrange
                                  .withValues(alpha: 0.2),
                              backgroundImage: authorImg != null &&
                                      authorImg.startsWith('http')
                                  ? NetworkImage(authorImg)
                                  : null,
                              child: authorImg == null ||
                                      !authorImg.startsWith('http')
                                  ? Text(
                                      comment.authorName.isNotEmpty
                                          ? comment.authorName[0].toUpperCase()
                                          : '?',
                                      style: const TextStyle(
                                        color: AppColors.primaryOrange,
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    )
                                  : null,
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: AppColors.iconColor.withValues(
                                    alpha: 0.3,
                                  ),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          comment.authorName,
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 13,
                                          ),
                                        ),
                                        Text(
                                          _formatTimeAgo(comment.createdAt),
                                          style: const TextStyle(
                                            color: Colors.white38,
                                            fontSize: 11,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      comment.content,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 13,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        );
                      },
                    ),
            ),

            // Input field
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.iconColor.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: AppColors.iconColor.withValues(alpha: 0.8),
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _commentController,
                      style: const TextStyle(color: Colors.white, fontSize: 14),
                      decoration: const InputDecoration(
                        hintText: "Add a comment...",
                        hintStyle: TextStyle(
                          color: Colors.white38,
                          fontSize: 14,
                        ),
                        border: InputBorder.none,
                        isDense: true,
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 6,
                        ),
                      ),
                      maxLines: 3,
                      minLines: 1,
                    ),
                  ),
                  const SizedBox(width: 6),
                  _isSubmitting
                      ? const SizedBox(
                          width: 28,
                          height: 28,
                          child: CircularProgressIndicator(
                            color: AppColors.primaryOrange,
                            strokeWidth: 2,
                          ),
                        )
                      : IconButton(
                          icon: const Icon(
                            Icons.send_rounded,
                            color: AppColors.primaryOrange,
                            size: 20,
                          ),
                          onPressed: _submitComment,
                        ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
