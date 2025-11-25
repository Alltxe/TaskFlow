import 'package:dartz/dartz.dart' show Either;
import 'package:taskflow/core/errors/failure.dart';
import 'package:taskflow/data/models/task.dart';
import 'package:taskflow/data/repositories/task_repository.dart';

class CompleteTaskUseCase {
  final TaskRepository repository;

  CompleteTaskUseCase(this.repository);

  Future<Either<Failure, Task>> call(String taskId) {
    return repository.completeTask(taskId);
  }
}
