import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:gql_exec/gql_exec.dart';
import 'package:gql_http_link/gql_http_link.dart';
import 'package:gql_link/gql_link.dart' hide ServerException;
import 'package:http/http.dart' as http;
import 'package:taskflow/core/config/app_config.dart';
import 'package:taskflow/core/errors/exceptions.dart';

/// Simple GraphQL Client using gql_http_link
/// Provides direct GraphQL request execution with authentication
class GraphQLClientConfig {
  GraphQLClientConfig._();

  static Link? _link;
  static const FlutterSecureStorage _secureStorage = FlutterSecureStorage();

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
          'For Android emulator use 10.0.2.2 and make sure backend is running on port 3100.',
      details: error.toString(),
    );
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
