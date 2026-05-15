import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:taskflow/l10n/app_localizations.dart';
/// Entry screen for unauthenticated users: choose login or registration.
class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  static const double _horizontalPadding = 24;
  static const double _buttonRadius = 12;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: _horizontalPadding),
          child: Column(
            children: [
              const Spacer(flex: 2),
              Icon(Icons.task_alt, size: 96, color: colorScheme.primary),
              const SizedBox(height: 24),
              Text(
                l10n.welcomeScreenTitle,
                style: theme.textTheme.headlineLarge?.copyWith(fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Text(
                l10n.welcomeScreenSubtitle,
                style: theme.textTheme.bodyLarge?.copyWith(color: colorScheme.onSurfaceVariant),
                textAlign: TextAlign.center,
              ),
              const Spacer(flex: 3),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () => context.push('/register'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(_buttonRadius)),
                  ),
                  child: Text(l10n.welcomeCreateAccount),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: () => context.push('/login'),
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(_buttonRadius)),
                  ),
                  child: Text(l10n.login),
                ),
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}
