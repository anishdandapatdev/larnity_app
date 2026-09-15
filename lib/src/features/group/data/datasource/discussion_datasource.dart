import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fpdart/fpdart.dart';
import 'package:larnity/src/core/error/failures.dart';
import 'package:larnity/src/core/service/supabase/src/supabase_provider.dart';
import 'package:larnity/src/core/service/supabase/src/supabase_table.dart';
import 'package:larnity/src/core/utils/logger.dart';
import 'package:larnity/src/features/group/data/models/post_model.dart';
import 'package:larnity/src/features/group/data/models/comment_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final discussionDataSourceProvider = Provider<DiscussionDataSource>((ref) {
  return DiscussionDataSource(
    supabaseClient: ref.watch(supabaseClientProvider),
  );
});

class DiscussionDataSource {
  final SupabaseClient supabaseClient;

  DiscussionDataSource({required this.supabaseClient});

  /// Fetch or create the default channel for a group.
  Future<Either<Failure, String>> getDefaultChannelId(String groupId) async {
    try {
      final response = await supabaseClient
          .from(SupabaseTable.channel)
          .select('id')
          .eq('groupId', groupId)
          .limit(1)
          .maybeSingle();

      if (response != null && response['id'] != null) {
        return Right(response['id'] as String);
      } else {
        // Create a default 'General' channel if it doesn't exist
        final newChannel = await supabaseClient
            .from(SupabaseTable.channel)
            .insert({
              'groupId': groupId,
              'name': 'General',
            })
            .select('id')
            .single();
        return Right(newChannel['id'] as String);
      }
    } on PostgrestException catch (e) {
      Log.error('getDefaultChannelId error: ${e.message}');
      return Left(Failure(e.message));
    } catch (e) {
      Log.error('getDefaultChannelId error: $e');
      return Left(Failure(e.toString()));
    }
  }

  /// Fetch posts for a channel.
  Future<Either<Failure, List<PostModel>>> getPosts({
    required String channelId,
    int limit = 20,
    int offset = 0,
  }) async {
    try {
      final response = await supabaseClient
          .from(SupabaseTable.post)
          .select('*, profiles(*), Comment(count), Like(count)')
          .eq('channelId', channelId)
          .order('created_at', ascending: false)
          .range(offset, offset + limit - 1);

      final posts = (response as List)
          .map((e) => PostModel.fromMap(e as Map<String, dynamic>))
          .toList();

      Log.info('Fetched ${posts.length} posts for channel $channelId');
      return Right(posts);
    } on PostgrestException catch (e) {
      Log.error('getPosts error: ${e.message}');
      return Left(Failure(e.message));
    } catch (e) {
      Log.error('getPosts error: $e');
      return Left(Failure(e.toString()));
    }
  }

  /// Create a new post.
  Future<Either<Failure, PostModel>> createPost({
    required PostModel post,
  }) async {
    try {
      final response = await supabaseClient
          .from(SupabaseTable.post)
          .insert(post.toMap())
          .select('*, profiles(*), Comment(count), Like(count)')
          .single();

      final created = PostModel.fromMap(response);
      Log.info('Created post: ${created.id}');
      return Right(created);
    } on PostgrestException catch (e) {
      Log.error('createPost error: ${e.message}');
      return Left(Failure(e.message));
    } catch (e) {
      Log.error('createPost error: $e');
      return Left(Failure(e.toString()));
    }
  }

  /// Update an existing post.
  Future<Either<Failure, PostModel>> updatePost({
    required PostModel post,
  }) async {
    try {
      final response = await supabaseClient
          .from(SupabaseTable.post)
          .update(post.toMap())
          .eq('id', post.id!)
          .select('*, profiles(*), Comment(count), Like(count)')
          .single();

      final updated = PostModel.fromMap(response);
      Log.info('Updated post: ${updated.id}');
      return Right(updated);
    } on PostgrestException catch (e) {
      Log.error('updatePost error: ${e.message}');
      return Left(Failure(e.message));
    } catch (e) {
      Log.error('updatePost error: $e');
      return Left(Failure(e.toString()));
    }
  }

