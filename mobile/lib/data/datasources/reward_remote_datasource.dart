import 'package:dio/dio.dart' as dio_pkg;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:gql/language.dart' as gql_lang;
import 'package:gql_exec/gql_exec.dart';
import 'package:taskflow/core/config/app_config.dart';
import 'package:taskflow/core/config/graphql_client.dart';
import 'package:taskflow/core/errors/exceptions.dart';
import 'package:taskflow/data/models/leaderboard_entry.dart';
import 'package:taskflow/data/models/point_balance.dart';
import 'package:taskflow/data/models/point_transaction_history.dart';
import 'package:taskflow/data/models/request_reward_input.dart';
import 'package:taskflow/data/models/reward.dart';
import 'package:taskflow/data/models/reward_transaction.dart';
import 'package:taskflow/data/models/user_statistics.dart';

class RewardRemoteDataSource {
  RewardRemoteDataSource();

  static const String _rewardTransactionFields = r'''
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
    user {
      id
      username
      email
      avatarUrl
      isAway
      awayUntil
      createdAt
      updatedAt
    }
    reward {
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
  ''';

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
      final gqlRequest = Request(
        operation: Operation(
          document: gql_lang.parseString(query),
          operationName: 'GetGroupRewards',
        ),
        variables: {'groupId': groupId},
      );

      final response = await GraphQLClientConfig.request(gqlRequest);

      if (response.errors != null && response.errors!.isNotEmpty) {
        _handleGraphQLErrors(response.errors!);
      }

