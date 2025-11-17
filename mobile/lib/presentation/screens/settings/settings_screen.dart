import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile/data/providers/auth_providers.dart';
import 'package:mobile/l10n/app_localizations.dart';

/// Settings screen
class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateProvider);

    return Scaffold(
      appBar: AppBar(title: Text(AppLocalizations.of(context)!.settingsTitle)),
      body: ListView(
        children: [
          // Account section
          _buildSectionHeader(context, AppLocalizations.of(context)!.account),
          if (authState.status == AuthStatus.authenticated && authState.user != null)
            ListTile(
              leading: const Icon(Icons.person),
              title: Text(AppLocalizations.of(context)!.username),
              subtitle: Text(authState.user!.username),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => context.push('/edit-profile'),
            ),
          if (authState.status == AuthStatus.authenticated && authState.user != null)
            ListTile(
              leading: const Icon(Icons.email),
              title: Text(AppLocalizations.of(context)!.emailLabel),
              subtitle: Text(authState.user!.email),
            ),
          ListTile(
            leading: const Icon(Icons.lock),
            title: Text(AppLocalizations.of(context)!.changePassword),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              // TODO: Implement change password
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(SnackBar(content: Text(AppLocalizations.of(context)!.comingSoon)));
            },
          ),

          const Divider(),

          // Notifications section
          _buildSectionHeader(context, AppLocalizations.of(context)!.notifications),
          SwitchListTile(
            secondary: const Icon(Icons.notifications),
            title: Text(AppLocalizations.of(context)!.pushNotifications),
            subtitle: const Text('Receive notifications for tasks and rewards'),
            value: true,
            onChanged: (value) {
              // TODO: Implement notification toggle
            },
          ),
          SwitchListTile(
            secondary: const Icon(Icons.vibration),
            title: Text(AppLocalizations.of(context)!.vibration),
            subtitle: const Text('Vibrate on notifications'),
            value: false,
            onChanged: (value) {
              // TODO: Implement vibration toggle
            },
          ),

          const Divider(),

          // Appearance section
          _buildSectionHeader(context, AppLocalizations.of(context)!.appearance),
          ListTile(
            leading: const Icon(Icons.palette),
            title: Text(AppLocalizations.of(context)!.theme),
            subtitle: Text(AppLocalizations.of(context)!.systemDefault),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              // TODO: Implement theme selector
              _showThemeDialog(context);
            },
          ),

          const Divider(),

          // About section
          _buildSectionHeader(context, AppLocalizations.of(context)!.aboutTaskFlow),
          ListTile(
            leading: const Icon(Icons.info),
            title: Text(AppLocalizations.of(context)!.aboutTaskFlow),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              showAboutDialog(
                context: context,
                applicationName: AppLocalizations.of(context)!.appTitle,
                applicationVersion: '1.0.0',
                applicationLegalese: '© 2025 TaskFlow Team',
                children: [
                  const SizedBox(height: 16),
                  Text(AppLocalizations.of(context)!.aboutTaskFlow),
                ],
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.policy),
            title: Text(AppLocalizations.of(context)!.privacyPolicy),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              // TODO: Navigate to privacy policy
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(const SnackBar(content: Text('Coming soon')));
            },
          ),
          ListTile(
            leading: const Icon(Icons.description),
            title: Text(AppLocalizations.of(context)!.termsOfService),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              // TODO: Navigate to terms of service
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(const SnackBar(content: Text('Coming soon')));
            },
          ),

          const Divider(),

          // Logout section
          Padding(
            padding: const EdgeInsets.all(16),
            child: FilledButton.tonalIcon(
              onPressed: () => _handleLogout(context, ref),
              icon: const Icon(Icons.logout),
              label: Text(AppLocalizations.of(context)!.logout),
              style: FilledButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.errorContainer,
                foregroundColor: Theme.of(context).colorScheme.onErrorContainer,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleSmall?.copyWith(
          color: Theme.of(context).colorScheme.primary,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  void _showThemeDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Choose Theme'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            RadioListTile<String>(
              title: const Text('Light'),
              value: 'light',
              groupValue: 'system',
              onChanged: (value) {
                // TODO: Implement theme change
                Navigator.pop(context);
              },
            ),
            RadioListTile<String>(
              title: const Text('Dark'),
              value: 'dark',
              groupValue: 'system',
              onChanged: (value) {
                // TODO: Implement theme change
                Navigator.pop(context);
              },
            ),
            RadioListTile<String>(
              title: const Text('System default'),
              value: 'system',
              groupValue: 'system',
              onChanged: (value) {
                // TODO: Implement theme change
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _handleLogout(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(AppLocalizations.of(context)!.logoutConfirmationTitle),
        content: Text(AppLocalizations.of(context)!.logoutConfirmationText),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(AppLocalizations.of(context)!.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            style: FilledButton.styleFrom(backgroundColor: Theme.of(context).colorScheme.error),
            child: Text(AppLocalizations.of(context)!.logout),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      await ref.read(authStateProvider.notifier).logout();
      if (context.mounted) {
        context.go('/login');
      }
    }
  }
}
