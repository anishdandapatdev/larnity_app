// ignore_for_file: constant_identifier_names

import 'package:equatable/equatable.dart';

enum NotificationType {
  group_invite,
  group_update,
  payment_success,
  payment_failed,
  subscription_expiry,
  promotion_alert,
  system_alert,
  user_mention,
  comment_reply,
  like,
  follow,
}

class NotificationModel extends Equatable {
  final String id;
  final DateTime createdAt;
  final String recipientId;
  final Map<String, dynamic> content;
  final bool isRead;
  final NotificationType type;
  final String? actorId;
  final String? groupId;
  final String? actionItemId;

  const NotificationModel({
    required this.id,
    required this.createdAt,
    required this.recipientId,
    required this.content,
    required this.isRead,
    required this.type,
    this.actorId,
    this.groupId,
    this.actionItemId,
  });

  NotificationModel copyWith({
    String? id,
    DateTime? createdAt,
    String? recipientId,
    Map<String, dynamic>? content,
    bool? isRead,
    NotificationType? type,
    String? actorId,
    String? groupId,
    String? actionItemId,
  }) {
    return NotificationModel(
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      recipientId: recipientId ?? this.recipientId,
      content: content ?? this.content,
      isRead: isRead ?? this.isRead,
      type: type ?? this.type,
      actorId: actorId ?? this.actorId,
      groupId: groupId ?? this.groupId,
      actionItemId: actionItemId ?? this.actionItemId,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'created_at': createdAt.toIso8601String(),
      'recipientId': recipientId,
      'content': content,
      'isRead': isRead,
      'type': type.name,
      'actorId': actorId,
      'groupId': groupId,
      'actionItemId': actionItemId,
    }..removeWhere((key, value) => value == null);
  }

  factory NotificationModel.fromMap(Map<String, dynamic> map) {
    return NotificationModel(
      id: map['id'] as String,
      createdAt: DateTime.parse(map['created_at'] as String),
      recipientId: map['recipientId'] as String,
      content: Map<String, dynamic>.from(map['content'] as Map),
      isRead: map['isRead'] as bool,
      type: NotificationType.values.firstWhere(
        (e) => e.name == map['type'],
        orElse: () => NotificationType.system_alert,
      ),
      actorId: map['actorId'] as String?,
      groupId: map['groupId'] as String?,
      actionItemId: map['actionItemId'] as String?,
    );
  }

  String get title => content['title'] as String? ?? 'Notification';
  String get body => content['body'] as String? ?? '';
  String? get image => content['image'] as String?;
  Map<String, dynamic>? get metadata =>
      content['metadata'] as Map<String, dynamic>?;

  bool get hasAction => actionItemId != null;
  bool get involvesGroup => groupId != null;
  bool get involvesActor => actorId != null;

  @override
  List<Object?> get props => [
    id,
    createdAt,
    recipientId,
    content,
    isRead,
    type,
    actorId,
    groupId,
    actionItemId,
  ];

  @override
  bool get stringify => true;
}
