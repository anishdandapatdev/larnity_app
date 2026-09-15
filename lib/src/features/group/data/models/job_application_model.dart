import 'package:equatable/equatable.dart';

class JobApplicationModel extends Equatable {
  final String? id;
  final String jobId;
  final String userId;
  final String? resumeUrl;
  final String? coverLetter;
  final String? status; // 'PENDING', 'ACCEPTED', 'REJECTED'
  final DateTime? createdAt;
  final Map<String, dynamic>? profile;

  const JobApplicationModel({
    this.id,
    required this.jobId,
    required this.userId,
    this.resumeUrl,
    this.coverLetter,
    this.status,
    this.createdAt,
    this.profile,
  });

  JobApplicationModel copyWith({
    String? id,
    String? jobId,
    String? userId,
    String? resumeUrl,
    String? coverLetter,
    String? status,
    DateTime? createdAt,
    Map<String, dynamic>? profile,
  }) {
    return JobApplicationModel(
      id: id ?? this.id,
      jobId: jobId ?? this.jobId,
      userId: userId ?? this.userId,
      resumeUrl: resumeUrl ?? this.resumeUrl,
      coverLetter: coverLetter ?? this.coverLetter,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      profile: profile ?? this.profile,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'jobId': jobId,
      'userId': userId,
      'resumeUrl': resumeUrl,
      'coverLetter': coverLetter,
      'status': status,
    }..removeWhere((key, value) => value == null);
  }

  factory JobApplicationModel.fromMap(Map<String, dynamic> map) {
    return JobApplicationModel(
      id: map['id'] as String?,
      jobId: map['jobId'] as String,
      userId: map['userId'] as String,
      resumeUrl: map['resumeUrl'] as String?,
      coverLetter: map['coverLetter'] as String?,
      status: map['status'] as String? ?? 'PENDING',
      createdAt: map['created_at'] != null
          ? DateTime.parse(map['created_at'] as String)
          : null,
      profile: map['profiles'] as Map<String, dynamic>?,
    );
  }

  String get applicantName {
    if (profile == null) return 'Unknown';
    final first = profile!['firstname'] as String? ?? '';
    final last = profile!['lastname'] as String? ?? '';
    return '$first $last'.trim();
  }

  @override
  List<Object?> get props => [id, jobId, userId, resumeUrl, status, createdAt];

  @override
  bool get stringify => true;
}