  /// Delete a post by ID.
  Future<Either<Failure, void>> deletePost({required String postId}) async {
    try {
      await supabaseClient.from(SupabaseTable.post).delete().eq('id', postId);

      Log.info('Deleted post: $postId');
      return const Right(null);
    } on PostgrestException catch (e) {
      Log.error('deletePost error: ${e.message}');
      return Left(Failure(e.message));
    } catch (e) {
      Log.error('deletePost error: $e');
      return Left(Failure(e.toString()));
    }
  }

  /// Get comments for a post.
  Future<Either<Failure, List<CommentModel>>> getComments({
    required String postId,
  }) async {
    try {
      final response = await supabaseClient
          .from(SupabaseTable.comment)
          .select('*, profiles(*)')
          .eq('postId', postId)
          .order('created_at', ascending: true);

      final comments = (response as List)
          .map((e) => CommentModel.fromMap(e as Map<String, dynamic>))
          .toList();

      Log.info('Fetched ${comments.length} comments for post $postId');
      return Right(comments);
    } on PostgrestException catch (e) {
      Log.error('getComments error: ${e.message}');
      return Left(Failure(e.message));
    } catch (e) {
      Log.error('getComments error: $e');
      return Left(Failure(e.toString()));
    }
  }

  /// Create a new comment on a post.
  Future<Either<Failure, CommentModel>> createComment({
    required CommentModel comment,
  }) async {
    try {
      final response = await supabaseClient
          .from(SupabaseTable.comment)
          .insert(comment.toMap())
          .select('*, profiles(*)')
          .single();

      final created = CommentModel.fromMap(response);
      Log.info('Created comment: ${created.id}');
      return Right(created);
    } on PostgrestException catch (e) {
      Log.error('createComment error: ${e.message}');
      return Left(Failure(e.message));
    } catch (e) {
      Log.error('createComment error: $e');
      return Left(Failure(e.toString()));
    }
  }

  /// Delete a comment.
  Future<Either<Failure, void>> deleteComment({
    required String commentId,
  }) async {
    try {
      await supabaseClient
          .from(SupabaseTable.comment)
          .delete()
          .eq('id', commentId);

      Log.info('Deleted comment: $commentId');
      return const Right(null);
    } on PostgrestException catch (e) {
      Log.error('deleteComment error: ${e.message}');
      return Left(Failure(e.message));
    } catch (e) {
      Log.error('deleteComment error: $e');
      return Left(Failure(e.toString()));
    }
  }

  /// Toggle like on a post. Returns true if liked, false if unliked.
  Future<Either<Failure, bool>> toggleLike({
    required String postId,
    required String userId,
  }) async {
    try {
      final existing = await supabaseClient
          .from(SupabaseTable.like)
          .select('id')
          .eq('postId', postId)
          .eq('userId', userId)
          .maybeSingle();

      if (existing != null) {
        // Unlike
        await supabaseClient
            .from(SupabaseTable.like)
            .delete()
            .eq('id', existing['id']);
        Log.info('Unliked post $postId');
        return const Right(false);
      } else {
        // Like
        await supabaseClient.from(SupabaseTable.like).insert({
          'postId': postId,
          'userId': userId,
        });
        Log.info('Liked post $postId');
        return const Right(true);
      }
    } on PostgrestException catch (e) {
      Log.error('toggleLike error: ${e.message}');
      return Left(Failure(e.message));
    } catch (e) {
      Log.error('toggleLike error: $e');
      return Left(Failure(e.toString()));
    }
  }

  /// Check if a user has liked a post.
  Future<Either<Failure, bool>> checkIfLiked({
    required String postId,
    required String userId,
  }) async {
    try {
      final existing = await supabaseClient
          .from(SupabaseTable.like)
          .select('id')
          .eq('postId', postId)
          .eq('userId', userId)
          .maybeSingle();

      return Right(existing != null);
    } on PostgrestException catch (e) {
      Log.error('checkIfLiked error: ${e.message}');
      return Left(Failure(e.message));
    } catch (e) {
      Log.error('checkIfLiked error: $e');
      return Left(Failure(e.toString()));
    }
  }
}
