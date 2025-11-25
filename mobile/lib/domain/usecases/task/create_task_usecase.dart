import 'package:dartz/dartz.dart' show Either;
import 'package:taskflow/core/errors/failure.dart';
import 'package:taskflow/data/models/create_task_request.dart';
import 'package:taskflow/data/models/task.dart';
import 'package:taskflow/data/repositories/task_repository.dart';

class CreateTaskUseCase {
  final TaskRepository repository;

  CreateTaskUseCase(this.repository);

  Future<Either<Failure, Task>> call(CreateTaskRequest request) {
    return repository.createTask(request);
  }
}
