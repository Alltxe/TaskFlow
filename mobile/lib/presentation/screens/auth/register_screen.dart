import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:taskflow/data/providers/auth_providers.dart';
import 'package:taskflow/l10n/app_localizations.dart';

/// Register screen with inline email verification step
class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  // Step 1 — registration form
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  // Step 2 — verification code
  final _codeController = TextEditingController();
  String? _codeError;
  bool _codeSending = false;

  @override
  void dispose() {
    _emailController.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _codeController.dispose();
    super.dispose();
  }

  void _handleRegister() {
    if (_formKey.currentState!.validate()) {
      ref.read(authStateProvider.notifier).register(
        _emailController.text.trim(),
        _usernameController.text.trim(),
        _passwordController.text,
      );
    }
  }

  Future<void> _handleVerify() async {
    final code = _codeController.text.trim();
    if (code.length != 6) {
      setState(() => _codeError = 'Введите 6-значный код');
      return;
    }
    setState(() => _codeError = null);
    try {
      await ref.read(authStateProvider.notifier).verifyEmailCode(code);
    } catch (e) {
      setState(() {
        _codeError = _mapVerifyError(e.toString());
      });
    }
  }

  Future<void> _handleResend() async {
    setState(() => _codeSending = true);
    try {
      await ref.read(authStateProvider.notifier).resendVerificationCode();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Код отправлен повторно')),
        );
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Не удалось отправить код')),
        );
      }
    } finally {
      if (mounted) setState(() => _codeSending = false);
    }
  }

  String _mapVerifyError(String raw) {
    final msg = raw.toLowerCase();
    if (msg.contains('invalid or expired')) return 'Неверный или устаревший код';
    if (msg.contains('already verified')) return 'Email уже подтверждён';
    return raw;
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authStateProvider);
    final isPending = authState.status == AuthStatus.pendingVerification;
    final isLoading = authState.status == AuthStatus.loading;

    // Show snackbar on registration error
    ref.listen<AuthState>(authStateProvider, (previous, next) {
      if (next.status == AuthStatus.unauthenticated &&
          next.error != null &&
          previous?.status == AuthStatus.loading) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.error!),
            backgroundColor: Theme.of(context).colorScheme.error,
            duration: const Duration(seconds: 4),
          ),
        );
      }
    });

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: isLoading
              ? null
              : () {
                  if (isPending) {
                    ref.read(authStateProvider.notifier).resetToUnauthenticated();
                  }
                  context.go('/welcome');
                },
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: isPending ? _buildVerificationStep(isLoading) : _buildRegistrationForm(isLoading),
        ),
      ),
    );
  }

  // ─── Step 1: Registration form ────────────────────────────────────────────

  Widget _buildRegistrationForm(bool isLoading) {
    final l10n = AppLocalizations.of(context)!;

    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            l10n.createAccountTitle,
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            l10n.fillDetails,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),

          // Email
          TextFormField(
            controller: _emailController,
            decoration: InputDecoration(
              labelText: l10n.emailLabel,
              hintText: l10n.enterYourEmail,
              prefixIcon: const Icon(Icons.email_outlined),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            ),
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.next,
            enabled: !isLoading,
            validator: (value) {
              if (value == null || value.isEmpty) return 'Email обязателен';
              if (!value.contains('@')) return 'Некорректный email';
              return null;
            },
          ),
          const SizedBox(height: 16),

          // Username
          TextFormField(
            controller: _usernameController,
            decoration: InputDecoration(
              labelText: l10n.username,
              hintText: l10n.chooseUsername,
              prefixIcon: const Icon(Icons.person_outlined),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            ),
            textInputAction: TextInputAction.next,
            enabled: !isLoading,
            validator: (value) {
              if (value == null || value.isEmpty) return l10n.usernameRequired;
              if (value.length < 3) return l10n.usernameMinLength;
              return null;
            },
          ),
          const SizedBox(height: 16),

          // Password
          TextFormField(
            controller: _passwordController,
            decoration: InputDecoration(
              labelText: l10n.password,
              hintText: l10n.createPassword,
              prefixIcon: const Icon(Icons.lock_outlined),
              suffixIcon: IconButton(
                icon: Icon(
                  _obscurePassword ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                ),
                onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
              ),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            ),
            obscureText: _obscurePassword,
            textInputAction: TextInputAction.next,
            enabled: !isLoading,
            validator: (value) {
              if (value == null || value.isEmpty) return l10n.passwordRequired;
              if (value.length < 6) return l10n.passwordMinLength;
              return null;
            },
          ),
          const SizedBox(height: 16),

          // Confirm Password
          TextFormField(
            controller: _confirmPasswordController,
            decoration: InputDecoration(
              labelText: l10n.confirmPassword,
              hintText: l10n.enterYourPassword,
              prefixIcon: const Icon(Icons.lock_outlined),
              suffixIcon: IconButton(
                icon: Icon(
                  _obscureConfirmPassword
                      ? Icons.visibility_outlined
                      : Icons.visibility_off_outlined,
                ),
                onPressed: () =>
                    setState(() => _obscureConfirmPassword = !_obscureConfirmPassword),
              ),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            ),
            obscureText: _obscureConfirmPassword,
            textInputAction: TextInputAction.done,
            enabled: !isLoading,
            onFieldSubmitted: (_) => _handleRegister(),
            validator: (value) {
              if (value == null || value.isEmpty) return l10n.confirmPasswordRequired;
              if (value != _passwordController.text) return l10n.passwordsDoNotMatch;
              return null;
            },
          ),
          const SizedBox(height: 24),

          FilledButton(
            onPressed: isLoading ? null : _handleRegister,
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
                : Text(l10n.register),
          ),
          const SizedBox(height: 16),

          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(l10n.alreadyHaveAccount, style: Theme.of(context).textTheme.bodyMedium),
              TextButton(
                onPressed: isLoading ? null : () => context.go('/login'),
                child: Text(l10n.login),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ─── Step 2: Email verification ───────────────────────────────────────────

  Widget _buildVerificationStep(bool isLoading) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Icon(Icons.mark_email_unread_outlined, size: 64),
        const SizedBox(height: 16),
        Text(
          'Подтвердите email',
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        Text(
          'Мы отправили 6-значный код на\n${_emailController.text.trim()}',
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 32),

        // Code input
        TextFormField(
          controller: _codeController,
          decoration: InputDecoration(
            labelText: 'Код из письма',
            hintText: '123456',
            prefixIcon: const Icon(Icons.pin_outlined),
            errorText: _codeError,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            counterText: '',
          ),
          keyboardType: TextInputType.number,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(letterSpacing: 8),
          maxLength: 6,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          textInputAction: TextInputAction.done,
          enabled: !isLoading,
          onFieldSubmitted: (_) => _handleVerify(),
          onChanged: (_) {
            if (_codeError != null) setState(() => _codeError = null);
          },
        ),
        const SizedBox(height: 24),

        FilledButton(
          onPressed: isLoading ? null : _handleVerify,
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
              : const Text('Подтвердить'),
        ),
        const SizedBox(height: 16),

        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Не получили письмо? ',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            TextButton(
              onPressed: (isLoading || _codeSending) ? null : _handleResend,
              child: _codeSending
                  ? const SizedBox(
                      height: 16,
                      width: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Отправить снова'),
            ),
          ],
        ),
      ],
    );
  }
}
