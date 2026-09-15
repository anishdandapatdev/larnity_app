

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:larnity/src/core/service/supabase/src/supabase_provider.dart';
import 'package:larnity/src/core/utils/logger.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Provider for [SupabaseRealtimeService].
final realtimeServiceProvider = Provider<SupabaseRealtimeService>((ref) {
  final client = ref.watch(supabaseClientProvider);
  final service = SupabaseRealtimeService(client: client);
  ref.onDispose(() => service.unsubscribeAll());
  return service;
});

/// Centralized manager for Supabase Realtime subscriptions.
///
/// Usage:
/// ```dart
/// final realtime = ref.read(realtimeServiceProvider);
/// realtime.subscribeToTable(
///   channelName: 'discussion:$groupId',
///   table: 'Post',
///   filterColumn: 'groupId',
///   filterValue: groupId,
///   onInsert: (payload) { /* add new post */ },
/// );
/// ```
class SupabaseRealtimeService {
  final SupabaseClient client;
  final Map<String, RealtimeChannel> _channels = {};

  SupabaseRealtimeService({required this.client});

  /// Subscribe to Postgres row-level changes on a table.
  ///
  /// [channelName] must be unique per subscription.
  /// [filterColumn] + [filterValue] narrow the subscription to specific rows.
  RealtimeChannel subscribeToTable({
    required String channelName,
    required String table,
    String? filterColumn,
    String? filterValue,
    required void Function(PostgresChangePayload payload) onInsert,
    void Function(PostgresChangePayload payload)? onUpdate,
    void Function(PostgresChangePayload payload)? onDelete,
  }) {
    // Unsubscribe existing channel with same name
    unsubscribe(channelName);

    final channel = client.channel(channelName);

    // INSERT listener
    channel.onPostgresChanges(
      event: PostgresChangeEvent.insert,
      schema: 'public',
      table: table,
      filter: filterColumn != null && filterValue != null
          ? PostgresChangeFilter(
              type: PostgresChangeFilterType.eq,
              column: filterColumn,
              value: filterValue,
            )
          : null,
      callback: (payload) {
        Log.info('Realtime INSERT on $table: ${payload.newRecord}');
        onInsert(payload);
      },
    );

    // UPDATE listener
    if (onUpdate != null) {
      channel.onPostgresChanges(
        event: PostgresChangeEvent.update,
        schema: 'public',
        table: table,
        filter: filterColumn != null && filterValue != null
            ? PostgresChangeFilter(
                type: PostgresChangeFilterType.eq,
                column: filterColumn,
                value: filterValue,
              )
            : null,
        callback: (payload) {
          Log.info('Realtime UPDATE on $table: ${payload.newRecord}');
          onUpdate(payload);
        },
      );
    }

    // DELETE listener
    if (onDelete != null) {
      channel.onPostgresChanges(
        event: PostgresChangeEvent.delete,
        schema: 'public',
        table: table,
        filter: filterColumn != null && filterValue != null
            ? PostgresChangeFilter(
                type: PostgresChangeFilterType.eq,
                column: filterColumn,
                value: filterValue,
              )
            : null,
        callback: (payload) {
          Log.info('Realtime DELETE on $table: ${payload.oldRecord}');
          onDelete(payload);
        },
      );
    }

    channel.subscribe();
    _channels[channelName] = channel;

    Log.info('Subscribed to realtime channel: $channelName');
    return channel;
  }

  /// Subscribe to a Supabase Realtime stream (alternative using .stream()).
  ///
  /// This returns a [Stream] of list of maps that auto-updates on changes.
  /// Useful for simpler use cases like chat or live member counts.
  Stream<List<Map<String, dynamic>>> streamTable({
    required String table,
    required List<String> primaryKey,
    String? filterColumn,
    String? filterValue,
    String? orderBy,
    bool ascending = false,
  }) {
    final streamBuilder = client.from(table).stream(primaryKey: primaryKey);

    if (filterColumn != null && filterValue != null) {
      final filtered = streamBuilder.eq(filterColumn, filterValue);
      if (orderBy != null) {
        return filtered.order(orderBy, ascending: ascending);
      }
      return filtered;
    }

    if (orderBy != null) {
      return streamBuilder.order(orderBy, ascending: ascending);
    }

    return streamBuilder;
  }

  /// Unsubscribe from a specific channel.
  void unsubscribe(String channelName) {
    final channel = _channels.remove(channelName);
    if (channel != null) {
      client.removeChannel(channel);
      Log.info('Unsubscribed from realtime channel: $channelName');
    }
  }

  /// Unsubscribe from all active channels.
  void unsubscribeAll() {
    for (final entry in _channels.entries) {
      client.removeChannel(entry.value);
    }
    _channels.clear();
    Log.info('Unsubscribed from all realtime channels');
  }

  /// Check if a channel is currently subscribed.
  bool isSubscribed(String channelName) => _channels.containsKey(channelName);

  /// Get the number of active subscriptions.
  int get activeSubscriptionCount => _channels.length;
}
