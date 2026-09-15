import 'package:equatable/equatable.dart';

class SupporterModel extends Equatable {
  final String? id;
  final String groupId;
  final String userId;
  final String? phoneNumber;
  final String? whatsappNumber;
  final String? link;
  final DateTime? createdAt;

  // Relational data to show user info
  final Map<String, dynamic>? profile;

  const SupporterModel({
    this.id,
    required this.groupId,
    required this.userId,
    this.phoneNumber,
    this.whatsappNumber,
    this.link,
    this.createdAt,
    this.profile,
  });

  SupporterModel copyWith({
    String? id,
    String? groupId,
    String? userId,
    String? phoneNumber,
    String? whatsappNumber,
    String? link,
    DateTime? createdAt,
    Map<String, dynamic>? profile,
  }) {
    return SupporterModel(
      id: id ?? this.id,
      groupId: groupId ?? this.groupId,
      userId: userId ?? this.userId,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      whatsappNumber: whatsappNumber ?? this.whatsappNumber,
      link: link ?? this.link,
      createdAt: createdAt ?? this.createdAt,
      profile: profile ?? this.profile,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'groupId': groupId,
      'userId': userId,
      'phoneNumber': phoneNumber,
      'whatsappNumber': whatsappNumber,
      'link': link,
    }..removeWhere((key, value) => value == null);
  }

  factory SupporterModel.fromMap(Map<String, dynamic> map) {
    return SupporterModel(
      id: map['id'] as String?,
      groupId: map['groupId'] as String,
      userId: map['userId'] as String,
      phoneNumber: map['phoneNumber'] as String?,
      whatsappNumber: map['whatsappNumber'] as String?,
      link: map['link'] as String?,
      createdAt: map['created_at'] != null
          ? DateTime.parse(map['created_at'] as String)
          : null,
      profile: map['profiles'] as Map<String, dynamic>?,
    );
  }

  String get supporterName {
    if (profile == null) return 'Unknown';
    final first = profile!['firstname'] as String? ?? '';
    final last = profile!['lastname'] as String? ?? '';
    return '$first $last'.trim();
  }

  String? get supporterImage => profile?['image'] as String?;

  @override
  List<Object?> get props => [
    id,
    groupId,
    userId,
    phoneNumber,
    whatsappNumber,
    link,
    createdAt,
  ];

  @override
  bool get stringify => true;
}
