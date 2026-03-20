import 'dart:io';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:gql/language.dart' as gql_lang;
import 'package:gql_exec/gql_exec.dart';
import 'package:taskflow/core/config/app_config.dart';
import 'package:taskflow/core/config/graphql_client.dart';

class PushNotificationService {
  PushNotificationService._();

  static final PushNotificationService instance = PushNotificationService._();
  static const FlutterSecureStorage _secureStorage = FlutterSecureStorage();
  static const String _fcmTokenStorageKey = 'fcm_device_token';

  bool _initialized = false;

  Future<void> initialize({void Function(String route)? onNavigate}) async {
    if (_initialized || !AppConfig.enablePushNotifications) {
      return;
    }

    try {
      await Firebase.initializeApp();
    } catch (e) {
      debugPrint('[Push] Firebase init skipped/failed: $e');
      return;
    }

    final messaging = FirebaseMessaging.instance;

    if (!kIsWeb && (Platform.isIOS || Platform.isAndroid)) {
      await messaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
        provisional: false,
      );
    }

    FirebaseMessaging.onMessage.listen((message) {
      debugPrint('[Push] Foreground message: ${message.messageId}');
    });

    FirebaseMessaging.onMessageOpenedApp.listen((message) {
      final route = _routeFromNotificationData(message.data);
      if (route != null) {
        onNavigate?.call(route);
      }
    });

    final initialMessage = await messaging.getInitialMessage();
    if (initialMessage != null) {
      final route = _routeFromNotificationData(initialMessage.data);
      if (route != null) {
        onNavigate?.call(route);
      }
    }

    _initialized = true;
  }

  Future<void> syncDeviceToken() async {
    if (!AppConfig.enablePushNotifications) {
      return;
    }

    String? token;
    try {
      token = await FirebaseMessaging.instance.getToken();
    } catch (e) {
      debugPrint('[Push] Unable to read FCM token: $e');
      return;
    }

    if (token == null || token.isEmpty) {
      return;
    }

    await _registerDeviceToken(token);
    await _secureStorage.write(key: _fcmTokenStorageKey, value: token);

    FirebaseMessaging.instance.onTokenRefresh.listen((newToken) async {
      await _registerDeviceToken(newToken);
      await _secureStorage.write(key: _fcmTokenStorageKey, value: newToken);
    });
  }

  Future<void> unregisterCurrentDeviceToken() async {
    final token = await _secureStorage.read(key: _fcmTokenStorageKey);
    if (token == null || token.isEmpty) {
      return;
    }

    const mutationString = r'''
      mutation RemoveDeviceToken($token: String!) {
        removeDeviceToken(input: { token: $token })
      }
    ''';

    try {
      final gqlRequest = Request(
        operation: Operation(
          document: gql_lang.parseString(mutationString),
          operationName: 'RemoveDeviceToken',
        ),
        variables: {'token': token},
      );

      await GraphQLClientConfig.request(gqlRequest);
      await _secureStorage.delete(key: _fcmTokenStorageKey);
    } catch (e) {
      debugPrint('[Push] Failed to unregister device token: $e');
    }
  }

  Future<void> _registerDeviceToken(String token) async {
    const mutationString = r'''
      mutation RegisterDeviceToken(
        $token: String!,
        $provider: String,
        $platform: String
      ) {
        registerDeviceToken(input: {
          token: $token,
          provider: $provider,
          platform: $platform
        }) {
          id
        }
      }
    ''';

    final gqlRequest = Request(
      operation: Operation(
        document: gql_lang.parseString(mutationString),
        operationName: 'RegisterDeviceToken',
      ),
      variables: {
        'token': token,
        'provider': 'firebase',
        'platform': _platformName(),
      },
    );

    try {
      await GraphQLClientConfig.request(gqlRequest);
    } catch (e) {
      debugPrint('[Push] Failed to register device token: $e');
    }
  }

  String _platformName() {
    if (kIsWeb) return 'web';
    if (Platform.isAndroid) return 'android';
    if (Platform.isIOS) return 'ios';
    if (Platform.isMacOS) return 'macos';
    if (Platform.isWindows) return 'windows';
    if (Platform.isLinux) return 'linux';
    return 'unknown';
  }

  String? _routeFromNotificationData(Map<String, dynamic> data) {
    final entityType = (data['entityType'] ?? data['entity_type'])?.toString();
    final entityId = (data['entityId'] ?? data['entity_id'])?.toString();

    if (entityType == null || entityId == null || entityId.isEmpty) {
      return null;
    }

    switch (entityType.toLowerCase()) {
      case 'task':
        return '/tasks/$entityId';
      case 'group':
        return '/groups/$entityId';
      default:
        return null;
    }
  }
}
