import 'package:equatable/equatable.dart';
import 'package:larnity/src/features/group/data/models/module_model.dart';

class CourseModel extends Equatable {
  final String? id;
  final String groupId;
  final String? title;
  final String? description;
  final String? image;
  final bool? isPaid;
  final int? price;
  final String? currency;
  final bool? isPublished;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final int? moduleCount;
  final List<ModuleModel>? modules;

  const CourseModel({
    this.id,
    required this.groupId,
    this.title,
    this.description,
    this.image,
    this.isPaid,
    this.price,
    this.currency,
    this.isPublished,
    this.createdAt,
    this.updatedAt,
    this.moduleCount,
    this.modules,
  });

  CourseModel copyWith({
    String? id,
    String? groupId,
    String? title,
    String? description,
    String? image,
    bool? isPaid,
    int? price,
    String? currency,
    bool? isPublished,
    DateTime? createdAt,
    DateTime? updatedAt,
    int? moduleCount,
    List<ModuleModel>? modules,
  }) {
    return CourseModel(
      id: id ?? this.id,
      groupId: groupId ?? this.groupId,
      title: title ?? this.title,
      description: description ?? this.description,
      image: image ?? this.image,
      isPaid: isPaid ?? this.isPaid,
      price: price ?? this.price,
      currency: currency ?? this.currency,
      isPublished: isPublished ?? this.isPublished,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      moduleCount: moduleCount ?? this.moduleCount,
      modules: modules ?? this.modules,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'groupId': groupId,
      'name': title,
      'description': description,
      'thumbnail': image ?? "",
      'privacy': (isPaid ?? false) ? 'PAID' : 'PUBLIC',
      'price': price,
    }..removeWhere((key, value) => value == null);
  }

  factory CourseModel.fromMap(Map<String, dynamic> map) {
    return CourseModel(
      id: map['id'] as String?,
      groupId: map['groupId'] as String,
      title: map['name'] as String?,
      description: map['description'] as String?,
      image: map['thumbnail'] as String?,
      isPaid: map['privacy'] == 'PAID',
      price: map['price'] != null ? (map['price'] as num).toInt() : null,
      isPublished: map['is_published'] as bool? ?? false,
      createdAt: map['created_at'] != null
          ? DateTime.parse(map['created_at'] as String)
          : null,
      updatedAt: map['updated_at'] != null
          ? DateTime.parse(map['updated_at'] as String)
          : null,
      moduleCount: map['Module'] is List && map['Module'].isNotEmpty && (map['Module'][0] as Map).containsKey('count')
          ? (map['Module'][0]['count'] as int?)
          : (map['Module'] is Map ? (map['Module']['count'] as int?) : null),
      modules: map['Module'] is List && (map['Module'].isEmpty || !(map['Module'][0] as Map).containsKey('count'))
          ? (map['Module'] as List)
                .map((m) => ModuleModel.fromMap(m as Map<String, dynamic>))
                .toList()
          : null,
    );
  }

  @override
  List<Object?> get props => [
    id,
    groupId,
    title,
    description,
    image,
    isPaid,
    price,
    currency,
    isPublished,
    createdAt,
    moduleCount,
  ];

  @override
  bool get stringify => true;
}
