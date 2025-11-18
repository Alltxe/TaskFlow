import 'package:dartz/dartz.dart' show Either;
import 'package:mobile/core/errors/failure.dart';
import 'package:mobile/data/models/task.dart';
import 'package:mobile/data/repositories/task_repository.dart';

/// Get all tasks assigned to current user (PRD 3.4.1)
class GetUserTasksUseCase {
  final TaskRepository repository;

  GetUserTasksUseCase(this.repository);

  Future<Either<Failure, List<Task>>> call({String? status}) {
    return repository.getUserTasks(status: status);
  }
}
