import 'dart:io';

import 'package:flutter/foundation.dart';

/// Application configuration
/// Contains API endpoints, environment settings, and app constants
class AppConfig {
  AppConfig._();

  // Environment
  static const String environment = String.fromEnvironment(
    'ENVIRONMENT',
    defaultValue: 'development',
  );

  // API Configuration
  // Android emulator cannot access host loopback directly; use 10.0.2.2 by default.
  static const String _apiBaseUrlFromEnv = String.fromEnvironment('API_BASE_URL', defaultValue: '');

  static String get apiBaseUrl {
    if (_apiBaseUrlFromEnv.isNotEmpty) return _apiBaseUrlFromEnv;
    if (kIsWeb) return 'http://127.0.0.1:3100';
    if (Platform.isAndroid) return 'http://10.0.2.2:3100';
    return 'http://127.0.0.1:3100';
  }

  static String get graphqlEndpoint => '$apiBaseUrl/graphql';

  static String get wsEndpoint {
    final base = Uri.parse(apiBaseUrl);
    final wsScheme = base.scheme == 'https' ? 'wss' : 'ws';
    return base.replace(scheme: wsScheme, path: '/graphql').toString();
  }
  // Web Frontend URL (for invite links)
  static const String webBaseUrl = String.fromEnvironment(
    'WEB_BASE_URL',
    defaultValue: 'http://127.0.0.1:3100', // Replace with actual URL
  );

  // Timeouts
  static const Duration connectionTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);
  static const Duration sendTimeout = Duration(seconds: 30);

  // Storage Keys
  static const String accessTokenKey = 'access_token';
  static const String refreshTokenKey = 'refresh_token';
  static const String userIdKey = 'user_id';
  static const String themeKey = 'theme_mode';
  static const String localeKey = 'locale';

  // Pagination
  static const int defaultPageSize = 20;
  static const int maxPageSize = 100;

  // Cache
  static const Duration cacheExpiration = Duration(minutes: 5);
  static const int maxCacheSize = 50; // MB

  // Images
  static const int maxImageUploadSize = 5 * 1024 * 1024; // 5 MB
  static const int maxImageUploadCount = 3;
  static const List<String> allowedImageExtensions = ['jpg', 'jpeg', 'png', 'gif'];

  // Validation
  static const int minPasswordLength = 8;
  static const int maxPasswordLength = 128;
  static const int minUsernameLength = 3;
  static const int maxUsernameLength = 30;
  static const int maxTaskTitleLength = 100;
  static const int maxTaskDescriptionLength = 500;
  static const int maxCommentLength = 500;

  // Feature Flags
  static const bool enablePushNotifications = true;
  static const bool enableOfflineMode = true;
  static const bool enableAnalytics = false; // Disabled for development

  // Helper methods
  static bool get isDevelopment => environment == 'development';
  static bool get isProduction => environment == 'production';
  static bool get isStaging => environment == 'staging';
}
