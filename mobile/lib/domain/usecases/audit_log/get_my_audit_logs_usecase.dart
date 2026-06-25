import 'package:dartz/dartz.dart';
import 'package:taskflow/core/errors/failure.dart';
import 'package:taskflow/data/models/audit_log.dart';
import 'package:taskflow/data/repositories/audit_log_repository.dart';

class GetMyAuditLogsUseCase {
  final AuditLogRepository repository;

  GetMyAuditLogsUseCase(this.repository);

  Future<Either<Failure, List<AuditLog>>> call({int limit = 100}) {
    return repository.getMyAuditLogs(limit: limit);
  }
}
