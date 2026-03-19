import 'package:gql/language.dart' as gql_lang;
import 'package:gql_exec/gql_exec.dart';
import 'package:taskflow/core/config/graphql_client.dart';
import 'package:taskflow/core/errors/exceptions.dart';
import 'package:taskflow/data/models/group_summary.dart';
import 'package:taskflow/data/models/user.dart';
import 'package:taskflow/data/models/user_statistics.dart';

/// Remote data source for user profile operations via GraphQL API
class ProfileRemoteDataSource {
  ProfileRemoteDataSource();

  /// Get current user profile (uses existing 'me' query)
  Future<User> getCurrentUserProfile() async {
    const query = r'''
      query GetCurrentUser {
        me {
          id
          email
          username
          avatarUrl
          isAway
          awayUntil
          createdAt
          updatedAt
        }
      }
    ''';

    try {
      final gqlRequest = Request(
        operation: Operation(
          document: gql_lang.parseString(query),
          operationName: 'GetCurrentUser',
        ),
      );

      final response = await GraphQLClientConfig.request(gqlRequest);

      if (response.errors != null && response.errors!.isNotEmpty) {
        _handleGraphQLErrors(response.errors!);
      }

      final data = response.data?['me'];
      if (data == null) {
        throw const ServerException(message: 'Failed to fetch user profile');
      }

      return User.fromJson(data);
    } on AppException {
      rethrow;
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  /// Get user statistics
  Future<UserStatistics> getUserStatistics({String? groupId}) async {
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

      final data = response.data?['myStatistics'];
      if (data == null) {
        throw const ServerException(message: 'Failed to fetch statistics');
      }

      return UserStatistics.fromJson(data);
    } on AppException {
      rethrow;
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  /// Get user's groups
  Future<List<GroupSummary>> getUserGroups() async {
    const query = r'''
      query GetUserGroups {
        getUserGroups {
          id
          name
          description
          gamificationEnabled
          createdAt
        }
      }
    ''';

    try {
      final gqlRequest = Request(
        operation: Operation(document: gql_lang.parseString(query), operationName: 'GetUserGroups'),
      );

      final response = await GraphQLClientConfig.request(gqlRequest);

      if (response.errors != null && response.errors!.isNotEmpty) {
        _handleGraphQLErrors(response.errors!);
      }

      final List<dynamic> groupsData = response.data?['getUserGroups'] ?? [];

      // We need to get member role separately or transform the data
      // For now, we'll return groups with default 'participant' role
      return groupsData.map((json) {
        return GroupSummary(
          id: json['id'],
          name: json['name'],
          description: json['description'],
          role: 'participant', // TODO: Get actual role from GroupMember query
          gamificationEnabled: json['gamificationEnabled'],
          joinedAt: DateTime.parse(json['createdAt']),
        );
      }).toList();
    } on AppException {
      rethrow;
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  /// Update user profile (username, avatar, away status)
  /// Note: Backend doesn't have updateProfile mutation yet,
  /// this is a placeholder for future implementation
  Future<User> updateProfile({
    String? username,
    String? avatarUrl,
    bool? isAway,
    DateTime? awayUntil,
  }) async {
    // TODO: Implement when backend adds updateProfile mutation
    throw const ServerException(message: 'Profile update not yet implemented in backend');
  }

  /// Upload avatar image
  /// Note: Backend doesn't have avatar upload endpoint yet,
  /// this is a placeholder for future implementation
  Future<String> uploadAvatar(String filePath) async {
    // TODO: Implement when backend adds file upload endpoint
    throw const ServerException(message: 'Avatar upload not yet implemented in backend');
  }

  void _handleGraphQLErrors(List<GraphQLError> errors) {
    if (errors.isEmpty) return;

    final error = errors.first;
    final message = error.message;

    if (message.toLowerCase().contains('unauthorized') ||
        message.toLowerCase().contains('unauthenticated')) {
      throw const AuthException(message: 'Session expired');
    }

    throw ServerException(message: message);
  }
}
