import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile/data/providers/task_providers.dart';
import 'package:mobile/domain/usecases/task/claim_task_usecase.dart';
import 'package:mobile/domain/usecases/task/complete_task_usecase.dart';
import 'package:mobile/domain/usecases/task/create_task_usecase.dart';
import 'package:mobile/domain/usecases/task/get_group_tasks_usecase.dart';

// Task Use Cases
final getGroupTasksUseCaseProvider = Provider<GetGroupTasksUseCase>((ref) {
  final repository = ref.watch(taskRepositoryProvider);
  return GetGroupTasksUseCase(repository);
});

final createTaskUseCaseProvider = Provider<CreateTaskUseCase>((ref) {
  final repository = ref.watch(taskRepositoryProvider);
  return CreateTaskUseCase(repository);
});

final claimTaskUseCaseProvider = Provider<ClaimTaskUseCase>((ref) {
  final repository = ref.watch(taskRepositoryProvider);
  return ClaimTaskUseCase(repository);
});

final completeTaskUseCaseProvider = Provider<CompleteTaskUseCase>((ref) {
  final repository = ref.watch(taskRepositoryProvider);
  return CompleteTaskUseCase(repository);
});
