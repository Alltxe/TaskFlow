// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'notification.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$AppNotificationImpl _$$AppNotificationImplFromJson(
        Map<String, dynamic> json) =>
    _$AppNotificationImpl(
      id: json['id'] as String,
      title: json['title'] as String,
      message: json['message'] as String,
      type: $enumDecode(_$AppNotificationTypeEnumMap, json['type']),
      isRead: json['isRead'] as bool,
      relatedEntityType: json['relatedEntityType'] as String?,
      relatedEntityId: json['relatedEntityId'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );

Map<String, dynamic> _$$AppNotificationImplToJson(
        _$AppNotificationImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'message': instance.message,
      'type': _$AppNotificationTypeEnumMap[instance.type]!,
      'isRead': instance.isRead,
      'relatedEntityType': instance.relatedEntityType,
      'relatedEntityId': instance.relatedEntityId,
      'createdAt': instance.createdAt.toIso8601String(),
    };

const _$AppNotificationTypeEnumMap = {
  AppNotificationType.taskAssigned: 'taskAssigned',
  AppNotificationType.taskCompleted: 'taskCompleted',
  AppNotificationType.taskApproved: 'taskApproved',
  AppNotificationType.taskRejected: 'taskRejected',
  AppNotificationType.rewardRequested: 'rewardRequested',
  AppNotificationType.rewardApproved: 'rewardApproved',
  AppNotificationType.rewardRejected: 'rewardRejected',
  AppNotificationType.pointAwarded: 'pointAwarded',
  AppNotificationType.invitation: 'invitation',
  AppNotificationType.system: 'system',
};

_$NotificationListImpl _$$NotificationListImplFromJson(
        Map<String, dynamic> json) =>
    _$NotificationListImpl(
      items: (json['items'] as List<dynamic>)
          .map((e) => AppNotification.fromJson(e as Map<String, dynamic>))
          .toList(),
      total: (json['total'] as num).toInt(),
    );

Map<String, dynamic> _$$NotificationListImplToJson(
        _$NotificationListImpl instance) =>
    <String, dynamic>{
      'items': instance.items,
      'total': instance.total,
    };
