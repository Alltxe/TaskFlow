import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:taskflow/core/utils/enum_l10n.dart';
import 'package:taskflow/data/models/group_member.dart';
import 'package:taskflow/data/providers/auth_providers.dart';
import 'package:taskflow/data/providers/group_providers.dart';
import 'package:taskflow/l10n/app_localizations.dart';
import 'package:taskflow/presentation/screens/groups/invite_screen.dart';
import 'package:taskflow/presentation/widgets/common/app_badge.dart';

class GroupMembersScreen extends ConsumerStatefulWidget {
  final String groupId;

  const GroupMembersScreen({super.key, required this.groupId});

  @override
  ConsumerState<GroupMembersScreen> createState() => _GroupMembersScreenState();
}

class _GroupMembersScreenState extends ConsumerState<GroupMembersScreen> {
  List<GroupMember> _members = [];
  bool _isLoading = true;
  String? _error;
  String? _currentUserId;

  @override
  void initState() {
    super.initState();
    _loadMembers();
  }

  Future<void> _loadMembers() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    final authState = ref.read(authStateProvider);
    if (authState.status == AuthStatus.authenticated && authState.user != null) {
      _currentUserId = authState.user!.id;
    } else {
      _currentUserId = null;
    }

    final getMembersUseCase = ref.read(getGroupMembersUseCaseProvider);
    final result = await getMembersUseCase(widget.groupId);

    if (!mounted) return;

