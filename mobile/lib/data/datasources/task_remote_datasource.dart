import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:mobile/core/errors/exceptions.dart' as app_exceptions;
import 'package:mobile/data/models/create_task_request.dart';
import 'package:mobile/data/models/task.dart';
import 'package:mobile/data/models/update_task_request.dart';

class TaskRemoteDataSource {
  final GraphQLClient client;

  TaskRemoteDataSource(this.client);

  // GraphQL Fragments
  // Backend returns GroupMemberUserType for assignee/createdBy in TaskType
  static const String _userFragment = r'''
    fragment TaskAssigneeFields on GroupMemberUserType {
      id
      username
      avatarUrl
      isAway
      awayUntil
    }
  ''';

  static const String _taskFragment = r'''
    fragment TaskFields on TaskType {
      id
      title
      description
      deadline
      priority
      status
      points
      requiresApproval
      isRecurring
      recurrenceRule
      rotationType
      weight
      wasClaimedFromPool
      rejectionReason
      createdAt
      completedAt
      groupId
      createdById
      assigneeId
      assignee {
        ...TaskAssigneeFields
      }
      createdBy {
        ...TaskAssigneeFields
      }
    }
  ''';

  // Queries

  Future<List<Task>> getGroupTasks(String groupId, {String? status}) async {
    const query = r'''
      query GetGroupTasks($groupId: String!, $status: String) {
        getGroupTasks(groupId: $groupId, status: $status) {
          ...TaskFields
        }
      }
    ''';

    try {
      final result = await client.query(
        QueryOptions(
          document: gql(query + _taskFragment + _userFragment),
          variables: {'groupId': groupId, if (status != null) 'status': status},
          fetchPolicy: FetchPolicy.networkOnly,
        ),
      );

      if (result.hasException) {
        _handleGraphQLException(result.exception!);
      }

      final List<dynamic> tasksData = result.data?['getGroupTasks'] ?? [];
      return tasksData.map((json) => Task.fromJson(json)).toList();
    } catch (e) {
      if (e is app_exceptions.AppException) rethrow;
      throw app_exceptions.NetworkException(
        message: 'Failed to fetch group tasks: ${e.toString()}',
      );
    }
  }

  Future<List<Task>> getUserTasks({String? status}) async {
    const query = r'''
      query GetUserTasks($status: String) {
        getUserTasks(status: $status) {
          ...TaskFields
        }
      }
    ''';

    try {
      final result = await client.query(
        QueryOptions(
          document: gql(query + _taskFragment + _userFragment),
          variables: {if (status != null) 'status': status},
          fetchPolicy: FetchPolicy.networkOnly,
        ),
      );

      if (result.hasException) {
        _handleGraphQLException(result.exception!);
      }

      final List<dynamic> tasksData = result.data?['getUserTasks'] ?? [];
      return tasksData.map((json) => Task.fromJson(json)).toList();
    } catch (e) {
      if (e is app_exceptions.AppException) rethrow;
      throw app_exceptions.NetworkException(message: 'Failed to fetch user tasks: ${e.toString()}');
    }
  }

  Future<Task> getTask(String taskId) async {
    const query = r'''
      query GetTask($taskId: String!) {
        getTask(taskId: $taskId) {
          ...TaskFields
        }
      }
    ''';

    try {
      final result = await client.query(
        QueryOptions(
          document: gql(query + _taskFragment + _userFragment),
          variables: {'taskId': taskId},
          fetchPolicy: FetchPolicy.networkOnly,
        ),
      );

      if (result.hasException) {
        _handleGraphQLException(result.exception!);
      }

      final taskData = result.data?['getTask'];
      if (taskData == null) {
        throw const app_exceptions.ServerException(message: 'Task not found');
      }

      return Task.fromJson(taskData);
    } catch (e) {
      if (e is app_exceptions.AppException) rethrow;
      throw app_exceptions.NetworkException(message: 'Failed to fetch task: ${e.toString()}');
    }
  }

  // Mutations

  Future<Task> createTask(CreateTaskRequest request) async {
    const mutation = r'''
      mutation CreateTask($input: CreateTaskInput!) {
        createTask(input: $input) {
          ...TaskFields
        }
      }
    ''';

    try {
      final result = await client.mutate(
        MutationOptions(
          document: gql(mutation + _taskFragment + _userFragment),
          variables: {'input': request.toJson()},
        ),
      );

      if (result.hasException) {
        _handleGraphQLException(result.exception!);
      }

      final taskData = result.data?['createTask'];
      if (taskData == null) {
        throw const app_exceptions.ServerException(message: 'Failed to create task');
      }

      return Task.fromJson(taskData);
    } catch (e) {
      if (e is app_exceptions.AppException) rethrow;
      throw app_exceptions.NetworkException(message: 'Failed to create task: ${e.toString()}');
    }
  }

  Future<Task> updateTask(String taskId, UpdateTaskRequest request) async {
    const mutation = r'''
      mutation UpdateTask($taskId: String!, $input: UpdateTaskInput!) {
        updateTask(taskId: $taskId, input: $input) {
          ...TaskFields
        }
      }
    ''';

    try {
      final result = await client.mutate(
        MutationOptions(
          document: gql(mutation + _taskFragment + _userFragment),
          variables: {'taskId': taskId, 'input': request.toJson()},
        ),
      );

      if (result.hasException) {
        _handleGraphQLException(result.exception!);
      }

      final taskData = result.data?['updateTask'];
      if (taskData == null) {
        throw const app_exceptions.ServerException(message: 'Failed to update task');
      }

      return Task.fromJson(taskData);
    } catch (e) {
      if (e is app_exceptions.AppException) rethrow;
      throw app_exceptions.NetworkException(message: 'Failed to update task: ${e.toString()}');
    }
  }

