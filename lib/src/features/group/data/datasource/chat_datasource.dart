import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fpdart/fpdart.dart';
import 'package:larnity/src/core/error/failures.dart';
import 'package:larnity/src/core/service/supabase/src/supabase_provider.dart';
import 'package:larnity/src/core/service/supabase/src/supabase_table.dart';
import 'package:larnity/src/core/utils/logger.dart';
import 'package:larnity/src/features/group/data/models/channel_model.dart';
import 'package:larnity/src/features/group/data/models/message_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final chatDataSourceProvider = Provider<ChatDataSource>((ref) {
  return ChatDataSource(supabaseClient: ref.watch(supabaseClientProvider));
});

class ChatDataSource {
  final SupabaseClient supabaseClient;

  ChatDataSource({required this.supabaseClient});

  /// Get channels for a group.
  Future<Either<Failure, List<ChannelModel>>> getChannels({
    required String groupId,
  }) async {
    try {
      final response = await supabaseClient
          .from(SupabaseTable.channel)
          .select('*')
          .eq('groupId', groupId)
          .order('created_at', ascending: true);

      final channels = (response as List)
          .map((e) => ChannelModel.fromMap(e as Map<String, dynamic>))
          .toList();

      Log.info('Fetched ${channels.length} channels for group $groupId');
      return Right(channels);
    } on PostgrestException catch (e) {
      Log.error('getChannels error: ${e.message}');
      return Left(Failure(e.message));
    } catch (e) {
      Log.error('getChannels error: $e');
      return Left(Failure(e.toString()));
    }
  }

  /// Create a new channel (or default channel).
  Future<Either<Failure, ChannelModel>> createChannel({
    required ChannelModel channel,
  }) async {
    try {
      final response = await supabaseClient
          .from(SupabaseTable.channel)
          .insert(channel.toMap())
          .select()
          .single();
      return Right(ChannelModel.fromMap(response));
    } on PostgrestException catch (e) {
      return Left(Failure(e.message));
    } catch (e) {
      return Left(Failure(e.toString()));
    }
  }

  /// Get messages for a channel (newest first for pagination).
  Future<Either<Failure, List<MessageModel>>> getMessages({
    required String channelId,
    int limit = 50,
    int offset = 0,
  }) async {
    try {
      final response = await supabaseClient
          .from(SupabaseTable.message)
          .select('*, profiles(*)')
          .eq('channelId', channelId)
          .order('created_at', ascending: false)
          .range(offset, offset + limit - 1);

      final messages = (response as List)
          .map((e) => MessageModel.fromMap(e as Map<String, dynamic>))
          .toList();

      Log.info('Fetched ${messages.length} messages for channel $channelId');
      return Right(messages);
    } on PostgrestException catch (e) {
      Log.error('getMessages error: ${e.message}');
      return Left(Failure(e.message));
    } catch (e) {
      Log.error('getMessages error: $e');
      return Left(Failure(e.toString()));
    }
  }

  /// Send a message.
  Future<Either<Failure, MessageModel>> sendMessage({
    required MessageModel message,
  }) async {
    try {
      final response = await supabaseClient
          .from(SupabaseTable.message)
          .insert(message.toMap())
          .select('*, profiles(*)')
          .single();

      final sent = MessageModel.fromMap(response);
      Log.info('Sent message: ${sent.id}');
      return Right(sent);
    } on PostgrestException catch (e) {
      Log.error('sendMessage error: ${e.message}');
      return Left(Failure(e.message));
    } catch (e) {
      Log.error('sendMessage error: $e');
      return Left(Failure(e.toString()));
    }
  }

  /// Edit a message.
  Future<Either<Failure, MessageModel>> editMessage({
    required String messageId,
    required String content,
  }) async {
    try {
      final response = await supabaseClient
          .from(SupabaseTable.message)
          .update({
            'content': content,
            'isEdited': true,
          })
          .eq('id', messageId)
          .select('*, profiles(*)')
          .single();

      final updated = MessageModel.fromMap(response);
      Log.info('Edited message: $messageId');
      return Right(updated);
    } on PostgrestException catch (e) {
      Log.error('editMessage error: ${e.message}');
      return Left(Failure(e.message));
    } catch (e) {
      Log.error('editMessage error: $e');
      return Left(Failure(e.toString()));
    }
  }

  /// Delete a message.
  Future<Either<Failure, void>> deleteMessage({
    required String messageId,
  }) async {
    try {
      await supabaseClient
          .from(SupabaseTable.message)
          .delete()
          .eq('id', messageId);

      Log.info('Deleted message: $messageId');
      return const Right(null);
    } on PostgrestException catch (e) {
      Log.error('deleteMessage error: ${e.message}');
      return Left(Failure(e.message));
    } catch (e) {
      Log.error('deleteMessage error: $e');
      return Left(Failure(e.toString()));
    }
  }

  /// Stream messages via Supabase Realtime .stream().
  Stream<List<Map<String, dynamic>>> streamMessages({
    required String channelId,
  }) {
    return supabaseClient
        .from(SupabaseTable.message)
        .stream(primaryKey: ['id'])
        .eq('channelId', channelId)
        .order('created_at', ascending: true);
  }
}