    setState(() {
      _isLoading = false;
      result.fold(
        (failure) => _error = failure.message,
        (members) => _members = members,
      );
    });
  }

  void _navigateToInvite() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => InviteScreen(groupId: widget.groupId),
      ),
    );
  }

  Future<void> _removeMember(GroupMember member) async {
    final l10n = AppLocalizations.of(context)!;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.removeMemberTitle),
        content: Text(l10n.removeMemberConfirm(member.user.username)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: Text(l10n.cancel)),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            style: FilledButton.styleFrom(backgroundColor: Theme.of(context).colorScheme.error),
            child: Text(l10n.removeLabel),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;

    final result = await ref.read(removeMemberUseCaseProvider).call(widget.groupId, member.userId);
    if (!mounted) return;

    result.fold(
      (failure) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.errorWithMessage(failure.message)),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      },
      (_) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.memberRemovedSuccess)),
        );
        _loadMembers();
      },
    );
  }

  Future<void> _changeRole(GroupMember member) async {
    final l10n = AppLocalizations.of(context)!;
    final newRole = member.role == 'ADMIN' ? 'MEMBER' : 'ADMIN';
    final newRoleLabel = memberRoleLabel(l10n, newRole);

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.changeRoleTitle),
        content: Text(l10n.changeRoleConfirm(member.user.username, newRoleLabel)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: Text(l10n.cancel)),
          FilledButton(onPressed: () => Navigator.pop(context, true), child: Text(l10n.change)),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;

    final result = await ref
        .read(updateMemberRoleUseCaseProvider)
        .call(widget.groupId, member.userId, newRole);

    if (!mounted) return;

    result.fold(
      (failure) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.errorWithMessage(failure.message)),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      },
      (_) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.roleChangedTo(newRoleLabel))),
        );
        _loadMembers();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final l10n = AppLocalizations.of(context)!;
    final isAdminAsync = ref.watch(isGroupAdminProvider(widget.groupId));

    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.error_outline, size: 64, color: colorScheme.error),
              const SizedBox(height: 16),
              Text(_error!, textAlign: TextAlign.center),
              const SizedBox(height: 16),
              FilledButton.icon(
                onPressed: _loadMembers,
                icon: const Icon(Icons.refresh),
                label: Text(l10n.retry),
              ),
            ],
          ),
        ),
      );
    }

    if (_members.isEmpty) {
      return Stack(
        children: [
          RefreshIndicator(
            onRefresh: _loadMembers,
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(32),
                    child: Column(
                      children: [
                        Icon(Icons.people, size: 64, color: colorScheme.onSurfaceVariant),
                        const SizedBox(height: 16),
                        Text(l10n.noDataYet, style: theme.textTheme.titleLarge),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            right: 16,
            bottom: 16,
            child: FloatingActionButton.extended(
              onPressed: _navigateToInvite,
              icon: const Icon(Icons.person_add),
              label: Text(l10n.inviteMembers),
            ),
          ),
        ],
      );
    }

    final isAdmin = isAdminAsync.value ?? false;

    return Stack(
      children: [
        RefreshIndicator(
          onRefresh: _loadMembers,
          child: ListView.builder(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 80),
            itemCount: _members.length,
            itemBuilder: (context, index) {
              final member = _members[index];
              final isCurrentUser = member.userId == _currentUserId;
              final canManage = isAdmin && !isCurrentUser;

              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isCurrentUser
                        ? colorScheme.primary.withValues(alpha: 0.5)
                        : colorScheme.outline.withValues(alpha: 0.1),
                    width: isCurrentUser ? 2 : 1,
                  ),
                  color: isCurrentUser
                      ? colorScheme.primaryContainer.withValues(alpha: 0.2)
                      : colorScheme.surface,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Stack(
                        children: [
                          CircleAvatar(
                            radius: 28,
                            backgroundColor: isCurrentUser
                                ? colorScheme.primary
                                : colorScheme.primaryContainer,
                            child: Text(
                              member.user.username.isNotEmpty
                                  ? member.user.username[0].toUpperCase()
                                  : '?',
                              style: TextStyle(
                                color: isCurrentUser
                                    ? colorScheme.onPrimary
                                    : colorScheme.onPrimaryContainer,
                                fontWeight: FontWeight.bold,
                                fontSize: 20,
                              ),
                            ),
                          ),
                          Positioned(
                            right: 0,
                            bottom: 0,
                            child: Container(
                              width: 16,
                              height: 16,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: member.user.isAway ? colorScheme.error : Colors.green,
                                border: Border.all(color: colorScheme.surface, width: 2),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    member.user.username,
                                    style: theme.textTheme.titleMedium?.copyWith(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 16,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                if (isCurrentUser) ...[
                                  const SizedBox(width: 8),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: colorScheme.primary,
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      l10n.you,
                                      style: TextStyle(
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                        color: colorScheme.onPrimary,
                                      ),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                            const SizedBox(height: 8),
                            Wrap(
                              spacing: 8,
                              runSpacing: 6,
                              children: [
                                member.role == 'ADMIN'
                                    ? AppBadge.primary(
                                        context,
                                        label: memberRoleLabel(l10n, member.role),
                                        icon: Icons.admin_panel_settings,
                                        compact: true,
                                      )
                                    : AppBadge.neutral(
                                        context,
                                        label: memberRoleLabel(l10n, member.role),
                                        icon: Icons.person,
                                        compact: true,
                                      ),
                                member.user.isAway
                                    ? AppBadge.error(
                                        context,
                                        label: l10n.away,
                                        icon: Icons.access_time,
                                        compact: true,
                                      )
                                    : AppBadge.success(
                                        label: l10n.memberStatusActive,
                                        icon: Icons.check_circle,
                                        compact: true,
                                      ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            Row(
                              children: [
                                Icon(
                                  Icons.calendar_today,
                                  size: 14,
                                  color: colorScheme.onSurfaceVariant,
                                ),
                                const SizedBox(width: 4),
                                Flexible(
                                  child: Text(
                                    formatRelativeJoinDate(l10n, member.joinedAt),
                                    style: theme.textTheme.bodySmall?.copyWith(
                                      color: colorScheme.onSurfaceVariant,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      if (canManage)
                        PopupMenuButton<String>(
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(minWidth: 40),
                          onSelected: (value) {
                            if (value == 'role') {
                              _changeRole(member);
                            } else if (value == 'remove') {
                              _removeMember(member);
                            }
                          },
                          itemBuilder: (context) => [
                            PopupMenuItem(
                              value: 'role',
                              child: Text(l10n.changeRole),
                            ),
                            PopupMenuItem(
                              value: 'remove',
                              child: Text(
                                l10n.removeFromGroup,
                                style: TextStyle(color: colorScheme.error),
                              ),
                            ),
                          ],
                        ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
        Positioned(
          right: 16,
          bottom: 16,
          child: FloatingActionButton.extended(
            onPressed: _navigateToInvite,
            icon: const Icon(Icons.person_add),
            label: Text(l10n.inviteMembers),
          ),
        ),
      ],
    );
  }
}
