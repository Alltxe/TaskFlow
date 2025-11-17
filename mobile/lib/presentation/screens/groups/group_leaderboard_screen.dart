import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile/data/models/leaderboard_entry.dart';
import 'package:mobile/data/providers/auth_providers.dart';
import 'package:mobile/domain/usecases/reward/reward_usecase_providers.dart';
import 'package:mobile/l10n/app_localizations.dart';

class GroupLeaderboardScreen extends ConsumerStatefulWidget {
  final String groupId;

  const GroupLeaderboardScreen({super.key, required this.groupId});

  @override
  ConsumerState<GroupLeaderboardScreen> createState() => _GroupLeaderboardScreenState();
}

class _GroupLeaderboardScreenState extends ConsumerState<GroupLeaderboardScreen> {
  List<LeaderboardEntry> _leaderboard = [];
  bool _isLoading = true;
  String? _error;
  String? _currentUserId;

  @override
  void initState() {
    super.initState();
    _loadLeaderboard();
  }

  Future<void> _loadLeaderboard() async {
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

    final getLeaderboardUseCase = ref.read(getGroupLeaderboardUseCaseProvider);
    final result = await getLeaderboardUseCase(widget.groupId);

    if (!mounted) return;

    setState(() {
      _isLoading = false;
      result.fold(
        (failure) => _error = failure.message,
        (leaderboard) => _leaderboard = leaderboard,
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
                onPressed: _loadLeaderboard,
                icon: const Icon(Icons.refresh),
                label: Text(AppLocalizations.of(context)!.retry),
              ),
            ],
          ),
        ),
      );
    }

    if (_leaderboard.isEmpty) {
      return RefreshIndicator(
        onRefresh: _loadLeaderboard,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  children: [
                    Icon(Icons.leaderboard, size: 64, color: colorScheme.onSurfaceVariant),
                    const SizedBox(height: 16),
                    Text(
                      AppLocalizations.of(context)!.noDataYet,
                      style: theme.textTheme.titleLarge,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      AppLocalizations.of(context)!.completeTasksLeaderboard,
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
      onRefresh: _loadLeaderboard,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _leaderboard.length,
        itemBuilder: (context, index) {
          final entry = _leaderboard[index];
          final isCurrentUser = entry.user.id == _currentUserId;
          final position = entry.rank;

          return Card(
            margin: const EdgeInsets.only(bottom: 8),
            color: isCurrentUser
                ? colorScheme.primaryContainer.withAlpha((0.3 * 255).round())
                : null,
            child: ListTile(
              leading: _buildRankBadge(position, colorScheme),
              title: Row(
                children: [
                  Text(
                    entry.user.username,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: isCurrentUser ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                  if (isCurrentUser) ...[
                    const SizedBox(width: 8),
                    Chip(
                      label: Text(AppLocalizations.of(context)!.you),
                      labelStyle: const TextStyle(fontSize: 10),
                      visualDensity: VisualDensity.compact,
                      padding: EdgeInsets.zero,
                    ),
                  ],
                ],
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 4),
                  Text(AppLocalizations.of(context)!.pointsLabel(entry.pointsEarned)),
                ],
              ),
              trailing: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.stars, size: 20, color: colorScheme.primary),
                      const SizedBox(width: 4),
                      Text(
                        '${entry.pointsEarned}',
                        style: theme.textTheme.titleLarge?.copyWith(
                          color: colorScheme.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  Text(AppLocalizations.of(context)!.pointsWord, style: theme.textTheme.bodySmall),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildRankBadge(int position, ColorScheme colorScheme) {
    IconData icon;
    Color color;

    switch (position) {
      case 1:
        icon = Icons.emoji_events;
        color = Colors.amber;
        break;
      case 2:
        icon = Icons.emoji_events;
        color = Colors.grey[400]!;
        break;
      case 3:
        icon = Icons.emoji_events;
        color = Colors.brown[300]!;
        break;
      default:
        return CircleAvatar(
          backgroundColor: colorScheme.surfaceContainerHighest,
          child: Text(
            '#$position',
            style: TextStyle(color: colorScheme.onSurfaceVariant, fontWeight: FontWeight.bold),
          ),
        );
    }

    return CircleAvatar(
      backgroundColor: color.withAlpha((0.2 * 255).round()),
      child: Icon(icon, color: color),
    );
  }
}
