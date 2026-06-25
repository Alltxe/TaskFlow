import 'package:dartz/dartz.dart' show Either;
import 'package:taskflow/core/errors/failure.dart';
import 'package:taskflow/data/models/task.dart';
import 'package:taskflow/data/repositories/task_repository.dart';

class GenerateNextRecurringTaskUseCase {
  final TaskRepository _repository;

  GenerateNextRecurringTaskUseCase(this._repository);

  Future<Either<Failure, Task>> call(String taskId) =>
      _repository.generateNextRecurringTask(taskId);
}
