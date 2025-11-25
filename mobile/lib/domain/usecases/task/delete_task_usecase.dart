import 'package:dartz/dartz.dart' show Either;
import 'package:taskflow/core/errors/failure.dart';
import 'package:taskflow/data/repositories/task_repository.dart';

/// Delete a task (PRD 3.4.5)
class DeleteTaskUseCase {
  final TaskRepository repository;

  DeleteTaskUseCase(this.repository);

  Future<Either<Failure, void>> call(String taskId) {
    return repository.deleteTask(taskId);
  }
}
