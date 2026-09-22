// ignore_for_file: constant_identifier_names

import 'package:equatable/equatable.dart';

enum GroupPrivacy { PUBLIC, PRIVATE }

enum GroupStatus { CREATED, APPROVED, REJECTED }

class GroupModel extends Equatable {
  final String? id;
  final DateTime? createdAt;
  final String name;
  final String? category;
  final String? thumbnail;
  final String? description;
  final List<String>? gallery;
  final String? jsonDescription;
  final String? htmlDescription;
  final String? googleSheetId;
  final bool? enableGoogleSheetSync;
  final String? icon;
  final GroupPrivacy? privacy;
  final bool? active;
  final String? userId;
  final String? domain;
  final int? monthlyPrice;
  final int? yearlyPrice;
  final int? lifetimePrice;
  final bool? isSuspended;
  final DateTime? updatedAt;
  final String? packageSubscriptionId;
  final String? rejectionReason;
  final GroupStatus? status;
  final String? slug;
  final Map<String, dynamic>? landingSettings;
  final int? memberCount;

  const GroupModel({
    this.id,
    this.createdAt,
    required this.name,
    this.category,
    this.thumbnail,
    this.description,
    this.gallery,
    this.jsonDescription,
    this.htmlDescription,
    this.googleSheetId,
    this.enableGoogleSheetSync,
    this.icon,
    this.privacy,
    this.active,
    this.userId,
    this.domain,
    this.monthlyPrice,
    this.yearlyPrice,
    this.lifetimePrice,
    this.isSuspended,
    this.updatedAt,
    this.packageSubscriptionId,
    this.rejectionReason,
    this.status,
    this.slug,
    this.landingSettings,
    this.memberCount,
  });

  GroupModel copyWith({
    String? id,
    DateTime? createdAt,
    String? name,
    String? category,
    String? thumbnail,
    String? description,
    List<String>? gallery,
    String? jsonDescription,
    String? htmlDescription,
    String? googleSheetId,
    bool? enableGoogleSheetSync,
    String? icon,
    GroupPrivacy? privacy,
    bool? active,
    String? userId,
    String? domain,
    int? monthlyPrice,
    int? yearlyPrice,
    int? lifetimePrice,
    bool? isSuspended,
    DateTime? updatedAt,
    String? packageSubscriptionId,
    String? rejectionReason,
    GroupStatus? status,
    String? slug,
    Map<String, dynamic>? landingSettings,
    int? memberCount,
  }) {
    return GroupModel(
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      name: name ?? this.name,
      category: category ?? this.category,
      thumbnail: thumbnail ?? this.thumbnail,
      description: description ?? this.description,
      gallery: gallery ?? this.gallery,
      jsonDescription: jsonDescription ?? this.jsonDescription,
      htmlDescription: htmlDescription ?? this.htmlDescription,
      googleSheetId: googleSheetId ?? this.googleSheetId,
      enableGoogleSheetSync:
          enableGoogleSheetSync ?? this.enableGoogleSheetSync,
      icon: icon ?? this.icon,
      privacy: privacy ?? this.privacy,
      active: active ?? this.active,
      userId: userId ?? this.userId,
      domain: domain ?? this.domain,
      monthlyPrice: monthlyPrice ?? this.monthlyPrice,
      yearlyPrice: yearlyPrice ?? this.yearlyPrice,
      lifetimePrice: lifetimePrice ?? this.lifetimePrice,
      isSuspended: isSuspended ?? this.isSuspended,
      updatedAt: updatedAt ?? this.updatedAt,
      packageSubscriptionId:
          packageSubscriptionId ?? this.packageSubscriptionId,
      rejectionReason: rejectionReason ?? this.rejectionReason,
      status: status ?? this.status,
      slug: slug ?? this.slug,
      landingSettings: landingSettings ?? this.landingSettings,
      memberCount: memberCount ?? this.memberCount,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      // 'created_at': createdAt?.toIso8601String(),
      'name': name,
      'category': category,
      'thumbnail': thumbnail,
      'description': description,
      'gallery': gallery,
      'jsonDescription': jsonDescription,
      'htmlDescription': htmlDescription,
      'googleSheetId': googleSheetId,
      'enableGoogleSheetSync': enableGoogleSheetSync,
      'icon': icon,
      // 'privacy': privacy?.name,
      'active': active,
      'userId': userId,
      'domain': domain,
      'monthlyPrice': monthlyPrice,
      'yearlyPrice': yearlyPrice,
      'lifetimePrice': lifetimePrice,
      'isSuspended': isSuspended,
      // 'updated_at': updatedAt?.toIso8601String(),
      'packageSubscriptionId': packageSubscriptionId,
      'rejectionReason': rejectionReason,
      // 'status': status?.name,
      'slug': slug,
      'landingSettings': landingSettings,
    }..removeWhere((key, value) => value == null);
  }

