import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:mobile/core/errors/exceptions.dart' as app_exceptions;
import 'package:mobile/data/models/leaderboard_entry.dart';
import 'package:mobile/data/models/reward.dart';
import 'package:mobile/data/models/user_statistics.dart';

class RewardRemoteDataSource {
  final GraphQLClient client;

  RewardRemoteDataSource(this.client);

  // Get group rewards
  Future<List<Reward>> getGroupRewards(String groupId) async {
    const query = r'''
      query GetGroupRewards($groupId: String!) {
        getGroupRewards(groupId: $groupId) {
          id
          name
          description
          cost
          isActive
          imageUrl
          createdAt
          groupId
          createdById
        }
      }
    ''';

    try {
      final result = await client.query(
        QueryOptions(
          document: gql(query),
          variables: {'groupId': groupId},
          fetchPolicy: FetchPolicy.networkOnly,
        ),
      );

      if (result.hasException) {
        _handleGraphQLException(result.exception!);
      }

      final List<dynamic> rewardsData = result.data?['getGroupRewards'] ?? [];
      return rewardsData.map((json) => Reward.fromJson(json)).toList();
    } catch (e) {
      if (e is app_exceptions.AppException) rethrow;
      throw app_exceptions.NetworkException(message: 'Failed to fetch rewards: ${e.toString()}');
    }
  }

  // Get user statistics for a group
  Future<UserStatistics> getUserStatistics(String groupId) async {
    const query = r'''
      query GetUserStatistics($groupId: String) {
        getUserStatistics(groupId: $groupId) {
          userId
          currentPointBalance
          totalPointsEarned
          totalPointsSpent
          tasksCompleted
          tasksAssigned
          completionRate
          tasksCompletedOnTime
          onTimePercentage
          leaderboardPosition
          groupId
        }
      }
    ''';

    try {
      final result = await client.query(
        QueryOptions(
          document: gql(query),
          variables: {'groupId': groupId},
          fetchPolicy: FetchPolicy.networkOnly,
        ),
      );

      if (result.hasException) {
        _handleGraphQLException(result.exception!);
      }

      final statsData = result.data?['getUserStatistics'];
      if (statsData == null) {
        throw const app_exceptions.ServerException(message: 'Stats not found');
      }

      return UserStatistics.fromJson(statsData);
    } catch (e) {
      if (e is app_exceptions.AppException) rethrow;
      throw app_exceptions.NetworkException(message: 'Failed to fetch statistics: ${e.toString()}');
    }
  }

  // Get group leaderboard
  Future<List<LeaderboardEntry>> getGroupLeaderboard(String groupId) async {
    const query = r'''
      query GetGroupLeaderboard($groupId: String!) {
        getGroupLeaderboard(groupId: $groupId) {
          user {
            id
            username
          }
          pointsEarned
          rank
        }
      }
    ''';

    try {
      final result = await client.query(
        QueryOptions(
          document: gql(query),
          variables: {'groupId': groupId},
          fetchPolicy: FetchPolicy.networkOnly,
        ),
      );

      if (result.hasException) {
        _handleGraphQLException(result.exception!);
      }

      final List<dynamic> leaderboardData = result.data?['getGroupLeaderboard'] ?? [];
      return leaderboardData.map((json) => LeaderboardEntry.fromJson(json)).toList();
    } catch (e) {
      if (e is app_exceptions.AppException) rethrow;
      throw app_exceptions.NetworkException(
        message: 'Failed to fetch leaderboard: ${e.toString()}',
      );
    }
  }

  void _handleGraphQLException(OperationException exception) {
    if (exception.linkException != null) {
      throw app_exceptions.NetworkException(
        message: 'Network error: ${exception.linkException!.toString()}',
      );
    }

    if (exception.graphqlErrors.isNotEmpty) {
      final error = exception.graphqlErrors.first;
      final message = error.message;
      final code = error.extensions?['code'] as String?;

      if (code == 'UNAUTHENTICATED' || code == 'FORBIDDEN') {
        throw app_exceptions.AuthException(message: message, code: code);
      } else if (code == 'VALIDATION_ERROR') {
        throw app_exceptions.ValidationException(message: message, code: code);
      } else {
        throw app_exceptions.ServerException(message: message, code: code);
      }
    }

    throw const app_exceptions.ServerException(message: 'Unknown server error');
  }
}
