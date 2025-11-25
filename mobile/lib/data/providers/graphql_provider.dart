import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:taskflow/core/config/app_config.dart';
import 'package:taskflow/data/models/auth_tokens.dart';

/// StreamController for logout events
final logoutEventController = StreamController<bool>.broadcast();

/// Provider for secure storage
final secureStorageProvider = Provider<FlutterSecureStorage>((ref) {
  return const FlutterSecureStorage(aOptions: AndroidOptions(encryptedSharedPreferences: true));
});

/// Provider for GraphQL HTTP link
final httpLinkProvider = Provider<HttpLink>((ref) {
  return HttpLink(AppConfig.graphqlEndpoint);
});

/// Custom Link for automatic token refresh on 401 errors
class RefreshTokenLink extends Link {
  final FlutterSecureStorage storage;
  final ProviderRef ref;

  RefreshTokenLink(this.storage, this.ref);

  @override
  Stream<Response> request(Request request, [NextLink? forward]) async* {
    if (forward == null) {
      throw Exception('RefreshTokenLink: NextLink is null');
    }

    // Forward the request and listen to the response
    await for (final response in forward(request)) {
      // Check for authentication errors
      final hasAuthError =
          response.errors?.any((error) {
            return error.extensions?['code'] == 'UNAUTHENTICATED' ||
                error.extensions?['statusCode'] == 401;
          }) ??
          false;

      if (hasAuthError) {
        debugPrint('[Auth] Access token expired, attempting refresh...');

        try {
          // Try to refresh the token
          final refreshToken = await storage.read(key: AppConfig.refreshTokenKey);
          if (refreshToken == null) {
            debugPrint('[Auth] No refresh token found, clearing session');
            await _clearSession();
            yield response; // Return original error
            return;
          }

          // Perform token refresh
          final newTokens = await _refreshToken(refreshToken);

          if (newTokens != null) {
            debugPrint('[Auth] Token refreshed successfully, retrying request');

            // Save new tokens
            await storage.write(key: AppConfig.accessTokenKey, value: newTokens.accessToken);
            await storage.write(key: AppConfig.refreshTokenKey, value: newTokens.refreshToken);

            // Update request with new token
            final newRequest = request.updateContextEntry<HttpLinkHeaders>(
              (headers) => HttpLinkHeaders(
                headers: {
                  ...headers?.headers ?? {},
                  'Authorization': 'Bearer ${newTokens.accessToken}',
                },
              ),
            );

            // Retry the request with new token
            await for (final retryResponse in forward(newRequest)) {
              yield retryResponse;
            }
            return;
          } else {
            debugPrint('[Auth] Token refresh failed, clearing session');
            await _clearSession();
          }
        } catch (e) {
          debugPrint('[Auth] Error during token refresh: $e');
          await _clearSession();
        }
      }

      yield response;
    }
  }

  /// Helper function to refresh access token
  Future<AuthTokens?> _refreshToken(String refreshToken) async {
    try {
      final httpLink = ref.read(httpLinkProvider);
      final client = GraphQLClient(
        link: httpLink,
        cache: GraphQLCache(store: InMemoryStore()),
      );

      const mutation = r'''
        mutation RefreshToken($input: RefreshTokenInput!) {
          refreshToken(input: $input) {
            accessToken
            refreshToken
            user {
              id
            }
          }
        }
      ''';

      final result = await client.mutate(
        MutationOptions(
          document: gql(mutation),
          variables: {
            'input': {'refreshToken': refreshToken},
          },
        ),
      );

      if (result.hasException || result.data == null) {
        debugPrint('[Auth] Refresh mutation failed: ${result.exception}');
        return null;
      }

      final data = result.data?['refreshToken'];
      if (data == null) {
        return null;
      }

      return AuthTokens(
        accessToken: data['accessToken'],
        refreshToken: data['refreshToken'],
        accessTokenExpiresAt: DateTime.now().add(const Duration(minutes: 15)),
        refreshTokenExpiresAt: DateTime.now().add(const Duration(days: 7)),
      );
    } catch (e) {
      debugPrint('[Auth] Exception during token refresh: $e');
      return null;
    }
  }

  /// Helper function to clear authentication session
  Future<void> _clearSession() async {
    try {
      await storage.delete(key: AppConfig.accessTokenKey);
      await storage.delete(key: AppConfig.refreshTokenKey);
      await storage.delete(key: AppConfig.userIdKey);
      debugPrint('[Auth] Session cleared');

      // Notify listeners about logout (for UI redirect)
      logoutEventController.add(true);
    } catch (e) {
      debugPrint('[Auth] Error clearing session: $e');
    }
  }
}

/// Provider for RefreshTokenLink
final refreshTokenLinkProvider = Provider<RefreshTokenLink>((ref) {
  final storage = ref.read(secureStorageProvider);
  return RefreshTokenLink(storage, ref);
});

/// Provider for GraphQL Auth link
final authLinkProvider = Provider<AuthLink>((ref) {
  final storage = ref.read(secureStorageProvider);

  return AuthLink(
    getToken: () async {
      // Retrieve JWT token from secure storage
      final token = await storage.read(key: AppConfig.accessTokenKey);
      return token != null ? 'Bearer $token' : null;
    },
  );
});

/// Provider for GraphQL Request logging link
final requestLoggerLinkProvider = Provider<Link>((ref) {
  return Link.function((request, [forward]) async* {
    debugPrint('[GraphQL Request] Operation: ${request.operation.operationName}');
    debugPrint('[GraphQL Request] Variables: ${request.variables}');
    debugPrint('[GraphQL Request] Query: ${request.operation.document}');

    if (forward != null) {
      await for (final response in forward(request)) {
        debugPrint('[GraphQL Response] Data: ${response.data}');
        debugPrint('[GraphQL Response] Errors: ${response.errors}');
        yield response;
      }
    }
  });
});

/// Provider for GraphQL Error link (for logging only)
final errorLinkProvider = Provider<Link>((ref) {
  return ErrorLink(
    onException: (request, forward, exception) {
      debugPrint('[GraphQL Exception] ${exception.toString()}');
      throw exception;
    },
    onGraphQLError: (request, forward, response) {
      final errors = response.errors;
      if (errors != null && errors.isNotEmpty) {
        for (final error in errors) {
          debugPrint('[GraphQL Error] ${error.message} (${error.extensions?['code']})');
        }
      }
      throw response;
    },
  );
});

/// Provider for GraphQL Link chain
final graphqlLinkProvider = Provider<Link>((ref) {
  final httpLink = ref.read(httpLinkProvider);
  final authLink = ref.read(authLinkProvider);
  final refreshTokenLink = ref.read(refreshTokenLinkProvider);
  final errorLink = ref.read(errorLinkProvider);
  final requestLoggerLink = ref.read(requestLoggerLinkProvider);

  // Chain links: RequestLogger -> Error -> RefreshToken -> Auth -> HTTP
  return Link.from([requestLoggerLink, errorLink, refreshTokenLink, authLink, httpLink]);
});

/// Provider for GraphQL Client
final graphqlClientProvider = Provider<GraphQLClient>((ref) {
  final link = ref.read(graphqlLinkProvider);

  return GraphQLClient(
    link: link,
    cache: GraphQLCache(store: InMemoryStore()),
  );
});

/// Provider for ValueNotifier<GraphQLClient> (for GraphQLProvider widget)
final graphqlClientNotifierProvider = Provider<ValueNotifier<GraphQLClient>>((ref) {
  final client = ref.watch(graphqlClientProvider);
  return ValueNotifier(client);
});
