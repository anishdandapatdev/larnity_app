import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:larnity/src/core/utils/async_states.dart';
import 'package:larnity/src/features/group/data/datasource/discussion_datasource.dart';
import 'package:larnity/src/features/group/data/models/post_model.dart';
import 'package:larnity/src/features/group/data/models/comment_model.dart';

// ── State ──

class DiscussionState {
  final AsyncState? fetchState;
  final AsyncState? createState;
  final AsyncState? commentFetchState;
  final String? error;
  final String? channelId;
  final List<PostModel>? posts;
  final Map<String, List<CommentModel>>? comments;
  final bool hasMore;
  final int offset;

  DiscussionState({
    this.fetchState,
    this.createState,
    this.commentFetchState,
    this.error,
    this.channelId,
    this.posts,
    this.comments,
    this.hasMore = true,
    this.offset = 0,
  });

  DiscussionState copyWith({
    AsyncState? fetchState,
    AsyncState? createState,
    AsyncState? commentFetchState,
    String? error,
    String? channelId,
    List<PostModel>? posts,
    Map<String, List<CommentModel>>? comments,
    bool? hasMore,
    int? offset,
  }) {
    return DiscussionState(
      fetchState: fetchState ?? this.fetchState,
      createState: createState ?? this.createState,
      commentFetchState: commentFetchState ?? this.commentFetchState,
      error: error ?? this.error,
      channelId: channelId ?? this.channelId,
      posts: posts ?? this.posts,
      comments: comments ?? this.comments,
      hasMore: hasMore ?? this.hasMore,
      offset: offset ?? this.offset,
    );
  }
}

// ── Provider ──

final discussionProvider = NotifierProvider.autoDispose
    .family<DiscussionNotifier, DiscussionState, String>(
      DiscussionNotifier.new,
    );

// ── Notifier ──

class DiscussionNotifier
    extends AutoDisposeFamilyNotifier<DiscussionState, String> {
  static const int _pageSize = 20;

  @override
  DiscussionState build(String arg) {
    // Auto-load posts on first access
    Future.microtask(() => fetchPosts());
    return DiscussionState(fetchState: AsyncState.initial);
  }

  String get _groupId => arg;

  Future<void> fetchPosts() async {
    final ds = ref.read(discussionDataSourceProvider);
    state = state.copyWith(fetchState: AsyncState.loading, offset: 0);

    final channelResult = await ds.getDefaultChannelId(_groupId);

    channelResult.fold(
      (failure) {
        state = state.copyWith(
          fetchState: AsyncState.failure,
          error: failure.message,
        );
      },
      (channelId) async {
        state = state.copyWith(channelId: channelId);

        final result = await ds.getPosts(
          channelId: channelId,
          limit: _pageSize,
          offset: 0,
        );

        result.fold(
          (failure) {
            state = state.copyWith(
              fetchState: AsyncState.failure,
              error: failure.message,
            );
          },
          (posts) {
            state = state.copyWith(
              fetchState: AsyncState.success,
              posts: posts,
              hasMore: posts.length >= _pageSize,
              offset: posts.length,
            );
          },
        );
      },
    );
  }

  Future<void> loadMore() async {
    if (!state.hasMore || state.fetchState == AsyncState.loading) return;

    final ds = ref.read(discussionDataSourceProvider);

    if (state.channelId == null) return;

    final result = await ds.getPosts(
      channelId: state.channelId!,
      limit: _pageSize,
      offset: state.offset,
    );

    result.fold(
      (failure) {
        state = state.copyWith(error: failure.message);
      },
      (newPosts) {
        final allPosts = <PostModel>[...(state.posts ?? []), ...newPosts];
        state = state.copyWith(
          posts: allPosts,
          hasMore: newPosts.length >= _pageSize,
          offset: allPosts.length,
        );
      },
    );
  }

  Future<void> createPost({
    required PostModel post,
    void Function()? successCallBack,
    void Function(String error)? failureCallBack,
  }) async {
    final ds = ref.read(discussionDataSourceProvider);
    state = state.copyWith(createState: AsyncState.loading);

    final result = await ds.createPost(post: post);

    result.fold(
      (failure) {
        state = state.copyWith(
          createState: AsyncState.failure,
          error: failure.message,
        );
        failureCallBack?.call(failure.message);
      },
      (createdPost) {
        final updatedPosts = <PostModel>[createdPost, ...(state.posts ?? [])];
        state = state.copyWith(
          createState: AsyncState.success,
          posts: updatedPosts,
        );
        successCallBack?.call();
      },
    );
  }

  Future<void> deletePost({
    required String postId,
    void Function()? successCallBack,
    void Function(String error)? failureCallBack,
  }) async {
    final ds = ref.read(discussionDataSourceProvider);

    final result = await ds.deletePost(postId: postId);

    result.fold(
      (failure) {
        failureCallBack?.call(failure.message);
      },
      (_) {
        final updatedPosts = state.posts?.where((p) => p.id != postId).toList();
        state = state.copyWith(posts: updatedPosts);
        successCallBack?.call();
      },
    );
  }

  Future<void> fetchComments({required String postId}) async {
    final ds = ref.read(discussionDataSourceProvider);
    state = state.copyWith(commentFetchState: AsyncState.loading);

    final result = await ds.getComments(postId: postId);

    result.fold(
      (failure) {
        state = state.copyWith(
          commentFetchState: AsyncState.failure,
          error: failure.message,
        );
      },
      (commentList) {
        final updatedComments = Map<String, List<CommentModel>>.from(
          state.comments ?? {},
        );
        updatedComments[postId] = commentList;
        state = state.copyWith(
          commentFetchState: AsyncState.success,
          comments: updatedComments,
        );
      },
    );
  }

  Future<void> createComment({
    required CommentModel comment,
    void Function()? successCallBack,
    void Function(String error)? failureCallBack,
  }) async {
    final ds = ref.read(discussionDataSourceProvider);

    final result = await ds.createComment(comment: comment);

    result.fold(
      (failure) {
        failureCallBack?.call(failure.message);
      },
      (createdComment) {
        final updatedComments =
            Map<String, List<CommentModel>>.from(state.comments ?? {});
        final postComments = <CommentModel>[...(updatedComments[comment.postId] ?? [])];
        postComments.add(createdComment);
        updatedComments[comment.postId] = postComments;

        // Also increment the post's comment count
        final updatedPosts = state.posts?.map((p) {
          if (p.id == comment.postId) {
            return p.copyWith(commentCount: (p.commentCount ?? 0) + 1);
          }
          return p;
        }).toList();

        state = state.copyWith(comments: updatedComments, posts: updatedPosts);
        successCallBack?.call();
      },
    );
  }

  Future<void> toggleLike({
    required String postId,
    required String userId,
  }) async {
    final ds = ref.read(discussionDataSourceProvider);

    final result = await ds.toggleLike(postId: postId, userId: userId);

    result.fold(
      (failure) {
        // Silent fail for likes
      },
      (isLiked) {
        final updatedPosts = state.posts?.map((p) {
          if (p.id == postId) {
            return p.copyWith(
              isLikedByMe: isLiked,
              likeCount: isLiked
                  ? (p.likeCount ?? 0) + 1
                  : ((p.likeCount ?? 1) - 1).clamp(0, 999999),
            );
          }
          return p;
        }).toList();

        state = state.copyWith(posts: updatedPosts);
      },
    );
  }
}
