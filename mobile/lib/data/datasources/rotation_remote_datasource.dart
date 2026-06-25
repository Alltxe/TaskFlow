import 'package:gql/language.dart' as gql_lang;
import 'package:gql_exec/gql_exec.dart';
import 'package:taskflow/core/config/graphql_client.dart';
import 'package:taskflow/core/errors/exceptions.dart';
import 'package:taskflow/data/models/rotation.dart';

class RotationRemoteDataSource {
  RotationRemoteDataSource();

  Future<List<RotationScheduleEntry>> getRotationSchedule(String groupId) async {
    const query = r'''
      query GetRotationSchedule($groupId: String!) {
        getRotationSchedule(groupId: $groupId) {
          taskId
          taskTitle
          userId
          username
          avatarUrl
          scheduledDate
          rotationType
          priority
          points
        }
      }
    ''';

    try {
      final gqlRequest = Request(
        operation: Operation(
          document: gql_lang.parseString(query),
          operationName: 'GetRotationSchedule',
        ),
        variables: {'groupId': groupId},
      );

      final response = await GraphQLClientConfig.request(gqlRequest);

      if (response.errors != null && response.errors!.isNotEmpty) {
        _handleGraphQLErrors(response.errors!);
      }

      final List<dynamic> data = response.data?['getRotationSchedule'] ?? [];
      return data.map((e) => RotationScheduleEntry.fromJson(e)).toList();
    } on AppException {
      rethrow;
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  Future<RotationHistoryResult> getRotationHistory(
    String groupId, {
    int limit = 50,
    int offset = 0,
  }) async {
    const query = r'''
      query GetRotationHistory($groupId: String!, $limit: Int, $offset: Int) {
        getRotationHistory(groupId: $groupId, limit: $limit, offset: $offset) {
          items {
            taskId
            taskTitle
            userId
            username
            avatarUrl
            assignedAt
            completedAt
            status
            rotationType
            pointsEarned
          }
          total
        }
      }
    ''';

    try {
      final gqlRequest = Request(
        operation: Operation(
          document: gql_lang.parseString(query),
          operationName: 'GetRotationHistory',
        ),
        variables: {'groupId': groupId, 'limit': limit, 'offset': offset},
      );

      final response = await GraphQLClientConfig.request(gqlRequest);

      if (response.errors != null && response.errors!.isNotEmpty) {
        _handleGraphQLErrors(response.errors!);
      }

      final data = response.data?['getRotationHistory'];
      if (data == null) {
        throw const ServerException(message: 'Failed to fetch rotation history');
      }

      return RotationHistoryResult(
        items: (data['items'] as List<dynamic>)
            .map((e) => RotationHistoryEntry.fromJson(e))
            .toList(),
        total: (data['total'] as num).toInt(),
      );
    } on AppException {
      rethrow;
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  Future<RotationPattern> getRotationPattern(String groupId) async {
    const query = r'''
      query GetRotationPattern($groupId: String!) {
        getRotationPattern(groupId: $groupId) {
          rotationType
          currentCycle
          currentCycleIndex
        }
      }
    ''';

    try {
      final gqlRequest = Request(
        operation: Operation(
          document: gql_lang.parseString(query),
          operationName: 'GetRotationPattern',
        ),
        variables: {'groupId': groupId},
      );

      final response = await GraphQLClientConfig.request(gqlRequest);

      if (response.errors != null && response.errors!.isNotEmpty) {
        _handleGraphQLErrors(response.errors!);
      }

      final data = response.data?['getRotationPattern'];
      if (data == null) {
        throw const ServerException(message: 'Failed to fetch rotation pattern');
      }

      return RotationPattern.fromJson(data);
    } on AppException {
      rethrow;
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  void _handleGraphQLErrors(List<dynamic> errors) {
    final message = errors.map((e) => e.message).join(', ');
    if (message.toLowerCase().contains('unauthorized') ||
        message.toLowerCase().contains('unauthenticated')) {
      throw AuthException(message: message);
    }
    throw ServerException(message: message);
  }
}
