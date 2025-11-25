import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:taskflow/data/models/group.dart';
import 'package:taskflow/data/models/group_member.dart';
import 'package:taskflow/data/providers/auth_providers.dart';
import 'package:taskflow/data/providers/group_providers.dart';
import 'package:taskflow/l10n/app_localizations.dart';
import 'package:taskflow/presentation/providers/group_notifier.dart';

class GroupDetailScreen extends ConsumerStatefulWidget {
  final String groupId;

  const GroupDetailScreen({super.key, required this.groupId});

  @override
  ConsumerState<GroupDetailScreen> createState() => _GroupDetailScreenState();
}

class _GroupDetailScreenState extends ConsumerState<GroupDetailScreen> {
  Group? _group;
  List<GroupMember>? _members;
  bool _isLoading = true;
  String? _error;
  String? _currentUserId;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    // Get current user ID
    final authState = ref.read(authStateProvider);
    if (authState.status == AuthStatus.authenticated && authState.user != null) {
      _currentUserId = authState.user!.id;
    } else {
      _currentUserId = null;
    }

    // Load group details
    final getGroupUseCase = ref.read(getGroupDetailUseCaseProvider);
    final groupResult = await getGroupUseCase(widget.groupId);

    // Load group members
    final getMembersUseCase = ref.read(getGroupMembersUseCaseProvider);
    final membersResult = await getMembersUseCase(widget.groupId);

    if (!mounted) return;

    setState(() {
      _isLoading = false;
      groupResult.fold((failure) => _error = failure.message, (group) => _group = group);
      membersResult.fold(
        (failure) {}, // Silently fail for members if already have error
        (members) => _members = members,
      );
    });
  }

  bool get _isAdmin {
    if (_currentUserId == null || _members == null) return false;
    final currentMember = _members!.firstWhere(
      (m) => m.userId == _currentUserId,
      orElse: () => _members!.first,
    );
    return currentMember.role == 'ADMIN';
  }

  Future<void> _leaveGroup() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(AppLocalizations.of(context)!.leaveGroup),
        content: Text(AppLocalizations.of(context)!.leaveGroup),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(AppLocalizations.of(context)!.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(AppLocalizations.of(context)!.leave),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;

    final leaveGroupUseCase = ref.read(leaveGroupUseCaseProvider);
    final result = await leaveGroupUseCase(widget.groupId);

    if (!mounted) return;

    result.fold(
      (failure) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${failure.message}'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      },
      (_) {
        ref.read(groupNotifierProvider.notifier).refresh();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppLocalizations.of(context)!.leftGroupSuccessfully)),
        );
        context.go('/groups');
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(title: Text(AppLocalizations.of(context)!.groupDetailsTitle)),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_error != null || _group == null) {
      return Scaffold(
        appBar: AppBar(title: Text(AppLocalizations.of(context)!.groupDetailsTitle)),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 64, color: colorScheme.error),
              const SizedBox(height: 16),
              Text(_error ?? 'Failed to load group', style: theme.textTheme.bodyLarge),
              const SizedBox(height: 16),
              FilledButton.icon(
                onPressed: _loadData,
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
        title: Text(_group!.name),
        actions: [
          if (_isAdmin)
            IconButton(
              icon: const Icon(Icons.settings),
              onPressed: () => context.push('/groups/${widget.groupId}/settings'),
              tooltip: 'Group Settings',
            ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadData,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Group header
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 32,
                          backgroundColor: colorScheme.primaryContainer,
                          child: Icon(
                            Icons.groups,
                            size: 32,
                            color: colorScheme.onPrimaryContainer,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(_group!.name, style: theme.textTheme.headlineSmall),
                              if (_group!.description != null) ...[
                                const SizedBox(height: 4),
                                Text(
                                  _group!.description!,
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    color: colorScheme.onSurfaceVariant,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        if (_group!.gamificationEnabled)
                          Chip(
                            label: Text(AppLocalizations.of(context)!.gamificationLabel),
                            avatar: const Icon(Icons.emoji_events, size: 16),
                          ),
                        Chip(
                          label: Text(_group!.rotationType.replaceAll('_', ' ')),
                          avatar: const Icon(Icons.sync, size: 16),
                        ),
                        if (_group!.requiresApproval)
                          Chip(
                            label: Text(AppLocalizations.of(context)!.requiresApproval),
                            avatar: const Icon(Icons.check_circle, size: 16),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Quick actions
            Row(
              children: [
                Expanded(
                  child: FilledButton.tonalIcon(
                    onPressed: () => context.push('/groups/${widget.groupId}/invite'),
                    icon: const Icon(Icons.person_add),
                    label: Text(AppLocalizations.of(context)!.invite),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: FilledButton.tonalIcon(
                    onPressed: _leaveGroup,
                    icon: const Icon(Icons.exit_to_app),
                    label: Text(AppLocalizations.of(context)!.leave),
                    style: FilledButton.styleFrom(
                      backgroundColor: colorScheme.errorContainer,
                      foregroundColor: colorScheme.onErrorContainer,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Members section
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(AppLocalizations.of(context)!.members, style: theme.textTheme.titleMedium),
                Text(
                  '${_members?.length ?? 0}',
                  style: theme.textTheme.titleMedium?.copyWith(color: colorScheme.onSurfaceVariant),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Members list
            if (_members == null || _members!.isEmpty)
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Center(
                    child: Text(
                      'No members found',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                ),
              )
            else
              ..._members!.map((member) {
                return Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundImage: member.user.avatarUrl != null
                          ? NetworkImage(member.user.avatarUrl!)
                          : null,
                      child: member.user.avatarUrl == null
                          ? Text(member.user.username[0].toUpperCase())
                          : null,
                    ),
                    title: Text(member.user.username),
                    subtitle: Text(
                      AppLocalizations.of(
                        context,
                      )!.joinedDate(DateFormat('MMM d, y').format(member.joinedAt)),
                    ),
                    trailing: Chip(
                      label: Text(
                        member.role,
                        style: TextStyle(
                          color: member.role == 'ADMIN'
                              ? colorScheme.onPrimaryContainer
                              : colorScheme.onSecondaryContainer,
                        ),
                      ),
                      backgroundColor: member.role == 'ADMIN'
                          ? colorScheme.primaryContainer
                          : colorScheme.secondaryContainer,
                    ),
                  ),
                );
              }),
          ],
        ),
      ),
    );
  }
}
