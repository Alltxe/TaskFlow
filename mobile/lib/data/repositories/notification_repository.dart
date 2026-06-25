import 'package:dartz/dartz.dart';
import 'package:taskflow/core/errors/failure.dart';
import 'package:taskflow/data/models/notification.dart';

abstract class NotificationRepository {
  Future<Either<Failure, NotificationList>> getMyNotifications({
    bool? isRead,
    AppNotificationType? type,
    int offset,
    int limit,
  });

  Future<Either<Failure, void>> markNotificationsRead(List<String> ids);

  Future<Either<Failure, void>> markAllNotificationsRead();
}
