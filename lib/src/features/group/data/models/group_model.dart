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
      id: map['id'] as String,
      createdAt: DateTime.parse(map['created_at'] as String),
      name: map['name'] as String,
      category: map['category'] as String,
      thumbnail: map['thumbnail'] as String?,
      description: map['description'] as String?,
      gallery: map['gallery'] != null
          ? List<String>.from(map['gallery'] as List)
          : null,
      jsonDescription: map['jsonDescription'] as String?,
      htmlDescription: map['htmlDescription'] as String?,
      googleSheetId: map['googleSheetId'] as String?,
      enableGoogleSheetSync: map['enableGoogleSheetSync'] as bool?,
      icon: map['icon'] as String?,
      privacy: GroupPrivacy.values.firstWhere(
        (e) => e.name == map['privacy'],
        orElse: () => GroupPrivacy.PRIVATE,
      ),
      active: map['active'] as bool? ?? true,
      userId: map['userId'] as String,
      domain: map['domain'] as String?,
      monthlyPrice: map['monthlyPrice'] as int?,
      yearlyPrice: map['yearlyPrice'] as int?,
      lifetimePrice: map['lifetimePrice'] as int?,
      isSuspended: map['isSuspended'] as bool? ?? false,
      updatedAt: map['updated_at'] != null
          ? DateTime.parse(map['updated_at'] as String)
          : null,
      packageSubscriptionId: map['packageSubscriptionId'] as String?,
      rejectionReason: map['rejectionReason'] as String?,
      status: GroupStatus.values.firstWhere(
        (e) => e.name == map['status'],
        orElse: () => GroupStatus.CREATED,
      ),
      slug: map['slug'] as String?,
      landingSettings: map['landingSettings'] as Map<String, dynamic>?,
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
  ];

  @override
  bool get stringify => true;
}
