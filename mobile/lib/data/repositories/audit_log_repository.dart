import 'package:dartz/dartz.dart';
import 'package:taskflow/core/errors/failure.dart';
import 'package:taskflow/data/models/audit_log.dart';

abstract class AuditLogRepository {
  Future<Either<Failure, AuditLogList>> getAuditLogs({GetAuditLogsInput? input});
  Future<Either<Failure, List<AuditLog>>> getTaskAuditLog(String taskId);
  Future<Either<Failure, List<AuditLog>>> getGroupAuditLog(String groupId);
  Future<Either<Failure, List<AuditLog>>> getMyAuditLogs({int limit = 100});
}
