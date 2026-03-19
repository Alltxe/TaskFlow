import 'package:dartz/dartz.dart' show Either;
import 'package:taskflow/core/errors/failure.dart';
import 'package:taskflow/data/models/task.dart';
import 'package:taskflow/data/repositories/task_repository.dart';

class GetRecurringTemplatesUseCase {
  final TaskRepository repository;

  GetRecurringTemplatesUseCase(this.repository);

  Future<Either<Failure, List<Task>>> call(String groupId) {
    return repository.getRecurringTemplates(groupId);
  }
}