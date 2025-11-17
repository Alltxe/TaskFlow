import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile/data/models/reward.dart';
import 'package:mobile/domain/usecases/reward/reward_usecase_providers.dart';
import 'package:mobile/l10n/app_localizations.dart';

class GroupRewardsScreen extends ConsumerStatefulWidget {
  final String groupId;

  const GroupRewardsScreen({super.key, required this.groupId});

  @override
  ConsumerState<GroupRewardsScreen> createState() => _GroupRewardsScreenState();
}

class _GroupRewardsScreenState extends ConsumerState<GroupRewardsScreen> {
  List<Reward> _rewards = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadRewards();
  }

  Future<void> _loadRewards() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    final getRewardsUseCase = ref.read(getGroupRewardsUseCaseProvider);
    final result = await getRewardsUseCase(widget.groupId);

    if (!mounted) return;

    setState(() {
      _isLoading = false;
      result.fold(
        (failure) => _error = failure.message,
        (rewards) => _rewards = rewards.where((r) => r.isActive).toList(),
      );
    });
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
                onPressed: _loadRewards,
                icon: const Icon(Icons.refresh),
                label: Text(AppLocalizations.of(context)!.retry),
              ),
            ],
          ),
        ),
      );
    }

    if (_rewards.isEmpty) {
      return RefreshIndicator(
        onRefresh: _loadRewards,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  children: [
                    Icon(Icons.card_giftcard, size: 64, color: colorScheme.onSurfaceVariant),
                    const SizedBox(height: 16),
                    Text(
                      AppLocalizations.of(context)!.noRewardsAvailable,
                      style: theme.textTheme.titleLarge,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      AppLocalizations.of(context)!.checkBackLaterRewards,
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
      onRefresh: _loadRewards,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _rewards.length,
        itemBuilder: (context, index) {
          final reward = _rewards[index];
          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            child: ListTile(
              contentPadding: const EdgeInsets.all(16),
              leading: CircleAvatar(
                radius: 30,
                backgroundColor: colorScheme.primaryContainer,
                backgroundImage: reward.imageUrl != null ? NetworkImage(reward.imageUrl!) : null,
                child: reward.imageUrl == null
                    ? Icon(Icons.card_giftcard, color: colorScheme.onPrimaryContainer)
                    : null,
              ),
              title: Text(reward.name, style: theme.textTheme.titleMedium),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (reward.description != null) ...[
                    const SizedBox(height: 4),
                    Text(reward.description!, maxLines: 2, overflow: TextOverflow.ellipsis),
                  ],
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(Icons.stars, size: 16, color: colorScheme.primary),
                      const SizedBox(width: 4),
                      Text(
                        '${reward.cost} points',
                        style: TextStyle(color: colorScheme.primary, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ],
              ),
              trailing: FilledButton.tonalIcon(
                onPressed: () {
                  // TODO: Implement request reward
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(AppLocalizations.of(context)!.rewardRequestComingSoon)),
                  );
                },
                icon: const Icon(Icons.redeem),
                label: Text(AppLocalizations.of(context)!.request),
              ),
            ),
          );
        },
      ),
    );
  }
}
