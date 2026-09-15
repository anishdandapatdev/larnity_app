import 'package:equatable/equatable.dart';

class MemberModel extends Equatable {
  final String? id;
  final String groupId;
  final String userId;
  final DateTime? subscriptionStartDate;
  final DateTime? subscriptionEndDate;
  final bool isActive;
  final String? planType;
  final String role;
  final double? planPrice;
  final DateTime? createdAt;

  // Relational data
  final Map<String, dynamic>? profile;

  const MemberModel({
    this.id,
    required this.groupId,
    required this.userId,
    this.subscriptionStartDate,
    this.subscriptionEndDate,
    this.isActive = true,
    this.planType,
    this.role = 'MEMBER',
    this.planPrice,
    this.createdAt,
    this.profile,
  });

  MemberModel copyWith({
    String? id,
    String? groupId,
    String? userId,
    DateTime? subscriptionStartDate,
    DateTime? subscriptionEndDate,
    bool? isActive,
    String? planType,
    String? role,
    double? planPrice,
    DateTime? createdAt,
    Map<String, dynamic>? profile,
  }) {
    return MemberModel(
      id: id ?? this.id,
      groupId: groupId ?? this.groupId,
      userId: userId ?? this.userId,
      subscriptionStartDate:
          subscriptionStartDate ?? this.subscriptionStartDate,
      subscriptionEndDate: subscriptionEndDate ?? this.subscriptionEndDate,
      isActive: isActive ?? this.isActive,
      planType: planType ?? this.planType,
      role: role ?? this.role,
      planPrice: planPrice ?? this.planPrice,
      createdAt: createdAt ?? this.createdAt,
      profile: profile ?? this.profile,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'groupId': groupId,
      'userId': userId,
      'subscriptionStartDate': subscriptionStartDate?.toIso8601String(),
      'subscriptionEndDate': subscriptionEndDate?.toIso8601String(),
      'isActive': isActive,
      'planType': planType,
      'role': role,
      'planPrice': planPrice,
    }..removeWhere((key, value) => value == null);
  }

  factory MemberModel.fromMap(Map<String, dynamic> map) {
    return MemberModel(
      id: map['id'] as String?,
      groupId: map['groupId'] as String,
      userId: map['userId'] as String,
      subscriptionStartDate: map['subscriptionStartDate'] != null
          ? DateTime.parse(map['subscriptionStartDate'] as String)
          : null,
      subscriptionEndDate: map['subscriptionEndDate'] != null
          ? DateTime.parse(map['subscriptionEndDate'] as String)
          : null,
      isActive: map['isActive'] as bool? ?? true,
      planType: map['planType'] as String?,
      role: map['role'] as String? ?? 'MEMBER',
      planPrice: map['planPrice'] != null
          ? (map['planPrice'] as num).toDouble()
          : null,
      createdAt: map['created_at'] != null
          ? DateTime.parse(map['created_at'] as String)
          : null,
      profile: map['profiles'] as Map<String, dynamic>?,
    );
  }

  String get memberName {
    if (profile == null) return 'Unknown';
    final first = profile!['firstname'] as String? ?? '';
    final last = profile!['lastname'] as String? ?? '';
    return '$first $last'.trim();
  }

  String? get memberImage => profile?['image'] as String?;
  String? get memberEmail => profile?['email'] as String?;

  bool get isAdmin => role == 'ADMIN';
  bool get isManager => role == 'MANAGER';
  bool get isMember => role == 'MEMBER';
  // Removed isBlocked because status was removed, rely on isActive

  @override
  List<Object?> get props => [
    id,
    groupId,
    userId,
    subscriptionStartDate,
    subscriptionEndDate,
    isActive,
    planType,
    role,
    planPrice,
    createdAt,
  ];

  @override
  bool get stringify => true;
}
