import 'package:dartz/dartz.dart' show Either;
import 'package:taskflow/core/errors/failure.dart';
import 'package:taskflow/data/models/task.dart';
import 'package:taskflow/data/models/update_task_request.dart';
import 'package:taskflow/data/repositories/task_repository.dart';

/// Update task details (PRD 3.4.5)
class UpdateTaskUseCase {
  final TaskRepository repository;

  UpdateTaskUseCase(this.repository);

  Future<Either<Failure, Task>> call(String taskId, UpdateTaskRequest request) {
    return repository.updateTask(taskId, request);
  }
}
