// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'update_task_request.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$UpdateTaskRequestImpl _$$UpdateTaskRequestImplFromJson(
        Map<String, dynamic> json) =>
    _$UpdateTaskRequestImpl(
      title: json['title'] as String?,
      description: json['description'] as String?,
      deadline: json['deadline'] == null
          ? null
          : DateTime.parse(json['deadline'] as String),
      priority: json['priority'] as String?,
      points: (json['points'] as num?)?.toInt(),
      assigneeId: json['assigneeId'] as String?,
      weight: (json['weight'] as num?)?.toInt(),
    );

Map<String, dynamic> _$$UpdateTaskRequestImplToJson(
        _$UpdateTaskRequestImpl instance) =>
    <String, dynamic>{
      'title': instance.title,
      'description': instance.description,
      'deadline': instance.deadline?.toIso8601String(),
      'priority': instance.priority,
      'points': instance.points,
      'assigneeId': instance.assigneeId,
      'weight': instance.weight,
    };
