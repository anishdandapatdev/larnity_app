import 'package:equatable/equatable.dart';

class ChallengeSubmissionModel extends Equatable {
  final String? id;
  final String challengeDayId;
  final String userId;
  final String? content;
  final String? mediaUrl;
  final DateTime? submittedAt;
  final Map<String, dynamic>? profile;

  const ChallengeSubmissionModel({
    this.id,
    required this.challengeDayId,
    required this.userId,
    this.content,
    this.mediaUrl,
    this.submittedAt,
    this.profile,
  });

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'challengeDayId': challengeDayId,
      'userId': userId,
      'content': content,
      'mediaUrl': mediaUrl,
    }..removeWhere((key, value) => value == null);
  }

  factory ChallengeSubmissionModel.fromMap(Map<String, dynamic> map) {
    return ChallengeSubmissionModel(
      id: map['id'] as String?,
      challengeDayId: map['challengeDayId'] as String,
      userId: map['userId'] as String,
      content: map['content'] as String?,
      mediaUrl: map['mediaUrl'] as String?,
      submittedAt: map['created_at'] != null
          ? DateTime.parse(map['created_at'] as String)
          : null,
      profile: map['profiles'] as Map<String, dynamic>?,
    );
  }

  @override
  List<Object?> get props => [id, challengeDayId, userId, content, mediaUrl, submittedAt];

  @override
  bool get stringify => true;
}
