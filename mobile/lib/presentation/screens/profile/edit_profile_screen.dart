import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:taskflow/core/utils/date_l10n.dart';
import 'package:taskflow/data/providers/auth_providers.dart';
import 'package:taskflow/data/providers/profile_providers.dart';
import 'package:taskflow/l10n/app_localizations.dart';

/// Screen for editing user profile (username, away status)
class EditProfileScreen extends ConsumerStatefulWidget {
  const EditProfileScreen({super.key});

  @override
  ConsumerState<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends ConsumerState<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _usernameController;
  late bool _isAway;
  DateTime? _awayUntil;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final user = ref.read(authStateProvider).user;
    _usernameController = TextEditingController(text: user?.username ?? '');
    _isAway = user?.isAway ?? false;
    _awayUntil = user?.awayUntil;
  }

  @override
  void dispose() {
    _usernameController.dispose();
    super.dispose();
  }

  Future<void> _selectAwayUntilDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _awayUntil ?? DateTime.now().add(const Duration(days: 7)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (date != null) {
      setState(() => _awayUntil = date);
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    final l10n = AppLocalizations.of(context)!;
    final newUsername = _usernameController.text.trim();
    final currentUser = ref.read(authStateProvider).user;
    final usernameChanged = newUsername != currentUser?.username;
    final awayChanged = _isAway != (currentUser?.isAway ?? false) ||
        _awayUntil != currentUser?.awayUntil;

    if (!usernameChanged && !awayChanged) {
      context.pop();
      return;
    }

    setState(() => _saving = true);
    try {
      final useCase = ref.read(updateProfileUseCaseProvider);
      final result = await useCase(
        username: usernameChanged ? newUsername : null,
        isAway: awayChanged ? _isAway : null,
        awayUntil: awayChanged && _isAway ? _awayUntil : null,
      );

      result.fold(
        (failure) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(failure.message),
                backgroundColor: Theme.of(context).colorScheme.error,
              ),
            );
          }
        },
        (updatedUser) {
          ref.invalidate(getUserProfileUseCaseProvider);
          ref.read(authStateProvider.notifier).updateUser(updatedUser);
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(l10n.profileUpdatedSuccess)),
            );
            context.pop();
          }
        },
      );
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final user = ref.watch(authStateProvider).user;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.editProfile),
        actions: [
          if (_saving)
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Center(
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              ),
            )
          else
            TextButton(onPressed: _save, child: Text(l10n.save)),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.emailLabel,
                      style: Theme.of(context).textTheme.labelMedium?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(user?.email ?? '', style: Theme.of(context).textTheme.bodyLarge),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _usernameController,
              decoration: InputDecoration(
                labelText: l10n.username,
                hintText: l10n.usernameHint,
                prefixIcon: const Icon(Icons.person_outline),
                border: const OutlineInputBorder(),
              ),
              textInputAction: TextInputAction.done,
              onFieldSubmitted: (_) => _save(),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return l10n.usernameRequired;
                }
                if (value.trim().length < 3) {
                  return l10n.usernameMinLength;
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            Card(
              child: SwitchListTile(
                value: _isAway,
                onChanged: _saving
                    ? null
                    : (value) {
                        setState(() {
                          _isAway = value;
                          if (!value) _awayUntil = null;
                        });
                      },
                title: Text(l10n.away),
                subtitle: _awayUntil != null
                    ? Text(l10n.awayUntil(formatMonthDayYear(context, _awayUntil!)))
                    : null,
                secondary: const Icon(Icons.access_time),
              ),
            ),
            if (_isAway) ...[
              const SizedBox(height: 8),
              OutlinedButton.icon(
                onPressed: _saving ? null : _selectAwayUntilDate,
                icon: const Icon(Icons.calendar_today),
                label: Text(
                  _awayUntil == null
                      ? l10n.selectDate
                      : l10n.awayUntil(formatMonthDayYear(context, _awayUntil!)),
                ),
              ),
            ],
            const SizedBox(height: 24),
            OutlinedButton.icon(
              onPressed: () => context.push('/change-password'),
              icon: const Icon(Icons.lock_outline),
              label: Text(l10n.changePassword),
            ),
          ],
        ),
      ),
    );
  }
}
