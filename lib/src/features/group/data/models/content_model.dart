import 'package:equatable/equatable.dart';

class ContentModel extends Equatable {
  final String? id;
  final String sectionId;
  final String? title;
  final String? content;
  final DateTime? createdAt;

  const ContentModel({
    this.id,
    required this.sectionId,
    this.title,
    this.content,
    this.createdAt,
  });

  ContentModel copyWith({
    String? id,
    String? sectionId,
    String? title,
    String? content,
    DateTime? createdAt,
  }) {
    return ContentModel(
      id: id ?? this.id,
      sectionId: sectionId ?? this.sectionId,
      title: title ?? this.title,
      content: content ?? this.content,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'sectionId': sectionId,
      'title': title,
      'content': content,
    }..removeWhere((key, value) => value == null);
  }

  factory ContentModel.fromMap(Map<String, dynamic> map) {
    return ContentModel(
      id: map['id'] as String?,
      sectionId: map['sectionId'] as String,
      title: map['title'] as String?,
      content: map['content'] as String?,
      createdAt: map['created_at'] != null
          ? DateTime.parse(map['created_at'] as String)
          : null,
    );
  }

  @override
  List<Object?> get props => [id, sectionId, title, content, createdAt];

  @override
  bool get stringify => true;
}
