import 'package:equatable/equatable.dart';

class ResourceModel extends Equatable {
  final String? id;
  final String resourceImg;
  final String resourceName;
  final String resourceLink;
  final String groupId;
  final String? categoryId;
  final DateTime? createdAt;

  const ResourceModel({
    this.id,
    required this.resourceImg,
    required this.resourceName,
    required this.resourceLink,
    required this.groupId,
    this.categoryId,
    this.createdAt,
  });

  ResourceModel copyWith({
    String? id,
    String? resourceImg,
    String? resourceName,
    String? resourceLink,
    String? groupId,
    String? categoryId,
    DateTime? createdAt,
  }) {
    return ResourceModel(
      id: id ?? this.id,
      resourceImg: resourceImg ?? this.resourceImg,
      resourceName: resourceName ?? this.resourceName,
      resourceLink: resourceLink ?? this.resourceLink,
      groupId: groupId ?? this.groupId,
      categoryId: categoryId ?? this.categoryId,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'resourceImg': resourceImg,
      'resourceName': resourceName,
      'resourceLink': resourceLink,
      'groupId': groupId,
      'categoryId': categoryId,
    }..removeWhere((key, value) => value == null);
  }

  factory ResourceModel.fromMap(Map<String, dynamic> map) {
    return ResourceModel(
      id: map['id'] as String?,
      resourceImg: map['resourceImg'] as String,
      resourceName: map['resourceName'] as String,
      resourceLink: map['resourceLink'] as String,
      groupId: map['groupId'] as String,
      categoryId: map['categoryId'] as String?,
      createdAt: map['created_at'] != null
          ? DateTime.parse(map['created_at'] as String)
          : null,
    );
  }

  @override
  List<Object?> get props => [
    id,
    resourceImg,
    resourceName,
    resourceLink,
    groupId,
    categoryId,
    createdAt,
  ];

  @override
  bool get stringify => true;
}
