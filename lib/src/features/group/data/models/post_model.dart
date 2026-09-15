import 'package:equatable/equatable.dart';

class PostModel extends Equatable {
  final String? id;
  final String channelId;
  final String authorId;
  final String? title;
  final String content;
  final String? jsonContent;
  final String? htmlContent;
  final DateTime? createdAt;

  // Joined data
  final Map<String, dynamic>? author;
  final int? commentCount;
  final int? likeCount;
  final bool? isLikedByMe;

  const PostModel({
    this.id,
    required this.channelId,
    required this.authorId,
    this.title,
    required this.content,
    this.jsonContent,
    this.htmlContent,
    this.createdAt,
    this.author,
    this.commentCount,
    this.likeCount,
    this.isLikedByMe,
  });

  PostModel copyWith({
    String? id,
    String? channelId,
    String? authorId,
    String? title,
    String? content,
    String? jsonContent,
    String? htmlContent,
    DateTime? createdAt,
    Map<String, dynamic>? author,
    int? commentCount,
    int? likeCount,
    bool? isLikedByMe,
  }) {
    return PostModel(
      id: id ?? this.id,
      channelId: channelId ?? this.channelId,
      authorId: authorId ?? this.authorId,
      title: title ?? this.title,
      content: content ?? this.content,
      jsonContent: jsonContent ?? this.jsonContent,
      htmlContent: htmlContent ?? this.htmlContent,
      createdAt: createdAt ?? this.createdAt,
      author: author ?? this.author,
      commentCount: commentCount ?? this.commentCount,
      likeCount: likeCount ?? this.likeCount,
      isLikedByMe: isLikedByMe ?? this.isLikedByMe,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'channelId': channelId,
      'authorId': authorId,
      'title': title,
      'content': content,
      'jsonContent': jsonContent,
      'htmlContent': htmlContent,
    }..removeWhere((key, value) => value == null);
  }

  factory PostModel.fromMap(Map<String, dynamic> map) {
    return PostModel(
      id: map['id'] as String?,
      channelId: map['channelId'] as String,
      authorId: map['authorId'] as String,
      title: map['title'] as String?,
      content: map['content'] as String? ?? '',
      jsonContent: map['jsonContent'] as String?,
      htmlContent: map['htmlContent'] as String?,
      createdAt: map['created_at'] != null
          ? DateTime.parse(map['created_at'] as String)
          : null,
      author: map['profiles'] as Map<String, dynamic>?,
      commentCount: map['Comment'] is List
          ? (map['Comment'] as List).length
          : (map['Comment'] is Map ? (map['Comment']['count'] as int?) : null),
      likeCount: map['Like'] is List
          ? (map['Like'] as List).length
          : (map['Like'] is Map ? (map['Like']['count'] as int?) : null),
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
  List<Object?> get props => [
    id,
    channelId,
    authorId,
    title,
    content,
    jsonContent,
    htmlContent,
    createdAt,
    commentCount,
    likeCount,
    isLikedByMe,
  ];

  @override
  bool get stringify => true;
}
