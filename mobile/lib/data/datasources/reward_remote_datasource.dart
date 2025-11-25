import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:taskflow/core/errors/exceptions.dart' as app_exceptions;
import 'package:taskflow/data/models/leaderboard_entry.dart';
import 'package:taskflow/data/models/point_balance.dart';
import 'package:taskflow/data/models/point_transaction_history.dart';
import 'package:taskflow/data/models/request_reward_input.dart';
import 'package:taskflow/data/models/reward.dart';
import 'package:taskflow/data/models/reward_transaction.dart';
import 'package:taskflow/data/models/user_statistics.dart';

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

  // Request reward
  Future<RewardTransaction> requestReward(RequestRewardInput input) async {
    const mutation = r'''
      mutation RequestReward($input: RequestRewardInput!) {
        requestReward(input: $input) {
          id
          pointsSpent
          status
          requestedAt
          approvedAt
          rejectedAt
          rejectionReason
          rewardId
          userId
          approvedById
        }
      }
    ''';

    try {
      final result = await client.mutate(
        MutationOptions(
          document: gql(mutation),
          variables: {
            'input': {
              'rewardId': input.rewardId,
              'groupId': input.groupId,
            },
          },
          fetchPolicy: FetchPolicy.networkOnly,
        ),
      );

      if (result.hasException) {
        _handleGraphQLException(result.exception!);
      }

      final transactionData = result.data?['requestReward'];
      if (transactionData == null) {
        throw const app_exceptions.ServerException(
            message: 'Request reward response is null');
      }

      // server doesn't return groupId on RewardTransactionType; inject it from the input
      final Map<String, dynamic> transactionMap = Map<String, dynamic>.from(transactionData as Map);
      transactionMap['groupId'] = input.groupId;
      return RewardTransaction.fromJson(transactionMap);
    } catch (e) {
      if (e is app_exceptions.AppException) rethrow;
      throw app_exceptions.NetworkException(
          message: 'Failed to request reward: ${e.toString()}');
    }
  }

  // Get my reward requests
  Future<List<RewardTransaction>> getMyRewardRequests({String? groupId}) async {
    const query = r'''
      query GetMyRewardRequests($groupId: String) {
        getMyRewardRequests(groupId: $groupId) {
          id
          pointsSpent
          status
          requestedAt
          approvedAt
          rejectedAt
          rejectionReason
          rewardId
          userId
          approvedById
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

      final List<dynamic> requestsData = result.data?['getMyRewardRequests'] ?? [];
      return requestsData.map((json) {
        final Map<String, dynamic> map = Map<String, dynamic>.from(json as Map);
        if (groupId != null) map['groupId'] = groupId;
        return RewardTransaction.fromJson(map);
      }).toList();
    } catch (e) {
      if (e is app_exceptions.AppException) rethrow;
      throw app_exceptions.NetworkException(
          message: 'Failed to fetch reward requests: ${e.toString()}');
    }
  }

  // Get point balance
  Future<PointBalance> getPointBalance({String? groupId}) async {
    const query = r'''
      query GetPointBalance($groupId: String) {
        getPointBalance(groupId: $groupId) {
          totalEarned
          totalSpentApproved
          totalReservedPending
          currentBalance
          availableBalance
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

      final balanceData = result.data?['getPointBalance'];
      if (balanceData == null) {
        throw const app_exceptions.ServerException(message: 'Point balance not found');
      }

      return PointBalance.fromJson(balanceData);
    } catch (e) {
      if (e is app_exceptions.AppException) rethrow;
      throw app_exceptions.NetworkException(
          message: 'Failed to fetch point balance: ${e.toString()}');
    }
  }

  // Get point transaction history
  Future<PointTransactionHistory> getPointTransactionHistory({
    String? groupId,
    int? limit,
    int? offset,
  }) async {
    const query = r'''
      query GetPointTransactionHistory($groupId: String, $limit: Int, $offset: Int) {
        getPointTransactionHistory(groupId: $groupId, limit: $limit, offset: $offset) {
          items {
            id
            type
            amount
            description
            relatedTaskId
            relatedTaskTitle
            relatedRewardId
            relatedRewardName
            createdAt
          }
          total
        }
      }
    ''';

    try {
      final result = await client.query(
        QueryOptions(
          document: gql(query),
          variables: {
            'groupId': groupId,
            'limit': limit,
            'offset': offset,
          },
          fetchPolicy: FetchPolicy.networkOnly,
        ),
      );

      if (result.hasException) {
        _handleGraphQLException(result.exception!);
      }

      final historyData = result.data?['getPointTransactionHistory'];
      if (historyData == null) {
        throw const app_exceptions.ServerException(
            message: 'Transaction history not found');
      }

      return PointTransactionHistory.fromJson(historyData);
    } catch (e) {
      if (e is app_exceptions.AppException) rethrow;
      throw app_exceptions.NetworkException(
          message: 'Failed to fetch transaction history: ${e.toString()}');
    }
  }

  // Create reward (admin only)
  Future<Reward> createReward({
    required String groupId,
    required String name,
    required int cost,
    String? description,
    String? imageUrl,
    bool? isActive,
  }) async {
    const mutation = r'''
      mutation CreateReward($input: CreateRewardInput!) {
        createReward(input: $input) {
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
      final result = await client.mutate(
        MutationOptions(
          document: gql(mutation),
          variables: {
            'input': {
              'groupId': groupId,
              'name': name,
              'cost': cost,
              if (description != null) 'description': description,
              if (imageUrl != null) 'imageUrl': imageUrl,
              if (isActive != null) 'isActive': isActive,
            },
          },
          fetchPolicy: FetchPolicy.networkOnly,
        ),
      );

      if (result.hasException) {
        _handleGraphQLException(result.exception!);
      }

      final rewardData = result.data?['createReward'];
      if (rewardData == null) {
        throw const app_exceptions.ServerException(message: 'Create reward response is null');
      }

      return Reward.fromJson(rewardData);
    } catch (e) {
      if (e is app_exceptions.AppException) rethrow;
      throw app_exceptions.NetworkException(
          message: 'Failed to create reward: ${e.toString()}');
    }
  }

  // Update reward (admin only)
  Future<Reward> updateReward({
    required String rewardId,
    required String groupId,
    String? name,
    int? cost,
    String? description,
    String? imageUrl,
    bool? isActive,
  }) async {
    const mutation = r'''
      mutation UpdateReward($input: UpdateRewardInput!) {
        updateReward(input: $input) {
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
      final result = await client.mutate(
        MutationOptions(
          document: gql(mutation),
          variables: {
            'input': {
              'rewardId': rewardId,
              'groupId': groupId,
              if (name != null) 'name': name,
              if (cost != null) 'cost': cost,
              if (description != null) 'description': description,
              if (imageUrl != null) 'imageUrl': imageUrl,
              if (isActive != null) 'isActive': isActive,
            },
          },
          fetchPolicy: FetchPolicy.networkOnly,
        ),
      );

      if (result.hasException) {
        _handleGraphQLException(result.exception!);
      }

      final rewardData = result.data?['updateReward'];
      if (rewardData == null) {
        throw const app_exceptions.ServerException(message: 'Update reward response is null');
      }

      return Reward.fromJson(rewardData);
    } catch (e) {
      if (e is app_exceptions.AppException) rethrow;
      throw app_exceptions.NetworkException(
          message: 'Failed to update reward: ${e.toString()}');
    }
  }

  // Delete reward (admin only)
  Future<bool> deleteReward({
    required String rewardId,
    required String groupId,
  }) async {
    const mutation = r'''
      mutation DeleteReward($rewardId: String!, $groupId: String!) {
        deleteReward(rewardId: $rewardId, groupId: $groupId)
      }
    ''';

    try {
      final result = await client.mutate(
        MutationOptions(
          document: gql(mutation),
          variables: {
            'rewardId': rewardId,
            'groupId': groupId,
          },
          fetchPolicy: FetchPolicy.networkOnly,
        ),
      );

      if (result.hasException) {
        _handleGraphQLException(result.exception!);
      }

      return result.data?['deleteReward'] ?? false;
    } catch (e) {
      if (e is app_exceptions.AppException) rethrow;
      throw app_exceptions.NetworkException(
          message: 'Failed to delete reward: ${e.toString()}');
    }
  }

  // Get group reward requests (admin only)
  Future<List<RewardTransaction>> getGroupRewardRequests(String groupId) async {
    const query = r'''
      query GetGroupRewardRequests($groupId: String!) {
        getGroupRewardRequests(groupId: $groupId) {
          id
          pointsSpent
          status
          requestedAt
          approvedAt
          rejectedAt
          rejectionReason
          rewardId
          userId
          approvedById
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

      final List<dynamic> requestsData = result.data?['getGroupRewardRequests'] ?? [];
      return requestsData.map((json) {
        final Map<String, dynamic> map = Map<String, dynamic>.from(json as Map);
        map['groupId'] = groupId; // server doesn't expose groupId on RewardTransactionType
        return RewardTransaction.fromJson(map);
      }).toList();
    } catch (e) {
      if (e is app_exceptions.AppException) rethrow;
      throw app_exceptions.NetworkException(
          message: 'Failed to fetch group reward requests: ${e.toString()}');
    }
  }

  // Approve or reject reward request (admin only)
  Future<RewardTransaction> approveRewardRequest({
    required String requestId,
    required bool approved,
    String? reason,
  }) async {
    const mutation = r'''
      mutation ApproveRewardRequest($input: ApproveRewardRequestInput!) {
        approveRewardRequest(input: $input) {
          id
          pointsSpent
          status
          requestedAt
          approvedAt
          rejectedAt
          rejectionReason
          rewardId
          userId
          approvedById
        }
      }
    ''';

    try {
      final result = await client.mutate(
        MutationOptions(
          document: gql(mutation),
          variables: {
            'input': {
              'requestId': requestId,
              'approved': approved,
              if (reason != null) 'reason': reason,
            },
          },
          fetchPolicy: FetchPolicy.networkOnly,
        ),
      );

      if (result.hasException) {
        _handleGraphQLException(result.exception!);
      }

      final transactionData = result.data?['approveRewardRequest'];
      if (transactionData == null) {
        throw const app_exceptions.ServerException(
            message: 'Approve reward request response is null');
      }

      return RewardTransaction.fromJson(transactionData);
    } catch (e) {
      if (e is app_exceptions.AppException) rethrow;
      throw app_exceptions.NetworkException(
          message: 'Failed to approve/reject reward request: ${e.toString()}');
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
