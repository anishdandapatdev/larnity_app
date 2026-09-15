import 'package:equatable/equatable.dart';

class EventModel extends Equatable {
  final String? id;
  final String groupId;
  final String? title;
  final String? description;
  final String? image;
  final DateTime? startAt;
  final DateTime? endAt;
  final String? location;
  final String? meetingUrl;
  final bool? isOnline;
  final int? maxParticipants;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const EventModel({
    this.id,
    required this.groupId,
    this.title,
    this.description,
    this.image,
    this.startAt,
    this.endAt,
    this.location,
    this.meetingUrl,
    this.isOnline,
    this.maxParticipants,
    this.createdAt,
    this.updatedAt,
  });

  EventModel copyWith({
    String? id,
    String? groupId,
    String? title,
    String? description,
    String? image,
    DateTime? startAt,
    DateTime? endAt,
    String? location,
    String? meetingUrl,
    bool? isOnline,
    int? maxParticipants,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return EventModel(
      id: id ?? this.id,
      groupId: groupId ?? this.groupId,
      title: title ?? this.title,
      description: description ?? this.description,
      image: image ?? this.image,
      startAt: startAt ?? this.startAt,
      endAt: endAt ?? this.endAt,
      location: location ?? this.location,
      meetingUrl: meetingUrl ?? this.meetingUrl,
      isOnline: isOnline ?? this.isOnline,
      maxParticipants: maxParticipants ?? this.maxParticipants,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'groupId': groupId,
      'title': title,
      'description': description ?? '',
      'date': startAt?.toIso8601String().split('T').first,
      'time': startAt?.toIso8601String().split('T').last.split('.').first,
      'location': location ?? 'Online', // Satisfy NOT-NULL db constraint
      'coverImg': image ?? '', // Satisfy NOT-NULL db constraint
      'link': meetingUrl ?? '',
    }..removeWhere((key, value) => value == null);
  }

  factory EventModel.fromMap(Map<String, dynamic> map) {
    DateTime? parsedStartAt;
    if (map['date'] != null && map['time'] != null) {
      try {
        parsedStartAt = DateTime.parse('${map['date']}T${map['time']}');
      } catch (_) {}
    }
    return EventModel(
      id: map['id'] as String?,
      groupId: map['groupId'] as String,
      title: map['title'] as String?,
      description: map['description'] as String?,
      image: map['coverImg'] as String?,
      startAt: parsedStartAt,
      endAt: parsedStartAt?.add(const Duration(hours: 1)),
      location: map['location'] as String?,
      meetingUrl: map['link'] as String?,
      isOnline: map['link'] != null && (map['link'] as String).isNotEmpty,
      maxParticipants: null,
      createdAt: map['created_at'] != null
          ? DateTime.parse(map['created_at'] as String)
          : null,
      updatedAt: map['updated_at'] != null
          ? DateTime.parse(map['updated_at'] as String)
          : null,
    );
  }

  bool get isUpcoming => endAt != null && endAt!.isAfter(DateTime.now());
  bool get isPast => endAt != null && endAt!.isBefore(DateTime.now());
  bool get isHappeningNow =>
      startAt != null &&
      endAt != null &&
      DateTime.now().isAfter(startAt!) &&
      DateTime.now().isBefore(endAt!);

  @override
  List<Object?> get props => [
        id, groupId, title, description, image, startAt, endAt,
        location, meetingUrl, isOnline, maxParticipants, createdAt,
      ];

  @override
  bool get stringify => true;
}
