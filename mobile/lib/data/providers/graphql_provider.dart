import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:mobile/core/config/app_config.dart';

/// Provider for secure storage
final secureStorageProvider = Provider<FlutterSecureStorage>((ref) {
  return const FlutterSecureStorage(aOptions: AndroidOptions(encryptedSharedPreferences: true));
});

/// Provider for GraphQL HTTP link
final httpLinkProvider = Provider<HttpLink>((ref) {
  return HttpLink(AppConfig.graphqlEndpoint);
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

/// Provider for GraphQL Error link
final errorLinkProvider = Provider<Link>((ref) {
  final storage = ref.read(secureStorageProvider);

  return ErrorLink(
    onException: (request, forward, exception) {
      debugPrint('[GraphQL Exception] ${exception.toString()}');
      // Could implement token refresh logic here
      throw exception;
    },
    onGraphQLError: (request, forward, response) {
      final errors = response.errors;
      if (errors != null && errors.isNotEmpty) {
        for (final error in errors) {
          debugPrint('[GraphQL Error] ${error.message}');

          // Handle authentication errors (401)
          if (error.extensions?['code'] == 'UNAUTHENTICATED') {
            // Token expired or invalid - clear storage
            storage.delete(key: AppConfig.accessTokenKey);
            storage.delete(key: AppConfig.refreshTokenKey);
            storage.delete(key: AppConfig.userIdKey);

            // Could implement token refresh logic here
            // For now, just redirect to login (handled in app layer)
          }
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
  final errorLink = ref.read(errorLinkProvider);

  // Chain links: Error -> Auth -> HTTP
  return Link.from([errorLink, authLink, httpLink]);
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
