import 'package:equatable/equatable.dart';

class LikeModel extends Equatable {
  final String? id;
  final String postId;
  final String userId;
  final DateTime? createdAt;

  const LikeModel({
    this.id,
    required this.postId,
    required this.userId,
    this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'postId': postId,
      'userId': userId,
    };
  }

  factory LikeModel.fromMap(Map<String, dynamic> map) {
    return LikeModel(
      id: map['id'] as String?,
      postId: map['postId'] as String,
      userId: map['userId'] as String,
      createdAt: map['created_at'] != null
          ? DateTime.parse(map['created_at'] as String)
          : null,
    );
  }

  @override
  List<Object?> get props => [id, postId, userId, createdAt];

  @override
  bool get stringify => true;
}
