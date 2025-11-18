// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'update_group_request.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$UpdateGroupRequestImpl _$$UpdateGroupRequestImplFromJson(
        Map<String, dynamic> json) =>
    _$UpdateGroupRequestImpl(
      name: json['name'] as String?,
      description: json['description'] as String?,
      requiresApproval: json['requiresApproval'] as bool?,
      rotationType: json['rotationType'] as String?,
      gamificationEnabled: json['gamificationEnabled'] as bool?,
    );

Map<String, dynamic> _$$UpdateGroupRequestImplToJson(
        _$UpdateGroupRequestImpl instance) =>
    <String, dynamic>{
      'name': instance.name,
      'description': instance.description,
      'requiresApproval': instance.requiresApproval,
      'rotationType': instance.rotationType,
      'gamificationEnabled': instance.gamificationEnabled,
    };
