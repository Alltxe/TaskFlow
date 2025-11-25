import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:taskflow/data/providers/reward_providers.dart';
import 'package:taskflow/domain/usecases/reward/approve_reward_request_usecase.dart';
import 'package:taskflow/domain/usecases/reward/create_reward_usecase.dart';
import 'package:taskflow/domain/usecases/reward/delete_reward_usecase.dart';
import 'package:taskflow/domain/usecases/reward/get_group_leaderboard_usecase.dart';
import 'package:taskflow/domain/usecases/reward/get_group_reward_requests_usecase.dart';
import 'package:taskflow/domain/usecases/reward/get_group_rewards_usecase.dart';
import 'package:taskflow/domain/usecases/reward/get_my_reward_requests_usecase.dart';
import 'package:taskflow/domain/usecases/reward/get_point_balance_usecase.dart';
import 'package:taskflow/domain/usecases/reward/get_point_transaction_history_usecase.dart';
import 'package:taskflow/domain/usecases/reward/request_reward_usecase.dart';
import 'package:taskflow/domain/usecases/reward/update_reward_usecase.dart';

// Reward Use Cases
final getGroupRewardsUseCaseProvider = Provider<GetGroupRewardsUseCase>((ref) {
  final repository = ref.watch(rewardRepositoryProvider);
  return GetGroupRewardsUseCase(repository);
});

final getGroupLeaderboardUseCaseProvider =
    Provider<GetGroupLeaderboardUseCase>((ref) {
  final repository = ref.watch(rewardRepositoryProvider);
  return GetGroupLeaderboardUseCase(repository);
});

final requestRewardUseCaseProvider = Provider<RequestRewardUseCase>((ref) {
  final repository = ref.watch(rewardRepositoryProvider);
  return RequestRewardUseCase(repository);
});

final getMyRewardRequestsUseCaseProvider =
    Provider<GetMyRewardRequestsUseCase>((ref) {
  final repository = ref.watch(rewardRepositoryProvider);
  return GetMyRewardRequestsUseCase(repository);
});

final getPointBalanceUseCaseProvider = Provider<GetPointBalanceUseCase>((ref) {
  final repository = ref.watch(rewardRepositoryProvider);
  return GetPointBalanceUseCase(repository);
});

final getPointTransactionHistoryUseCaseProvider =
    Provider<GetPointTransactionHistoryUseCase>((ref) {
  final repository = ref.watch(rewardRepositoryProvider);
  return GetPointTransactionHistoryUseCase(repository);
});

// Admin Use Cases
final createRewardUseCaseProvider = Provider<CreateRewardUseCase>((ref) {
  final repository = ref.watch(rewardRepositoryProvider);
  return CreateRewardUseCase(repository);
});

final updateRewardUseCaseProvider = Provider<UpdateRewardUseCase>((ref) {
  final repository = ref.watch(rewardRepositoryProvider);
  return UpdateRewardUseCase(repository);
});

final deleteRewardUseCaseProvider = Provider<DeleteRewardUseCase>((ref) {
  final repository = ref.watch(rewardRepositoryProvider);
  return DeleteRewardUseCase(repository);
});

final getGroupRewardRequestsUseCaseProvider =
    Provider<GetGroupRewardRequestsUseCase>((ref) {
  final repository = ref.watch(rewardRepositoryProvider);
  return GetGroupRewardRequestsUseCase(repository);
});

final approveRewardRequestUseCaseProvider =
    Provider<ApproveRewardRequestUseCase>((ref) {
  final repository = ref.watch(rewardRepositoryProvider);
  return ApproveRewardRequestUseCase(repository);
});
