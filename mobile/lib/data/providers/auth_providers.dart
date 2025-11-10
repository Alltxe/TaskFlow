import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile/data/datasources/auth_local_datasource.dart';
import 'package:mobile/data/datasources/auth_remote_datasource.dart';
import 'package:mobile/data/providers/graphql_provider.dart';
import 'package:mobile/data/repositories/auth_repository.dart';
import 'package:mobile/data/repositories/auth_repository_impl.dart';

/// Provider for AuthRemoteDataSource
final authRemoteDataSourceProvider = Provider<AuthRemoteDataSource>((ref) {
  final client = ref.watch(graphqlClientProvider);
  return AuthRemoteDataSource(client);
});

/// Provider for AuthLocalDataSource
final authLocalDataSourceProvider = Provider<AuthLocalDataSource>((ref) {
  final storage = ref.watch(secureStorageProvider);
  return AuthLocalDataSource(storage);
});

/// Provider for AuthRepository
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  final remoteDataSource = ref.watch(authRemoteDataSourceProvider);
  final localDataSource = ref.watch(authLocalDataSourceProvider);

  return AuthRepositoryImpl(remoteDataSource: remoteDataSource, localDataSource: localDataSource);
});
