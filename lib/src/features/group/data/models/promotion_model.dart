import 'package:equatable/equatable.dart';

class PromotionModel extends Equatable {
  final DateTime createdAt;
  final DateTime? updatedAt;
  final String title;
  final DateTime startAt;
  final DateTime endAt;
  final String promoCodeld;
  final String groupld;
  final bool isShowRemainingUses;
  final bool isActive;

  const PromotionModel({
    required this.createdAt,
    this.updatedAt,
    required this.title,
    required this.startAt,
    required this.endAt,
    required this.promoCodeld,
    required this.groupld,
    required this.isShowRemainingUses,
    required this.isActive,
  });

  PromotionModel copyWith({
    DateTime? createdAt,
    DateTime? updatedAt,
    String? title,
    DateTime? startAt,
    DateTime? endAt,
    String? promoCodeld,
    String? groupld,
    bool? isShowRemainingUses,
    bool? isActive,
  }) {
    return PromotionModel(
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      title: title ?? this.title,
      startAt: startAt ?? this.startAt,
      endAt: endAt ?? this.endAt,
      promoCodeld: promoCodeld ?? this.promoCodeld,
      groupld: groupld ?? this.groupld,
      isShowRemainingUses: isShowRemainingUses ?? this.isShowRemainingUses,
      isActive: isActive ?? this.isActive,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
      'title': title,
      'startAt': startAt.toIso8601String(),
      'endAt': endAt.toIso8601String(),
      'promoCodeld': promoCodeld,
      'groupld': groupld,
      'isShowRemainingUses': isShowRemainingUses,
      'isActive': isActive,
    }..removeWhere((key, value) => value == null);
  }

  factory PromotionModel.fromMap(Map<String, dynamic> map) {
    return PromotionModel(
      createdAt: DateTime.parse(map['created_at'] as String),
      updatedAt: map['updated_at'] != null
          ? DateTime.parse(map['updated_at'] as String)
          : null,
      title: map['title'] as String,
      startAt: DateTime.parse(map['startAt'] as String),
      endAt: DateTime.parse(map['endAt'] as String),
      promoCodeld: map['promoCodeld'] as String,
      groupld: map['groupld'] as String,
      isShowRemainingUses: map['isShowRemainingUses'] as bool,
      isActive: map['isActive'] as bool,
    );
  }

  bool get isCurrentlyActive {
    final now = DateTime.now();
    return isActive && now.isAfter(startAt) && now.isBefore(endAt);
  }

  bool get hasExpired => DateTime.now().isAfter(endAt);

  bool get isScheduled => DateTime.now().isBefore(startAt);

  Duration get remainingDuration {
    final now = DateTime.now();
    if (now.isBefore(startAt)) {
      return startAt.difference(now);
    } else if (now.isBefore(endAt)) {
      return endAt.difference(now);
    }
    return Duration.zero;
  }

  String get status {
    if (!isActive) return 'Inactive';
    if (hasExpired) return 'Expired';
    if (isScheduled) return 'Scheduled';
    return 'Active';
  }

  @override
  List<Object?> get props => [
    createdAt,
    updatedAt,
    title,
    startAt,
    endAt,
    promoCodeld,
    groupld,
    isShowRemainingUses,
    isActive,
  ];

  @override
  bool get stringify => true;
}
