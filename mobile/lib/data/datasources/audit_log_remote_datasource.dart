import 'package:gql/language.dart' as gql_lang;
import 'package:gql_exec/gql_exec.dart';
import 'package:taskflow/core/config/graphql_client.dart';
import 'package:taskflow/core/errors/exceptions.dart' as app_exceptions;
import 'package:taskflow/data/models/audit_log.dart';

class AuditLogRemoteDataSource {
  AuditLogRemoteDataSource();

  static const String _auditLogUserFragment = r'''
    fragment AuditLogUserFields on AuditLogUserType {
      id
      username
      email
    }
  ''';

  static const String _auditLogFragment = r'''
    fragment AuditLogFields on AuditLogType {
      id
      action
      entityType
      entityId
      oldValues
      newValues
      performedAt
      userId
      user {
        ...AuditLogUserFields
      }
      performedBy {
        ...AuditLogUserFields
      }
    }
  ''';

  String get _document => _auditLogFragment + _auditLogUserFragment;

  Future<AuditLogList> getAuditLogs({GetAuditLogsInput? input}) async {
    const query = r'''
      query GetAuditLogs($input: GetAuditLogsInput) {
        getAuditLogs(input: $input) {
          logs {
            ...AuditLogFields
          }
          total
          limit
          offset
        }
      }
    ''';

    try {
      final gqlRequest = Request(
        operation: Operation(
          document: gql_lang.parseString(query + _document),
          operationName: 'GetAuditLogs',
        ),
        variables: {if (input != null) 'input': input.toJson()},
      );

      final response = await GraphQLClientConfig.request(gqlRequest);
      if (response.errors != null && response.errors!.isNotEmpty) {
        _handleGraphQLErrors(response.errors!);
      }

      final data = response.data?['getAuditLogs'];
      if (data == null) {
        throw const app_exceptions.ServerException(message: 'Failed to fetch audit logs');
      }

      return AuditLogList.fromJson(data as Map<String, dynamic>);
    } catch (e) {
      if (e is app_exceptions.AppException) rethrow;
      throw app_exceptions.NetworkException(message: 'Failed to fetch audit logs: $e');
    }
  }

  Future<List<AuditLog>> getTaskAuditLog(String taskId) async {
    const query = r'''
      query GetTaskAuditLog($taskId: String!) {
        getTaskAuditLog(taskId: $taskId) {
          ...AuditLogFields
        }
      }
    ''';

    return _fetchLogList(query, 'getTaskAuditLog', {'taskId': taskId});
  }

  Future<List<AuditLog>> getGroupAuditLog(String groupId) async {
    const query = r'''
      query GetGroupAuditLog($groupId: String!) {
        getGroupAuditLog(groupId: $groupId) {
          ...AuditLogFields
        }
      }
    ''';

    return _fetchLogList(query, 'getGroupAuditLog', {'groupId': groupId});
  }

  Future<List<AuditLog>> getMyAuditLogs({int limit = 100}) async {
    const query = r'''
      query GetMyAuditLogs($limit: Float) {
        getMyAuditLogs(limit: $limit) {
          ...AuditLogFields
        }
      }
    ''';

    return _fetchLogList(query, 'getMyAuditLogs', {'limit': limit.toDouble()});
  }

  Future<List<AuditLog>> _fetchLogList(
    String query,
    String resultFieldName,
    Map<String, dynamic> variables,
  ) async {
    try {
      final gqlRequest = Request(
        operation: Operation(
          document: gql_lang.parseString(query + _document),
          operationName: null,
        ),
        variables: variables,
      );

      final response = await GraphQLClientConfig.request(gqlRequest);
      if (response.errors != null && response.errors!.isNotEmpty) {
        _handleGraphQLErrors(response.errors!);
      }

      final data = response.data?[resultFieldName] as List<dynamic>? ?? [];
      return data.map((json) => AuditLog.fromJson(json as Map<String, dynamic>)).toList();
    } catch (e) {
      if (e is app_exceptions.AppException) rethrow;
      throw app_exceptions.NetworkException(message: 'Failed to fetch audit logs: $e');
    }
  }

  void _handleGraphQLErrors(List<GraphQLError> errors) {
    if (errors.isEmpty) return;

    final error = errors.first;
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
}