  factory GroupModel.fromMap(Map<String, dynamic> map) {
    return GroupModel(
      id: map['id']?.toString(),
      createdAt: map['created_at'] != null
          ? DateTime.tryParse(map['created_at'].toString())
          : null,
      name: map['name']?.toString() ?? '',
      category: map['category']?.toString(),
      thumbnail: map['thumbnail']?.toString(),
      description: map['description']?.toString(),
      gallery: map['gallery'] != null && map['gallery'] is List
          ? (map['gallery'] as List).map((e) => e.toString()).toList()
          : null,
      jsonDescription: map['jsonDescription']?.toString(),
      htmlDescription: map['htmlDescription']?.toString(),
      googleSheetId: map['googleSheetId']?.toString(),
      enableGoogleSheetSync: map['enableGoogleSheetSync'] as bool?,
      icon: map['icon']?.toString(),
      privacy: GroupPrivacy.values.firstWhere(
        (e) => e.name.toUpperCase() == map['privacy']?.toString().toUpperCase(),
        orElse: () => GroupPrivacy.PUBLIC,
      ),
      active: map['active'] as bool? ?? true,
      userId: map['userId']?.toString(),
      domain: map['domain']?.toString(),
      monthlyPrice: (map['monthlyPrice'] as num?)?.toInt(),
      yearlyPrice: (map['yearlyPrice'] as num?)?.toInt(),
      lifetimePrice: (map['lifetimePrice'] as num?)?.toInt(),
      isSuspended: map['isSuspended'] as bool? ?? false,
      updatedAt: map['updated_at'] != null
          ? DateTime.tryParse(map['updated_at'].toString())
          : null,
      packageSubscriptionId: map['packageSubscriptionId']?.toString(),
      rejectionReason: map['rejectionReason']?.toString(),
      status: GroupStatus.values.firstWhere(
        (e) => e.name.toUpperCase() == map['status']?.toString().toUpperCase(),
        orElse: () => GroupStatus.CREATED,
      ),
      slug: map['slug']?.toString(),
      landingSettings: map['landingSettings'] is Map<String, dynamic>
          ? map['landingSettings'] as Map<String, dynamic>
          : null,
      memberCount: (map['memberCount'] as num?)?.toInt() ??
          (map['member_count'] as num?)?.toInt() ??
          (map['membersCount'] as num?)?.toInt() ??
          (map['members_count'] as num?)?.toInt() ??
          (map['totalMembers'] as num?)?.toInt() ??
          (map['total_members'] as num?)?.toInt() ??
          (map['Members'] is List &&
                  (map['Members'] as List).isNotEmpty &&
                  (map['Members'] as List).first is Map &&
                  (map['Members'] as List).first.containsKey('count')
              ? ((map['Members'] as List).first['count'] as num?)?.toInt()
              : null) ??
          (map['members'] is List
              ? ((map['members'] as List).isNotEmpty &&
                      (map['members'] as List).first is Map &&
                      (map['members'] as List).first.containsKey('count')
                  ? ((map['members'] as List).first['count'] as num?)?.toInt()
                  : (map['members'] as List).length)
              : (map['members'] as num?)?.toInt()),
    );
  }

  bool get isPublic => privacy == GroupPrivacy.PUBLIC;
  bool get isPrivate => privacy == GroupPrivacy.PRIVATE;
  bool get isApproved => status == GroupStatus.APPROVED;
  bool get isRejected => status == GroupStatus.REJECTED;
  bool get isPending => status == GroupStatus.CREATED;

  @override
  List<Object?> get props => [
    id,
    createdAt,
    name,
    category,
    thumbnail,
    description,
    gallery,
    jsonDescription,
    htmlDescription,
    googleSheetId,
    enableGoogleSheetSync,
    icon,
    privacy,
    active,
    userId,
    domain,
    monthlyPrice,
    yearlyPrice,
    lifetimePrice,
    isSuspended,
    updatedAt,
    packageSubscriptionId,
    rejectionReason,
    status,
    slug,
    landingSettings,
    memberCount,
  ];

  @override
  bool get stringify => true;
}
