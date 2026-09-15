import 'package:equatable/equatable.dart';

class ChallengeWinnerModel extends Equatable {
  final String? id;
  final String challengeId;
  final String userId;
  final int? rank;
  final String? prize;
  final DateTime? createdAt;
  final Map<String, dynamic>? profile;

  const ChallengeWinnerModel({
    this.id,
    required this.challengeId,
    required this.userId,
    this.rank,
    this.prize,
    this.createdAt,
    this.profile,
  });

  factory ChallengeWinnerModel.fromMap(Map<String, dynamic> map) {
    return ChallengeWinnerModel(
      id: map['id'] as String?,
      challengeId: map['challengeId'] as String,
      userId: map['userId'] as String,
      rank: map['rank'] as int?,
      prize: map['prize'] as String?,
      createdAt: map['created_at'] != null
          ? DateTime.parse(map['created_at'] as String)
          : null,
      profile: map['profiles'] as Map<String, dynamic>?,
    );
  }

  @override
  List<Object?> get props => [id, challengeId, userId, rank, prize, createdAt];

  @override
  bool get stringify => true;
}
