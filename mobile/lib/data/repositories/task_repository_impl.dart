// Import Right/Left/Either helpers from dartz only. Hide Task to avoid conflict with our model
import 'package:dartz/dartz.dart' show Either, Left, Right;
import 'package:taskflow/core/errors/exceptions.dart';
import 'package:taskflow/core/errors/failure.dart';
import 'package:taskflow/data/datasources/task_remote_datasource.dart';
import 'package:taskflow/data/models/create_task_request.dart';
import 'package:taskflow/data/models/task.dart';
import 'package:taskflow/data/models/update_task_request.dart';
import 'package:taskflow/data/repositories/task_repository.dart';

class TaskRepositoryImpl implements TaskRepository {
  final TaskRemoteDataSource remoteDataSource;

  TaskRepositoryImpl(this.remoteDataSource);

  @override
  Future<Either<Failure, List<Task>>> getGroupTasks(String groupId, {String? status}) async {
    print('[TaskRepository] getGroupTasks called - groupId: $groupId, status: $status');
    try {
      final tasks = await remoteDataSource.getGroupTasks(groupId, status: status);
      print('[TaskRepository] getGroupTasks success - received ${tasks.length} tasks');
      return Right(tasks);
    } on NetworkException catch (e) {
      print('[TaskRepository] getGroupTasks NetworkException: ${e.message}');
      return Left(NetworkFailure(message: e.message));
    } on ServerException catch (e) {
      print('[TaskRepository] getGroupTasks ServerException: ${e.message}');
      return Left(ServerFailure(message: e.message));
    } on AuthException catch (e) {
      print('[TaskRepository] getGroupTasks AuthException: ${e.message}');
      return Left(AuthFailure(message: e.message));
    } catch (e) {
      print('[TaskRepository] getGroupTasks UnknownException: $e');
      return Left(UnknownFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<Task>>> getRecurringTemplates(String groupId) async {
    try {
      final templates = await remoteDataSource.getRecurringTemplates(groupId);
      return Right(templates);
    } on NetworkException catch (e) {
      return Left(NetworkFailure(message: e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } on AuthException catch (e) {
      return Left(AuthFailure(message: e.message));
    } catch (e) {
      return Left(UnknownFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<Task>>> getUserTasks({String? status}) async {
    try {
      final tasks = await remoteDataSource.getUserTasks(status: status);
      return Right(tasks);
    } on NetworkException catch (e) {
      return Left(NetworkFailure(message: e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } on AuthException catch (e) {
      return Left(AuthFailure(message: e.message));
    } catch (e) {
      return Left(UnknownFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, Task>> getTask(String taskId) async {
    try {
      final task = await remoteDataSource.getTask(taskId);
      return Right(task);
    } on NetworkException catch (e) {
      return Left(NetworkFailure(message: e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } on AuthException catch (e) {
      return Left(AuthFailure(message: e.message));
    } catch (e) {
      return Left(UnknownFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, Task>> createTask(CreateTaskRequest request) async {
    try {
      final task = await remoteDataSource.createTask(request);
      return Right(task);
    } on NetworkException catch (e) {
      return Left(NetworkFailure(message: e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } on AuthException catch (e) {
      return Left(AuthFailure(message: e.message));
    } on ValidationException catch (e) {
      return Left(ValidationFailure(message: e.message));
    } catch (e) {
      return Left(UnknownFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, Task>> updateTask(String taskId, UpdateTaskRequest request) async {
    try {
      final task = await remoteDataSource.updateTask(taskId, request);
      return Right(task);
    } on NetworkException catch (e) {
      return Left(NetworkFailure(message: e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } on AuthException catch (e) {
      return Left(AuthFailure(message: e.message));
    } on ValidationException catch (e) {
      return Left(ValidationFailure(message: e.message));
    } catch (e) {
      return Left(UnknownFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> deleteTask(String taskId) async {
    try {
      await remoteDataSource.deleteTask(taskId);
      return const Right(null);
    } on NetworkException catch (e) {
      return Left(NetworkFailure(message: e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } on AuthException catch (e) {
      return Left(AuthFailure(message: e.message));
    } catch (e) {
      return Left(UnknownFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, Task>> claimTask(String taskId) async {
    try {
      final task = await remoteDataSource.claimTask(taskId);
      return Right(task);
    } on NetworkException catch (e) {
      return Left(NetworkFailure(message: e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } on AuthException catch (e) {
      return Left(AuthFailure(message: e.message));
    } catch (e) {
      return Left(UnknownFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, Task>> completeTask(String taskId) async {
    try {
      final task = await remoteDataSource.completeTask(taskId);
      return Right(task);
    } on NetworkException catch (e) {
      return Left(NetworkFailure(message: e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } on AuthException catch (e) {
      return Left(AuthFailure(message: e.message));
    } catch (e) {
      return Left(UnknownFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, Task>> approveTask(String taskId, bool approved, {String? rejectionReason}) async {
    try {
      final task = await remoteDataSource.approveTask(taskId, approved, rejectionReason: rejectionReason);
      return Right(task);
    } on NetworkException catch (e) {
      return Left(NetworkFailure(message: e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } on AuthException catch (e) {
      return Left(AuthFailure(message: e.message));
    } on ValidationException catch (e) {
      return Left(ValidationFailure(message: e.message));
    } catch (e) {
      return Left(UnknownFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, Task>> generateNextRecurringTask(String taskId) async {
    try {
      final task = await remoteDataSource.generateNextRecurringTask(taskId);
      return Right(task);
    } on NetworkException catch (e) {
      return Left(NetworkFailure(message: e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } on AuthException catch (e) {
      return Left(AuthFailure(message: e.message));
    } catch (e) {
      return Left(UnknownFailure(message: e.toString()));
    }
  }
}
