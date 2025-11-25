import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:taskflow/data/models/reward.dart';
import 'package:taskflow/domain/usecases/reward/reward_usecase_providers.dart';
import 'package:taskflow/l10n/app_localizations.dart';

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
      child: GridView.builder(
        padding: const EdgeInsets.all(16),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 0.75,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
        ),
        itemCount: _rewards.length,
        itemBuilder: (context, index) {
          final reward = _rewards[index];

          return Card(
            elevation: 0,
            clipBehavior: Clip.antiAlias,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(color: colorScheme.outline.withValues(alpha: 0.2)),
            ),
            child: InkWell(
              onTap: () {
                // TODO: Implement request reward
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(AppLocalizations.of(context)!.rewardRequestComingSoon),
                  ),
                );
              },
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
                  Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          reward.name,
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
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
                            const Spacer(),
                            Icon(
                              Icons.arrow_forward,
                              size: 16,
                              color: colorScheme.onSurfaceVariant,
                            ),
                          ],
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
    );
  }
}
