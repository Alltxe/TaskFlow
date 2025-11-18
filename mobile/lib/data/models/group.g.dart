// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'group.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$GroupImpl _$$GroupImplFromJson(Map<String, dynamic> json) => _$GroupImpl(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String?,
      inviteToken: json['inviteToken'] as String,
      requiresApproval: json['requiresApproval'] as bool,
      rotationType: json['rotationType'] as String,
      gamificationEnabled: json['gamificationEnabled'] as bool,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      createdById: json['createdById'] as String,
    );

Map<String, dynamic> _$$GroupImplToJson(_$GroupImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'description': instance.description,
      'inviteToken': instance.inviteToken,
      'requiresApproval': instance.requiresApproval,
      'rotationType': instance.rotationType,
      'gamificationEnabled': instance.gamificationEnabled,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
      'createdById': instance.createdById,
    };
