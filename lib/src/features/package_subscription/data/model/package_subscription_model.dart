import 'package:equatable/equatable.dart';

class PackageSubscriptionModel extends Equatable {
  final String? id;
  final DateTime? createdAt;
  final String userId;
  final String packageId;
  final DateTime? subscriptionStartDate;
  final DateTime? subscriptionEndDate;
  final bool? isActive;
  final int? totalGroupsCreated;
  final DateTime? updatedAt;

  const PackageSubscriptionModel({
    this.id,
    this.createdAt,
    required this.userId,
    required this.packageId,
    this.subscriptionStartDate,
    this.subscriptionEndDate,
    this.isActive,
    this.totalGroupsCreated,
    this.updatedAt,
  });

  PackageSubscriptionModel copyWith({
    DateTime? createdAt,
    String? userId,
    String? packageId,
    DateTime? subscriptionStartDate,
    DateTime? subscriptionEndDate,
    bool? isActive,
    int? totalGroupsCreated,
    DateTime? updatedAt,
  }) {
    return PackageSubscriptionModel(
      createdAt: createdAt ?? this.createdAt,
      userId: userId ?? this.userId,
      packageId: packageId ?? this.packageId,
      subscriptionStartDate:
          subscriptionStartDate ?? this.subscriptionStartDate,
      subscriptionEndDate: subscriptionEndDate ?? this.subscriptionEndDate,
      isActive: isActive ?? this.isActive,
      totalGroupsCreated: totalGroupsCreated ?? this.totalGroupsCreated,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'created_at': createdAt?.toIso8601String(),
      'userId': userId,
      'packageId': packageId,
      'subscriptionStartDate': subscriptionStartDate?.toIso8601String(),
      'subscriptionEndDate': subscriptionEndDate?.toIso8601String(),
      'isActive': isActive,
      'totalGroupsCreated': totalGroupsCreated,
      'updated_at': updatedAt?.toIso8601String(),
    }..removeWhere((key, value) => value == null);
  }

  factory PackageSubscriptionModel.fromMap(Map<String, dynamic> map) {
    return PackageSubscriptionModel(
      id: map["id"] as String,
      createdAt: DateTime.parse(map['created_at'] as String),
      userId: map['userId'] as String,
      packageId: map['packageId'] as String,
      subscriptionStartDate: DateTime.parse(
        map['subscriptionStartDate'] as String,
      ),
      subscriptionEndDate: DateTime.parse(map['subscriptionEndDate'] as String),
      isActive: map['isActive'] as bool,
      totalGroupsCreated: map['totalGroupsCreated'] as int,
      updatedAt: map['updated_at'] != null
          ? DateTime.parse(map['updated_at'] as String)
          : null,
    );
  }

  bool? get isExpired => subscriptionEndDate?.isBefore(DateTime.now());
  bool? get isValid =>
      isActive != null && isExpired != null && isActive! && !isExpired!;

  Duration? get remainingDuration =>
      subscriptionEndDate?.difference(DateTime.now());

  int? get daysUntilExpiry => remainingDuration?.inDays;

  // bool? get canCreateMoreGroups {
  //   // Assuming there's a limit - you might want to fetch this from package details
  //   const maxGroupsLimit = 10; // Adjust based on your package tiers
  //   return isValid && totalGroupsCreated < maxGroupsLimit;
  // }

  @override
  List<Object?> get props => [
    createdAt,
    userId,
    packageId,
    subscriptionStartDate,
    subscriptionEndDate,
    isActive,
    totalGroupsCreated,
    updatedAt,
  ];

  @override
  bool get stringify => true;
}
