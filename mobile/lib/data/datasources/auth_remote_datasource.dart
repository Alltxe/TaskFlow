import 'package:gql/language.dart' as gql_lang;
import 'package:gql_exec/gql_exec.dart';
import 'package:taskflow/core/config/graphql_client.dart';
import 'package:taskflow/core/errors/exceptions.dart';
import 'package:taskflow/data/models/auth_response.dart';
import 'package:taskflow/data/models/auth_tokens.dart';
import 'package:taskflow/data/models/login_request.dart';
import 'package:taskflow/data/models/register_request.dart';
import 'package:taskflow/data/models/user.dart';

/// Remote data source for authentication via GraphQL
class AuthRemoteDataSource {
  AuthRemoteDataSource();

  /// Login with email and password
  Future<AuthResponse> login(LoginRequest request) async {
    const mutationString = r'''
      mutation Login($email: String!, $password: String!) {
        login(input: {email: $email, password: $password}) {
          accessToken
          refreshToken
          user {
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
      }
    ''';

    try {
      final gqlRequest = Request(
        operation: Operation(
          document: gql_lang.parseString(mutationString),
          operationName: 'Login',
        ),
        variables: {'email': request.email, 'password': request.password},
      );

      final response = await GraphQLClientConfig.request(gqlRequest);

      // Check for partial errors (when data exists but has errors)
      if (response.errors != null && response.errors!.isNotEmpty) {
        final errorMessage = response.errors!.map((e) => e.message).join(', ');
        throw ServerException(message: errorMessage);
      }

      // Check for data
      final data = response.data?['login'];
      if (data == null) {
        throw const ServerException(message: 'Login failed: No data returned from server');
      }

      // Validate required fields
      if (data['accessToken'] == null || data['refreshToken'] == null || data['user'] == null) {
        throw const ServerException(message: 'Login failed: Incomplete data received from server');
      }

      return AuthResponse(
        user: User.fromJson(data['user'] as Map<String, dynamic>),
        tokens: AuthTokens(
          accessToken: data['accessToken'] as String,
          refreshToken: data['refreshToken'] as String,
          accessTokenExpiresAt: DateTime.now().add(const Duration(minutes: 15)),
          refreshTokenExpiresAt: DateTime.now().add(const Duration(days: 7)),
        ),
      );
    } on AppException {
      // Re-throw known exceptions
      rethrow;
    } on FormatException catch (e) {
      throw ServerException(message: 'Invalid server response format: ${e.message}');
    } catch (e) {
      throw ServerException(message: 'Login failed: ${e.toString()}');
    }
  }

  /// Register new user
  Future<AuthResponse> register(RegisterRequest request) async {
    const mutationString = r'''
      mutation Register($email: String!, $username: String!, $password: String!) {
        register(input: {email: $email, username: $username, password: $password}) {
          accessToken
          refreshToken
          user {
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
      }
    ''';

    try {
      final gqlRequest = Request(
        operation: Operation(
          document: gql_lang.parseString(mutationString),
          operationName: 'Register',
        ),
        variables: {
          'email': request.email,
          'username': request.username,
          'password': request.password,
        },
      );

      final response = await GraphQLClientConfig.request(gqlRequest);

      // Check for partial errors (when data exists but has errors)
      if (response.errors != null && response.errors!.isNotEmpty) {
        final errorMessage = response.errors!.map((e) => e.message).join(', ');
        throw ServerException(message: errorMessage);
      }

      final data = response.data?['register'];
      if (data == null) {
        throw const ServerException(message: 'Registration failed: No data returned');
      }

      return AuthResponse(
        user: User.fromJson(data['user'] as Map<String, dynamic>),
        tokens: AuthTokens(
          accessToken: data['accessToken'] as String,
          refreshToken: data['refreshToken'] as String,
          accessTokenExpiresAt: DateTime.now().add(const Duration(minutes: 15)),
          refreshTokenExpiresAt: DateTime.now().add(const Duration(days: 7)),
        ),
      );
    } on AppException {
      rethrow;
    } catch (e) {
      throw ServerException(message: 'Registration error: ${e.toString()}');
    }
  }

