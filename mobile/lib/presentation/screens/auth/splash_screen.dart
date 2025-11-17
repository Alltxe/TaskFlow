import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Splash screen for checking authentication status
/// Note: Navigation is handled by GoRouter redirect logic in app_router.dart
class SplashScreen extends ConsumerWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Router handles navigation based on authStateProvider

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
