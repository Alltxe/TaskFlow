import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:taskflow/data/datasources/notification_remote_datasource.dart';
import 'package:taskflow/data/models/notification.dart';
import 'package:taskflow/data/repositories/notification_repository.dart';
import 'package:taskflow/data/repositories/notification_repository_impl.dart';

final notificationRemoteDataSourceProvider =
    Provider<NotificationRemoteDataSource>((_) => NotificationRemoteDataSource());

final notificationRepositoryProvider = Provider<NotificationRepository>((ref) {
  return NotificationRepositoryImpl(
    remoteDataSource: ref.watch(notificationRemoteDataSourceProvider),
  );
});

/// Provider for inbox notifications (unread first)
final myNotificationsProvider = FutureProvider<NotificationList>((ref) async {
  final repo = ref.watch(notificationRepositoryProvider);
  final result = await repo.getMyNotifications(limit: 50);
  return result.fold(
    (failure) => throw failure,
    (list) => list,
  );
});

/// Provider for unread notification count (badge)
final unreadNotificationCountProvider = FutureProvider<int>((ref) async {
  final repo = ref.watch(notificationRepositoryProvider);
  final result = await repo.getMyNotifications(isRead: false, limit: 1);
  return result.fold(
    (failure) => 0,
    (list) => list.total,
  );
});
