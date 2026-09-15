import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:larnity/src/core/utils/async_states.dart';
import 'package:larnity/src/features/group/data/datasource/notification_datasource.dart';
import 'package:larnity/src/features/group/data/models/notification_model.dart';

class NotificationState {
  final AsyncState? fetchState;
  final String? error;
  final List<NotificationModel>? notifications;
  final int unreadCount;
  final bool hasMore;
  final int offset;

  NotificationState({
    this.fetchState, this.error, this.notifications,
    this.unreadCount = 0, this.hasMore = true, this.offset = 0,
  });

  NotificationState copyWith({
    AsyncState? fetchState, String? error,
    List<NotificationModel>? notifications,
    int? unreadCount, bool? hasMore, int? offset,
  }) => NotificationState(
    fetchState: fetchState ?? this.fetchState,
    error: error ?? this.error,
    notifications: notifications ?? this.notifications,
    unreadCount: unreadCount ?? this.unreadCount,
    hasMore: hasMore ?? this.hasMore,
    offset: offset ?? this.offset,
  );
}

final notificationProvider = NotifierProvider.autoDispose
    .family<NotificationNotifier, NotificationState, String>(
  NotificationNotifier.new,
);

class NotificationNotifier
    extends AutoDisposeFamilyNotifier<NotificationState, String> {
  static const int _pageSize = 30;

  @override
  NotificationState build(String arg) {
    Future.microtask(() {
      fetchNotifications();
      fetchUnreadCount();
    });
    return NotificationState(fetchState: AsyncState.initial);
  }

  String get _userId => arg;

  Future<void> fetchNotifications() async {
    final ds = ref.read(notificationDataSourceProvider);
    state = state.copyWith(fetchState: AsyncState.loading, offset: 0);

    final result = await ds.getNotifications(
      userId: _userId, limit: _pageSize, offset: 0,
    );

    result.fold(
      (f) => state = state.copyWith(fetchState: AsyncState.failure, error: f.message),
      (notifications) => state = state.copyWith(
        fetchState: AsyncState.success,
        notifications: notifications,
        hasMore: notifications.length >= _pageSize,
        offset: notifications.length,
      ),
    );
  }

  Future<void> loadMore() async {
    if (!state.hasMore) return;
    final ds = ref.read(notificationDataSourceProvider);

    final result = await ds.getNotifications(
      userId: _userId, limit: _pageSize, offset: state.offset,
    );

    result.fold(
      (f) => state = state.copyWith(error: f.message),
      (newNotifications) {
        final all = [...(state.notifications ?? []), ...newNotifications];
        state = state.copyWith(
          notifications: all,
          hasMore: newNotifications.length >= _pageSize,
          offset: all.length,
        );
      },
    );
  }

  Future<void> fetchUnreadCount() async {
    final ds = ref.read(notificationDataSourceProvider);
    final result = await ds.getUnreadCount(userId: _userId);
    result.fold((_) {}, (count) => state = state.copyWith(unreadCount: count));
  }

  Future<void> markAsRead({required String notificationId}) async {
    final ds = ref.read(notificationDataSourceProvider);
    await ds.markAsRead(notificationId: notificationId);

    state = state.copyWith(
      notifications: state.notifications?.map((n) {
        if (n.id == notificationId) return n.copyWith(isRead: true);
        return n;
      }).toList(),
      unreadCount: (state.unreadCount - 1).clamp(0, 999999),
    );
  }

  Future<void> markAllAsRead() async {
    final ds = ref.read(notificationDataSourceProvider);
    await ds.markAllAsRead(userId: _userId);

    state = state.copyWith(
      notifications: state.notifications?.map((n) => n.copyWith(isRead: true)).toList(),
      unreadCount: 0,
    );
  }

  /// Add a notification from realtime subscription.
  void addRealtimeNotification(NotificationModel notification) {
    state = state.copyWith(
      notifications: [notification, ...(state.notifications ?? [])],
      unreadCount: state.unreadCount + 1,
    );
  }
}
