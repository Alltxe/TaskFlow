import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:taskflow/data/providers/auth_providers.dart';
import 'package:taskflow/l10n/app_localizations.dart';
import 'package:taskflow/presentation/screens/auth/forgot_password_screen.dart';
import 'package:taskflow/presentation/screens/auth/login_screen.dart';
import 'package:taskflow/presentation/screens/auth/register_screen.dart';
import 'package:taskflow/presentation/screens/auth/splash_screen.dart';
import 'package:taskflow/presentation/screens/auth/welcome_screen.dart';
import 'package:taskflow/presentation/screens/dashboard/dashboard_screen.dart';
import 'package:taskflow/presentation/screens/groups/create_group_screen.dart';
import 'package:taskflow/presentation/screens/groups/group_layout_screen.dart';
import 'package:taskflow/presentation/screens/groups/group_settings_screen.dart';
import 'package:taskflow/presentation/screens/groups/groups_screen.dart';
import 'package:taskflow/presentation/screens/groups/invite_screen.dart';
import 'package:taskflow/presentation/screens/groups/group_audit_log_screen.dart';
import 'package:taskflow/presentation/screens/groups/join_by_token_screen.dart';
import 'package:taskflow/presentation/screens/groups/join_group_screen.dart';
import 'package:taskflow/presentation/screens/main_navigation_screen.dart';
import 'package:taskflow/presentation/screens/profile/change_password_screen.dart';
import 'package:taskflow/presentation/screens/profile/edit_profile_screen.dart';
import 'package:taskflow/presentation/screens/profile/my_audit_logs_screen.dart';
import 'package:taskflow/presentation/screens/profile/points_detail_screen.dart';
import 'package:taskflow/presentation/screens/profile/profile_screen.dart';
import 'package:taskflow/presentation/screens/groups/group_recurring_templates_screen.dart';
import 'package:taskflow/presentation/screens/groups/group_rotation_screen.dart';
import 'package:taskflow/presentation/screens/notifications/notifications_screen.dart';
import 'package:taskflow/presentation/screens/rewards/my_reward_requests_screen.dart';
import 'package:taskflow/presentation/screens/settings/settings_screen.dart';
import 'package:taskflow/presentation/screens/tasks/create_task_screen.dart';
import 'package:taskflow/presentation/screens/tasks/task_detail_screen.dart';

class _RouterRefreshNotifier extends ChangeNotifier {
  void refresh() => notifyListeners();
}

/// Router configuration for the app
final routerProvider = Provider<GoRouter>((ref) {
  final refreshNotifier = _RouterRefreshNotifier();

  ref.onDispose(refreshNotifier.dispose);
  ref.listen<AuthState>(authStateProvider, (_, __) {
    refreshNotifier.refresh();
  });

  return GoRouter(
    initialLocation: '/',
    refreshListenable: refreshNotifier,
    redirect: (context, state) {
      final authState = ref.read(authStateProvider);
      final isAuthenticated = authState.status == AuthStatus.authenticated;
      final isLoading = authState.status == AuthStatus.loading;
      final isPendingVerification = authState.status == AuthStatus.pendingVerification;
      final isOnSplash = state.matchedLocation == '/';
      final isOnPublicAuth = state.matchedLocation == '/login' ||
          state.matchedLocation == '/register' ||
          state.matchedLocation == '/welcome' ||
          state.matchedLocation == '/forgot-password';
      final isOnJoin = state.matchedLocation.startsWith('/join/');
      final isOnJoinForm = state.matchedLocation == '/groups/join';

      // While verifying email — stay on /register
      if (isPendingVerification) {
        return state.matchedLocation == '/register' ? null : '/register';
      }

      // If loading, stay on splash except when user is already on auth pages.
      if (isLoading && !isOnSplash && !isOnPublicAuth) {
        return '/';
      }

      // If authenticated, redirect to home
      if (isAuthenticated && (isOnSplash || isOnPublicAuth)) {
        return '/home';
      }

      // Allow join group screen for unauthenticated users
      if (isOnJoin || isOnJoinForm) {
        return null;
      }

      // If not authenticated and not loading, redirect to welcome
      if (!isAuthenticated && !isLoading && !isOnPublicAuth && !isOnSplash) {
        return '/welcome';
      }

      // If not authenticated and done loading on splash, go to welcome
      if (!isAuthenticated && !isLoading && isOnSplash) {
        return '/welcome';
      }

      return null;
    },
    routes: [
      GoRoute(path: '/', builder: (context, state) => const SplashScreen()),
      GoRoute(path: '/welcome', builder: (context, state) => const WelcomeScreen()),
      GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),
      GoRoute(path: '/register', builder: (context, state) => const RegisterScreen()),
      GoRoute(
        path: '/forgot-password',
        builder: (context, state) => const ForgotPasswordScreen(),
      ),

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
        builder: (context, state) => const EditProfileScreen(),
      ),
      GoRoute(
        path: '/change-password',
        builder: (context, state) => const ChangePasswordScreen(),
      ),
      GoRoute(
        path: '/my-audit-logs',
        builder: (context, state) => const MyAuditLogsScreen(),
      ),
      GoRoute(
        path: '/notifications',
        builder: (context, state) => const NotificationsScreen(),
      ),

      // Group routes (nested)
      GoRoute(path: '/groups/create', builder: (context, state) => const CreateGroupScreen()),
      GoRoute(path: '/groups/join', builder: (context, state) => const JoinByTokenScreen()),
      GoRoute(
        path: '/groups/:groupId/audit-log',
        builder: (context, state) {
          final groupId = state.pathParameters['groupId']!;
          return GroupAuditLogScreen(groupId: groupId);
        },
      ),
      GoRoute(
        path: '/groups/:groupId/rotation',
        builder: (context, state) {
          final groupId = state.pathParameters['groupId']!;
          return GroupRotationScreen(groupId: groupId);
        },
      ),
      GoRoute(
        path: '/groups/:groupId/recurring-templates',
        builder: (context, state) {
          final groupId = state.pathParameters['groupId']!;
          return GroupRecurringTemplatesScreen(groupId: groupId);
        },
      ),
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

      // Reward routes
      GoRoute(
        path: '/points-detail',
        builder: (context, state) {
          final groupId = state.uri.queryParameters['groupId'];
          return PointsDetailScreen(groupId: groupId);
        },
      ),
      GoRoute(
        path: '/my-reward-requests',
        builder: (context, state) {
          final groupId = state.uri.queryParameters['groupId'];
          return MyRewardRequestsScreen(groupId: groupId);
        },
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      body: Center(child: Text(AppLocalizations.of(context)!.pageNotFound(state.uri.toString()))),
    ),
  );
});
