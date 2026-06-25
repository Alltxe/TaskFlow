import 'package:dartz/dartz.dart';
import 'package:taskflow/core/errors/exceptions.dart';
import 'package:taskflow/core/errors/failure.dart';
import 'package:taskflow/data/datasources/audit_log_remote_datasource.dart';
import 'package:taskflow/data/models/audit_log.dart';
import 'package:taskflow/data/repositories/audit_log_repository.dart';

class AuditLogRepositoryImpl implements AuditLogRepository {
  final AuditLogRemoteDataSource remoteDataSource;

  AuditLogRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, AuditLogList>> getAuditLogs({GetAuditLogsInput? input}) async {
    try {
      final result = await remoteDataSource.getAuditLogs(input: input);
      return Right(result);
    } on NetworkException catch (e) {
      return Left(Failure.network(message: e.message, code: e.code));
    } on ServerException catch (e) {
      return Left(Failure.server(message: e.message, code: e.code));
    } on AuthException catch (e) {
      return Left(Failure.auth(message: e.message, code: e.code));
    } catch (e) {
      return Left(Failure.unknown(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<AuditLog>>> getTaskAuditLog(String taskId) async {
    try {
      final logs = await remoteDataSource.getTaskAuditLog(taskId);
      return Right(logs);
    } on NetworkException catch (e) {
      return Left(Failure.network(message: e.message, code: e.code));
    } on ServerException catch (e) {
      return Left(Failure.server(message: e.message, code: e.code));
    } on AuthException catch (e) {
      return Left(Failure.auth(message: e.message, code: e.code));
    } catch (e) {
      return Left(Failure.unknown(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<AuditLog>>> getGroupAuditLog(String groupId) async {
    try {
      final logs = await remoteDataSource.getGroupAuditLog(groupId);
      return Right(logs);
    } on NetworkException catch (e) {
      return Left(Failure.network(message: e.message, code: e.code));
    } on ServerException catch (e) {
      return Left(Failure.server(message: e.message, code: e.code));
    } on AuthException catch (e) {
      return Left(Failure.auth(message: e.message, code: e.code));
    } catch (e) {
      return Left(Failure.unknown(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<AuditLog>>> getMyAuditLogs({int limit = 100}) async {
    try {
      final logs = await remoteDataSource.getMyAuditLogs(limit: limit);
      return Right(logs);
    } on NetworkException catch (e) {
      return Left(Failure.network(message: e.message, code: e.code));
    } on ServerException catch (e) {
      return Left(Failure.server(message: e.message, code: e.code));
    } on AuthException catch (e) {
      return Left(Failure.auth(message: e.message, code: e.code));
    } catch (e) {
      return Left(Failure.unknown(message: e.toString()));
    }
  }
}
