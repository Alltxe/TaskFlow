import 'package:dartz/dartz.dart' show Either;
import 'package:taskflow/core/errors/failure.dart';
import 'package:taskflow/data/models/task.dart';
import 'package:taskflow/data/repositories/task_repository.dart';

/// Get task details by ID (PRD 3.4.3)
class GetTaskUseCase {
  final TaskRepository repository;

  GetTaskUseCase(this.repository);

  Future<Either<Failure, Task>> call(String taskId) {
    return repository.getTask(taskId);
  }
}
