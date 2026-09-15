import 'package:equatable/equatable.dart';

class ChallengeModel extends Equatable {
  final String? id;
  final String groupId;
  final String? title;
  final String? description;
  final String? image;
  final DateTime? startDate;
  final DateTime? endDate;
  final int? maxParticipants;
  final String? prize;
  final String? rules;
  final String? jsonRules;
  final String? htmlRules;
  final bool? isActive;
  final String? status; // 'REGISTRATION_OPEN', 'LIVE', 'FINISHED', 'RESULTS_DECLARED'
  final String? type; // 'FREE', 'PAID'
  final double? price;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  // Joined / aggregated data
  final int? dayCount;
  final int? registrationCount;

  const ChallengeModel({
    this.id,
    required this.groupId,
    this.title,
    this.description,
    this.image,
    this.startDate,
    this.endDate,
    this.maxParticipants,
    this.prize,
    this.rules,
    this.jsonRules,
    this.htmlRules,
    this.isActive,
    this.status,
    this.type,
    this.price,
    this.createdAt,
    this.updatedAt,
    this.dayCount,
    this.registrationCount,
  });

  ChallengeModel copyWith({
    String? id,
    String? groupId,
    String? title,
    String? description,
    String? image,
    DateTime? startDate,
    DateTime? endDate,
    int? maxParticipants,
    String? prize,
    String? rules,
    String? jsonRules,
    String? htmlRules,
    bool? isActive,
    String? status,
    String? type,
    double? price,
    DateTime? createdAt,
    DateTime? updatedAt,
    int? dayCount,
    int? registrationCount,
  }) {
    return ChallengeModel(
      id: id ?? this.id,
      groupId: groupId ?? this.groupId,
      title: title ?? this.title,
      description: description ?? this.description,
      image: image ?? this.image,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      maxParticipants: maxParticipants ?? this.maxParticipants,
      prize: prize ?? this.prize,
      rules: rules ?? this.rules,
      jsonRules: jsonRules ?? this.jsonRules,
      htmlRules: htmlRules ?? this.htmlRules,
      isActive: isActive ?? this.isActive,
      status: status ?? this.status,
      type: type ?? this.type,
      price: price ?? this.price,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      dayCount: dayCount ?? this.dayCount,
      registrationCount: registrationCount ?? this.registrationCount,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'groupId': groupId,
      'title': title,
      'description': description,
      'image': image,
      'startDate': startDate?.toIso8601String(),
      'endDate': endDate?.toIso8601String(),
      'maxParticipants': maxParticipants,
      'prize': prize,
      'rules': rules,
      'jsonRules': jsonRules,
      'htmlRules': htmlRules,
      'isActive': isActive,
      'status': status,
      'type': type,
      'price': price,
    }..removeWhere((key, value) => value == null);
  }

  factory ChallengeModel.fromMap(Map<String, dynamic> map) {
    return ChallengeModel(
      id: map['id'] as String?,
      groupId: map['groupId'] as String,
      title: map['title'] as String?,
      description: map['description'] as String?,
      image: map['image'] as String?,
      startDate: map['startDate'] != null
          ? DateTime.parse(map['startDate'] as String)
          : null,
      endDate: map['endDate'] != null
          ? DateTime.parse(map['endDate'] as String)
          : null,
      maxParticipants: map['maxParticipants'] as int?,
      prize: map['prize'] as String?,
      rules: map['rules'] as String?,
      jsonRules: map['jsonRules'] as String?,
      htmlRules: map['htmlRules'] as String?,
      isActive: map['isActive'] as bool? ?? true,
      status: map['status'] as String?,
      type: map['type'] as String?,
      price: (map['price'] as num?)?.toDouble(),
      createdAt: map['created_at'] != null
          ? DateTime.parse(map['created_at'] as String)
          : null,
      updatedAt: map['updated_at'] != null
          ? DateTime.parse(map['updated_at'] as String)
          : null,
      dayCount: map['ChallengeDays'] is List
          ? (map['ChallengeDays'] as List).length
          : (map['ChallengeDays'] is Map
              ? (map['ChallengeDays']['count'] as int?)
              : null),
      registrationCount: map['ChallengeRegistrations'] is List
          ? (map['ChallengeRegistrations'] as List).length
          : (map['ChallengeRegistrations'] is Map
              ? (map['ChallengeRegistrations']['count'] as int?)
              : null),
    );
  }

  bool get isFree => type == 'FREE';
  bool get isPaid => type == 'PAID';
  bool get isRegistrationOpen => status == 'REGISTRATION_OPEN';
  bool get isLive => status == 'LIVE';
  bool get isFinished => status == 'FINISHED';
  bool get isResultsDeclared => status == 'RESULTS_DECLARED';

  @override
  List<Object?> get props => [
        id, groupId, title, description, image, startDate, endDate,
        maxParticipants, prize, rules, isActive, status, type, price,
        createdAt, updatedAt, dayCount, registrationCount,
      ];

  @override
  bool get stringify => true;
}
