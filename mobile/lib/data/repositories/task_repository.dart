// Import only the Either type from dartz to avoid name conflicts with our `Task` model
import 'package:dartz/dartz.dart' show Either;
import 'package:taskflow/core/errors/failure.dart';
import 'package:taskflow/data/models/create_task_request.dart';
import 'package:taskflow/data/models/task.dart';
import 'package:taskflow/data/models/update_task_request.dart';

abstract class TaskRepository {
  /// Get all tasks for a group (PRD 3.4.1)
  Future<Either<Failure, List<Task>>> getGroupTasks(String groupId, {String? status});

  /// Get all tasks assigned to current user (PRD 3.4.1)
  Future<Either<Failure, List<Task>>> getUserTasks({String? status});

  /// Get task details by ID (PRD 3.4.3)
  Future<Either<Failure, Task>> getTask(String taskId);

  /// Create a new task (PRD 3.4.4)
  Future<Either<Failure, Task>> createTask(CreateTaskRequest request);

  /// Update task details (PRD 3.4.5)
  Future<Either<Failure, Task>> updateTask(String taskId, UpdateTaskRequest request);

  /// Delete a task (PRD 3.4.5)
  Future<Either<Failure, void>> deleteTask(String taskId);

  /// Claim an Up-for-Grabs task (PRD 3.4.8)
  Future<Either<Failure, Task>> claimTask(String taskId);

  /// Mark task as complete (PRD 3.4.6)
  Future<Either<Failure, Task>> completeTask(String taskId);

  /// Approve or reject a task (PRD 3.4.7)
  Future<Either<Failure, Task>> approveTask(String taskId, bool approved, {String? rejectionReason});
}
