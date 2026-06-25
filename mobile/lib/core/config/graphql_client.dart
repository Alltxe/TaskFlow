import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:gql_exec/gql_exec.dart';
import 'package:gql_http_link/gql_http_link.dart';
import 'package:gql_link/gql_link.dart' hide ServerException;
import 'package:http/http.dart' as http;
import 'package:taskflow/core/config/app_config.dart';
import 'package:taskflow/core/errors/exceptions.dart';
import 'package:taskflow/core/events/app_events.dart';

/// Simple GraphQL Client using gql_http_link
/// Provides direct GraphQL request execution with authentication
class GraphQLClientConfig {
  GraphQLClientConfig._();

  static Link? _link;
  static Future<bool>? _refreshFuture;
  static const FlutterSecureStorage _secureStorage = FlutterSecureStorage();
  static const String _accessTokenExpiresAtKey = 'access_token_expires_at';
  static const String _refreshTokenExpiresAtKey = 'refresh_token_expires_at';

  /// Get or create GraphQL link (singleton)
  static Link getLink() {
    if (_link != null) return _link!;

    // Custom HTTP client with timeout
    final httpClient = http.Client();

    // HTTP Link for GraphQL requests
    final httpLink = HttpLink(
      AppConfig.graphqlEndpoint,
      defaultHeaders: {'Content-Type': 'application/json'},
      httpClient: _TimeoutHttpClient(httpClient, AppConfig.connectionTimeout),
    );

    // Error handling link
    final errorLink = Link.function((request, [forward]) async* {
      try {
        yield* forward!(request);
      } on SocketException catch (e) {
        _log('Network error: $e');
        throw const NetworkException(
          message: 'No internet connection. Please check your network settings.',
        );
      } on TimeoutException catch (e) {
        _log('Timeout error: $e');
        throw const TimeoutException(message: 'Request timeout. Please try again.');
      } on HttpException catch (e) {
        _log('HTTP error: $e');
        throw NetworkException(message: 'Network error: ${e.message}');
      } catch (e) {
        _log('Unknown error: $e');
        rethrow;
      }
    });

    // Logging link (only in debug mode)
    final loggingLink = Link.function((request, [forward]) async* {
      _log('GraphQL Request: ${request.operation.operationName}');
      _log('Variables: ${request.variables}');

      final stopwatch = Stopwatch()..start();

      try {
        await for (final response in forward!(request)) {
          stopwatch.stop();
          _log('Response received in ${stopwatch.elapsedMilliseconds}ms');

          if (response.errors != null && response.errors!.isNotEmpty) {
            _log('GraphQL Errors: ${response.errors}');
          } else {
            _log('Response data keys: ${response.data?.keys.toList()}');
          }

          yield response;
        }
      } catch (e) {
        stopwatch.stop();
        _log('Request failed after ${stopwatch.elapsedMilliseconds}ms: $e');
        rethrow;
      }
    });

    // Auth Link - adds JWT token to requests
    final authLink = Link.function((request, [forward]) async* {
      final token = await _secureStorage.read(key: AppConfig.accessTokenKey);

      if (token != null) {
        request = request.updateContextEntry<HttpLinkHeaders>(
          (headers) => HttpLinkHeaders(
            headers: {...headers?.headers ?? {}, 'Authorization': 'Bearer $token'},
          ),
        );
      }

      yield* forward!(request);
    });

    // Combine links: logging -> error handling -> auth -> http
    _link = Link.from([loggingLink, errorLink, authLink, httpLink]);

    return _link!;
  }

  /// Log helper (only in debug mode)
  static void _log(String message) {
    if (kDebugMode) {
      debugPrint('[GraphQL] $message');
    }
  }

  /// Handle GraphQL errors and throw appropriate AppException
  static Never _handleGraphQLErrors(List<GraphQLError> errors) {
    if (errors.isEmpty) {
      throw const ServerException(message: 'GraphQL operation failed');
    }

    final firstError = errors.first;
    final message = firstError.message;

    _log('GraphQL Error: $message');
    _log('Error extensions: ${firstError.extensions}');

    // Check error extensions for specific error types
    final extensions = firstError.extensions;
    if (extensions != null) {
      final code = extensions['code'] as String?;

      if (code == 'UNAUTHENTICATED' || code == 'UNAUTHORIZED') {
        throw AuthException(message: message);
      }

      if (code == 'BAD_USER_INPUT' || code == 'GRAPHQL_VALIDATION_FAILED') {
        throw ValidationException(message: message);
      }

      if (code == 'NOT_FOUND') {
        throw NotFoundException(message: message);
      }

      if (code == 'FORBIDDEN') {
        throw PermissionException(message: message);
      }
    }

    // Check message content for authentication errors
    final lowerMessage = message.toLowerCase();
    if (lowerMessage.contains('unauthorized') ||
        lowerMessage.contains('unauthenticated') ||
        lowerMessage.contains('not authenticated')) {
      throw AuthException(message: message);
    }

    // Check for validation errors
    if (lowerMessage.contains('validation') || lowerMessage.contains('invalid')) {
      throw ValidationException(message: message);
    }

    // Default to server exception
    throw ServerException(message: message);
  }

