// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'group_summary.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$GroupSummaryImpl _$$GroupSummaryImplFromJson(Map<String, dynamic> json) =>
    _$GroupSummaryImpl(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String?,
      role: json['role'] as String,
      gamificationEnabled: json['gamificationEnabled'] as bool,
      joinedAt: DateTime.parse(json['joinedAt'] as String),
    );

Map<String, dynamic> _$$GroupSummaryImplToJson(_$GroupSummaryImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'description': instance.description,
      'role': instance.role,
      'gamificationEnabled': instance.gamificationEnabled,
      'joinedAt': instance.joinedAt.toIso8601String(),
    };
