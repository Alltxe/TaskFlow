import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:taskflow/data/models/group_member.dart';
import 'package:taskflow/data/models/request_reward_input.dart';
import 'package:taskflow/data/models/reward.dart';
import 'package:taskflow/data/providers/auth_providers.dart';
import 'package:taskflow/data/providers/group_providers.dart';
import 'package:taskflow/domain/usecases/reward/reward_usecase_providers.dart';
import 'package:taskflow/l10n/app_localizations.dart';
import 'package:taskflow/presentation/screens/rewards/reward_requests_queue_screen.dart';
import 'package:taskflow/presentation/widgets/rewards/create_reward_dialog.dart';
import 'package:taskflow/presentation/widgets/rewards/edit_reward_dialog.dart';

class GroupRewardsScreen extends ConsumerStatefulWidget {
  final String groupId;

  const GroupRewardsScreen({super.key, required this.groupId});

  @override
  ConsumerState<GroupRewardsScreen> createState() =>
      _GroupRewardsScreenState();
}

class _GroupRewardsScreenState extends ConsumerState<GroupRewardsScreen>
    with SingleTickerProviderStateMixin {
  List<Reward> _rewards = [];
  List<GroupMember>? _members;
  bool _isLoading = true;
  String? _error;
  int? _availablePoints;
  String? _currentUserId;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  bool get _isAdmin {
    if (_currentUserId == null || _members == null || _members!.isEmpty) {
      return false;
    }
    try {
      final currentMember = _members!.firstWhere(
        (m) => m.userId == _currentUserId,
        orElse: () => _members!.first,
      );
      return currentMember.role == 'ADMIN';
    } catch (e) {
      return false;
    }
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    // Get current user
    final authState = ref.read(authStateProvider);
    _currentUserId = authState.user?.id;

    // Load rewards
    final getRewardsUseCase = ref.read(getGroupRewardsUseCaseProvider);
    final rewardsResult = await getRewardsUseCase(widget.groupId);

    // Load members to check role
    final getMembersUseCase = ref.read(getGroupMembersUseCaseProvider);
    final membersResult = await getMembersUseCase(widget.groupId);

    // Load point balance
    final getPointBalanceUseCase = ref.read(getPointBalanceUseCaseProvider);
    final balanceResult = await getPointBalanceUseCase(groupId: widget.groupId);

    if (!mounted) return;

    setState(() {
      _isLoading = false;
      rewardsResult.fold(
        (failure) => _error = failure.message,
        (rewards) => _rewards = rewards.where((r) => r.isActive).toList(),
      );
      membersResult.fold(
        (failure) => null,
        (members) => _members = members,
      );
      balanceResult.fold(
        (failure) => null,
        (balance) => _availablePoints = balance.availableBalance,
      );
    });
  }

  Future<void> _requestReward(Reward reward) async {
    final l10n = AppLocalizations.of(context)!;

    // Check if user has enough points
    if (_availablePoints != null && _availablePoints! < reward.cost) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            l10n.insufficientPoints(reward.cost, _availablePoints!),
          ),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
      return;
    }

    // Show confirmation dialog
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.requestRewardTitle),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l10n.requestRewardMessage(reward.name, reward.cost)),
            if (_availablePoints != null) ...[
              const SizedBox(height: 16),
              Text(
                l10n.yourBalance(_availablePoints!),
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
              ),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(l10n.request),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    // Request the reward
    final requestRewardUseCase = ref.read(requestRewardUseCaseProvider);
    final input = RequestRewardInput(
      rewardId: reward.id,
      groupId: widget.groupId,
    );

    final result = await requestRewardUseCase(input);

    if (!mounted) return;

    result.fold(
      (failure) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(failure.message),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      },
      (transaction) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.rewardRequestedSuccess),
            backgroundColor: Theme.of(context).colorScheme.primary,
          ),
        );
        _loadData();
      },
    );
  }

  Future<void> _showCreateDialog() async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => CreateRewardDialog(groupId: widget.groupId),
    );

    if (result == true) {
      _loadData();
    }
  }

  Future<void> _showEditDialog(Reward reward) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => EditRewardDialog(reward: reward),
    );

    if (result == true) {
      _loadData();
    }
  }

  Future<void> _deleteReward(Reward reward) async {
    final l10n = AppLocalizations.of(context)!;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.confirmDeleteReward),
        content: Text(l10n.confirmDeleteRewardMessage),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            child: Text(l10n.delete),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    final deleteUseCase = ref.read(deleteRewardUseCaseProvider);
    final result = await deleteUseCase(
      rewardId: reward.id,
      groupId: widget.groupId,
    );

    if (!mounted) return;

    result.fold(
      (failure) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(failure.message),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      },
      (_) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.rewardDeletedSuccess),
            backgroundColor: Theme.of(context).colorScheme.primary,
          ),
        );
        _loadData();
      },
    );
  }

  Widget _buildRewardCard(Reward reward) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final canAfford =
        _availablePoints != null && _availablePoints! >= reward.cost;

    return Card(
      elevation: 0,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: canAfford && !_isAdmin
              ? colorScheme.primary
              : colorScheme.outline.withValues(alpha: 0.2),
          width: canAfford && !_isAdmin ? 2 : 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Image or icon
          AspectRatio(
            aspectRatio: 16 / 9,
            child: reward.imageUrl != null
                ? Image.network(
                    reward.imageUrl!,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        color: colorScheme.primaryContainer,
                        child: Icon(
                          Icons.card_giftcard,
                          size: 40,
                          color: colorScheme.onPrimaryContainer,
                        ),
                      );
                    },
                  )
                : Container(
                    color: colorScheme.primaryContainer,
                    child: Icon(
                      Icons.card_giftcard,
                      size: 40,
                      color: colorScheme.onPrimaryContainer,
                    ),
                  ),
          ),

          // Content
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          reward.name,
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (_isAdmin) ...[
                        IconButton(
                          icon: const Icon(Icons.edit, size: 20),
                          onPressed: () => _showEditDialog(reward),
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete, size: 20),
                          color: colorScheme.error,
                          onPressed: () => _deleteReward(reward),
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                        ),
                      ],
                    ],
                  ),
                  if (reward.description != null) ...[
                    const SizedBox(height: 4),
                    Expanded(
                      child: Text(
                        reward.description!,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                  const Spacer(),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(
                        Icons.stars,
                        size: 16,
                        color: colorScheme.primary,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${reward.cost}',
                        style: theme.textTheme.labelLarge?.copyWith(
                          color: colorScheme.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (canAfford && !_isAdmin) ...[
                        const Spacer(),
                        Icon(
                          Icons.check_circle,
                          size: 16,
                          color: colorScheme.primary,
                        ),
                      ],
                    ],
                  ),
                  if (!_isAdmin) ...[
                    const SizedBox(height: 8),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton(
                        onPressed: canAfford ? () => _requestReward(reward) : null,
                        style: FilledButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                        ),
                        child: Text(
                          canAfford
                              ? AppLocalizations.of(context)!.request
                              : AppLocalizations.of(context)!.insufficientPointsShort,
                          style: theme.textTheme.labelSmall,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final l10n = AppLocalizations.of(context)!;

    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (_error != null) {
      return Scaffold(
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error_outline, size: 64, color: colorScheme.error),
                const SizedBox(height: 16),
                Text(_error!, textAlign: TextAlign.center),
                const SizedBox(height: 16),
                FilledButton.icon(
                  onPressed: _loadData,
                  icon: const Icon(Icons.refresh),
                  label: Text(l10n.retry),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: _isAdmin
          ? AppBar(
              title: Text(l10n.rewards),
              bottom: TabBar(
                controller: _tabController,
                tabs: [
                  Tab(text: l10n.manageRewards),
                  Tab(text: l10n.viewRequests),
                ],
              ),
            )
          : AppBar(
              title: Text(l10n.rewards),
            ),
      body: _isAdmin
          ? TabBarView(
              controller: _tabController,
              children: [
                _buildRewardsGrid(),
                RewardRequestsQueueScreen(groupId: widget.groupId),
              ],
            )
          : _buildRewardsGrid(),
      floatingActionButton: _isAdmin
          ? FloatingActionButton.extended(
              onPressed: _showCreateDialog,
              icon: const Icon(Icons.add),
              label: Text(l10n.createReward),
            )
          : null,
    );
  }

  Widget _buildRewardsGrid() {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    if (_rewards.isEmpty) {
      return RefreshIndicator(
        onRefresh: _loadData,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  children: [
                    Icon(Icons.card_giftcard,
                        size: 64, color: colorScheme.onSurfaceVariant),
                    const SizedBox(height: 16),
                    Text(
                      l10n.noRewardsAvailable,
                      style: theme.textTheme.titleLarge,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      l10n.checkBackLaterRewards,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadData,
      child: GridView.builder(
        padding: const EdgeInsets.all(16),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 0.75,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
        ),
        itemCount: _rewards.length,
        itemBuilder: (context, index) => _buildRewardCard(_rewards[index]),
      ),
    );
  }
}