  static bool _looksLikeConnectivityFailure(Object error) {
    final msg = error.toString().toLowerCase();
    return msg.contains('socketexception') ||
        msg.contains('connection refused') ||
        msg.contains('failed host lookup') ||
        msg.contains('network is unreachable') ||
        msg.contains('connection timed out') ||
        msg.contains('clientexception');
  }

  static NetworkException _buildConnectivityException(Object error) {
    return NetworkException(
      message:
          'Cannot connect to backend at ${AppConfig.apiBaseUrl}. '
          'Check SERVER_HOST and API_PORT in mobile/.env.',
      details: error.toString(),
    );
  }

  static bool _isUnauthorizedCode(String? code) {
    if (code == null) return false;
    final normalized = code.toUpperCase();
    return normalized == 'UNAUTHORIZED' || normalized == 'UNAUTHENTICATED';
  }

  static bool _isUnauthorizedMessage(String message) {
    final lower = message.toLowerCase();
    return lower.contains('unauthorized') ||
        lower.contains('unauthenticated') ||
        lower.contains('not authenticated') ||
        lower.contains('требуется авторизация');
  }

  static bool _hasUnauthorizedErrors(List<GraphQLError> errors) {
    for (final error in errors) {
      final code = error.extensions?['code'] as String?;
      if (_isUnauthorizedCode(code) || _isUnauthorizedMessage(error.message)) {
        return true;
      }
    }
    return false;
  }

  static bool _canAttemptRefresh(Request gqlRequest) {
    final operationName = gqlRequest.operation.operationName?.toLowerCase() ?? '';
    return operationName != 'logintoken' &&
        operationName != 'register' &&
        operationName != 'refreshtoken' &&
        operationName != 'login';
  }

  static Future<bool> _refreshAccessToken() {
    final inFlight = _refreshFuture;
    if (inFlight != null) {
      return inFlight;
    }

    final refreshTask = _performTokenRefresh();
    _refreshFuture = refreshTask;

    refreshTask.whenComplete(() {
      if (identical(_refreshFuture, refreshTask)) {
        _refreshFuture = null;
      }
    });

    return refreshTask;
  }

  static Future<bool> _performTokenRefresh() async {
    final refreshToken = await _secureStorage.read(key: AppConfig.refreshTokenKey);
    if (refreshToken == null || refreshToken.isEmpty) {
      return false;
    }

    final body = jsonEncode({
      'query':
          'mutation RefreshToken(\$refreshToken: String!) { '
              'refreshToken(input: {refreshToken: \$refreshToken}) { '
              'accessToken refreshToken user { id } '
              '} '
              '}',
      'variables': {'refreshToken': refreshToken},
      'operationName': 'RefreshToken',
    });

    final client = _TimeoutHttpClient(http.Client(), AppConfig.connectionTimeout);

    try {
      final response = await client.post(
        Uri.parse(AppConfig.graphqlEndpoint),
        headers: {'Content-Type': 'application/json'},
        body: body,
      );

      if (response.statusCode < 200 || response.statusCode >= 300) {
        _log('Refresh HTTP failed with status ${response.statusCode}');
        return false;
      }

      final decoded = jsonDecode(response.body);
      if (decoded is! Map<String, dynamic>) {
        return false;
      }

      final errors = decoded['errors'];
      if (errors is List && errors.isNotEmpty) {
        for (final error in errors) {
          if (error is Map<String, dynamic>) {
            final message = (error['message'] as String?) ?? '';
            final extensions = error['extensions'];
            String? code;
            if (extensions is Map<String, dynamic>) {
              final rawCode = extensions['code'];
              code = rawCode is String ? rawCode : null;
            }

            if (_isUnauthorizedCode(code) || _isUnauthorizedMessage(message)) {
              _log('Refresh rejected with auth error: $message');
              return false;
            }
          }
        }
        return false;
      }

      final data = decoded['data'];
      if (data is! Map<String, dynamic>) {
        return false;
      }

      final refreshData = data['refreshToken'];
      if (refreshData is! Map<String, dynamic>) {
        return false;
      }

      final newAccessToken = refreshData['accessToken'];
      final newRefreshToken = refreshData['refreshToken'];
      if (newAccessToken is! String || newRefreshToken is! String) {
        return false;
      }

      final now = DateTime.now();
      await Future.wait([
        _secureStorage.write(key: AppConfig.accessTokenKey, value: newAccessToken),
        _secureStorage.write(key: AppConfig.refreshTokenKey, value: newRefreshToken),
        _secureStorage.write(
          key: _accessTokenExpiresAtKey,
          value: now.add(const Duration(minutes: 15)).toIso8601String(),
        ),
        _secureStorage.write(
          key: _refreshTokenExpiresAtKey,
          value: now.add(const Duration(days: 7)).toIso8601String(),
        ),
      ]);

      _log('Token refreshed successfully');
      return true;
    } catch (e) {
      _log('Refresh request failed: $e');
      return false;
    } finally {
      client.close();
    }
  }

