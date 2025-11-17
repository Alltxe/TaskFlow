// Import only the Either type from dartz to avoid name conflicts with our `Task` model
import 'package:dartz/dartz.dart' show Either;
import 'package:mobile/core/errors/failure.dart';
import 'package:mobile/data/models/create_task_request.dart';
import 'package:mobile/data/models/task.dart';
import 'package:mobile/data/models/update_task_request.dart';

abstract class TaskRepository {
  Future<Either<Failure, List<Task>>> getGroupTasks(String groupId, {String? status});
  Future<Either<Failure, List<Task>>> getUserTasks({String? status});
  Future<Either<Failure, Task>> getTask(String taskId);
  Future<Either<Failure, Task>> createTask(CreateTaskRequest request);
  Future<Either<Failure, Task>> updateTask(String taskId, UpdateTaskRequest request);
  Future<Either<Failure, void>> deleteTask(String taskId);
  Future<Either<Failure, Task>> claimTask(String taskId);
  Future<Either<Failure, Task>> unclaimTask(String taskId);
  Future<Either<Failure, Task>> completeTask(String taskId);
  Future<Either<Failure, Task>> approveTask(String taskId);
  Future<Either<Failure, Task>> rejectTask(String taskId, String reason);
}
