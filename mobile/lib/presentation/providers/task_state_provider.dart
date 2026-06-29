import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:taskflow/data/models/task.dart';
import 'package:taskflow/domain/usecases/task/task_usecase_providers.dart';

/// Task list state for a specific group
final groupTasksProvider = FutureProvider.family<List<Task>, String>((ref, groupId) async {
  print('[TaskProvider] groupTasksProvider called for groupId: $groupId');
  final useCase = ref.watch(getGroupTasksUseCaseProvider);
  final result = await useCase(groupId, status: null);
  return result.fold(
    (failure) {
      print('[TaskProvider] groupTasksProvider failed: ${failure.message}');
      throw Exception(failure.message);
    },
    (tasks) {
      print('[TaskProvider] groupTasksProvider success - ${tasks.length} tasks loaded');
      return tasks;
    },
  );
});

/// Recurring templates for a specific group
final recurringTemplatesProvider =
    FutureProvider.family<List<Task>, String>((ref, groupId) async {
      final useCase = ref.watch(getRecurringTemplatesUseCaseProvider);
      final result = await useCase(groupId);
      return result.fold(
        (failure) => throw Exception(failure.message),
        (tasks) => tasks,
      );
    });

/// Tasks assigned to current user
final userTasksProvider = FutureProvider<List<Task>>((ref) async {
  final useCase = ref.watch(getUserTasksUseCaseProvider);
  final result = await useCase(status: null);
  return result.fold(
    (failure) => throw Exception(failure.message),
    (tasks) => tasks,
  );
});

/// Single task details
final taskDetailsProvider = FutureProvider.family<Task, String>((ref, taskId) async {
  final useCase = ref.watch(getTaskUseCaseProvider);
  final result = await useCase(taskId);
  return result.fold(
    (failure) => throw Exception(failure.message),
    (task) => task,
  );
});

/// Task actions notifier for state management
class TaskActionsNotifier extends StateNotifier<AsyncValue<void>> {
  final Ref ref;

  TaskActionsNotifier(this.ref) : super(const AsyncValue.data(null));

  Future<void> claimTask(String taskId, {String? groupId}) async {
    state = const AsyncValue.loading();
    final useCase = ref.read(claimTaskUseCaseProvider);
    final result = await useCase(taskId);
    state = result.fold(
      (failure) => AsyncValue.error(failure.message, StackTrace.current),
      (_) => const AsyncValue.data(null),
    );
    // Invalidate task lists and the task detail to refresh the UI.
    ref.invalidate(userTasksProvider);
    ref.invalidate(taskDetailsProvider(taskId));
    if (groupId != null) ref.invalidate(groupTasksProvider(groupId));
  }

  Future<void> completeTask(String taskId, {String? groupId}) async {
    state = const AsyncValue.loading();
    final useCase = ref.read(completeTaskUseCaseProvider);
    final result = await useCase(taskId);
    state = result.fold(
      (failure) => AsyncValue.error(failure.message, StackTrace.current),
      (_) => const AsyncValue.data(null),
    );
    // Invalidate to refresh
    ref.invalidate(userTasksProvider);
    if (groupId != null) ref.invalidate(groupTasksProvider(groupId));
    // Ensure group lists also refresh if the caller supplies groupId
    ref.invalidate(taskDetailsProvider(taskId));
  }

  Future<void> approveTask(String taskId, bool approved, {String? rejectionReason, String? groupId}) async {
    state = const AsyncValue.loading();
    final useCase = ref.read(approveTaskUseCaseProvider);
    final result = await useCase(taskId, approved, rejectionReason: rejectionReason);
    state = result.fold(
      (failure) => AsyncValue.error(failure.message, StackTrace.current),
      (_) => const AsyncValue.data(null),
    );
    // Invalidate to refresh
    ref.invalidate(taskDetailsProvider(taskId));
    if (groupId != null) ref.invalidate(groupTasksProvider(groupId));
  }

  Future<void> deleteTask(String taskId, {String? groupId}) async {
    state = const AsyncValue.loading();
    final useCase = ref.read(deleteTaskUseCaseProvider);
    final result = await useCase(taskId);
    state = result.fold(
      (failure) => AsyncValue.error(failure.message, StackTrace.current),
      (_) => const AsyncValue.data(null),
    );
    // Invalidate to refresh
    ref.invalidate(userTasksProvider);
    if (groupId != null) ref.invalidate(groupTasksProvider(groupId));
    if (groupId != null) ref.invalidate(recurringTemplatesProvider(groupId));
  }
}

final taskActionsProvider = StateNotifierProvider<TaskActionsNotifier, AsyncValue<void>>((ref) {
  return TaskActionsNotifier(ref);
});
