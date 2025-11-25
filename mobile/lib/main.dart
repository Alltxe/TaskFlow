import 'dart:async';

import 'package:app_links/app_links.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:taskflow/core/router/app_router.dart';
import 'package:taskflow/core/theme/app_theme.dart';
import 'package:taskflow/data/providers/graphql_provider.dart';
import 'package:taskflow/l10n/app_localizations.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initHiveForFlutter();

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
    // Handle taskflow://invite/{token}
    if (uri.scheme == 'taskflow' && uri.host == 'invite') {
      final token = uri.pathSegments.isNotEmpty ? uri.pathSegments[0] : null;
      if (token != null) {
        // Navigate to join group screen
        final router = ref.read(routerProvider);
        router.go('/join/$token');
      }
    }
  }

  @override
  void dispose() {
    _linkSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final graphqlClientNotifier = ref.watch(graphqlClientNotifierProvider);
    final router = ref.watch(routerProvider);

    return GraphQLProvider(
      client: graphqlClientNotifier,
      child: MaterialApp.router(
        onGenerateTitle: (context) => AppLocalizations.of(context)!.appTitle,
        locale: const Locale('ru'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: ThemeMode.system,
        routerConfig: router,
      ),
    );
  }
}