  Future<void> deleteTask(String taskId) async {
    const mutation = r'''
      mutation DeleteTask($taskId: String!) {
        deleteTask(taskId: $taskId)
      }
    ''';

    try {
      final result = await client.mutate(
        MutationOptions(document: gql(mutation), variables: {'taskId': taskId}),
      );

      if (result.hasException) {
        _handleGraphQLException(result.exception!);
      }
    } catch (e) {
      if (e is app_exceptions.AppException) rethrow;
      throw app_exceptions.NetworkException(message: 'Failed to delete task: ${e.toString()}');
    }
  }

  Future<Task> claimTask(String taskId) async {
    const mutation = r'''
      mutation ClaimTask($taskId: String!) {
        claimTask(taskId: $taskId) {
          ...TaskFields
        }
      }
    ''';

    try {
      final result = await client.mutate(
        MutationOptions(
          document: gql(mutation + _taskFragment + _userFragment),
          variables: {'taskId': taskId},
        ),
      );

      if (result.hasException) {
        _handleGraphQLException(result.exception!);
      }

      final taskData = result.data?['claimTask'];
      if (taskData == null) {
        throw const app_exceptions.ServerException(message: 'Failed to claim task');
      }

      return Task.fromJson(taskData);
    } catch (e) {
      if (e is app_exceptions.AppException) rethrow;
      throw app_exceptions.NetworkException(message: 'Failed to claim task: ${e.toString()}');
    }
  }

  Future<Task> unclaimTask(String taskId) async {
    const mutation = r'''
      mutation UnclaimTask($taskId: String!) {
        unclaimTask(taskId: $taskId) {
          ...TaskFields
        }
      }
    ''';

    try {
      final result = await client.mutate(
        MutationOptions(
          document: gql(mutation + _taskFragment + _userFragment),
          variables: {'taskId': taskId},
        ),
      );

      if (result.hasException) {
        _handleGraphQLException(result.exception!);
      }

      final taskData = result.data?['unclaimTask'];
      if (taskData == null) {
        throw const app_exceptions.ServerException(message: 'Failed to unclaim task');
      }

      return Task.fromJson(taskData);
    } catch (e) {
      if (e is app_exceptions.AppException) rethrow;
      throw app_exceptions.NetworkException(message: 'Failed to unclaim task: ${e.toString()}');
    }
  }

  Future<Task> completeTask(String taskId) async {
    const mutation = r'''
      mutation CompleteTask($taskId: String!) {
        completeTask(taskId: $taskId) {
          ...TaskFields
        }
      }
    ''';

    try {
      final result = await client.mutate(
        MutationOptions(
          document: gql(mutation + _taskFragment + _userFragment),
          variables: {'taskId': taskId},
        ),
      );

      if (result.hasException) {
        _handleGraphQLException(result.exception!);
      }

      final taskData = result.data?['completeTask'];
      if (taskData == null) {
        throw const app_exceptions.ServerException(message: 'Failed to complete task');
      }

      return Task.fromJson(taskData);
    } catch (e) {
      if (e is app_exceptions.AppException) rethrow;
      throw app_exceptions.NetworkException(message: 'Failed to complete task: ${e.toString()}');
    }
  }

  Future<Task> approveTask(String taskId) async {
    const mutation = r'''
      mutation ApproveTask($taskId: String!) {
        approveTask(taskId: $taskId) {
          ...TaskFields
        }
      }
    ''';

    try {
      final result = await client.mutate(
        MutationOptions(
          document: gql(mutation + _taskFragment + _userFragment),
          variables: {'taskId': taskId},
        ),
      );

      if (result.hasException) {
        _handleGraphQLException(result.exception!);
      }

      final taskData = result.data?['approveTask'];
      if (taskData == null) {
        throw const app_exceptions.ServerException(message: 'Failed to approve task');
      }

      return Task.fromJson(taskData);
    } catch (e) {
      if (e is app_exceptions.AppException) rethrow;
      throw app_exceptions.NetworkException(message: 'Failed to approve task: ${e.toString()}');
    }
  }

  Future<Task> rejectTask(String taskId, String reason) async {
    const mutation = r'''
      mutation RejectTask($taskId: String!, $reason: String!) {
        rejectTask(taskId: $taskId, reason: $reason) {
          ...TaskFields
        }
      }
    ''';

    try {
      final result = await client.mutate(
        MutationOptions(
          document: gql(mutation + _taskFragment + _userFragment),
          variables: {'taskId': taskId, 'reason': reason},
        ),
      );

      if (result.hasException) {
        _handleGraphQLException(result.exception!);
      }

      final taskData = result.data?['rejectTask'];
      if (taskData == null) {
        throw const app_exceptions.ServerException(message: 'Failed to reject task');
      }

      return Task.fromJson(taskData);
    } catch (e) {
      if (e is app_exceptions.AppException) rethrow;
      throw app_exceptions.NetworkException(message: 'Failed to reject task: ${e.toString()}');
    }
  }

  // Error handling

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
