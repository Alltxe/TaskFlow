import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:taskflow/data/datasources/task_remote_datasource.dart';
import 'package:taskflow/data/repositories/task_repository.dart';
import 'package:taskflow/data/repositories/task_repository_impl.dart';

// Data Sources
final taskRemoteDataSourceProvider = Provider<TaskRemoteDataSource>((ref) {
  return TaskRemoteDataSource();
});

// Repositories
final taskRepositoryProvider = Provider<TaskRepository>((ref) {
  final remoteDataSource = ref.watch(taskRemoteDataSourceProvider);
  return TaskRepositoryImpl(remoteDataSource);
});
