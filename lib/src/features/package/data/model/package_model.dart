class PackageModel {
  final String id;
  final DateTime createdAt;
  final String name;
  final String? description;
  final int maxGroups;
  final int monthlyPrice;
  final bool isActive;
  final int displayOrder;
  final Map<String, dynamic> features;
  final bool isFreeTrialPack;
  final int? freeTrialDays;
  final int? fakePrice;

  const PackageModel({
    required this.id,
    required this.createdAt,
    required this.name,
    this.description,
    required this.maxGroups,
    required this.monthlyPrice,
    required this.isActive,
    required this.displayOrder,
    required this.features,
    required this.isFreeTrialPack,
    this.freeTrialDays,
    this.fakePrice,
  });

  PackageModel copyWith({
    String? id,
    DateTime? createdAt,
    String? name,
    String? description,
    int? maxGroups,
    int? monthlyPrice,
    bool? isActive,
    int? displayOrder,
    Map<String, dynamic>? features,
    bool? isFreeTrialPack,
    int? freeTrialDays,
    int? fakePrice,
  }) {
    return PackageModel(
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      name: name ?? this.name,
      description: description ?? this.description,
      maxGroups: maxGroups ?? this.maxGroups,
      monthlyPrice: monthlyPrice ?? this.monthlyPrice,
      isActive: isActive ?? this.isActive,
      displayOrder: displayOrder ?? this.displayOrder,
      features: features ?? this.features,
      isFreeTrialPack: isFreeTrialPack ?? this.isFreeTrialPack,
      freeTrialDays: freeTrialDays ?? this.freeTrialDays,
      fakePrice: fakePrice ?? this.fakePrice,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'created_at': createdAt.toIso8601String(),
      'name': name,
      'description': description,
      'maxGroups': maxGroups,
      'monthlyPrice': monthlyPrice,
      'isActive': isActive,
      'displayOrder': displayOrder,
      'features': features,
      'isFreeTrialPack': isFreeTrialPack,
      'freeTrialDays': freeTrialDays,
      'fakePrice': fakePrice,
    }..removeWhere((key, value) => value == null);
  }

  factory PackageModel.fromMap(Map<String, dynamic> map) {
    return PackageModel(
      id: map['id']?.toString() ?? '',
      createdAt: map['created_at'] != null
          ? DateTime.tryParse(map['created_at'].toString()) ?? DateTime.now()
          : DateTime.now(),
      name: map['name']?.toString() ?? 'Standard Plan',
      description: map['description'] as String?,
      maxGroups: (map['maxGroups'] as num?)?.toInt() ?? 1,
      monthlyPrice: (map['monthlyPrice'] as num?)?.toInt() ?? 0,
      isActive: map['isActive'] as bool? ?? true,
      displayOrder: (map['displayOrder'] as num?)?.toInt() ?? 0,
      features: map['features'] != null && map['features'] is Map
          ? Map<String, dynamic>.from(map['features'] as Map)
          : <String, dynamic>{},
      isFreeTrialPack: map['isFreeTrialPack'] as bool? ?? false,
      freeTrialDays: (map['freeTrialDays'] as num?)?.toInt(),
      fakePrice: (map['fakePrice'] as num?)?.toInt(),
    );
  }

  bool get isFree => monthlyPrice == 0;
  bool get hasFreeTrial =>
      isFreeTrialPack && freeTrialDays != null && freeTrialDays! > 0;

  List<String> get featureList {
    final list = features['list'];
    if (list is List && list.isNotEmpty) {
      return list.map((e) => e.toString()).toList();
    }
    return [
      'Create up to $maxGroups ${maxGroups == 1 ? 'community' : 'communities'}',
      'Unlimited public & private channels',
      'Send & receive rich messages and media',
      'Community challenges and leaderboard',
      if (maxGroups > 5) 'Dedicated manager and moderation roles',
      if (monthlyPrice > 0) 'Priority support & analytics',
    ];
  }

  int get discountPercentage {
    if (fakePrice != null && fakePrice! > monthlyPrice && fakePrice! > 0) {
      return (((fakePrice! - monthlyPrice) / fakePrice!) * 100).round();
    }
    return 0;
  }

  bool get hasDiscount => discountPercentage > 0;

  String get formattedPrice {
    if (isFree) return 'Free';
    return '₹$monthlyPrice/month';
  }

  String get formattedFakePrice {
    if (fakePrice == null) return '';
    return '₹$fakePrice';
  }

  String get trialInfo {
    if (!hasFreeTrial) return '';
    return '$freeTrialDays days free trial';
  }
}
