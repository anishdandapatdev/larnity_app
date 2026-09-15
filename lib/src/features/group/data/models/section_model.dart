import 'package:equatable/equatable.dart';
import 'package:larnity/src/features/group/data/models/content_model.dart';

class SectionModel extends Equatable {
  final String? id;
  final String moduleId;
  final String? name;
  final String? icon;
  final bool? complete;
  final DateTime? createdAt;
  final List<ContentModel>? contents;

  const SectionModel({
    this.id,
    required this.moduleId,
    this.name,
    this.icon,
    this.complete,
    this.createdAt,
    this.contents,
  });

  SectionModel copyWith({
    String? id,
    String? moduleId,
    String? name,
    String? icon,
    bool? complete,
    DateTime? createdAt,
    List<ContentModel>? contents,
  }) {
    return SectionModel(
      id: id ?? this.id,
      moduleId: moduleId ?? this.moduleId,
      name: name ?? this.name,
      icon: icon ?? this.icon,
      complete: complete ?? this.complete,
      createdAt: createdAt ?? this.createdAt,
      contents: contents ?? this.contents,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'moduleId': moduleId,
      'name': name,
      'icon': icon,
      'complete': complete ?? false,
    }..removeWhere((key, value) => value == null);
  }

  factory SectionModel.fromMap(Map<String, dynamic> map) {
    return SectionModel(
      id: map['id'] as String?,
      moduleId: map['moduleId'] as String,
      name: map['name'] as String?,
      icon: map['icon'] as String?,
      complete: map['complete'] as bool? ?? false,
      createdAt: map['created_at'] != null
          ? DateTime.parse(map['created_at'] as String)
          : null,
      contents: map['Content'] is List
          ? (map['Content'] as List)
                .map((c) => ContentModel.fromMap(c as Map<String, dynamic>))
                .toList()
          : null,
    );
  }

  @override
  List<Object?> get props => [id, moduleId, name, icon, complete, createdAt];

  @override
  bool get stringify => true;
}
