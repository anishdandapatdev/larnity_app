import 'package:equatable/equatable.dart';

class ChannelModel extends Equatable {
  final String? id;
  final String groupId;
  final String? name;
  final String? icon;
  final DateTime? createdAt;

  const ChannelModel({
    this.id,
    required this.groupId,
    this.name,
    this.icon,
    this.createdAt,
  });

  ChannelModel copyWith({
    String? id,
    String? groupId,
    String? name,
    String? icon,
    DateTime? createdAt,
  }) {
    return ChannelModel(
      id: id ?? this.id,
      groupId: groupId ?? this.groupId,
      name: name ?? this.name,
      icon: icon ?? this.icon,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'groupId': groupId,
      'name': name,
      'icon': icon,
    }..removeWhere((key, value) => value == null);
  }

  factory ChannelModel.fromMap(Map<String, dynamic> map) {
    return ChannelModel(
      id: map['id'] as String?,
      groupId: map['groupId'] as String,
      name: map['name'] as String?,
      icon: map['icon'] as String?,
      createdAt: map['created_at'] != null
          ? DateTime.parse(map['created_at'] as String)
          : null,
    );
  }

  @override
  List<Object?> get props => [id, groupId, name, icon, createdAt];

  @override
  bool get stringify => true;
}
