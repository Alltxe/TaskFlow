import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:taskflow/data/providers/task_providers.dart';
import 'package:taskflow/domain/usecases/task/approve_task_usecase.dart';
import 'package:taskflow/domain/usecases/task/generate_next_recurring_task_usecase.dart';
import 'package:taskflow/domain/usecases/task/claim_task_usecase.dart';
import 'package:taskflow/domain/usecases/task/complete_task_usecase.dart';
import 'package:taskflow/domain/usecases/task/create_task_usecase.dart';
import 'package:taskflow/domain/usecases/task/delete_task_usecase.dart';
import 'package:taskflow/domain/usecases/task/get_group_tasks_usecase.dart';
import 'package:taskflow/domain/usecases/task/get_recurring_templates_usecase.dart';
import 'package:taskflow/domain/usecases/task/get_task_usecase.dart';
import 'package:taskflow/domain/usecases/task/get_user_tasks_usecase.dart';
import 'package:taskflow/domain/usecases/task/update_task_usecase.dart';

// Task Use Cases Providers

final getGroupTasksUseCaseProvider = Provider<GetGroupTasksUseCase>((ref) {
  final repository = ref.watch(taskRepositoryProvider);
  return GetGroupTasksUseCase(repository);
});

final getRecurringTemplatesUseCaseProvider =
    Provider<GetRecurringTemplatesUseCase>((ref) {
      final repository = ref.watch(taskRepositoryProvider);
      return GetRecurringTemplatesUseCase(repository);
    });

final getUserTasksUseCaseProvider = Provider<GetUserTasksUseCase>((ref) {
  final repository = ref.watch(taskRepositoryProvider);
  return GetUserTasksUseCase(repository);
});

final getTaskUseCaseProvider = Provider<GetTaskUseCase>((ref) {
  final repository = ref.watch(taskRepositoryProvider);
  return GetTaskUseCase(repository);
});

final createTaskUseCaseProvider = Provider<CreateTaskUseCase>((ref) {
  final repository = ref.watch(taskRepositoryProvider);
  return CreateTaskUseCase(repository);
});

final updateTaskUseCaseProvider = Provider<UpdateTaskUseCase>((ref) {
  final repository = ref.watch(taskRepositoryProvider);
  return UpdateTaskUseCase(repository);
});

final deleteTaskUseCaseProvider = Provider<DeleteTaskUseCase>((ref) {
  final repository = ref.watch(taskRepositoryProvider);
  return DeleteTaskUseCase(repository);
});

final claimTaskUseCaseProvider = Provider<ClaimTaskUseCase>((ref) {
  final repository = ref.watch(taskRepositoryProvider);
  return ClaimTaskUseCase(repository);
});

final completeTaskUseCaseProvider = Provider<CompleteTaskUseCase>((ref) {
  final repository = ref.watch(taskRepositoryProvider);
  return CompleteTaskUseCase(repository);
});

final approveTaskUseCaseProvider = Provider<ApproveTaskUseCase>((ref) {
  final repository = ref.watch(taskRepositoryProvider);
  return ApproveTaskUseCase(repository);
});

final generateNextRecurringTaskUseCaseProvider =
    Provider<GenerateNextRecurringTaskUseCase>((ref) {
  final repository = ref.watch(taskRepositoryProvider);
  return GenerateNextRecurringTaskUseCase(repository);
});
