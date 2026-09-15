import 'package:equatable/equatable.dart';

class ResourceCategoryModel extends Equatable {
  final String? id;
  final String name;
  final String thumbnail;
  final String groupId;
  final DateTime? createdAt;

  const ResourceCategoryModel({
    this.id,
    required this.name,
    required this.thumbnail,
    required this.groupId,
    this.createdAt,
  });

  ResourceCategoryModel copyWith({
    String? id,
    String? name,
    String? thumbnail,
    String? groupId,
    DateTime? createdAt,
  }) {
    return ResourceCategoryModel(
      id: id ?? this.id,
      name: name ?? this.name,
      thumbnail: thumbnail ?? this.thumbnail,
      groupId: groupId ?? this.groupId,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'name': name,
      'thumbnail': thumbnail,
      'groupId': groupId,
    }..removeWhere((key, value) => value == null);
  }

  factory ResourceCategoryModel.fromMap(Map<String, dynamic> map) {
    return ResourceCategoryModel(
      id: map['id'] as String?,
      name: map['name'] as String,
      thumbnail: map['thumbnail'] as String,
      groupId: map['groupId'] as String,
      createdAt: map['created_at'] != null
          ? DateTime.parse(map['created_at'] as String)
          : null,
    );
  }

  @override
  List<Object?> get props => [id, name, thumbnail, groupId, createdAt];

  @override
  bool get stringify => true;
}
