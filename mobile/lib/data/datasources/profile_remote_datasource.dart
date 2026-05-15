import 'package:dio/dio.dart' as dio_pkg;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:gql/language.dart' as gql_lang;
import 'package:gql_exec/gql_exec.dart';
import 'package:taskflow/core/config/app_config.dart';
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

  /// Update user profile (username, avatarUrl, away status) via GraphQL updateUser mutation.
  Future<User> updateProfile({
    String? username,
    String? avatarUrl,
    bool? isAway,
    DateTime? awayUntil,
  }) async {
    const mutation = r'''
      mutation UpdateUser($input: UpdateUserInput!) {
        updateUser(input: $input) {
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

    final input = <String, dynamic>{
      if (username != null) 'username': username,
      if (avatarUrl != null) 'avatarUrl': avatarUrl,
    };

    try {
      final gqlRequest = Request(
        operation: Operation(
          document: gql_lang.parseString(mutation),
          operationName: 'UpdateUser',
        ),
        variables: {'input': input},
      );

      final response = await GraphQLClientConfig.request(gqlRequest);

      if (response.errors != null && response.errors!.isNotEmpty) {
        _handleGraphQLErrors(response.errors!);
      }

      final data = response.data?['updateUser'];
      if (data == null) {
        throw const ServerException(message: 'Failed to update profile');
      }

      return User.fromJson(data);
    } on AppException {
      rethrow;
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  /// Upload avatar image to MinIO via REST, then update the user's avatarUrl.
  /// Returns the new avatar URL.
  Future<String> uploadAvatar(String filePath) async {
    const storage = FlutterSecureStorage();
    final token = await storage.read(key: AppConfig.accessTokenKey);

    final dio = dio_pkg.Dio();
    final formData = dio_pkg.FormData.fromMap({
      'file': await dio_pkg.MultipartFile.fromFile(filePath, filename: filePath.split('/').last),
    });

    try {
      print('[Avatar] Uploading to: ${AppConfig.apiBaseUrl}/upload/avatar');
      print('[Avatar] File path: $filePath');
      print('[Avatar] Token present: ${token != null}');

      final response = await dio.post<Map<String, dynamic>>(
        '${AppConfig.apiBaseUrl}/upload/avatar',
        data: formData,
        options: dio_pkg.Options(
          headers: {
            if (token != null) 'Authorization': 'Bearer $token',
          },
        ),
      );

      print('[Avatar] Response status: ${response.statusCode}');
      print('[Avatar] Response data: ${response.data}');

      final url = response.data?['url'] as String?;
      if (url == null) {
        throw const ServerException(message: 'Upload response missing url');
      }

      print('[Avatar] URL from server: $url');

      // Persist the new avatarUrl in the user profile
      await updateProfile(avatarUrl: url);

      print('[Avatar] Profile updated with new URL');
      return url;
    } on dio_pkg.DioException catch (e) {
      final details = e.response?.data?.toString() ??
          e.error?.toString() ??
          e.type.name;
      print('[Avatar] DioException: type=${e.type}, status=${e.response?.statusCode}, details=$details');
      throw ServerException(message: 'Ошибка загрузки аватара: $details');
    } on AppException {
      rethrow;
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  /// Change user password via GraphQL changePassword mutation.
  Future<void> changePassword({
    required String oldPassword,
    required String newPassword,
  }) async {
    const mutation = r'''
      mutation ChangePassword($input: ChangePasswordInput!) {
        changePassword(input: $input)
      }
    ''';

    try {
      final gqlRequest = Request(
        operation: Operation(
          document: gql_lang.parseString(mutation),
          operationName: 'ChangePassword',
        ),
        variables: {
          'input': {
            'oldPassword': oldPassword,
            'newPassword': newPassword,
          },
        },
      );

      final response = await GraphQLClientConfig.request(gqlRequest);

      if (response.errors != null && response.errors!.isNotEmpty) {
        _handleGraphQLErrors(response.errors!);
      }
    } on AppException {
      rethrow;
    } catch (e) {
      throw ServerException(message: e.toString());
    }
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
