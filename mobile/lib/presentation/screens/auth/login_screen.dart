import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:taskflow/data/providers/auth_providers.dart';
import 'package:taskflow/l10n/app_localizations.dart';

/// Login screen
class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _handleLogin() {
    if (_formKey.currentState!.validate()) {
      final email = _emailController.text.trim();
      final password = _passwordController.text;
      ref.read(authStateProvider.notifier).login(email, password);
    }
  }

  String _mapAuthError(String rawMessage, AppLocalizations l10n) {
    final normalized = rawMessage.toLowerCase();

    if (normalized.contains('incorrect email or password') ||
        normalized.contains('invalid credentials')) {
      return l10n.invalidCredentialsError;
    }

    if (normalized.contains('unauthorized') || normalized.contains('unauthenticated')) {
      return l10n.authError;
    }

    if (normalized.contains('cannot connect to backend') ||
        normalized.contains('connection refused') ||
        normalized.contains('failed host lookup')) {
      return 'Backend недоступен. Проверьте, что сервер запущен на 3100 и API URL настроен корректно.';
    }

    return rawMessage;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final authState = ref.watch(authStateProvider);
    final isLoading = authState.status == AuthStatus.loading;

    // Show snackbar when error appears in state
    ref.listen<AuthState>(authStateProvider, (previous, next) {
      if (next.status == AuthStatus.unauthenticated &&
          next.error != null &&
          previous?.status == AuthStatus.loading) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_mapAuthError(next.error!, l10n)),
            backgroundColor: Theme.of(context).colorScheme.error,
            duration: const Duration(seconds: 4),
          ),
        );
      }
    });

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 48),

                // App logo
                Icon(Icons.task_alt, size: 80, color: Theme.of(context).colorScheme.primary),
                const SizedBox(height: 16),

                // Title
                Text(
                  AppLocalizations.of(context)!.welcomeBack,
                  style: Theme.of(
                    context,
                  ).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),

                // Subtitle
                Text(
                  AppLocalizations.of(context)!.signInToContinue,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 48),

                // Email field
                TextFormField(
                  controller: _emailController,
                  decoration: InputDecoration(
                    labelText: AppLocalizations.of(context)!.emailLabel,
                    hintText: AppLocalizations.of(context)!.enterYourEmail,
                    prefixIcon: const Icon(Icons.email_outlined),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.next,
                  enabled: !isLoading,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return AppLocalizations.of(context)!.emailRequired;
                    }
                    if (!value.contains('@')) {
                      return AppLocalizations.of(context)!.invalidEmailFormat;
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Password field
                TextFormField(
                  controller: _passwordController,
                  decoration: InputDecoration(
                    labelText: AppLocalizations.of(context)!.password,
                    hintText: AppLocalizations.of(context)!.enterYourPassword,
                    prefixIcon: const Icon(Icons.lock_outlined),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword
                            ? Icons.visibility_outlined
                            : Icons.visibility_off_outlined,
                      ),
                      onPressed: () {
                        setState(() {
                          _obscurePassword = !_obscurePassword;
                        });
                      },
                    ),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  obscureText: _obscurePassword,
                  textInputAction: TextInputAction.done,
                  enabled: !isLoading,
                  onFieldSubmitted: (_) => _handleLogin(),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return AppLocalizations.of(context)!.passwordRequired;
                    }
                    if (value.length < 8) {
                      return AppLocalizations.of(context)!.passwordMinLength;
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 24),

                // Login button
                FilledButton(
                  onPressed: isLoading ? null : _handleLogin,
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : Text(AppLocalizations.of(context)!.login),
                ),
                const SizedBox(height: 16),

                // Register link
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      AppLocalizations.of(context)!.dontHaveAccount,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    TextButton(
                      onPressed: isLoading ? null : () => context.go('/register'),
                      child: Text(AppLocalizations.of(context)!.register),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
