import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile/presentation/providers/auth/auth_notifier.dart';
import 'package:mobile/presentation/providers/auth/auth_state.dart';

/// Splash screen for checking authentication status
class SplashScreen extends ConsumerWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Listen to auth state changes
    ref.listen<AuthState>(authNotifierProvider, (previous, next) {
      next.when(
        initial: () {}, // Still checking
        authenticated: (user) {
          // Navigate to home screen
          context.go('/home');
        },
        unauthenticated: () {
          // Navigate to login screen
          context.go('/login');
        },
        loading: () {}, // Should not happen in splash
        error: (message) {
          // Show error and navigate to login
          context.go('/login');
        },
      );
    });

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.primary,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // App logo
            Icon(Icons.task_alt, size: 100, color: Theme.of(context).colorScheme.onPrimary),
            const SizedBox(height: 24),

            // App name
            Text(
              'TaskFlow',
              style: Theme.of(context).textTheme.displayMedium?.copyWith(
                color: Theme.of(context).colorScheme.onPrimary,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 48),

            // Loading indicator
            CircularProgressIndicator(color: Theme.of(context).colorScheme.onPrimary),
          ],
        ),
      ),
    );
  }
}
