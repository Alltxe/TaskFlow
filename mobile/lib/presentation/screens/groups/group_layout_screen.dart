import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:taskflow/data/models/group.dart';
import 'package:taskflow/data/models/group_member.dart';
import 'package:taskflow/data/providers/auth_providers.dart';
import 'package:taskflow/data/providers/group_providers.dart';
import 'package:taskflow/l10n/app_localizations.dart';
import 'package:taskflow/presentation/screens/groups/group_leaderboard_screen.dart';
import 'package:taskflow/presentation/screens/groups/group_members_screen.dart';
import 'package:taskflow/presentation/screens/groups/group_rewards_screen.dart';
import 'package:taskflow/presentation/screens/groups/group_settings_screen.dart';
import 'package:taskflow/presentation/screens/tasks/tasks_screen.dart';
import 'package:taskflow/presentation/widgets/common/app_navigation_back_button.dart';

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
      print('DEBUG: Current user ID: $_currentUserId');
    } else {
      _currentUserId = null;
      print('DEBUG: No authenticated user');
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
      groupResult.fold(
        (failure) {
          print('DEBUG: Failed to load group: ${failure.message}');
        },
        (group) {
          _group = group;
          print('DEBUG: Group loaded: ${group.name}');
        },
      );
      membersResult.fold(
        (failure) {
          print('DEBUG: Failed to load members: ${failure.message}');
        },
        (members) {
          _members = members;
          print('DEBUG: Members loaded: ${members.length}');
          for (var member in members) {
            print(
              'DEBUG: Member - userId: ${member.userId}, role: ${member.role}, username: ${member.user.username}',
            );
          }
        },
      );
    });

    // Check admin status
    print('DEBUG: Is admin check: $_isAdmin');

    // Initialize tab controller after loading group
    if (_group != null) {
      _tabController = TabController(length: _getTabsCount(), vsync: this);
      print('DEBUG: Tab count: ${_getTabsCount()}');
      setState(() {});
    }
  }

  bool get _isAdmin {
    if (_currentUserId == null || _members == null) return false;
    try {
      final currentMember = _members!.firstWhere((m) => m.userId == _currentUserId);
      return currentMember.role == 'ADMIN';
    } catch (e) {
      // User not found in members list
      return false;
    }
  }

  int _getTabsCount() {
    int count = 1; // Tasks tab always present

    if (_group?.gamificationEnabled == true) {
      count += 2; // Rewards and Leaderboard
    }

    if (_isAdmin) {
      // if (_group?.requiresApproval == true) {
      //   count++; // Approval tab
      // }
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
      // if (_group?.requiresApproval == true) {
      //   tabs.add(
      //     Tab(
      //       text: AppLocalizations.of(context)!.approval,
      //       icon: const Icon(Icons.check_circle, size: 20),
      //     ),
      //   );
      // }
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
        leading: const AppNavigationBackButton(fallbackRoute: '/groups'),
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
      // if (_group?.requiresApproval == true) {
      //   views.add(_buildApprovalTab());
      // }
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

  Widget _buildMembersTab() {
    return GroupMembersScreen(groupId: widget.groupId);
  }

  Widget _buildSettingsTab() {
    return GroupSettingsContent(groupId: widget.groupId, group: _group!);
  }
}
