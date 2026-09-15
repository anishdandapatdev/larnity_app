import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:larnity/src/core/utils/async_states.dart';
import 'package:larnity/src/features/group/data/datasource/discussion_datasource.dart';
import 'package:larnity/src/features/group/data/models/post_model.dart';
import 'package:larnity/src/features/group/data/models/comment_model.dart';

// ── State ──

class DoubtState {
  final AsyncState? fetchState;
  final AsyncState? createState;
  final AsyncState? commentFetchState;
  final String? error;
  final List<PostModel>? posts;
  final Map<String, List<CommentModel>>? comments;
  final bool hasMore;
  final int offset;

  DoubtState({
    this.fetchState,
    this.createState,
    this.commentFetchState,
    this.error,
    this.posts,
    this.comments,
    this.hasMore = true,
    this.offset = 0,
  });

  DoubtState copyWith({
    AsyncState? fetchState,
    AsyncState? createState,
    AsyncState? commentFetchState,
    String? error,
    List<PostModel>? posts,
    Map<String, List<CommentModel>>? comments,
    bool? hasMore,
    int? offset,
  }) {
    return DoubtState(
      fetchState: fetchState ?? this.fetchState,
      createState: createState ?? this.createState,
      commentFetchState: commentFetchState ?? this.commentFetchState,
      error: error ?? this.error,
      posts: posts ?? this.posts,
      comments: comments ?? this.comments,
      hasMore: hasMore ?? this.hasMore,
      offset: offset ?? this.offset,
    );
  }
}

// ── Provider ──

final doubtProvider = NotifierProvider.autoDispose
    .family<DoubtNotifier, DoubtState, String>(DoubtNotifier.new);

// ── Notifier ──

class DoubtNotifier extends AutoDisposeFamilyNotifier<DoubtState, String> {
  static const int _pageSize = 20;

  @override
  DoubtState build(String arg) {
    Future.microtask(() => fetchDoubts());
    return DoubtState(fetchState: AsyncState.initial);
  }

  String get groupId => arg;

  Future<void> fetchDoubts() async {
    final ds = ref.read(discussionDataSourceProvider);
    state = state.copyWith(fetchState: AsyncState.loading, offset: 0);

    final result = await ds.getPosts(
      channelId: '',
      // groupId: _groupId,
      // type: 'doubt',
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
  }

  Future<void> loadMore() async {
    if (!state.hasMore || state.fetchState == AsyncState.loading) return;

    final ds = ref.read(discussionDataSourceProvider);

    final result = await ds.getPosts(
      channelId: '',
      // groupId: _groupId,
      // type: 'doubt',
      limit: _pageSize,
      offset: state.offset,
    );

    result.fold((failure) => state = state.copyWith(error: failure.message), (
      newPosts,
    ) {
      final allPosts = [...(state.posts ?? []), ...newPosts];
      state = state.copyWith(
        posts: allPosts,
        hasMore: newPosts.length >= _pageSize,
        offset: allPosts.length,
      );
    });
  }

  Future<void> createDoubt({
    required PostModel post,
    void Function()? successCallBack,
    void Function(String error)? failureCallBack,
  }) async {
    final ds = ref.read(discussionDataSourceProvider);
    state = state.copyWith(createState: AsyncState.loading);

    final doubtPost = post.copyWith(id: 'doubt');
    final result = await ds.createPost(post: doubtPost);

    result.fold(
      (failure) {
        state = state.copyWith(
          createState: AsyncState.failure,
          error: failure.message,
        );
        failureCallBack?.call(failure.message);
      },
      (created) {
        state = state.copyWith(
          createState: AsyncState.success,
          posts: [created, ...(state.posts ?? [])],
        );
        successCallBack?.call();
      },
    );
  }

  Future<void> fetchComments({required String postId}) async {
    final ds = ref.read(discussionDataSourceProvider);
    state = state.copyWith(commentFetchState: AsyncState.loading);

    final result = await ds.getComments(postId: postId);
    result.fold(
      (failure) => state = state.copyWith(
        commentFetchState: AsyncState.failure,
        error: failure.message,
      ),
      (commentList) {
        final updated = Map<String, List<CommentModel>>.from(
          state.comments ?? {},
        );
        updated[postId] = commentList;
        state = state.copyWith(
          commentFetchState: AsyncState.success,
          comments: updated,
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

    result.fold((failure) => failureCallBack?.call(failure.message), (created) {
      final updated = Map<String, List<CommentModel>>.from(
        state.comments ?? {},
      );
      updated[comment.postId] = [...(updated[comment.postId] ?? []), created];
      state = state.copyWith(comments: updated);
      successCallBack?.call();
    });
  }

  Future<void> toggleLike({
    required String postId,
    required String userId,
  }) async {
    final ds = ref.read(discussionDataSourceProvider);
    final result = await ds.toggleLike(postId: postId, userId: userId);

    result.fold((_) {}, (isLiked) {
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
    });
  }
}
