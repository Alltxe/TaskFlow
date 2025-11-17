import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:mobile/data/models/group.dart';
import 'package:mobile/data/models/group_member.dart';
import 'package:mobile/data/providers/auth_providers.dart';
import 'package:mobile/data/providers/group_providers.dart';
import 'package:mobile/l10n/app_localizations.dart';
import 'package:mobile/presentation/screens/groups/group_leaderboard_screen.dart';
import 'package:mobile/presentation/screens/groups/group_rewards_screen.dart';
import 'package:mobile/presentation/screens/tasks/tasks_screen.dart';

/// Layout for group screens with tabs
class GroupLayoutScreen extends ConsumerStatefulWidget {
  final String groupId;
  final Widget child;

  const GroupLayoutScreen({super.key, required this.groupId, required this.child});

  @override
  ConsumerState<GroupLayoutScreen> createState() => _GroupLayoutScreenState();
}

class _GroupLayoutScreenState extends ConsumerState<GroupLayoutScreen>
    with SingleTickerProviderStateMixin {
  Group? _group;
  List<GroupMember>? _members;
  bool _isLoading = true;
  String? _currentUserId;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);

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
      groupResult.fold((failure) {}, (group) => _group = group);
      membersResult.fold((failure) {}, (members) => _members = members);
    });

    // Initialize tab controller after loading group
    if (_group != null) {
      _tabController = TabController(length: _getTabsCount(), vsync: this);
      setState(() {});
    }
  }

  bool get _isAdmin {
    if (_currentUserId == null || _members == null) return false;
    final currentMember = _members!.firstWhere(
      (m) => m.userId == _currentUserId,
      orElse: () => _members!.first,
    );
    return currentMember.role == 'ADMIN';
  }

  int _getTabsCount() {
    int count = 1; // Tasks tab always present

    if (_group?.gamificationEnabled == true) {
      count += 2; // Rewards and Leaderboard
    }

    if (_isAdmin) {
      if (_group?.requiresApproval == true) {
        count++; // Approval tab
      }
      count += 2; // Members and Settings
    }

    return count;
  }

  List<Tab> _getTabs() {
    final tabs = <Tab>[
      Tab(
        text: AppLocalizations.of(context)!.tasksTitle,
        icon: const Icon(Icons.task_alt, size: 20),
      ),
    ];

    if (_group?.gamificationEnabled == true) {
      tabs.addAll([
        Tab(
          text: AppLocalizations.of(context)!.rewards,
          icon: const Icon(Icons.card_giftcard, size: 20),
        ),
        Tab(
          text: AppLocalizations.of(context)!.leaderboard,
          icon: const Icon(Icons.leaderboard, size: 20),
        ),
      ]);
    }

    if (_isAdmin) {
      if (_group?.requiresApproval == true) {
        tabs.add(
          Tab(
            text: AppLocalizations.of(context)!.approval,
            icon: const Icon(Icons.check_circle, size: 20),
          ),
        );
      }
      tabs.addAll([
        Tab(text: AppLocalizations.of(context)!.members, icon: const Icon(Icons.people, size: 20)),
        Tab(
          text: AppLocalizations.of(context)!.settingsTitle,
          icon: const Icon(Icons.settings, size: 20),
        ),
      ]);
    }

    return tabs;
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading || _group == null) {
      return Scaffold(
        appBar: AppBar(title: Text(AppLocalizations.of(context)!.loading)),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(_group!.name),
            if (_group!.description != null)
              Text(
                _group!.description!,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
          ],
        ),
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          tabs: _getTabs(),
          tabAlignment: TabAlignment.start,
        ),
      ),
      body: TabBarView(controller: _tabController, children: _getTabViews()),
    );
  }

  List<Widget> _getTabViews() {
    final views = <Widget>[
      // Tasks tab
      _buildTasksTab(),
    ];

    if (_group?.gamificationEnabled == true) {
      views.addAll([_buildRewardsTab(), _buildLeaderboardTab()]);
    }

    if (_isAdmin) {
      if (_group?.requiresApproval == true) {
        views.add(_buildApprovalTab());
      }
      views.addAll([_buildMembersTab(), _buildSettingsTab()]);
    }

    return views;
  }

  Widget _buildTasksTab() {
    // Show tasks in the context of this group — which now includes a My Tasks tab
    return TasksScreen(groupId: widget.groupId);
  }

  Widget _buildRewardsTab() {
    return GroupRewardsScreen(groupId: widget.groupId);
  }

  Widget _buildLeaderboardTab() {
    return GroupLeaderboardScreen(groupId: widget.groupId);
  }

  Widget _buildApprovalTab() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.check_circle, size: 64),
          const SizedBox(height: 16),
          Text(AppLocalizations.of(context)!.taskApproval),
          const SizedBox(height: 8),
          Text(
            AppLocalizations.of(context)!.comingSoon,
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ),
    );
  }

  Widget _buildMembersTab() {
    if (_members == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return RefreshIndicator(
      onRefresh: _loadData,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            AppLocalizations.of(context)!.groupMembersCount(_members!.length),
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 16),
          ..._members!.map((member) {
            final isCurrentUser = member.userId == _currentUserId;
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
                title: Row(
                  children: [
                    Text(member.user.username),
                    if (isCurrentUser) ...[
                      const SizedBox(width: 8),
                      Chip(
                        label: Text(AppLocalizations.of(context)!.youLabel),
                        labelStyle: const TextStyle(fontSize: 10),
                        visualDensity: VisualDensity.compact,
                        padding: EdgeInsets.zero,
                      ),
                    ],
                  ],
                ),
                subtitle: Text(
                  AppLocalizations.of(
                    context,
                  )!.joinedAt(DateFormat('MMM d, y').format(member.joinedAt)),
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Chip(
                      label: Text(member.role),
                      backgroundColor: member.role == 'ADMIN'
                          ? Theme.of(context).colorScheme.primaryContainer
                          : Theme.of(context).colorScheme.secondaryContainer,
                    ),
                    if (_isAdmin && !isCurrentUser) ...[
                      const SizedBox(width: 8),
                      PopupMenuButton<String>(
                        onSelected: (value) {
                          if (value == 'remove') {
                            _removeMember(member);
                          } else if (value == 'promote' || value == 'demote') {
                            _changeRole(member);
                          }
                        },
                        itemBuilder: (context) => [
                          PopupMenuItem(
                            value: member.role == 'ADMIN' ? 'demote' : 'promote',
                            child: Text(
                              member.role == 'ADMIN'
                                  ? AppLocalizations.of(context)!.makeMember
                                  : AppLocalizations.of(context)!.makeAdmin,
                            ),
                          ),
                          PopupMenuItem(
                            value: 'remove',
                            child: Text(AppLocalizations.of(context)!.removeFromGroup),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildSettingsTab() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.settings, size: 64),
            const SizedBox(height: 16),
            Text(AppLocalizations.of(context)!.useSettingsIconInAppBar),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: () => context.push('/groups/${widget.groupId}/settings'),
              icon: const Icon(Icons.settings),
              label: Text(AppLocalizations.of(context)!.goToSettings),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _removeMember(GroupMember member) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(AppLocalizations.of(context)!.removeMemberTitle),
        content: Text(AppLocalizations.of(context)!.removeMemberConfirm(member.user.username)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(AppLocalizations.of(context)!.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            style: FilledButton.styleFrom(backgroundColor: Theme.of(context).colorScheme.error),
            child: Text(AppLocalizations.of(context)!.removeLabel),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;

    final removeMemberUseCase = ref.read(removeMemberUseCaseProvider);
    final result = await removeMemberUseCase(widget.groupId, member.userId);

    if (!mounted) return;

    result.fold(
      (failure) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context)!.errorWithMessage(failure.message)),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      },
      (_) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(AppLocalizations.of(context)!.memberRemovedSuccess)));
        _loadData(); // Reload members
      },
    );
  }

  Future<void> _changeRole(GroupMember member) async {
    final newRole = member.role == 'ADMIN' ? 'MEMBER' : 'ADMIN';
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(AppLocalizations.of(context)!.changeRoleTitle),
        content: Text(
          AppLocalizations.of(context)!.changeRoleConfirm(member.user.username, newRole),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(AppLocalizations.of(context)!.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(AppLocalizations.of(context)!.change),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;

    final updateRoleUseCase = ref.read(updateMemberRoleUseCaseProvider);
    final result = await updateRoleUseCase(widget.groupId, member.userId, newRole);

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
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppLocalizations.of(context)!.roleChangedTo(newRole))),
        );
        _loadData(); // Reload members
      },
    );
  }
}
