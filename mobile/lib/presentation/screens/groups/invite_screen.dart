import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:taskflow/core/config/app_config.dart';
import 'package:taskflow/data/models/group.dart';
import 'package:taskflow/data/providers/group_providers.dart';
import 'package:taskflow/l10n/app_localizations.dart';
import 'package:taskflow/presentation/widgets/common/app_navigation_back_button.dart';
import 'package:share_plus/share_plus.dart';

class InviteScreen extends ConsumerStatefulWidget {
  final String groupId;

  const InviteScreen({super.key, required this.groupId});

  @override
  ConsumerState<InviteScreen> createState() => _InviteScreenState();
}

class _InviteScreenState extends ConsumerState<InviteScreen> {
  Group? _group;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadGroup();
  }

  Future<void> _loadGroup() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    final getGroupUseCase = ref.read(getGroupDetailUseCaseProvider);
    final result = await getGroupUseCase(widget.groupId);

    if (!mounted) return;

    setState(() {
      _isLoading = false;
      result.fold((failure) => _error = failure.message, (group) => _group = group);
    });
  }

  String get _inviteLink {
    if (_group == null) return '';
    // Use web frontend URL for invite links (works in browsers and can be shared)
    return '${AppConfig.webBaseUrl}/join/${_group!.inviteToken}';
  }

  Future<void> _copyToClipboard() async {
    await Clipboard.setData(ClipboardData(text: _inviteLink));
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(AppLocalizations.of(context)!.inviteLinkCopied),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  Future<void> _shareInvite() async {
    final message =
        '''
Join "${_group!.name}" on TaskFlow!

Use this invite link to join the group:
$_inviteLink
''';

    await Share.share(message, subject: 'Join ${_group!.name} on TaskFlow');
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(
          leading: AppNavigationBackButton(fallbackRoute: '/groups/${widget.groupId}'),
          title: Text(AppLocalizations.of(context)!.inviteMembers),
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_error != null || _group == null) {
      return Scaffold(
        appBar: AppBar(
          leading: AppNavigationBackButton(fallbackRoute: '/groups/${widget.groupId}'),
          title: Text(AppLocalizations.of(context)!.inviteMembers),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 64, color: colorScheme.error),
              const SizedBox(height: 16),
              Text(_error ?? AppLocalizations.of(context)!.failedToLoadGroup),
              const SizedBox(height: 16),
              FilledButton.icon(
                onPressed: _loadGroup,
                icon: const Icon(Icons.refresh),
                label: Text(AppLocalizations.of(context)!.retry),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        leading: AppNavigationBackButton(fallbackRoute: '/groups/${widget.groupId}'),
        title: Text(AppLocalizations.of(context)!.inviteMembers),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
            // Info card
            Card(
              color: colorScheme.primaryContainer,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Icon(Icons.group_add, size: 64, color: colorScheme.onPrimaryContainer),
                    const SizedBox(height: 16),
                    Text(
                      AppLocalizations.of(context)!.invitePeopleToGroup(_group!.name),
                      style: theme.textTheme.titleLarge?.copyWith(
                        color: colorScheme.onPrimaryContainer,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      AppLocalizations.of(context)!.inviteLink, // fallback for description
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onPrimaryContainer,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Invite link display
            Text(AppLocalizations.of(context)!.inviteLink, style: theme.textTheme.titleMedium),
            const SizedBox(height: 8),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Expanded(
                      child: SelectableText(
                        _inviteLink,
                        style: theme.textTheme.bodySmall?.copyWith(
                          fontFamily: 'monospace',
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.copy),
                      onPressed: _copyToClipboard,
                      tooltip: AppLocalizations.of(context)!.copyInviteLink,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Invite token (for manual entry)
            Text(AppLocalizations.of(context)!.inviteToken, style: theme.textTheme.titleMedium),
            const SizedBox(height: 8),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Expanded(
                      child: SelectableText(
                        _group!.inviteToken,
                        style: theme.textTheme.bodyLarge?.copyWith(
                          fontFamily: 'monospace',
                          fontWeight: FontWeight.bold,
                          letterSpacing: 2,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.copy),
                      onPressed: () async {
                        await Clipboard.setData(ClipboardData(text: _group!.inviteToken));
                        if (!mounted) return;
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(AppLocalizations.of(context)!.tokenCopied),
                            duration: const Duration(seconds: 2),
                          ),
                        );
                      },
                      tooltip: 'Copy token',
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 32),

            // Share button
            FilledButton.icon(
              onPressed: _shareInvite,
              icon: const Icon(Icons.share),
              label: Text(AppLocalizations.of(context)!.shareInviteLink),
            ),
            const SizedBox(height: 12),

            // Copy button
            FilledButton.tonalIcon(
              onPressed: _copyToClipboard,
              icon: const Icon(Icons.copy),
              label: Text(AppLocalizations.of(context)!.copyInviteLink),
            ),
            const SizedBox(height: 32),

            // Info text
            Text(
              AppLocalizations.of(context)!.inviteLinkNeverExpires,
              style: theme.textTheme.bodySmall?.copyWith(color: colorScheme.onSurfaceVariant),
              textAlign: TextAlign.center,
            ),
          ],
        ),
        ),
      ),
    );
  }
}
