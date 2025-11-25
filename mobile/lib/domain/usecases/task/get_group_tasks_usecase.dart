import 'package:dartz/dartz.dart' show Either;
import 'package:taskflow/core/errors/failure.dart';
import 'package:taskflow/data/models/task.dart';
import 'package:taskflow/data/repositories/task_repository.dart';

class GetGroupTasksUseCase {
  final TaskRepository repository;

  GetGroupTasksUseCase(this.repository);

  Future<Either<Failure, List<Task>>> call(String groupId, {String? status}) {
    return repository.getGroupTasks(groupId, status: status);
  }
}
