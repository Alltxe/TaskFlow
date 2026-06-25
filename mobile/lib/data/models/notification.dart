import 'package:freezed_annotation/freezed_annotation.dart';

part 'notification.freezed.dart';
part 'notification.g.dart';

enum AppNotificationType {
  taskAssigned,
  taskCompleted,
  taskApproved,
  taskRejected,
  rewardRequested,
  rewardApproved,
  rewardRejected,
  pointAwarded,
  invitation,
  system;

  static AppNotificationType fromString(String value) {
    switch (value) {
      case 'TASK_ASSIGNED':
        return taskAssigned;
      case 'TASK_COMPLETED':
        return taskCompleted;
      case 'TASK_APPROVED':
        return taskApproved;
      case 'TASK_REJECTED':
        return taskRejected;
      case 'REWARD_REQUESTED':
        return rewardRequested;
      case 'REWARD_APPROVED':
        return rewardApproved;
      case 'REWARD_REJECTED':
        return rewardRejected;
      case 'POINT_AWARDED':
        return pointAwarded;
      case 'INVITATION':
        return invitation;
      default:
        return system;
    }
  }

  String get value {
    switch (this) {
      case taskAssigned:
        return 'TASK_ASSIGNED';
      case taskCompleted:
        return 'TASK_COMPLETED';
      case taskApproved:
        return 'TASK_APPROVED';
      case taskRejected:
        return 'TASK_REJECTED';
      case rewardRequested:
        return 'REWARD_REQUESTED';
      case rewardApproved:
        return 'REWARD_APPROVED';
      case rewardRejected:
        return 'REWARD_REJECTED';
      case pointAwarded:
        return 'POINT_AWARDED';
      case invitation:
        return 'INVITATION';
      case system:
        return 'SYSTEM';
    }
  }
}

@freezed
class AppNotification with _$AppNotification {
  const factory AppNotification({
    required String id,
    required String title,
    required String message,
    required AppNotificationType type,
    required bool isRead,
    String? relatedEntityType,
    String? relatedEntityId,
    required DateTime createdAt,
  }) = _AppNotification;

  factory AppNotification.fromJson(Map<String, dynamic> json) =>
      _$AppNotificationFromJson(json);
}

@freezed
class NotificationList with _$NotificationList {
  const factory NotificationList({
    required List<AppNotification> items,
    required int total,
  }) = _NotificationList;

  factory NotificationList.fromJson(Map<String, dynamic> json) =>
      _$NotificationListFromJson(json);
}
