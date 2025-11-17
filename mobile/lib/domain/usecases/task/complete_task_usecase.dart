import 'package:dartz/dartz.dart' show Either;
import 'package:mobile/core/errors/failure.dart';
import 'package:mobile/data/models/task.dart';
import 'package:mobile/data/repositories/task_repository.dart';

class CompleteTaskUseCase {
  final TaskRepository repository;

  CompleteTaskUseCase(this.repository);

  Future<Either<Failure, Task>> call(String taskId) {
    return repository.completeTask(taskId);
  }
}
