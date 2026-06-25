import 'dart:async';

import 'package:app_links/app_links.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:taskflow/core/config/app_config.dart';
import 'package:taskflow/core/router/app_router.dart';
import 'package:taskflow/core/services/push_notification_service.dart';
import 'package:taskflow/core/theme/app_theme.dart';
import 'package:taskflow/l10n/app_localizations.dart';

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  debugPrint('[Push] Background message: ${message.messageId}');
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await AppConfig.load();
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  runApp(const ProviderScope(child: TaskFlowApp()));
}

class TaskFlowApp extends ConsumerStatefulWidget {
  const TaskFlowApp({super.key});

  @override
  ConsumerState<TaskFlowApp> createState() => _TaskFlowAppState();
}

class _TaskFlowAppState extends ConsumerState<TaskFlowApp> {
  late AppLinks _appLinks;
  StreamSubscription? _linkSubscription;

  @override
  void initState() {
    super.initState();
    _appLinks = AppLinks();
    _initDeepLinks();
    _initPushNotifications();
  }

  Future<void> _initDeepLinks() async {
    // Handle initial deep link when app is opened from closed state
    try {
      final initialUri = await _appLinks.getInitialLink();
      if (initialUri != null) {
        _handleDeepLink(initialUri);
      }
    } catch (e) {
      debugPrint('Error getting initial link: $e');
    }

    // Handle deep links when app is already running
    _linkSubscription = _appLinks.uriLinkStream.listen(
      (Uri? uri) {
        if (uri != null) {
          _handleDeepLink(uri);
        }
      },
      onError: (err) {
        debugPrint('Error listening to link stream: $err');
      },
    );
  }

  void _handleDeepLink(Uri uri) {
    // Кастомная схема: taskflow://invite/{token}
    if (uri.scheme == 'taskflow' && uri.host == 'invite') {
      final token = uri.pathSegments.isNotEmpty ? uri.pathSegments[0] : null;
      if (token != null) {
        ref.read(routerProvider).go('/join/$token');
      }
      return;
    }

    // HTTPS App Links (Android) / Universal Links (iOS): https://{host}/join/{token}
    // Также обрабатывает пути вида /TaskFlow/join/{token} (если приложение на подпути)
    if (uri.scheme == 'https' || uri.scheme == 'http') {
      final segments = uri.pathSegments;
      final joinIndex = segments.indexOf('join');
      if (joinIndex >= 0 && joinIndex + 1 < segments.length) {
        final token = segments[joinIndex + 1];
        if (token.isNotEmpty) {
          ref.read(routerProvider).go('/join/$token');
        }
      }
    }
  }

  Future<void> _initPushNotifications() async {
    await PushNotificationService.instance.initialize(
      onNavigate: (route) {
        final router = ref.read(routerProvider);
        router.go(route);
      },
    );
  }

  @override
  void dispose() {
    _linkSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final router = ref.watch(routerProvider);

    return MaterialApp.router(
      onGenerateTitle: (context) => AppLocalizations.of(context)!.appTitle,
      locale: const Locale('ru'),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      routerConfig: router,
    );
  }
}
