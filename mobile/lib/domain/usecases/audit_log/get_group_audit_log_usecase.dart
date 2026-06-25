import 'package:dartz/dartz.dart';
import 'package:taskflow/core/errors/failure.dart';
import 'package:taskflow/data/models/audit_log.dart';
import 'package:taskflow/data/repositories/audit_log_repository.dart';

class GetGroupAuditLogUseCase {
  final AuditLogRepository repository;

  GetGroupAuditLogUseCase(this.repository);

  Future<Either<Failure, List<AuditLog>>> call(String groupId) {
    return repository.getGroupAuditLog(groupId);
  }
}
