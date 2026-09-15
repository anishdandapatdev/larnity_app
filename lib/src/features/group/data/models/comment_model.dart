import 'package:equatable/equatable.dart';

class CommentModel extends Equatable {
  final String? id;
  final String postId;
  final String userId;
  final String content;
  final String? parentId;
  final DateTime? createdAt;
  final Map<String, dynamic>? author;

  const CommentModel({
    this.id,
    required this.postId,
    required this.userId,
    required this.content,
    this.parentId,
    this.createdAt,
    this.author,
  });

  CommentModel copyWith({
    String? id,
    String? postId,
    String? userId,
    String? content,
    String? parentId,
    DateTime? createdAt,
    Map<String, dynamic>? author,
  }) {
    return CommentModel(
      id: id ?? this.id,
      postId: postId ?? this.postId,
      userId: userId ?? this.userId,
      content: content ?? this.content,
      parentId: parentId ?? this.parentId,
      createdAt: createdAt ?? this.createdAt,
      author: author ?? this.author,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'postId': postId,
      'userId': userId,
      'content': content,
      'parentId': parentId,
    }..removeWhere((key, value) => value == null);
  }

  factory CommentModel.fromMap(Map<String, dynamic> map) {
    return CommentModel(
      id: map['id'] as String?,
      postId: map['postId'] as String,
      userId: map['userId'] as String,
      content: map['content'] as String,
      parentId: map['parentId'] as String?,
      createdAt: map['created_at'] != null
          ? DateTime.parse(map['created_at'] as String)
          : null,
      author: map['profiles'] as Map<String, dynamic>?,
    );
  }

  String get authorName {
    if (author == null) return 'Unknown';
    final first = author!['firstname'] as String? ?? '';
    final last = author!['lastname'] as String? ?? '';
    return '$first $last'.trim();
  }

  String? get authorImage => author?['image'] as String?;

  @override
  List<Object?> get props => [id, postId, userId, content, parentId, createdAt];

  @override
  bool get stringify => true;
}
