import 'package:gql/language.dart' as gql_lang;
import 'package:gql_exec/gql_exec.dart';
import 'package:taskflow/core/config/graphql_client.dart';
import 'package:taskflow/core/errors/exceptions.dart' as app_exceptions;
import 'package:taskflow/data/models/create_task_request.dart';
import 'package:taskflow/data/models/task.dart';
import 'package:taskflow/data/models/update_task_request.dart';

class TaskRemoteDataSource {
  TaskRemoteDataSource();

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
      final variables = {'groupId': groupId, if (status != null) 'status': status};
      print('[GetGroupTasks] Request - groupId: $groupId, status: $status');
      print('[GetGroupTasks] Variables: $variables');

      final gqlRequest = Request(
        operation: Operation(
          document: gql_lang.parseString(query + _taskFragment + _userFragment),
          operationName: 'GetGroupTasks',
        ),
        variables: variables,
      );

      final response = await GraphQLClientConfig.request(gqlRequest);

      if (response.errors != null && response.errors!.isNotEmpty) {
        print('[GetGroupTasks] GraphQL Errors: ${response.errors}');
        _handleGraphQLErrors(response.errors!);
      }

      final List<dynamic> tasksData = response.data?['getGroupTasks'] ?? [];
      print('[GetGroupTasks] Success - received ${tasksData.length} tasks');
      return tasksData.map((json) => Task.fromJson(json)).toList();
    } catch (e) {
      print('[GetGroupTasks] Error: $e');
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
      final gqlRequest = Request(
        operation: Operation(
          document: gql_lang.parseString(query + _taskFragment + _userFragment),
          operationName: 'GetUserTasks',
        ),
        variables: {if (status != null) 'status': status},
      );

      final response = await GraphQLClientConfig.request(gqlRequest);

      final List<dynamic> tasksData = response.data?['getUserTasks'] ?? [];
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
      final gqlRequest = Request(
        operation: Operation(
          document: gql_lang.parseString(query + _taskFragment + _userFragment),
          operationName: 'GetTask',
        ),
        variables: {'taskId': taskId},
      );

      final response = await GraphQLClientConfig.request(gqlRequest);

      if (response.errors != null && response.errors!.isNotEmpty) {
        _handleGraphQLErrors(response.errors!);
      }

      final taskData = response.data?['getTask'];
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
      final inputJson = request.toJson();
      print('[CreateTask] Request JSON: $inputJson');

      final gqlRequest = Request(
        operation: Operation(
          document: gql_lang.parseString(mutation + _taskFragment + _userFragment),
          operationName: 'CreateTask',
        ),
        variables: {'input': inputJson},
      );

      final response = await GraphQLClientConfig.request(gqlRequest);

      if (response.errors != null && response.errors!.isNotEmpty) {
        print('[CreateTask] GraphQL Errors: ${response.errors}');
        _handleGraphQLErrors(response.errors!);
      }

      final taskData = response.data?['createTask'];
      if (taskData == null) {
        throw const app_exceptions.ServerException(message: 'Failed to create task');
      }

      return Task.fromJson(taskData);
    } catch (e) {
      print('[CreateTask] Error: $e');
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
      final gqlRequest = Request(
        operation: Operation(
          document: gql_lang.parseString(mutation + _taskFragment + _userFragment),
          operationName: 'UpdateTask',
        ),
        variables: {'taskId': taskId, 'input': request.toJson()},
      );

      final response = await GraphQLClientConfig.request(gqlRequest);

      if (response.errors != null && response.errors!.isNotEmpty) {
        _handleGraphQLErrors(response.errors!);
      }

      final taskData = response.data?['updateTask'];
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
      final gqlRequest = Request(
        operation: Operation(document: gql_lang.parseString(mutation), operationName: 'DeleteTask'),
        variables: {'taskId': taskId},
      );

      final response = await GraphQLClientConfig.request(gqlRequest);

      if (response.errors != null && response.errors!.isNotEmpty) {
        _handleGraphQLErrors(response.errors!);
      }
    } catch (e) {
      if (e is app_exceptions.AppException) rethrow;
      throw app_exceptions.NetworkException(message: 'Failed to delete task: ${e.toString()}');
    }
  }

  Future<Task> claimTask(String taskId) async {
    const mutation = r'''
      mutation ClaimTask($input: ClaimTaskInput!) {
        claimTask(input: $input) {
          ...TaskFields
        }
      }
    ''';

    try {
      final gqlRequest = Request(
        operation: Operation(
          document: gql_lang.parseString(mutation + _taskFragment + _userFragment),
          operationName: 'ClaimTask',
        ),
        variables: {
          'input': {'taskId': taskId},
        },
      );

      final response = await GraphQLClientConfig.request(gqlRequest);

      if (response.errors != null && response.errors!.isNotEmpty) {
        _handleGraphQLErrors(response.errors!);
      }

      final taskData = response.data?['claimTask'];
      if (taskData == null) {
        throw const app_exceptions.ServerException(message: 'Failed to claim task');
      }

      return Task.fromJson(taskData);
    } catch (e) {
      if (e is app_exceptions.AppException) rethrow;
      throw app_exceptions.NetworkException(message: 'Failed to claim task: ${e.toString()}');
    }
  }

  Future<Task> completeTask(String taskId) async {
    const mutation = r'''
      mutation CompleteTask($input: CompleteTaskInput!) {
        completeTask(input: $input) {
          ...TaskFields
        }
      }
    ''';

    try {
      final gqlRequest = Request(
        operation: Operation(
          document: gql_lang.parseString(mutation + _taskFragment + _userFragment),
          operationName: 'CompleteTask',
        ),
        variables: {
          'input': {'taskId': taskId},
        },
      );

      final response = await GraphQLClientConfig.request(gqlRequest);

      if (response.errors != null && response.errors!.isNotEmpty) {
        _handleGraphQLErrors(response.errors!);
      }

      final taskData = response.data?['completeTask'];
      if (taskData == null) {
        throw const app_exceptions.ServerException(message: 'Failed to complete task');
      }

      return Task.fromJson(taskData);
    } catch (e) {
      if (e is app_exceptions.AppException) rethrow;
      throw app_exceptions.NetworkException(message: 'Failed to complete task: ${e.toString()}');
    }
  }

  Future<Task> approveTask(String taskId, bool approved, {String? rejectionReason}) async {
    const mutation = r'''
      mutation ApproveTask($input: ApproveTaskInput!) {
        approveTask(input: $input) {
          ...TaskFields
        }
      }
    ''';

    try {
      final gqlRequest = Request(
        operation: Operation(
          document: gql_lang.parseString(mutation + _taskFragment + _userFragment),
          operationName: 'ApproveTask',
        ),
        variables: {
          'input': {
            'taskId': taskId,
            'approved': approved,
            if (rejectionReason != null) 'rejectionReason': rejectionReason,
          },
        },
      );

      final response = await GraphQLClientConfig.request(gqlRequest);

      if (response.errors != null && response.errors!.isNotEmpty) {
        _handleGraphQLErrors(response.errors!);
      }

      final taskData = response.data?['approveTask'];
      if (taskData == null) {
        throw const app_exceptions.ServerException(message: 'Failed to approve/reject task');
      }

      return Task.fromJson(taskData);
    } catch (e) {
      if (e is app_exceptions.AppException) rethrow;
      throw app_exceptions.NetworkException(
        message: 'Failed to approve/reject task: ${e.toString()}',
      );
    }
  }

  // Error handling

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
