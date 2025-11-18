// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'create_task_request.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$CreateTaskRequestImpl _$$CreateTaskRequestImplFromJson(
        Map<String, dynamic> json) =>
    _$CreateTaskRequestImpl(
      groupId: json['groupId'] as String,
      title: json['title'] as String,
      description: json['description'] as String?,
      deadline: DateTime.parse(json['deadline'] as String),
      priority: json['priority'] as String,
      points: (json['points'] as num).toInt(),
      requiresApproval: json['requiresApproval'] as bool?,
      assigneeId: json['assigneeId'] as String?,
      isRecurring: json['isRecurring'] as bool?,
      recurrenceRule: json['recurrenceRule'] as String?,
      rotationType: json['rotationType'] as String?,
      weight: (json['weight'] as num?)?.toInt(),
    );

Map<String, dynamic> _$$CreateTaskRequestImplToJson(
        _$CreateTaskRequestImpl instance) =>
    <String, dynamic>{
      'groupId': instance.groupId,
      'title': instance.title,
      'description': instance.description,
      'deadline': instance.deadline.toIso8601String(),
      'priority': instance.priority,
      'points': instance.points,
      'requiresApproval': instance.requiresApproval,
      'assigneeId': instance.assigneeId,
      'isRecurring': instance.isRecurring,
      'recurrenceRule': instance.recurrenceRule,
      'rotationType': instance.rotationType,
      'weight': instance.weight,
    };
