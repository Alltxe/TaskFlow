import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile/data/datasources/task_remote_datasource.dart';
import 'package:mobile/data/providers/graphql_provider.dart';
import 'package:mobile/data/repositories/task_repository.dart';
import 'package:mobile/data/repositories/task_repository_impl.dart';

// Data Sources
final taskRemoteDataSourceProvider = Provider<TaskRemoteDataSource>((ref) {
  final client = ref.watch(graphqlClientProvider);
  return TaskRemoteDataSource(client);
});

// Repositories
final taskRepositoryProvider = Provider<TaskRepository>((ref) {
  final remoteDataSource = ref.watch(taskRemoteDataSourceProvider);
  return TaskRepositoryImpl(remoteDataSource);
});
