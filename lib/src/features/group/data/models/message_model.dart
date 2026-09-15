import 'package:equatable/equatable.dart';

class MessageModel extends Equatable {
  final String? id;
  final String channelId;
  final String userId;
  final String? content;
  final String? type; // 'text', 'image', 'video', 'file'
  final String? mediaUrl;
  final String? replyToId;
  final bool? isEdited;
  final DateTime? createdAt;
  final Map<String, dynamic>? sender;

  const MessageModel({
    this.id,
    required this.channelId,
    required this.userId,
    this.content,
    this.type,
    this.mediaUrl,
    this.replyToId,
    this.isEdited,
    this.createdAt,
    this.sender,
  });

  MessageModel copyWith({
    String? id,
    String? channelId,
    String? userId,
    String? content,
    String? type,
    String? mediaUrl,
    String? replyToId,
    bool? isEdited,
    DateTime? createdAt,
    Map<String, dynamic>? sender,
  }) {
    return MessageModel(
      id: id ?? this.id,
      channelId: channelId ?? this.channelId,
      userId: userId ?? this.userId,
      content: content ?? this.content,
      type: type ?? this.type,
      mediaUrl: mediaUrl ?? this.mediaUrl,
      replyToId: replyToId ?? this.replyToId,
      isEdited: isEdited ?? this.isEdited,
      createdAt: createdAt ?? this.createdAt,
      sender: sender ?? this.sender,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'channelId': channelId,
      'userId': userId,
      'content': content,
      'type': type ?? 'text',
      'mediaUrl': mediaUrl,
      'replyToId': replyToId,
    }..removeWhere((key, value) => value == null);
  }

  factory MessageModel.fromMap(Map<String, dynamic> map) {
    return MessageModel(
      id: map['id'] as String?,
      channelId: map['channelId'] as String,
      userId: map['userId'] as String,
      content: map['content'] as String?,
      type: map['type'] as String? ?? 'text',
      mediaUrl: map['mediaUrl'] as String?,
      replyToId: map['replyToId'] as String?,
      isEdited: map['isEdited'] as bool? ?? false,
      createdAt: map['created_at'] != null
          ? DateTime.parse(map['created_at'] as String)
          : null,
      sender: map['profiles'] as Map<String, dynamic>?,
    );
  }

  String get senderName {
    if (sender == null) return 'Unknown';
    final first = sender!['firstname'] as String? ?? '';
    final last = sender!['lastname'] as String? ?? '';
    return '$first $last'.trim();
  }

  String? get senderImage => sender?['image'] as String?;

  bool get isTextMessage => type == 'text';
  bool get isImageMessage => type == 'image';
  bool get isVideoMessage => type == 'video';
  bool get isFileMessage => type == 'file';

  @override
  List<Object?> get props => [
        id, channelId, userId, content, type,
        mediaUrl, replyToId, isEdited, createdAt,
      ];

  @override
  bool get stringify => true;
}
