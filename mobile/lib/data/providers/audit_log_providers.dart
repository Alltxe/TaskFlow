import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:taskflow/data/datasources/audit_log_remote_datasource.dart';
import 'package:taskflow/data/models/audit_log.dart';
import 'package:taskflow/data/providers/profile_providers.dart';
import 'package:taskflow/data/repositories/audit_log_repository.dart';
import 'package:taskflow/data/repositories/audit_log_repository_impl.dart';
import 'package:taskflow/domain/usecases/audit_log/get_group_audit_log_usecase.dart';
import 'package:taskflow/domain/usecases/audit_log/get_my_audit_logs_usecase.dart';
import 'package:taskflow/domain/usecases/audit_log/get_task_audit_log_usecase.dart';

final auditLogRemoteDataSourceProvider = Provider<AuditLogRemoteDataSource>((ref) {
  return AuditLogRemoteDataSource();
});

final auditLogRepositoryProvider = Provider<AuditLogRepository>((ref) {
  return AuditLogRepositoryImpl(remoteDataSource: ref.watch(auditLogRemoteDataSourceProvider));
});

final getTaskAuditLogUseCaseProvider = Provider<GetTaskAuditLogUseCase>((ref) {
  return GetTaskAuditLogUseCase(ref.watch(auditLogRepositoryProvider));
});

final getGroupAuditLogUseCaseProvider = Provider<GetGroupAuditLogUseCase>((ref) {
  return GetGroupAuditLogUseCase(ref.watch(auditLogRepositoryProvider));
});

final getMyAuditLogsUseCaseProvider = Provider<GetMyAuditLogsUseCase>((ref) {
  return GetMyAuditLogsUseCase(ref.watch(auditLogRepositoryProvider));
});

final taskAuditLogProvider = FutureProvider.family<List<AuditLog>, String>((ref, taskId) async {
  final useCase = ref.watch(getTaskAuditLogUseCaseProvider);
  final result = await useCase(taskId);
  return result.fold((failure) => throw Exception(failure.message), (logs) => logs);
});

final groupAuditLogProvider = FutureProvider.family<List<AuditLog>, String>((ref, groupId) async {
  final useCase = ref.watch(getGroupAuditLogUseCaseProvider);
  final result = await useCase(groupId);
  return result.fold((failure) => throw Exception(failure.message), (logs) => logs);
});

final myAuditLogsProvider = FutureProvider<List<AuditLog>>((ref) async {
  final useCase = ref.watch(getMyAuditLogsUseCaseProvider);
  final result = await useCase();
  return result.fold((failure) => throw Exception(failure.message), (logs) => logs);
});

final userGroupNamesProvider = FutureProvider<Map<String, String>>((ref) async {
  final result = await ref.watch(getUserGroupsUseCaseProvider).call();
  return result.fold(
    (_) => {},
    (groups) => {for (final group in groups) group.id: group.name},
  );
});
