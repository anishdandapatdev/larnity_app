import 'package:equatable/equatable.dart';

class ChallengeDayModel extends Equatable {
  final String? id;
  final String challengeId;
  final int? dayNumber;
  final String? title;
  final String? description;
  final String? task;
  final DateTime? createdAt;

  const ChallengeDayModel({
    this.id,
    required this.challengeId,
    this.dayNumber,
    this.title,
    this.description,
    this.task,
    this.createdAt,
  });

  ChallengeDayModel copyWith({
    String? id,
    String? challengeId,
    int? dayNumber,
    String? title,
    String? description,
    String? task,
    DateTime? createdAt,
  }) {
    return ChallengeDayModel(
      id: id ?? this.id,
      challengeId: challengeId ?? this.challengeId,
      dayNumber: dayNumber ?? this.dayNumber,
      title: title ?? this.title,
      description: description ?? this.description,
      task: task ?? this.task,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'challengeId': challengeId,
      'dayNumber': dayNumber,
      'title': title,
      'description': description,
      'task': task,
    }..removeWhere((key, value) => value == null);
  }

  factory ChallengeDayModel.fromMap(Map<String, dynamic> map) {
    return ChallengeDayModel(
      id: map['id'] as String?,
      challengeId: map['challengeId'] as String,
      dayNumber: map['dayNumber'] as int?,
      title: map['title'] as String?,
      description: map['description'] as String?,
      task: map['task'] as String?,
      createdAt: map['created_at'] != null
          ? DateTime.parse(map['created_at'] as String)
          : null,
    );
  }

  @override
  List<Object?> get props => [id, challengeId, dayNumber, title, description, task, createdAt];

  @override
  bool get stringify => true;
}
