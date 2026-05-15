import 'package:dio/dio.dart' as dio_pkg;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:gql/language.dart' as gql_lang;
import 'package:gql_exec/gql_exec.dart';
import 'package:taskflow/core/config/app_config.dart';
import 'package:taskflow/core/config/graphql_client.dart';
import 'package:taskflow/core/errors/exceptions.dart' as app_exceptions;
import 'package:taskflow/data/models/create_task_request.dart';
import 'package:taskflow/data/models/task.dart';
import 'package:taskflow/data/models/task_attachment.dart';
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
      attachments {
        id
        url
        filename
        fileSize
        mimeType
        uploadedAt
        taskId
        groupId
        uploadedById
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

  Future<List<Task>> getRecurringTemplates(String groupId) async {
    const query = r'''
      query GetRecurringTemplates($groupId: String!) {
        getRecurringTemplates(groupId: $groupId) {
          ...TaskFields
        }
      }
    ''';

    try {
      final gqlRequest = Request(
        operation: Operation(
          document: gql_lang.parseString(query + _taskFragment + _userFragment),
          operationName: 'GetRecurringTemplates',
        ),
        variables: {'groupId': groupId},
      );

      final response = await GraphQLClientConfig.request(gqlRequest);

      if (response.errors != null && response.errors!.isNotEmpty) {
        _handleGraphQLErrors(response.errors!);
      }

      final List<dynamic> tasksData =
          response.data?['getRecurringTemplates'] ?? [];
      return tasksData.map((json) => Task.fromJson(json)).toList();
    } catch (e) {
      if (e is app_exceptions.AppException) rethrow;
      throw app_exceptions.NetworkException(
        message: 'Failed to fetch recurring templates: ${e.toString()}',
      );
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

  /// Upload a file as task attachment via REST and register it via GraphQL.
  /// Returns the created [TaskAttachment].
  Future<TaskAttachment> uploadAndAddAttachment({
    required String taskId,
    required String filePath,
    required String filename,
    required String mimeType,
  }) async {
    const storage = FlutterSecureStorage();
    final token = await storage.read(key: AppConfig.accessTokenKey);

    final dio = dio_pkg.Dio();
    final formData = dio_pkg.FormData.fromMap({
      'file': await dio_pkg.MultipartFile.fromFile(filePath, filename: filename),
    });

    dio_pkg.Response<Map<String, dynamic>> uploadResponse;
    try {
      uploadResponse = await dio.post<Map<String, dynamic>>(
        '${AppConfig.apiBaseUrl}/upload/task-attachment',
        data: formData,
        options: dio_pkg.Options(
          headers: {
            if (token != null) 'Authorization': 'Bearer $token',
          },
        ),
      );
    } on dio_pkg.DioException catch (e) {
      final details = e.response?.data?.toString() ??
          e.error?.toString() ??
          e.type.name;
      throw app_exceptions.ServerException(
        message: 'Ошибка загрузки файла: $details',
      );
    }

    final uploadData = uploadResponse.data;
    if (uploadData == null) {
      throw const app_exceptions.ServerException(message: 'Empty upload response');
    }

    final url = uploadData['url'] as String;
    final fileSize = (uploadData['fileSize'] as num).toInt();
    final respMimeType = uploadData['mimeType'] as String? ?? mimeType;

    // Register the attachment via GraphQL
    const mutation = r'''
      mutation AddTaskAttachment($input: AddTaskAttachmentInput!) {
        addTaskAttachment(input: $input) {
          id
          url
          filename
          fileSize
          mimeType
          uploadedAt
          taskId
          groupId
          uploadedById
        }
      }
    ''';

    final gqlRequest = Request(
      operation: Operation(
        document: gql_lang.parseString(mutation),
        operationName: 'AddTaskAttachment',
      ),
      variables: {
        'input': {
          'taskId': taskId,
          'url': url,
          'filename': filename,
          'fileSize': fileSize,
          'mimeType': respMimeType,
        },
      },
    );

    final response = await GraphQLClientConfig.request(gqlRequest);
    if (response.errors != null && response.errors!.isNotEmpty) {
      _handleGraphQLErrors(response.errors!);
    }

    final data = response.data?['addTaskAttachment'];
    if (data == null) {
      throw const app_exceptions.ServerException(message: 'Failed to register attachment');
    }

    return TaskAttachment.fromJson(data as Map<String, dynamic>);
  }

  /// Delete a task attachment.
  Future<void> deleteTaskAttachment(String attachmentId) async {
    const mutation = r'''
      mutation DeleteTaskAttachment($attachmentId: String!) {
        deleteTaskAttachment(attachmentId: $attachmentId)
      }
    ''';

    final gqlRequest = Request(
      operation: Operation(
        document: gql_lang.parseString(mutation),
        operationName: 'DeleteTaskAttachment',
      ),
      variables: {'attachmentId': attachmentId},
    );

    final response = await GraphQLClientConfig.request(gqlRequest);
    if (response.errors != null && response.errors!.isNotEmpty) {
      _handleGraphQLErrors(response.errors!);
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
