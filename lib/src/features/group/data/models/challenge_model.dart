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
    int firstPrize = 0;
    int secondPrize = 0;
    int thirdPrize = 0;
    if (prize != null && prize!.isNotEmpty) {
      final reg1 = RegExp(r'1st:\s*(\d+)');
      final reg2 = RegExp(r'2nd:\s*(\d+)');
      final reg3 = RegExp(r'3rd:\s*(\d+)');
      firstPrize = int.tryParse(reg1.firstMatch(prize!)?.group(1) ?? '') ?? 0;
      secondPrize = int.tryParse(reg2.firstMatch(prize!)?.group(1) ?? '') ?? 0;
      thirdPrize = int.tryParse(reg3.firstMatch(prize!)?.group(1) ?? '') ?? 0;
    }

    final isPaidBool = type == 'PAID' || (price != null && price! > 0);
    String statusVal = 'PUBLISHED';
    if (status == 'LIVE' ||
        status == 'FINISHED' ||
        status == 'CANCELLED' ||
        status == 'DRAFT' ||
        status == 'ARCHIVED') {
      statusVal = status!;
    }

    final sDate = startDate ?? DateTime.now();
    final eDate = endDate ?? DateTime.now().add(const Duration(days: 7));

    final map = <String, dynamic>{
      if (id != null) 'id': id,
      'groupId': groupId,
      'title': title ?? '',
      'description': description ?? '',
      'thumbnail': (image != null && image!.isNotEmpty)
          ? image
          : 'https://images.unsplash.com/photo-1523275335684-37898b6baf30',
      'startDate':
          "${sDate.year}-${sDate.month.toString().padLeft(2, '0')}-${sDate.day.toString().padLeft(2, '0')}",
      'endDate':
          "${eDate.year}-${eDate.month.toString().padLeft(2, '0')}-${eDate.day.toString().padLeft(2, '0')}",
      'maxParticipants': maxParticipants ?? 100,
      'firstPlacePrize': firstPrize,
      'secondPlacePrize': secondPrize,
      'thirdPlacePrize': thirdPrize,
      'registrationFee': price?.toInt() ?? 0,
      'isPaid': isPaidBool,
      'status': statusVal,
    };
    return map;
  }

  factory ChallengeModel.fromMap(Map<String, dynamic> map) {
    final first = map['firstPlacePrize'];
    final second = map['secondPlacePrize'];
    final third = map['thirdPlacePrize'];
    final prizeParts = <String>[];
    if (first != null && first != 0) prizeParts.add('1st: $first');
    if (second != null && second != 0) prizeParts.add('2nd: $second');
    if (third != null && third != 0) prizeParts.add('3rd: $third');
    final synthesizedPrize =
        prizeParts.isNotEmpty ? prizeParts.join(', ') : null;

    final isPaid = map['isPaid'] == true;
    final fee = (map['registrationFee'] as num?)?.toDouble() ?? 0.0;
    final dbStatus = map['status'] as String?;

    return ChallengeModel(
      id: map['id'] as String?,
      groupId: (map['groupId'] as String?) ?? '',
      title: map['title'] as String?,
      description: map['description'] as String?,
      image: (map['thumbnail'] ?? map['image']) as String?,
      startDate: map['startDate'] != null
          ? DateTime.tryParse(map['startDate'].toString())
          : null,
      endDate: map['endDate'] != null
          ? DateTime.tryParse(map['endDate'].toString())
          : null,
      maxParticipants: map['maxParticipants'] as int?,
      prize: map['prize'] as String? ?? synthesizedPrize,
      rules: map['rules'] as String?,
      jsonRules: map['jsonRules'] as String?,
      htmlRules: map['htmlRules'] as String?,
      isActive: map['isActive'] as bool? ?? true,
      status: (dbStatus == 'PUBLISHED') ? 'REGISTRATION_OPEN' : dbStatus,
      type: (map['type'] as String?) ?? (isPaid ? 'PAID' : 'FREE'),
      price: (map['price'] as num?)?.toDouble() ?? fee,
      createdAt: map['created_at'] != null
          ? DateTime.tryParse(map['created_at'].toString())
          : null,
      updatedAt: map['updated_at'] != null
          ? DateTime.tryParse(map['updated_at'].toString())
          : null,
      dayCount: _extractCount(map['ChallengeDays']),
      registrationCount: _extractCount(map['ChallengeRegistrations']),
    );
  }

  static int? _extractCount(dynamic val) {
    if (val == null) return null;
    if (val is List) {
      if (val.isEmpty) return 0;
      final first = val.first;
      if (first is Map && first.containsKey('count')) {
        return (first['count'] as num?)?.toInt();
      }
      return val.length;
    }
    if (val is Map && val.containsKey('count')) {
      return (val['count'] as num?)?.toInt();
    }
    if (val is num) return val.toInt();
    return null;
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
