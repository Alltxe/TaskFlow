import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile/data/providers/auth_providers.dart';
import 'package:mobile/l10n/app_localizations.dart';
import 'package:mobile/presentation/screens/auth/login_screen.dart';
import 'package:mobile/presentation/screens/auth/register_screen.dart';
import 'package:mobile/presentation/screens/auth/splash_screen.dart';
import 'package:mobile/presentation/screens/dashboard/dashboard_screen.dart';
import 'package:mobile/presentation/screens/groups/create_group_screen.dart';
import 'package:mobile/presentation/screens/groups/group_layout_screen.dart';
import 'package:mobile/presentation/screens/groups/group_settings_screen.dart';
import 'package:mobile/presentation/screens/groups/groups_screen.dart';
import 'package:mobile/presentation/screens/groups/invite_screen.dart';
import 'package:mobile/presentation/screens/groups/join_group_screen.dart';
import 'package:mobile/presentation/screens/main_navigation_screen.dart';
import 'package:mobile/presentation/screens/profile/profile_screen.dart';
import 'package:mobile/presentation/screens/settings/settings_screen.dart';
import 'package:mobile/presentation/screens/tasks/create_task_screen.dart';
import 'package:mobile/presentation/screens/tasks/task_detail_screen.dart';

/// Router configuration for the app
final routerProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authStateProvider);

  return GoRouter(
    initialLocation: '/',
    redirect: (context, state) {
      final isAuthenticated = authState.status == AuthStatus.authenticated;
      final isLoading = authState.status == AuthStatus.loading;
      final isOnSplash = state.matchedLocation == '/';
      final isOnAuth = state.matchedLocation == '/login' || state.matchedLocation == '/register';

      // If loading, stay on splash
      if (isLoading && !isOnSplash) {
        return '/';
      }

      // If authenticated, redirect to home
      if (isAuthenticated && (isOnSplash || isOnAuth)) {
        return '/home';
      }

      // If not authenticated and not loading, redirect to login
      if (!isAuthenticated && !isLoading && !isOnAuth && !isOnSplash) {
        return '/login';
      }

      // If not authenticated and done loading on splash, go to login
      if (!isAuthenticated && !isLoading && isOnSplash) {
        return '/login';
      }

      return null; // No redirect
    },
    routes: [
      GoRoute(path: '/', builder: (context, state) => const SplashScreen()),
      GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),
      GoRoute(path: '/register', builder: (context, state) => const RegisterScreen()),

      // Main navigation with bottom tabs
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return MainNavigationScreen(navigationShell: navigationShell);
        },
        branches: [
          StatefulShellBranch(
            routes: [GoRoute(path: '/home', builder: (context, state) => const DashboardScreen())],
          ),
          // Tasks removed from main nav shell — accessible from GroupLayout only
          StatefulShellBranch(
            routes: [GoRoute(path: '/groups', builder: (context, state) => const GroupsScreen())],
          ),
          // Rewards removed from main navigation for now (destination not shown)
          StatefulShellBranch(
            routes: [GoRoute(path: '/profile', builder: (context, state) => const ProfileScreen())],
          ),
        ],
      ),

      // Standalone routes (not in bottom navigation)
      GoRoute(path: '/settings', builder: (context, state) => const SettingsScreen()),
      GoRoute(
        path: '/edit-profile',
        builder: (context, state) => Scaffold(
          body: Center(child: Text(AppLocalizations.of(context)!.editProfileComingSoon)),
        ),
      ),

      // Group routes (nested)
      GoRoute(path: '/groups/create', builder: (context, state) => const CreateGroupScreen()),
      GoRoute(
        path: '/groups/:groupId',
        builder: (context, state) {
          final groupId = state.pathParameters['groupId']!;
          return GroupLayoutScreen(groupId: groupId, child: const SizedBox.shrink());
        },
      ),
      GoRoute(
        path: '/groups/:groupId/settings',
        builder: (context, state) {
          final groupId = state.pathParameters['groupId']!;
          return GroupSettingsScreen(groupId: groupId);
        },
      ),
      GoRoute(
        path: '/groups/:groupId/invite',
        builder: (context, state) {
          final groupId = state.pathParameters['groupId']!;
          return InviteScreen(groupId: groupId);
        },
      ),

      // Join group via invite token
      GoRoute(
        path: '/join/:inviteToken',
        builder: (context, state) {
          final inviteToken = state.pathParameters['inviteToken']!;
          return JoinGroupScreen(inviteToken: inviteToken);
        },
      ),

      // Task routes
      GoRoute(
        path: '/tasks/create',
        builder: (context, state) {
          final groupId = state.uri.queryParameters['groupId'] ?? '';
          return CreateTaskScreen(groupId: groupId);
        },
      ),
      GoRoute(
        path: '/tasks/:taskId',
        builder: (context, state) {
          final taskId = state.pathParameters['taskId']!;
          return TaskDetailScreen(taskId: taskId);
        },
      ),
      GoRoute(
        path: '/tasks/:taskId/edit',
        builder: (context, state) {
          final taskId = state.pathParameters['taskId']!;
          final groupId = state.uri.queryParameters['groupId'] ?? '';
          return CreateTaskScreen(taskId: taskId, groupId: groupId);
        },
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      body: Center(child: Text(AppLocalizations.of(context)!.pageNotFound(state.uri.toString()))),
    ),
  );
});