      final List<dynamic> rewardsData = response.data?['getGroupRewards'] ?? [];
      return rewardsData.map((json) => Reward.fromJson(json)).toList();
    } on AppException {
      rethrow;
    } catch (e) {
      throw NetworkException(message: 'Failed to fetch rewards: ${e.toString()}');
    }
  }

  // Get user statistics for a group
  Future<UserStatistics> getUserStatistics(String groupId) async {
    const query = r'''
      query GetMyStatistics($groupId: String) {
        myStatistics(groupId: $groupId) {
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
      final gqlRequest = Request(
        operation: Operation(
          document: gql_lang.parseString(query),
          operationName: 'GetMyStatistics',
        ),
        variables: {'groupId': groupId},
      );

      final response = await GraphQLClientConfig.request(gqlRequest);

      if (response.errors != null && response.errors!.isNotEmpty) {
        _handleGraphQLErrors(response.errors!);
      }

      final statsData = response.data?['myStatistics'];
      if (statsData == null) {
        throw const ServerException(message: 'Stats not found');
      }

      return UserStatistics.fromJson(statsData);
    } on AppException {
      rethrow;
    } catch (e) {
      throw NetworkException(message: 'Failed to fetch statistics: ${e.toString()}');
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
      final gqlRequest = Request(
        operation: Operation(
          document: gql_lang.parseString(query),
          operationName: 'GetGroupLeaderboard',
        ),
        variables: {'groupId': groupId},
      );

      final response = await GraphQLClientConfig.request(gqlRequest);

      if (response.errors != null && response.errors!.isNotEmpty) {
        _handleGraphQLErrors(response.errors!);
      }

      final List<dynamic> leaderboardData = response.data?['getGroupLeaderboard'] ?? [];
      return leaderboardData.map((json) => LeaderboardEntry.fromJson(json)).toList();
    } on AppException {
      rethrow;
    } catch (e) {
      throw NetworkException(message: 'Failed to fetch leaderboard: ${e.toString()}');
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
      final gqlRequest = Request(
        operation: Operation(
          document: gql_lang.parseString(mutation),
          operationName: 'RequestReward',
        ),
        variables: {
          'input': {'rewardId': input.rewardId},
        },
      );

      final response = await GraphQLClientConfig.request(gqlRequest);

      if (response.errors != null && response.errors!.isNotEmpty) {
        _handleGraphQLErrors(response.errors!);
      }

      final transactionData = response.data?['requestReward'];
      if (transactionData == null) {
        throw const ServerException(message: 'Request reward response is null');
      }

      // server doesn't return groupId on RewardTransactionType; inject it from the input
      final Map<String, dynamic> transactionMap = Map<String, dynamic>.from(transactionData as Map);
      return RewardTransaction.fromJson(transactionMap);
    } on AppException {
      rethrow;
    } catch (e) {
      throw NetworkException(message: 'Failed to request reward: ${e.toString()}');
    }
  }

  // Get my reward requests
  Future<List<RewardTransaction>> getMyRewardRequests({String? groupId}) async {
    final query = '''
      query GetMyRewardRequests(\$groupId: String) {
        getMyRewardRequests(groupId: \$groupId) {
$_rewardTransactionFields
        }
      }
    ''';

    try {
      final gqlRequest = Request(
        operation: Operation(
          document: gql_lang.parseString(query),
          operationName: 'GetMyRewardRequests',
        ),
        variables: {'groupId': groupId},
      );

      final response = await GraphQLClientConfig.request(gqlRequest);

      if (response.errors != null && response.errors!.isNotEmpty) {
        _handleGraphQLErrors(response.errors!);
      }

      final List<dynamic> requestsData = response.data?['getMyRewardRequests'] ?? [];
      return requestsData.map((json) {
        final Map<String, dynamic> map = Map<String, dynamic>.from(json as Map);
        if (groupId != null) map['groupId'] = groupId;
        return RewardTransaction.fromJson(map);
      }).toList();
    } on AppException {
      rethrow;
    } catch (e) {
      throw NetworkException(message: 'Failed to fetch reward requests: ${e.toString()}');
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
      final gqlRequest = Request(
        operation: Operation(
          document: gql_lang.parseString(query),
          operationName: 'GetPointBalance',
        ),
        variables: {'groupId': groupId},
      );

      final response = await GraphQLClientConfig.request(gqlRequest);

      if (response.errors != null && response.errors!.isNotEmpty) {
        _handleGraphQLErrors(response.errors!);
      }

      final balanceData = response.data?['getPointBalance'];
      if (balanceData == null) {
        throw const ServerException(message: 'Point balance not found');
      }

      return PointBalance.fromJson(balanceData);
    } on AppException {
      rethrow;
    } catch (e) {
      throw NetworkException(message: 'Failed to fetch point balance: ${e.toString()}');
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
      final gqlRequest = Request(
        operation: Operation(
          document: gql_lang.parseString(query),
          operationName: 'GetPointTransactionHistory',
        ),
        variables: {'groupId': groupId, 'limit': limit, 'offset': offset},
      );

      final response = await GraphQLClientConfig.request(gqlRequest);

      if (response.errors != null && response.errors!.isNotEmpty) {
        _handleGraphQLErrors(response.errors!);
      }

      final historyData = response.data?['getPointTransactionHistory'];
      if (historyData == null) {
        throw const ServerException(message: 'Transaction history not found');
      }

      return PointTransactionHistory.fromJson(historyData);
    } on AppException {
      rethrow;
    } catch (e) {
      throw NetworkException(message: 'Failed to fetch transaction history: ${e.toString()}');
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
      final gqlRequest = Request(
        operation: Operation(
          document: gql_lang.parseString(mutation),
          operationName: 'CreateReward',
        ),
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
      );

      final response = await GraphQLClientConfig.request(gqlRequest);

      if (response.errors != null && response.errors!.isNotEmpty) {
        _handleGraphQLErrors(response.errors!);
      }

      final rewardData = response.data?['createReward'];
      if (rewardData == null) {
        throw const ServerException(message: 'Create reward response is null');
      }

      return Reward.fromJson(rewardData);
    } on AppException {
      rethrow;
    } catch (e) {
      throw NetworkException(message: 'Failed to create reward: ${e.toString()}');
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
      final gqlRequest = Request(
        operation: Operation(
          document: gql_lang.parseString(mutation),
          operationName: 'UpdateReward',
        ),
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
      );

      final response = await GraphQLClientConfig.request(gqlRequest);

      if (response.errors != null && response.errors!.isNotEmpty) {
        _handleGraphQLErrors(response.errors!);
      }

      final rewardData = response.data?['updateReward'];
      if (rewardData == null) {
        throw const ServerException(message: 'Update reward response is null');
      }

      return Reward.fromJson(rewardData);
    } on AppException {
      rethrow;
    } catch (e) {
      throw NetworkException(message: 'Failed to update reward: ${e.toString()}');
    }
  }

  // Delete reward (admin only)
  Future<bool> deleteReward({required String rewardId, required String groupId}) async {
    const mutation = r'''
      mutation DeleteReward($rewardId: String!, $groupId: String!) {
        deleteReward(rewardId: $rewardId, groupId: $groupId)
      }
    ''';

    try {
      final gqlRequest = Request(
        operation: Operation(
          document: gql_lang.parseString(mutation),
          operationName: 'DeleteReward',
        ),
        variables: {'rewardId': rewardId, 'groupId': groupId},
      );

      final response = await GraphQLClientConfig.request(gqlRequest);

      if (response.errors != null && response.errors!.isNotEmpty) {
        _handleGraphQLErrors(response.errors!);
      }

      return response.data?['deleteReward'] ?? false;
    } on AppException {
      rethrow;
    } catch (e) {
      throw NetworkException(message: 'Failed to delete reward: ${e.toString()}');
    }
  }

  // Get group reward requests (admin only)
  Future<List<RewardTransaction>> getGroupRewardRequests(String groupId) async {
    final query = '''
      query GetGroupRewardRequests(\$groupId: String!) {
        getGroupRewardRequests(groupId: \$groupId) {
$_rewardTransactionFields
        }
      }
    ''';

    try {
      final gqlRequest = Request(
        operation: Operation(
          document: gql_lang.parseString(query),
          operationName: 'GetGroupRewardRequests',
        ),
        variables: {'groupId': groupId},
      );

      final response = await GraphQLClientConfig.request(gqlRequest);

      if (response.errors != null && response.errors!.isNotEmpty) {
        _handleGraphQLErrors(response.errors!);
      }

      final List<dynamic> requestsData = response.data?['getGroupRewardRequests'] ?? [];
      return requestsData.map((json) {
        final Map<String, dynamic> map = Map<String, dynamic>.from(json as Map);
        map['groupId'] = groupId; // server doesn't expose groupId on RewardTransactionType
        return RewardTransaction.fromJson(map);
      }).toList();
    } on AppException {
      rethrow;
    } catch (e) {
      throw NetworkException(message: 'Failed to fetch group reward requests: ${e.toString()}');
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
      final gqlRequest = Request(
        operation: Operation(
          document: gql_lang.parseString(mutation),
          operationName: 'ApproveRewardRequest',
        ),
        variables: {
          'input': {
            'requestId': requestId,
            'approved': approved,
            if (reason != null) 'reason': reason,
          },
        },
      );

      final response = await GraphQLClientConfig.request(gqlRequest);

      if (response.errors != null && response.errors!.isNotEmpty) {
        _handleGraphQLErrors(response.errors!);
      }

      final transactionData = response.data?['approveRewardRequest'];
      if (transactionData == null) {
        throw const ServerException(message: 'Approve reward request response is null');
      }

      return RewardTransaction.fromJson(transactionData);
    } on AppException {
      rethrow;
    } catch (e) {
      throw NetworkException(message: 'Failed to approve/reject reward request: ${e.toString()}');
    }
  }

  /// Upload a reward image to MinIO and return its public URL.
  Future<String> uploadRewardImage(String filePath) async {
    const storage = FlutterSecureStorage();
    final token = await storage.read(key: AppConfig.accessTokenKey);

    final dio = dio_pkg.Dio();
    final formData = dio_pkg.FormData.fromMap({
      'file': await dio_pkg.MultipartFile.fromFile(
        filePath,
        filename: filePath.split('/').last,
      ),
    });

    try {
      final dioResponse = await dio.post<Map<String, dynamic>>(
        '${AppConfig.apiBaseUrl}/upload/reward-image',
        data: formData,
        options: dio_pkg.Options(
          headers: {
            if (token != null) 'Authorization': 'Bearer $token',
          },
        ),
      );
      final url = dioResponse.data?['url'] as String?;
      if (url == null) throw const ServerException(message: 'Upload response missing url');
      return url;
    } on dio_pkg.DioException catch (e) {
      throw ServerException(message: 'Ошибка загрузки изображения: ${e.message}');
    }
  }

  void _handleGraphQLErrors(List<GraphQLError> errors) {
    if (errors.isEmpty) return;

    final error = errors.first;
    final message = error.message;
    final code = error.extensions?['code'] as String?;

    if (code == 'UNAUTHENTICATED' || code == 'FORBIDDEN') {
      throw AuthException(message: message, code: code);
    } else if (code == 'VALIDATION_ERROR') {
      throw ValidationException(message: message, code: code);
    } else {
      throw ServerException(message: message, code: code);
    }
  }
}
