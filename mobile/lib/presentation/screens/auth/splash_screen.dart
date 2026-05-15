import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
/// Splash screen for checking authentication status
/// Note: Navigation is handled by GoRouter redirect logic in app_router.dart
class SplashScreen extends ConsumerWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: scheme.primary,
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.task_alt, size: 100, color: scheme.onPrimary),
              const SizedBox(height: 24),
              Text(
                'TaskFlow',
                style: Theme.of(context).textTheme.displayMedium?.copyWith(
                  color: scheme.onPrimary,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 48),
              CircularProgressIndicator(color: scheme.onPrimary),
            ],
          ),
        ),
      ),
    );
  }
}