  /// Refresh access token using refresh token
  Future<AuthTokens> refreshToken(String refreshToken) async {
    const mutationString = r'''
      mutation RefreshToken($refreshToken: String!) {
        refreshToken(input: {refreshToken: $refreshToken}) {
          accessToken
          refreshToken
          user {
            id
            email
            username
          }
        }
      }
    ''';

    try {
      final gqlRequest = Request(
        operation: Operation(
          document: gql_lang.parseString(mutationString),
          operationName: 'RefreshToken',
        ),
        variables: {'refreshToken': refreshToken},
      );

      final response = await GraphQLClientConfig.request(gqlRequest);

      // Check for partial errors
      if (response.errors != null && response.errors!.isNotEmpty) {
        final errorMessage = response.errors!.map((e) => e.message).join(', ');
        throw ServerException(message: errorMessage);
      }

      final data = response.data?['refreshToken'];
      if (data == null) {
        throw const ServerException(message: 'Token refresh failed: No data returned');
      }

      return AuthTokens(
        accessToken: data['accessToken'] as String,
        refreshToken: data['refreshToken'] as String,
        accessTokenExpiresAt: DateTime.now().add(const Duration(minutes: 15)),
        refreshTokenExpiresAt: DateTime.now().add(const Duration(days: 7)),
      );
    } on AppException {
      rethrow;
    } catch (e) {
      throw ServerException(message: 'Token refresh error: ${e.toString()}');
    }
  }

  /// Logout - invalidate refresh token
  Future<void> logout(String refreshToken) async {
    const mutationString = r'''
      mutation Logout($refreshToken: String!) {
        logout(refreshToken: $refreshToken)
      }
    ''';

    try {
      final gqlRequest = Request(
        operation: Operation(
          document: gql_lang.parseString(mutationString),
          operationName: 'Logout',
        ),
        variables: {'refreshToken': refreshToken},
      );

      final response = await GraphQLClientConfig.request(gqlRequest);

      // Check for partial errors
      if (response.errors != null && response.errors!.isNotEmpty) {
        final errorMessage = response.errors!.map((e) => e.message).join(', ');
        throw ServerException(message: errorMessage);
      }
    } on AppException {
      rethrow;
    } catch (e) {
      throw ServerException(message: 'Logout error: ${e.toString()}');
    }
  }

  /// Logout from all devices
  Future<void> logoutAll() async {
    const mutationString = r'''
      mutation LogoutAll {
        logoutAll
      }
    ''';

    try {
      final gqlRequest = Request(
        operation: Operation(
          document: gql_lang.parseString(mutationString),
          operationName: 'LogoutAll',
        ),
      );

      final response = await GraphQLClientConfig.request(gqlRequest);

      // Check for partial errors
      if (response.errors != null && response.errors!.isNotEmpty) {
        final errorMessage = response.errors!.map((e) => e.message).join(', ');
        throw ServerException(message: errorMessage);
      }
    } on AppException {
      rethrow;
    } catch (e) {
      throw ServerException(message: 'Logout all error: ${e.toString()}');
    }
  }

  /// Change password
  Future<void> changePassword(String oldPassword, String newPassword) async {
    const mutationString = r'''
      mutation ChangePassword($oldPassword: String!, $newPassword: String!) {
        changePassword(input: {oldPassword: $oldPassword, newPassword: $newPassword})
      }
    ''';

    try {
      final gqlRequest = Request(
        operation: Operation(
          document: gql_lang.parseString(mutationString),
          operationName: 'ChangePassword',
        ),
        variables: {'oldPassword': oldPassword, 'newPassword': newPassword},
      );

      final response = await GraphQLClientConfig.request(gqlRequest);

      // Check for partial errors
      if (response.errors != null && response.errors!.isNotEmpty) {
        final errorMessage = response.errors!.map((e) => e.message).join(', ');
        throw ServerException(message: errorMessage);
      }
    } on AppException {
      rethrow;
    } catch (e) {
      throw ServerException(message: 'Change password error: ${e.toString()}');
    }
  }

  /// Get current user
  Future<User> getCurrentUser() async {
    const queryString = r'''
      query Me {
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
        operation: Operation(document: gql_lang.parseString(queryString), operationName: 'Me'),
      );

      final response = await GraphQLClientConfig.request(gqlRequest);

      // Check for partial errors
      if (response.errors != null && response.errors!.isNotEmpty) {
        final errorMessage = response.errors!.map((e) => e.message).join(', ');
        throw ServerException(message: errorMessage);
      }

      final data = response.data?['me'];
      if (data == null) {
        throw const ServerException(message: 'Get current user failed: No data returned');
      }

      return User.fromJson(data as Map<String, dynamic>);
    } on AppException {
      rethrow;
    } catch (e) {
      throw ServerException(message: 'Get current user error: ${e.toString()}');
    }
  }
}
