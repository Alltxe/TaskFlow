import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:taskflow/data/models/leaderboard_entry.dart';
import 'package:taskflow/data/providers/auth_providers.dart';
import 'package:taskflow/domain/usecases/reward/reward_usecase_providers.dart';
import 'package:taskflow/l10n/app_localizations.dart';

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

          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            decoration: BoxDecoration(
              color: isCurrentUser
                  ? colorScheme.primaryContainer.withValues(alpha: 0.15)
                  : colorScheme.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isCurrentUser
                    ? colorScheme.primary.withValues(alpha: 0.5)
                    : colorScheme.outlineVariant.withValues(alpha: 0.5),
                width: isCurrentUser ? 2 : 1,
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  // Rank badge
                  _buildRankBadge(position, colorScheme),
                  const SizedBox(width: 16),

                  // User info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          entry.user.username,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: isCurrentUser ? FontWeight.bold : FontWeight.w600,
                            color: colorScheme.onSurface,
                          ),
                        ),
                        if (isCurrentUser) ...[
                          const SizedBox(height: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: colorScheme.primary,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              AppLocalizations.of(context)!.you,
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: colorScheme.onPrimary,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),

                  // Points
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          const Color(0xFFFFA726),
                          const Color(0xFFFF9800),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFFFF9800).withValues(alpha: 0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.stars_rounded,
                          size: 20,
                          color: Colors.white,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          '${entry.pointsEarned}',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
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
    );
  }

  Widget _buildRankBadge(int position, ColorScheme colorScheme) {
    IconData icon;
    List<Color> gradientColors;
    Color shadowColor;

    switch (position) {
      case 1:
        icon = Icons.emoji_events_rounded;
        gradientColors = [
          const Color(0xFFFFD700),
          const Color(0xFFFFA000),
        ];
        shadowColor = const Color(0xFFFFD700);
        break;
      case 2:
        icon = Icons.emoji_events_rounded;
        gradientColors = [
          const Color(0xFFE0E0E0),
          const Color(0xFFBDBDBD),
        ];
        shadowColor = const Color(0xFFBDBDBD);
        break;
      case 3:
        icon = Icons.emoji_events_rounded;
        gradientColors = [
          const Color(0xFFD4A574),
          const Color(0xFFCD7F32),
        ];
        shadowColor = const Color(0xFFCD7F32);
        break;
      default:
        return Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
            shape: BoxShape.circle,
            border: Border.all(
              color: colorScheme.outlineVariant.withValues(alpha: 0.3),
              width: 2,
            ),
          ),
          child: Center(
            child: Text(
              '#$position',
              style: TextStyle(
                color: colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.bold,
                fontSize: 15,
              ),
            ),
          ),
        );
    }

    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: gradientColors,
        ),
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: shadowColor.withValues(alpha: 0.4),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Icon(icon, color: Colors.white, size: 28),
    );
  }
}
