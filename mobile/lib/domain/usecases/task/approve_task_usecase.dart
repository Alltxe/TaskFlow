import 'package:dartz/dartz.dart' show Either;
import 'package:mobile/core/errors/failure.dart';
import 'package:mobile/data/models/task.dart';
import 'package:mobile/data/repositories/task_repository.dart';

/// Approve or reject a task (PRD 3.4.7)
class ApproveTaskUseCase {
  final TaskRepository repository;

  ApproveTaskUseCase(this.repository);

  Future<Either<Failure, Task>> call(String taskId, bool approved, {String? rejectionReason}) {
    return repository.approveTask(taskId, approved, rejectionReason: rejectionReason);
  }
}
