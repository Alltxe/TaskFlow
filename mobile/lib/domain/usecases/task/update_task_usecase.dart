import 'package:dartz/dartz.dart' show Either;
import 'package:mobile/core/errors/failure.dart';
import 'package:mobile/data/models/task.dart';
import 'package:mobile/data/models/update_task_request.dart';
import 'package:mobile/data/repositories/task_repository.dart';

/// Update task details (PRD 3.4.5)
class UpdateTaskUseCase {
  final TaskRepository repository;

  UpdateTaskUseCase(this.repository);

  Future<Either<Failure, Task>> call(String taskId, UpdateTaskRequest request) {
    return repository.updateTask(taskId, request);
  }
}
