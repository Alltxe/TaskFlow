import 'package:graphql_flutter/graphql_flutter.dart' hide ServerException, NetworkException;
import 'package:mobile/core/errors/exceptions.dart';
import 'package:mobile/data/models/auth_response.dart';
import 'package:mobile/data/models/auth_tokens.dart';
import 'package:mobile/data/models/login_request.dart';
import 'package:mobile/data/models/register_request.dart';
import 'package:mobile/data/models/user.dart';

/// Remote data source for authentication via GraphQL API
class AuthRemoteDataSource {
  final GraphQLClient client;

  AuthRemoteDataSource(this.client);

  /// Login with email and password
  Future<AuthResponse> login(LoginRequest request) async {
    const mutation = r'''
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
      final result = await client.mutate(
        MutationOptions(
          document: gql(mutation),
          variables: {'email': request.email, 'password': request.password},
        ),
      );

      if (result.hasException) {
        _handleGraphQLException(result.exception!);
      }

      final data = result.data?['login'];
      if (data == null) {
        throw const ServerException(message: 'Login failed: No data returned');
      }

      // Transform backend response to our model
      final user = data['user'];
      final accessToken = data['accessToken'];
      final refreshToken = data['refreshToken'];

      return AuthResponse(
        user: User.fromJson(user),
        tokens: AuthTokens(
          accessToken: accessToken,
          refreshToken: refreshToken,
          // Backend doesn't return expiry times, so we set default values
          accessTokenExpiresAt: DateTime.now().add(const Duration(hours: 1)),
          refreshTokenExpiresAt: DateTime.now().add(const Duration(days: 7)),
        ),
      );
    } catch (e) {
      if (e is AppException) rethrow;
      throw ServerException(message: e.toString());
    }
  }

  /// Register new user
  Future<AuthResponse> register(RegisterRequest request) async {
    const mutation = r'''
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
      final result = await client.mutate(
        MutationOptions(
          document: gql(mutation),
          variables: {
            'email': request.email,
            'username': request.username,
            'password': request.password,
          },
        ),
      );

      if (result.hasException) {
        _handleGraphQLException(result.exception!);
      }

      final data = result.data?['register'];
      if (data == null) {
        throw const ServerException(message: 'Registration failed: No data returned');
      }

      // Transform backend response to our model
      final user = data['user'];
      final accessToken = data['accessToken'];
      final refreshToken = data['refreshToken'];

      return AuthResponse(
        user: User.fromJson(user),
        tokens: AuthTokens(
          accessToken: accessToken,
          refreshToken: refreshToken,
          accessTokenExpiresAt: DateTime.now().add(const Duration(hours: 1)),
          refreshTokenExpiresAt: DateTime.now().add(const Duration(days: 7)),
        ),
      );
    } catch (e) {
      if (e is AppException) rethrow;
      throw ServerException(message: e.toString());
    }
  }

  /// Refresh access token using refresh token
  Future<AuthTokens> refreshToken(String refreshToken) async {
    const mutation = r'''
      mutation RefreshToken($input: RefreshTokenInput!) {
        refreshToken(input: $input) {
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
      final result = await client.mutate(
        MutationOptions(
          document: gql(mutation),
          variables: {
            'input': {'refreshToken': refreshToken},
          },
        ),
      );

      if (result.hasException) {
        _handleGraphQLException(result.exception!);
      }

      final data = result.data?['refreshToken'];
      if (data == null) {
        throw const ServerException(message: 'Token refresh failed: No data returned');
      }

      final accessToken = data['accessToken'];
      final newRefreshToken = data['refreshToken'];

      return AuthTokens(
        accessToken: accessToken,
        refreshToken: newRefreshToken,
        // Access token expires in 15 minutes (backend default)
        accessTokenExpiresAt: DateTime.now().add(const Duration(minutes: 15)),
        // Refresh token expires in 7 days (backend default)
        refreshTokenExpiresAt: DateTime.now().add(const Duration(days: 7)),
      );
    } catch (e) {
      if (e is AppException) rethrow;
      throw ServerException(message: e.toString());
    }
  }

  /// Get current user profile
  Future<AuthResponse> getCurrentUser() async {
    const query = r'''
      query GetCurrentUser {
        me {
          user {
            id
            email
            username
            avatarUrl
            isActive
            createdAt
            updatedAt
          }
          tokens {
            accessToken
            refreshToken
            accessTokenExpiresAt
            refreshTokenExpiresAt
          }
        }
      }
    ''';

    try {
      final result = await client.query(
        QueryOptions(document: gql(query), fetchPolicy: FetchPolicy.networkOnly),
      );

      if (result.hasException) {
        _handleGraphQLException(result.exception!);
      }

      final data = result.data?['me'];
      if (data == null) {
        throw const ServerException(message: 'Failed to get current user: No data returned');
      }

      return AuthResponse.fromJson(data);
    } catch (e) {
      if (e is AppException) rethrow;
      throw ServerException(message: e.toString());
    }
  }

  /// Handle GraphQL exceptions and convert to AppException
  void _handleGraphQLException(OperationException exception) {
    if (exception.graphqlErrors.isNotEmpty) {
      final error = exception.graphqlErrors.first;
      final message = error.message;

      // Check for specific error types
      if (message.toLowerCase().contains('invalid credentials') ||
          message.toLowerCase().contains('unauthorized')) {
        throw AuthException(message: message);
      } else if (message.toLowerCase().contains('validation')) {
        throw ValidationException(message: message);
      } else {
        throw ServerException(message: message);
      }
    }

    if (exception.linkException != null) {
      throw const NetworkException(message: 'Network error occurred');
    }

    throw ServerException(message: exception.toString());
  }
}
