import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fpdart/fpdart.dart';
import 'package:larnity/src/core/error/failures.dart';
import 'package:larnity/src/core/service/supabase/src/supabase_provider.dart';
import 'package:larnity/src/core/utils/logger.dart';
import 'package:larnity/src/features/explore/data/models/notification_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final notificationDataSourceProvider = Provider<NotificationDataSource>((ref) {
  return NotificationDataSource(
    supabaseClient: ref.watch(supabaseClientProvider),
  );
});

class NotificationDataSource {
  final SupabaseClient supabaseClient;

  NotificationDataSource({required this.supabaseClient});

  Future<Either<Failure, NotificationModel>> createNotification({
    required NotificationModel notification,
  }) async {
    try {
      final response = await supabaseClient
          .from('Notifications')
          .insert(notification.toMap())
          .select()
          .single();

      Log.info("Create Notification Response: ${response.toString()}");

      return Right(NotificationModel.fromMap(response));
    } on PostgrestException catch (e) {
      Log.error("Create Notification Error: ${e.message}");
      return Left(Failure(e.message));
    } catch (e) {
      Log.error("Create Notification Error: ${e.toString()}");
      return Left(Failure(e.toString()));
    }
  }

  Future<Either<Failure, List<NotificationModel>>> getNotificationsByUser({
    required String recipientId,
    int limit = 50,
    int offset = 0,
  }) async {
    try {
      final response = await supabaseClient
          .from('Notifications')
          .select()
          .eq('recipientId', recipientId)
          .order('created_at', ascending: false)
          .range(offset, offset + limit - 1);

      final notifications = response
          .map((data) => NotificationModel.fromMap(data))
          .toList();

      return Right(notifications);
    } on PostgrestException catch (e) {
      Log.error("Get Notifications by User Error: ${e.message}");
      return Left(Failure(e.message));
    } catch (e) {
      Log.error("Get Notifications by User Error: ${e.toString()}");
      return Left(Failure(e.toString()));
    }
  }

  Future<Either<Failure, List<NotificationModel>>>
  getUnreadNotificationsByUser({required String recipientId}) async {
    try {
      final response = await supabaseClient
          .from('Notifications')
          .select()
          .eq('recipientId', recipientId)
          .eq('isRead', false)
          .order('created_at', ascending: false);

      final notifications = response
          .map((data) => NotificationModel.fromMap(data))
          .toList();

      return Right(notifications);
    } on PostgrestException catch (e) {
      Log.error("Get Unread Notifications Error: ${e.message}");
      return Left(Failure(e.message));
    } catch (e) {
      Log.error("Get Unread Notifications Error: ${e.toString()}");
      return Left(Failure(e.toString()));
    }
  }

  Future<Either<Failure, List<NotificationModel>>> getNotificationsByType({
    required String recipientId,
    required NotificationType type,
  }) async {
    try {
      final response = await supabaseClient
          .from('Notifications')
          .select()
          .eq('recipientId', recipientId)
          .eq('type', type.name)
          .order('created_at', ascending: false);

      final notifications = response
          .map((data) => NotificationModel.fromMap(data))
          .toList();

      return Right(notifications);
    } on PostgrestException catch (e) {
      Log.error("Get Notifications by Type Error: ${e.message}");
      return Left(Failure(e.message));
    } catch (e) {
      Log.error("Get Notifications by Type Error: ${e.toString()}");
      return Left(Failure(e.toString()));
    }
  }

  Future<Either<Failure, List<NotificationModel>>> getGroupNotifications({
    required String recipientId,
    required String groupId,
  }) async {
    try {
      final response = await supabaseClient
          .from('Notifications')
          .select()
          .eq('recipientId', recipientId)
          .eq('groupId', groupId)
          .order('created_at', ascending: false);

      final notifications = response
          .map((data) => NotificationModel.fromMap(data))
          .toList();

      return Right(notifications);
    } on PostgrestException catch (e) {
      Log.error("Get Group Notifications Error: ${e.message}");
      return Left(Failure(e.message));
    } catch (e) {
      Log.error("Get Group Notifications Error: ${e.toString()}");
      return Left(Failure(e.toString()));
    }
  }

  Future<Either<Failure, NotificationModel>> markAsRead({
    required String notificationId,
  }) async {
    try {
      final response = await supabaseClient
          .from('Notifications')
          .update({'isRead': true})
          .eq('id', notificationId)
          .select()
          .single();

      Log.info("Mark Notification as Read Response: ${response.toString()}");

      return Right(NotificationModel.fromMap(response));
    } on PostgrestException catch (e) {
      Log.error("Mark Notification as Read Error: ${e.message}");
      return Left(Failure(e.message));
    } catch (e) {
      Log.error("Mark Notification as Read Error: ${e.toString()}");
      return Left(Failure(e.toString()));
    }
  }

  Future<Either<Failure, void>> markAllAsRead({
    required String recipientId,
  }) async {
    try {
      await supabaseClient
          .from('Notifications')
          .update({'isRead': true})
          .eq('recipientId', recipientId)
          .eq('isRead', false);

      Log.info("Mark All Notifications as Read for User: $recipientId");

      return const Right(null);
    } on PostgrestException catch (e) {
      Log.error("Mark All Notifications as Read Error: ${e.message}");
      return Left(Failure(e.message));
    } catch (e) {
      Log.error("Mark All Notifications as Read Error: ${e.toString()}");
      return Left(Failure(e.toString()));
    }
  }

  Future<Either<Failure, int>> getUnreadCount({
    required String recipientId,
  }) async {
    try {
      final response = await supabaseClient
          .from('Notifications')
          .select('id')
          .eq('recipientId', recipientId)
          .eq('isRead', false);

      return Right(response.length);
    } on PostgrestException catch (e) {
      Log.error("Get Unread Count Error: ${e.message}");
      return Left(Failure(e.message));
    } catch (e) {
      Log.error("Get Unread Count Error: ${e.toString()}");
      return Left(Failure(e.toString()));
    }
  }

  Future<Either<Failure, void>> deleteNotification({
    required String notificationId,
  }) async {
    try {
      await supabaseClient
          .from('Notifications')
          .delete()
          .eq('id', notificationId);

      Log.info("Delete Notification Success for ID: $notificationId");

      return const Right(null);
    } on PostgrestException catch (e) {
      Log.error("Delete Notification Error: ${e.message}");
      return Left(Failure(e.message));
    } catch (e) {
      Log.error("Delete Notification Error: ${e.toString()}");
      return Left(Failure(e.toString()));
    }
  }

  Future<Either<Failure, void>> deleteAllNotifications({
    required String recipientId,
  }) async {
    try {
      await supabaseClient
          .from('Notifications')
          .delete()
          .eq('recipientId', recipientId);

      Log.info("Delete All Notifications Success for User: $recipientId");

      return const Right(null);
    } on PostgrestException catch (e) {
      Log.error("Delete All Notifications Error: ${e.message}");
      return Left(Failure(e.message));
    } catch (e) {
      Log.error("Delete All Notifications Error: ${e.toString()}");
      return Left(Failure(e.toString()));
    }
  }

  // Real-time subscription for new notifications
  Stream<List<NotificationModel>> subscribeToUserNotifications(
    String recipientId,
  ) {
    return supabaseClient
        .from('Notifications')
        .stream(primaryKey: ['id'])
        .eq('recipientId', recipientId)
        .order('created_at', ascending: false)
        .map(
          (data) =>
              data.map((item) => NotificationModel.fromMap(item)).toList(),
        );
  }
}
