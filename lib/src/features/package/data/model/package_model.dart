
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
    }..removeWhere((key, value) => value == null);
  }

  factory PackageModel.fromMap(Map<String, dynamic> map) {
    return PackageModel(
      id: map['id'] as String,
      createdAt: DateTime.parse(map['created_at'] as String),
      name: map['name'] as String,
      description: map['description'] as String?,
      maxGroups: map['maxGroups'] as int,
      monthlyPrice: map['monthlyPrice'] as int,
      isActive: map['isActive'] as bool,
      displayOrder: map['displayOrder'] as int,
      features: Map<String, dynamic>.from(map['features'] as Map),
      isFreeTrialPack: map['isFreeTrialPack'] as bool,
      freeTrialDays: map['freeTrialDays'] as int?,
    );
  }

  bool get isFree => monthlyPrice == 0;
  bool get hasFreeTrial =>
      isFreeTrialPack && freeTrialDays != null && freeTrialDays! > 0;

  List<String> get featureList {
    final featuresList = features['list'] as List<dynamic>?;
    return featuresList?.cast<String>() ?? [];
  }

  String get formattedPrice {
    if (isFree) return 'Free';
    return '\$${(monthlyPrice / 100).toStringAsFixed(2)}/month';
  }

  String get trialInfo {
    if (!hasFreeTrial) return '';
    return '$freeTrialDays days free trial';
  }
}
