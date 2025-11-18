// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'update_profile_request.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$UpdateProfileRequestImpl _$$UpdateProfileRequestImplFromJson(
        Map<String, dynamic> json) =>
    _$UpdateProfileRequestImpl(
      username: json['username'] as String?,
      avatarUrl: json['avatarUrl'] as String?,
      isAway: json['isAway'] as bool?,
      awayUntil: json['awayUntil'] == null
          ? null
          : DateTime.parse(json['awayUntil'] as String),
    );

Map<String, dynamic> _$$UpdateProfileRequestImplToJson(
        _$UpdateProfileRequestImpl instance) =>
    <String, dynamic>{
      'username': instance.username,
      'avatarUrl': instance.avatarUrl,
      'isAway': instance.isAway,
      'awayUntil': instance.awayUntil?.toIso8601String(),
    };
