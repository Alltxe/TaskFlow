import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile/data/models/group_member.dart';
import 'package:mobile/data/providers/auth_providers.dart';
import 'package:mobile/data/providers/group_providers.dart';
import 'package:mobile/l10n/app_localizations.dart';
import 'package:mobile/presentation/screens/groups/invite_screen.dart';

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

    // Get current user ID
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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

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
                label: Text(AppLocalizations.of(context)!.retry),
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
                        Text(
                          AppLocalizations.of(context)!.noDataYet,
                          style: theme.textTheme.titleLarge,
                        ),
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
              label: Text(AppLocalizations.of(context)!.inviteMembers),
            ),
          ),
        ],
      );
    }

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
                    children: [
                      // Avatar with status indicator
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
                          // Status indicator
                          Positioned(
                            right: 0,
                            bottom: 0,
                            child: Container(
                              width: 16,
                              height: 16,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: member.user.isAway
                                    ? colorScheme.error
                                    : Colors.green,
                                border: Border.all(
                                  color: colorScheme.surface,
                                  width: 2,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(width: 16),

                      // User info
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Username and "You" badge
                            Row(
                              children: [
                                Flexible(
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
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 2,
                                    ),
                                    decoration: BoxDecoration(
                                      color: colorScheme.primary,
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      AppLocalizations.of(context)!.you,
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

                            // Role and Status badges
                            Row(
                              children: [
                                // Role badge
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: member.role == 'ADMIN'
                                        ? colorScheme.primaryContainer
                                        : colorScheme.surfaceContainerHighest,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        member.role == 'ADMIN'
                                            ? Icons.admin_panel_settings
                                            : Icons.person,
                                        size: 14,
                                        color: member.role == 'ADMIN'
                                            ? colorScheme.onPrimaryContainer
                                            : colorScheme.onSurfaceVariant,
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        member.role == 'ADMIN' ? 'Admin' : 'Member',
                                        style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w500,
                                          color: member.role == 'ADMIN'
                                              ? colorScheme.onPrimaryContainer
                                              : colorScheme.onSurfaceVariant,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 8),

                                // Status badge
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: member.user.isAway
                                        ? colorScheme.errorContainer.withValues(alpha: 0.5)
                                        : Colors.green.withValues(alpha: 0.15),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        member.user.isAway
                                            ? Icons.access_time
                                            : Icons.check_circle,
                                        size: 14,
                                        color: member.user.isAway
                                            ? colorScheme.error
                                            : Colors.green.shade700,
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        member.user.isAway
                                            ? AppLocalizations.of(context)!.away
                                            : 'Active',
                                        style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w500,
                                          color: member.user.isAway
                                              ? colorScheme.error
                                              : Colors.green.shade700,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),

                      // Join date
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.calendar_today,
                              size: 16,
                              color: colorScheme.onSurfaceVariant,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              _formatDate(member.joinedAt),
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: colorScheme.onSurfaceVariant,
                                fontWeight: FontWeight.w600,
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ),
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
            label: Text(AppLocalizations.of(context)!.inviteMembers),
          ),
        ),
      ],
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays < 1) {
      return 'Today';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else if (difference.inDays < 30) {
      return '${(difference.inDays / 7).floor()}w ago';
    } else if (difference.inDays < 365) {
      return '${(difference.inDays / 30).floor()}mo ago';
    } else {
      return '${(difference.inDays / 365).floor()}y ago';
    }
  }
}
