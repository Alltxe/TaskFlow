import 'package:dartz/dartz.dart' show Either;
import 'package:mobile/core/errors/failure.dart';
import 'package:mobile/data/repositories/task_repository.dart';

/// Delete a task (PRD 3.4.5)
class DeleteTaskUseCase {
  final TaskRepository repository;

  DeleteTaskUseCase(this.repository);

  Future<Either<Failure, void>> call(String taskId) {
    return repository.deleteTask(taskId);
  }
}
