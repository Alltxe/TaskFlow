// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'create_group_request.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$CreateGroupRequestImpl _$$CreateGroupRequestImplFromJson(
        Map<String, dynamic> json) =>
    _$CreateGroupRequestImpl(
      name: json['name'] as String,
      description: json['description'] as String?,
      requiresApproval: json['requiresApproval'] as bool? ?? true,
      rotationType: json['rotationType'] as String? ?? 'ROUND_ROBIN',
      gamificationEnabled: json['gamificationEnabled'] as bool? ?? true,
    );

Map<String, dynamic> _$$CreateGroupRequestImplToJson(
        _$CreateGroupRequestImpl instance) =>
    <String, dynamic>{
      'name': instance.name,
      'description': instance.description,
      'requiresApproval': instance.requiresApproval,
      'rotationType': instance.rotationType,
      'gamificationEnabled': instance.gamificationEnabled,
    };
