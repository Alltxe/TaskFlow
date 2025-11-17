import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile/data/models/join_group_request.dart';
import 'package:mobile/data/providers/group_providers.dart';
import 'package:mobile/l10n/app_localizations.dart';
import 'package:mobile/presentation/providers/group_notifier.dart';

class JoinGroupScreen extends ConsumerStatefulWidget {
  final String inviteToken;

  const JoinGroupScreen({super.key, required this.inviteToken});

  @override
  ConsumerState<JoinGroupScreen> createState() => _JoinGroupScreenState();
}

class _JoinGroupScreenState extends ConsumerState<JoinGroupScreen> {
  bool _isJoining = false;
  String? _error;
  String? _groupId;

  @override
  void initState() {
    super.initState();
    // Auto-join on screen load
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _joinGroup();
    });
  }

  Future<void> _joinGroup() async {
    setState(() {
      _isJoining = true;
      _error = null;
    });

    final request = JoinGroupRequest(inviteToken: widget.inviteToken);
    final joinGroupUseCase = ref.read(joinGroupUseCaseProvider);
    final result = await joinGroupUseCase(request);

    if (!mounted) return;

    result.fold(
      (failure) {
        setState(() {
          _isJoining = false;
          _error = failure.message;
        });
      },
      (group) {
        // Refresh groups list
        ref.read(groupNotifierProvider.notifier).refresh();

        setState(() {
          _isJoining = false;
          _groupId = group.id;
        });

        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppLocalizations.of(context)!.joinedSuccessfully(group.name))),
        );

        // Navigate to group after short delay
        Future.delayed(const Duration(seconds: 1), () {
          if (mounted) {
            context.go('/groups/${group.id}');
          }
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(title: Text(AppLocalizations.of(context)!.joinGroupTitle)),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (_isJoining) ...[
                const CircularProgressIndicator(),
                const SizedBox(height: 24),
                Text(AppLocalizations.of(context)!.joiningGroup, style: theme.textTheme.titleLarge),
                const SizedBox(height: 8),
                Text(
                  AppLocalizations.of(context)!.pleaseWait,
                  style: theme.textTheme.bodyMedium?.copyWith(color: colorScheme.onSurfaceVariant),
                ),
              ] else if (_error != null) ...[
                Icon(Icons.error_outline, size: 64, color: colorScheme.error),
                const SizedBox(height: 24),
                Text(
                  AppLocalizations.of(context)!.failedToJoinGroup,
                  style: theme.textTheme.titleLarge,
                ),
                const SizedBox(height: 8),
                Text(
                  _error!,
                  style: theme.textTheme.bodyMedium?.copyWith(color: colorScheme.error),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    FilledButton.tonalIcon(
                      onPressed: () => context.go('/groups'),
                      icon: const Icon(Icons.arrow_back),
                      label: Text(AppLocalizations.of(context)!.goToGroups),
                    ),
                    const SizedBox(width: 12),
                    FilledButton.icon(
                      onPressed: _joinGroup,
                      icon: const Icon(Icons.refresh),
                      label: Text(AppLocalizations.of(context)!.retry),
                    ),
                  ],
                ),
              ] else if (_groupId != null) ...[
                Icon(Icons.check_circle, size: 64, color: colorScheme.primary),
                const SizedBox(height: 24),
                Text(
                  AppLocalizations.of(context)!.successfullyJoined,
                  style: theme.textTheme.titleLarge,
                ),
                const SizedBox(height: 8),
                Text(
                  AppLocalizations.of(context)!.redirectingToGroup,
                  style: theme.textTheme.bodyMedium?.copyWith(color: colorScheme.onSurfaceVariant),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
