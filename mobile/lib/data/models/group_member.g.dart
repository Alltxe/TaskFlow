// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'group_member.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$GroupMemberUserImpl _$$GroupMemberUserImplFromJson(
        Map<String, dynamic> json) =>
    _$GroupMemberUserImpl(
      id: json['id'] as String,
      username: json['username'] as String,
      avatarUrl: json['avatarUrl'] as String?,
      isAway: json['isAway'] as bool? ?? false,
      awayUntil: json['awayUntil'] == null
          ? null
          : DateTime.parse(json['awayUntil'] as String),
    );

Map<String, dynamic> _$$GroupMemberUserImplToJson(
        _$GroupMemberUserImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'username': instance.username,
      'avatarUrl': instance.avatarUrl,
      'isAway': instance.isAway,
      'awayUntil': instance.awayUntil?.toIso8601String(),
    };

_$GroupMemberImpl _$$GroupMemberImplFromJson(Map<String, dynamic> json) =>
    _$GroupMemberImpl(
      id: json['id'] as String,
      userId: json['userId'] as String,
      groupId: json['groupId'] as String,
      role: json['role'] as String,
      joinedAt: DateTime.parse(json['joinedAt'] as String),
      roleChangedAt: DateTime.parse(json['roleChangedAt'] as String),
      user: GroupMemberUser.fromJson(json['user'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$$GroupMemberImplToJson(_$GroupMemberImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'userId': instance.userId,
      'groupId': instance.groupId,
      'role': instance.role,
      'joinedAt': instance.joinedAt.toIso8601String(),
      'roleChangedAt': instance.roleChangedAt.toIso8601String(),
      'user': instance.user,
    };
