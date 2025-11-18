// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'task.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$TaskImpl _$$TaskImplFromJson(Map<String, dynamic> json) => _$TaskImpl(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String?,
      deadline: DateTime.parse(json['deadline'] as String),
      priority: json['priority'] as String,
      status: json['status'] as String,
      points: (json['points'] as num).toInt(),
      requiresApproval: json['requiresApproval'] as bool,
      isRecurring: json['isRecurring'] as bool,
      recurrenceRule: json['recurrenceRule'] as String?,
      rotationType: json['rotationType'] as String?,
      weight: (json['weight'] as num).toInt(),
      wasClaimedFromPool: json['wasClaimedFromPool'] as bool,
      rejectionReason: json['rejectionReason'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      completedAt: json['completedAt'] == null
          ? null
          : DateTime.parse(json['completedAt'] as String),
      groupId: json['groupId'] as String,
      createdById: json['createdById'] as String,
      assigneeId: json['assigneeId'] as String?,
      assignee: json['assignee'] == null
          ? null
          : GroupMemberUser.fromJson(json['assignee'] as Map<String, dynamic>),
      createdBy: json['createdBy'] == null
          ? null
          : GroupMemberUser.fromJson(json['createdBy'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$$TaskImplToJson(_$TaskImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'description': instance.description,
      'deadline': instance.deadline.toIso8601String(),
      'priority': instance.priority,
      'status': instance.status,
      'points': instance.points,
      'requiresApproval': instance.requiresApproval,
      'isRecurring': instance.isRecurring,
      'recurrenceRule': instance.recurrenceRule,
      'rotationType': instance.rotationType,
      'weight': instance.weight,
      'wasClaimedFromPool': instance.wasClaimedFromPool,
      'rejectionReason': instance.rejectionReason,
      'createdAt': instance.createdAt.toIso8601String(),
      'completedAt': instance.completedAt?.toIso8601String(),
      'groupId': instance.groupId,
      'createdById': instance.createdById,
      'assigneeId': instance.assigneeId,
      'assignee': instance.assignee,
      'createdBy': instance.createdBy,
    };
