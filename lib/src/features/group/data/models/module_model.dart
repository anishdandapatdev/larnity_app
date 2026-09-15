import 'package:equatable/equatable.dart';
import 'package:larnity/src/features/group/data/models/section_model.dart';

class ModuleModel extends Equatable {
  final String? id;
  final String courseId;
  final String? title;
  final DateTime? createdAt;
  final List<SectionModel>? sections;

  const ModuleModel({
    this.id,
    required this.courseId,
    this.title,
    this.createdAt,
    this.sections,
  });

  ModuleModel copyWith({
    String? id,
    String? courseId,
    String? title,
    DateTime? createdAt,
    List<SectionModel>? sections,
  }) {
    return ModuleModel(
      id: id ?? this.id,
      courseId: courseId ?? this.courseId,
      title: title ?? this.title,
      createdAt: createdAt ?? this.createdAt,
      sections: sections ?? this.sections,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{'id': id, 'courseId': courseId, 'title': title}
      ..removeWhere((key, value) => value == null);
  }

  factory ModuleModel.fromMap(Map<String, dynamic> map) {
    return ModuleModel(
      id: map['id'] as String?,
      courseId: map['courseId'] as String,
      title: map['title'] as String?,
      createdAt: map['created_at'] != null
          ? DateTime.parse(map['created_at'] as String)
          : null,
      sections: map['Section'] is List
          ? (map['Section'] as List)
                .map((s) => SectionModel.fromMap(s as Map<String, dynamic>))
                .toList()
          : null,
    );
  }

  @override
  List<Object?> get props => [id, courseId, title, createdAt];

  @override
  bool get stringify => true;
}
