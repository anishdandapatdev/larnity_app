import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fpdart/fpdart.dart';
import 'package:larnity/src/core/error/failures.dart';
import 'package:larnity/src/core/service/supabase/src/supabase_provider.dart';
import 'package:larnity/src/core/service/supabase/src/supabase_table.dart';
import 'package:larnity/src/core/utils/logger.dart';
import 'package:larnity/src/features/group/data/models/notification_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final notificationDataSourceProvider =
    Provider<NotificationDataSource>((ref) {
  return NotificationDataSource(
      supabaseClient: ref.watch(supabaseClientProvider));
});

class NotificationDataSource {
  final SupabaseClient supabaseClient;

  NotificationDataSource({required this.supabaseClient});

  /// Get notifications for a user.
  Future<Either<Failure, List<NotificationModel>>> getNotifications({
    required String userId,
    int limit = 30,
    int offset = 0,
  }) async {
    try {
      final response = await supabaseClient
          .from(SupabaseTable.notifications)
          .select('*')
          .eq('userId', userId)
          .order('created_at', ascending: false)
          .range(offset, offset + limit - 1);

      final notifications = (response as List)
          .map((e) => NotificationModel.fromMap(e as Map<String, dynamic>))
          .toList();

      Log.info('Fetched ${notifications.length} notifications for user $userId');
      return Right(notifications);
    } on PostgrestException catch (e) {
      Log.error('getNotifications error: ${e.message}');
      return Left(Failure(e.message));
    } catch (e) {
      Log.error('getNotifications error: $e');
      return Left(Failure(e.toString()));
    }
  }

  /// Mark a notification as read.
  Future<Either<Failure, void>> markAsRead({
    required String notificationId,
  }) async {
    try {
      await supabaseClient
          .from(SupabaseTable.notifications)
          .update({'isRead': true})
          .eq('id', notificationId);

      Log.info('Marked notification $notificationId as read');
      return const Right(null);
    } on PostgrestException catch (e) {
      Log.error('markAsRead error: ${e.message}');
      return Left(Failure(e.message));
    } catch (e) {
      Log.error('markAsRead error: $e');
      return Left(Failure(e.toString()));
    }
  }

  /// Mark all notifications as read.
  Future<Either<Failure, void>> markAllAsRead({
    required String userId,
  }) async {
    try {
      await supabaseClient
          .from(SupabaseTable.notifications)
          .update({'isRead': true})
          .eq('userId', userId)
          .eq('isRead', false);

      Log.info('Marked all notifications as read for user $userId');
      return const Right(null);
    } on PostgrestException catch (e) {
      Log.error('markAllAsRead error: ${e.message}');
      return Left(Failure(e.message));
    } catch (e) {
      Log.error('markAllAsRead error: $e');
      return Left(Failure(e.toString()));
    }
  }

  /// Get unread notification count.
  Future<Either<Failure, int>> getUnreadCount({
    required String userId,
  }) async {
    try {
      final response = await supabaseClient
          .from(SupabaseTable.notifications)
          .select('id')
          .eq('userId', userId)
          .eq('isRead', false)
          .count(CountOption.exact);

      return Right(response.count);
    } on PostgrestException catch (e) {
      Log.error('getUnreadCount error: ${e.message}');
      return Left(Failure(e.message));
    } catch (e) {
      Log.error('getUnreadCount error: $e');
      return Left(Failure(e.toString()));
    }
  }

  /// Delete a notification.
  Future<Either<Failure, void>> deleteNotification({
    required String notificationId,
  }) async {
    try {
      await supabaseClient
          .from(SupabaseTable.notifications)
          .delete()
          .eq('id', notificationId);

      return const Right(null);
    } on PostgrestException catch (e) {
      Log.error('deleteNotification error: ${e.message}');
      return Left(Failure(e.message));
    } catch (e) {
      Log.error('deleteNotification error: $e');
      return Left(Failure(e.toString()));
    }
  }
}
