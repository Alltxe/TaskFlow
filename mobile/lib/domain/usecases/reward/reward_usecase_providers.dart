import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile/data/providers/reward_providers.dart';
import 'package:mobile/domain/usecases/reward/get_group_leaderboard_usecase.dart';
import 'package:mobile/domain/usecases/reward/get_group_rewards_usecase.dart';

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