  static Future<void> _emitLogoutEventSafely() async {
    try {
      logoutEventController.add(true);
    } catch (_) {
      // Ignore event delivery failures; auth state cleanup still proceeds.
    }
  }

  /// Execute a GraphQL request with timeout
  static Future<Response> request(Request gqlRequest) async {
    try {
      final link = getLink();

      final response = await link
          .request(gqlRequest)
          .timeout(
            AppConfig.receiveTimeout,
            onTimeout: (sink) {
              sink.addError(
                const TimeoutException(
                  message: 'Request timeout. Please check your connection.',
                ),
              );
            },
          )
          .first;

      // Check if we got a response
      // Check for GraphQL errors in the response
      if (response.errors != null && response.errors!.isNotEmpty) {
        _log('GraphQL returned errors: ${response.errors}');

        if (_hasUnauthorizedErrors(response.errors!) && _canAttemptRefresh(gqlRequest)) {
          _log('Unauthorized response detected, attempting token refresh');
          final refreshed = await _refreshAccessToken();

          if (refreshed) {
            final retriedResponse = await link
                .request(gqlRequest)
                .timeout(
                  AppConfig.receiveTimeout,
                  onTimeout: (sink) {
                    sink.addError(
                      const TimeoutException(
                        message: 'Request timeout. Please check your connection.',
                      ),
                    );
                  },
                )
                .first;

            if (retriedResponse.errors != null && retriedResponse.errors!.isNotEmpty) {
              _log('Retried request still has errors: ${retriedResponse.errors}');
              _handleGraphQLErrors(retriedResponse.errors!);
            }

            return retriedResponse;
          }

          await logout();
          await _emitLogoutEventSafely();
        }

        _handleGraphQLErrors(response.errors!);
      }

      return response;
    } on SocketException catch (e) {
      _log('Socket exception: $e');
      throw const NetworkException(
        message: 'Cannot connect to server. Please check your internet connection.',
      );
    } on AppException {
      // Re-throw any AppException (including TimeoutException, NetworkException, etc.)
      rethrow;
    } catch (e) {
      _log('Unexpected stream error: $e');

      if (_looksLikeConnectivityFailure(e)) {
        throw _buildConnectivityException(e);
      }

      // gql may surface GraphQL-only failures as OperationError/OperationException
      // through the stream instead of Response.errors.
      if (e.toString().contains('OperationError') || e.toString().contains('OperationException')) {
        final dynamic dynamicError = e;
        dynamic graphqlErrors;
        try {
          graphqlErrors = dynamicError.graphqlErrors;
        } catch (_) {
          graphqlErrors = null;
        }

        if (graphqlErrors is List<GraphQLError> && graphqlErrors.isNotEmpty) {
          _handleGraphQLErrors(graphqlErrors);
        }

        if (_looksLikeConnectivityFailure(e)) {
          throw _buildConnectivityException(e);
        }

        throw ServerException(message: e.toString());
      }

      throw ServerException(message: 'Unexpected error: ${e.toString()}');
    }
  }

  /// Update the access token
  static Future<void> updateToken(String accessToken) async {
    await _secureStorage.write(key: AppConfig.accessTokenKey, value: accessToken);
  }

  /// Clear tokens
  static Future<void> logout() async {
    await _secureStorage.delete(key: AppConfig.accessTokenKey);
    await _secureStorage.delete(key: AppConfig.refreshTokenKey);
    await _secureStorage.delete(key: AppConfig.userIdKey);

    // Reset link
    _link = null;
  }

  /// Dispose the link
  static void dispose() {
    _link = null;
  }
}

/// HTTP Client with timeout wrapper
class _TimeoutHttpClient extends http.BaseClient {
  _TimeoutHttpClient(this._inner, this._timeout);

  final http.Client _inner;
  final Duration _timeout;

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) async {
    return _inner
        .send(request)
        .timeout(
          _timeout,
          onTimeout: () {
            throw const TimeoutException(
              message: 'Connection timeout. Please check your internet.',
            );
          },
        );
  }

  @override
  void close() {
    _inner.close();
  }
}
