import 'package:equatable/equatable.dart';

class NotificationModel extends Equatable {
  final String? id;
  final String userId;
  final String? title;
  final String? body;
  final String? type;
  final Map<String, dynamic>? data;
  final bool? isRead;
  final DateTime? createdAt;

  const NotificationModel({
    this.id,
    required this.userId,
    this.title,
    this.body,
    this.type,
    this.data,
    this.isRead,
    this.createdAt,
  });

  NotificationModel copyWith({
    String? id,
    String? userId,
    String? title,
    String? body,
    String? type,
    Map<String, dynamic>? data,
    bool? isRead,
    DateTime? createdAt,
  }) {
    return NotificationModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      body: body ?? this.body,
      type: type ?? this.type,
      data: data ?? this.data,
      isRead: isRead ?? this.isRead,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  factory NotificationModel.fromMap(Map<String, dynamic> map) {
    return NotificationModel(
      id: map['id'] as String?,
      userId: map['userId'] as String,
      title: map['title'] as String?,
      body: map['body'] as String?,
      type: map['type'] as String?,
      data: map['data'] as Map<String, dynamic>?,
      isRead: map['isRead'] as bool? ?? false,
      createdAt: map['created_at'] != null
          ? DateTime.parse(map['created_at'] as String)
          : null,
    );
  }

  @override
  List<Object?> get props => [id, userId, title, body, type, isRead, createdAt];

  @override
  bool get stringify => true;
}
