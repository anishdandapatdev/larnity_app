import 'package:equatable/equatable.dart';

class JobModel extends Equatable {
  final String? id;
  final DateTime createdAt;
  final String title;
  final String? description;
  final String? image;
  final DateTime? postingEndDate;
  final String? googleSheetId;
  final String groupId;
  final DateTime? updatedAt;

  const JobModel({
    this.id,
    required this.createdAt,
    required this.title,
    this.description,
    this.image,
    this.postingEndDate,
    this.googleSheetId,
    required this.groupId,
    this.updatedAt,
  });

  JobModel copyWith({
    String? id,
    DateTime? createdAt,
    String? title,
    String? description,
    String? image,
    DateTime? postingEndDate,
    String? googleSheetId,
    String? groupId,
    DateTime? updatedAt,
  }) {
    return JobModel(
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      title: title ?? this.title,
      description: description ?? this.description,
      image: image ?? this.image,
      postingEndDate: postingEndDate ?? this.postingEndDate,
      googleSheetId: googleSheetId ?? this.googleSheetId,
      groupId: groupId ?? this.groupId,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'created_at': createdAt.toIso8601String(),
      'title': title,
      'description': description,
      'image': image,
      'postingEndDate': postingEndDate?.toIso8601String(),
      'googleSheetId': googleSheetId,
      'groupId': groupId,
      'updated_at': updatedAt?.toIso8601String(),
    }..removeWhere((key, value) => value == null);
  }

  factory JobModel.fromMap(Map<String, dynamic> map) {
    return JobModel(
      id: map['id'] as String?,
      createdAt: DateTime.parse(map['created_at'] as String),
      title: map['title'] as String,
      description: map['description'] as String?,
      image: map['image'] as String?,
      postingEndDate: map['postingEndDate'] != null
          ? DateTime.parse(map['postingEndDate'] as String)
          : null,
      googleSheetId: map['googleSheetId'] as String?,
      groupId: map['groupId'] as String,
      updatedAt: map['updated_at'] != null
          ? DateTime.parse(map['updated_at'] as String)
          : null,
    );
  }

  bool get hasExpired {
    if (postingEndDate == null) return false;
    return DateTime.now().isAfter(postingEndDate!);
  }

  bool get isActive => !hasExpired;

  Duration? get remainingDuration {
    if (postingEndDate == null) return null;
    final now = DateTime.now();
    if (now.isAfter(postingEndDate!)) return Duration.zero;
    return postingEndDate!.difference(now);
  }

  bool get hasGoogleSheetIntegration =>
      googleSheetId != null && googleSheetId!.isNotEmpty;

  bool get hasImage => image != null && image!.isNotEmpty;

  @override
  List<Object?> get props => [
    id,
    createdAt,
    title,
    description,
    image,
    postingEndDate,
    googleSheetId,
    groupId,
    updatedAt,
  ];

  @override
  bool get stringify => true;
}
