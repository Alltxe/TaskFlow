import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:taskflow/data/datasources/reward_remote_datasource.dart';
import 'package:taskflow/data/repositories/reward_repository.dart';
import 'package:taskflow/data/repositories/reward_repository_impl.dart';

// Data Sources
final rewardRemoteDataSourceProvider = Provider<RewardRemoteDataSource>((ref) {
  return RewardRemoteDataSource();
});

// Repositories
final rewardRepositoryProvider = Provider<RewardRepository>((ref) {
  final remoteDataSource = ref.watch(rewardRemoteDataSourceProvider);
  return RewardRepositoryImpl(remoteDataSource);
});
