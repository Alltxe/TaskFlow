import 'package:dartz/dartz.dart' show Either;
import 'package:mobile/core/errors/failure.dart';
import 'package:mobile/data/models/create_task_request.dart';
import 'package:mobile/data/models/task.dart';
import 'package:mobile/data/repositories/task_repository.dart';

class CreateTaskUseCase {
  final TaskRepository repository;

  CreateTaskUseCase(this.repository);

  Future<Either<Failure, Task>> call(CreateTaskRequest request) {
    return repository.createTask(request);
  }
}
