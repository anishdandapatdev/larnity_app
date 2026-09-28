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

  factory PostModel.fromMap(Map<String, dynamic> map, {bool? isLikedByMe}) {
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
      commentCount: _extractCount(map['Comment']),
      likeCount: _extractCount(map['Like']),
      isLikedByMe: isLikedByMe ?? (map['isLikedByMe'] as bool?),
    );
  }

  static int? _extractCount(dynamic val) {
    if (val == null) return null;
    if (val is List) {
      if (val.isEmpty) return 0;
      final first = val.first;
      if (first is Map && first.containsKey('count')) {
        return (first['count'] as num?)?.toInt();
      }
      return val.length;
    }
    if (val is Map && val.containsKey('count')) {
      return (val['count'] as num?)?.toInt();
    }
    if (val is num) return val.toInt();
    return null;
  }

  String get authorName {
    if (author == null) return 'Unknown';
    final first = author!['firstname'] as String? ?? '';
    final last = author!['lastname'] as String? ?? '';
    final full = '$first $last'.trim();
    return full.isNotEmpty ? full : 'Anonymous';
  }

  String? get authorImage => author?['image'] as String?;

  String? get imageUrl {
    if (htmlContent != null && htmlContent!.isNotEmpty) {
      final m = RegExp(r'<img[^>]+src="([^">]+)"').firstMatch(htmlContent!);
      if (m != null) return m.group(1);
    }
    if (content.isNotEmpty) {
      final m = RegExp(r'<img[^>]+src="([^">]+)"').firstMatch(content);
      if (m != null) return m.group(1);
      final mdMatch = RegExp(r'!\[.*?\]\((.*?)\)').firstMatch(content);
      if (mdMatch != null) return mdMatch.group(1);
      final m2 = RegExp(
        r'(https?://[^\s<"]+\.(?:jpg|jpeg|png|webp|gif))',
        caseSensitive: false,
      ).firstMatch(content);
      if (m2 != null) return m2.group(1);
    }
    return null;
  }

  String get cleanContent {
    if (content.isEmpty) return '';
    return content
        .replaceAll(RegExp(r'<img[^>]*>', dotAll: true), '')
        .replaceAll(RegExp(r'<br\s*/?>'), '\n')
        .replaceAll(RegExp(r'</p>'), '\n')
        .replaceAll(RegExp(r'<[^>]*>'), '')
        .replaceAll('&nbsp;', ' ')
        .replaceAll('&amp;', '&')
        .replaceAll('&quot;', '"')
        .replaceAll('&#39;', "'")
        .replaceAll('&lt;', '<')
        .replaceAll('&gt;', '>')
        .trim();
  }

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
