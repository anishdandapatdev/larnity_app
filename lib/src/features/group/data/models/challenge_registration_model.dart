import 'package:equatable/equatable.dart';

class ChallengeRegistrationModel extends Equatable {
  final String? id;
  final String challengeId;
  final String userId;
  final DateTime? createdAt;
  final Map<String, dynamic>? profile;

  const ChallengeRegistrationModel({
    this.id,
    required this.challengeId,
    required this.userId,
    this.createdAt,
    this.profile,
  });

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'challengeId': challengeId,
      'userId': userId,
    }..removeWhere((key, value) => value == null);
  }

  factory ChallengeRegistrationModel.fromMap(Map<String, dynamic> map) {
    return ChallengeRegistrationModel(
      id: map['id'] as String?,
      challengeId: map['challengeId'] as String,
      userId: map['userId'] as String,
      createdAt: map['created_at'] != null
          ? DateTime.parse(map['created_at'] as String)
          : null,
      profile: map['profiles'] as Map<String, dynamic>?,
    );
  }

  @override
  List<Object?> get props => [id, challengeId, userId, createdAt];

  @override
  bool get stringify => true;
}
