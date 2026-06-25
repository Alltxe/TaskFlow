import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Конфигурация приложения. Адреса сервера — в `mobile/.env` (см. `.env.example`).
class AppConfig {
  AppConfig._();

  static bool _loaded = false;

  /// Загрузить `.env` перед использованием AppConfig (вызывается из main).
  static Future<void> load() async {
    if (_loaded) return;
    await dotenv.load(fileName: '.env');
    _loaded = true;
  }

  static String _env(String key, {String fallback = ''}) {
    final fromDefine = String.fromEnvironment(key, defaultValue: '');
    if (fromDefine.isNotEmpty) return fromDefine;
    return dotenv.env[key]?.trim() ?? fallback;
  }

  static bool _envBool(String key, {bool fallback = false}) {
    final value = _env(key).toLowerCase();
    if (value.isEmpty) return fallback;
    return value == 'true' || value == '1' || value == 'yes';
  }

  static String get environment =>
      _env('ENVIRONMENT', fallback: 'development');

  static String get serverHost =>
      _env('SERVER_HOST', fallback: '127.0.0.1');

  static String get apiPort => _env('API_PORT', fallback: '3100');

  static String get deepLinkHost =>
      _env('DEEP_LINK_HOST', fallback: serverHost);

  /// Базовый URL API (GraphQL, upload).
  static String get apiBaseUrl {
    final override = _env('API_BASE_URL');
    if (override.isNotEmpty) return override;

    if (_envBool('USE_ANDROID_EMULATOR_HOST') &&
        !kIsWeb &&
        Platform.isAndroid) {
      final host = _env('ANDROID_EMULATOR_HOST', fallback: '10.0.2.2');
      final port = _env('ANDROID_EMULATOR_PORT', fallback: apiPort);
      return 'http://$host:$port';
    }

    return 'http://$serverHost:$apiPort';
  }

  static String get graphqlEndpoint => '$apiBaseUrl/graphql';

  static String get wsEndpoint {
    final base = Uri.parse(apiBaseUrl);
    final wsScheme = base.scheme == 'https' ? 'wss' : 'ws';
    return base.replace(scheme: wsScheme, path: '/graphql').toString();
  }

  /// URL для invite-ссылок (InviteScreen).
  static String get webBaseUrl {
    final override = _env('WEB_BASE_URL');
    if (override.isNotEmpty) return override;
    return 'http://$serverHost:$apiPort';
  }

  static const Duration connectionTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);
  static const Duration sendTimeout = Duration(seconds: 30);

  static const String accessTokenKey = 'access_token';
  static const String refreshTokenKey = 'refresh_token';
  static const String userIdKey = 'user_id';
  static const String themeKey = 'theme_mode';
  static const String localeKey = 'locale';

  static const int defaultPageSize = 20;
  static const int maxPageSize = 100;

  static const Duration cacheExpiration = Duration(minutes: 5);
  static const int maxCacheSize = 50;

  static const int maxImageUploadSize = 5 * 1024 * 1024;
  static const int maxImageUploadCount = 3;
  static const List<String> allowedImageExtensions = [
    'jpg',
    'jpeg',
    'png',
    'gif',
  ];

  static const int minPasswordLength = 8;
  static const int maxPasswordLength = 128;
  static const int minUsernameLength = 3;
  static const int maxUsernameLength = 30;
  static const int maxTaskTitleLength = 100;
  static const int maxTaskDescriptionLength = 500;
  static const int maxCommentLength = 500;

  static const bool enablePushNotifications = true;
  static const bool enableOfflineMode = true;
  static const bool enableAnalytics = false;

  static bool get isDevelopment => environment == 'development';
  static bool get isProduction => environment == 'production';
  static bool get isStaging => environment == 'staging';
}
