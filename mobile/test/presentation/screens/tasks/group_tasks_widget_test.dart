import 'package:dartz/dartz.dart' as dartz;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:taskflow/core/errors/failure.dart';
import 'package:taskflow/data/models/create_task_request.dart';
import 'package:taskflow/data/models/task.dart';
import 'package:taskflow/data/models/update_task_request.dart';
import 'package:taskflow/data/providers/task_providers.dart';
// dartz alias imported below
import 'package:taskflow/data/repositories/task_repository.dart';
import 'package:taskflow/presentation/screens/tasks/tasks_screen.dart';

void main() {
  testWidgets('TasksScreen displays group tasks when groupId is provided', (tester) async {
    final testTask = Task(
      id: 't1',
      title: 'Group Task 1',
      description: 'Test',
      deadline: DateTime.now().add(const Duration(days: 1)),
      priority: 'LOW',
      status: 'PENDING',
      points: 10,
      requiresApproval: false,
      isRecurring: false,
      recurrenceRule: null,
      rotationType: null,
      weight: 0,
      wasClaimedFromPool: false,
      rejectionReason: null,
      createdAt: DateTime.now(),
      completedAt: null,
      groupId: 'g1',
      createdById: 'u1',
      assigneeId: null,
    );

    // Provide a fake repository that returns the testTask for the group
    final fakeRepo = _FakeTaskRepository([testTask]);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [taskRepositoryProvider.overrideWithValue(fakeRepo)],
        child: const MaterialApp(home: TasksScreen(groupId: 'g1')),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('Group Task 1'), findsOneWidget);
  });
}

class _FakeTaskRepository implements TaskRepository {
  final List<Task> _tasks;

  _FakeTaskRepository(this._tasks);

  @override
  Future<dartz.Either<Failure, List<Task>>> getGroupTasks(String groupId, {String? status}) async {
    return dartz.Right(_tasks);
  }

  @override
  Future<dartz.Either<Failure, List<Task>>> getUserTasks({String? status}) =>
      Future.value(const dartz.Left(UnknownFailure(message: 'Not implemented')));

  @override
  Future<dartz.Either<Failure, Task>> getTask(String taskId) =>
      Future.value(const dartz.Left(UnknownFailure(message: 'Not implemented')));

  @override
  Future<dartz.Either<Failure, Task>> createTask(CreateTaskRequest request) =>
      Future.value(const dartz.Left(UnknownFailure(message: 'Not implemented')));

  @override
  Future<dartz.Either<Failure, Task>> updateTask(String taskId, UpdateTaskRequest request) =>
      Future.value(const dartz.Left(UnknownFailure(message: 'Not implemented')));

  @override
  Future<dartz.Either<Failure, void>> deleteTask(String taskId) =>
      Future.value(const dartz.Left(UnknownFailure(message: 'Not implemented')));

  @override
  Future<dartz.Either<Failure, Task>> claimTask(String taskId) =>
      Future.value(const dartz.Left(UnknownFailure(message: 'Not implemented')));

  @override
  Future<dartz.Either<Failure, Task>> completeTask(String taskId) =>
      Future.value(const dartz.Left(UnknownFailure(message: 'Not implemented')));

  @override
  Future<dartz.Either<Failure, Task>> approveTask(
    String taskId,
    bool approved, {
    String? rejectionReason,
  }) => Future.value(const dartz.Left(UnknownFailure(message: 'Not implemented')));
}
