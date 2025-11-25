import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:taskflow/data/providers/auth_providers.dart';
import 'package:taskflow/data/providers/profile_providers.dart';
import 'package:taskflow/l10n/app_localizations.dart';

/// Profile tab screen
class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statisticsAsync = ref.watch(getUserStatisticsUseCaseProvider);
    final groupsAsync = ref.watch(getUserGroupsUseCaseProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.profileTitle),
        actions: [
          IconButton(icon: const Icon(Icons.settings), onPressed: () => context.push('/settings')),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(getUserProfileUseCaseProvider);
          ref.invalidate(getUserStatisticsUseCaseProvider);
          ref.invalidate(getUserGroupsUseCaseProvider);
        },
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Profile header
            _buildProfileHeader(context, ref),
            const SizedBox(height: 24),

            // Statistics cards
            FutureBuilder(
              future: statisticsAsync.call(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                return snapshot.data?.fold(
                      (failure) => _buildErrorCard(context, failure.message),
                      (statistics) => _buildStatisticsSection(context, statistics),
                    ) ??
                    const SizedBox.shrink();
              },
            ),

            const SizedBox(height: 24),

            // Groups section
            FutureBuilder(
              future: groupsAsync.call(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                return snapshot.data?.fold(
                      (failure) => _buildErrorCard(context, failure.message),
                      (groups) => _buildGroupsSection(context, groups),
                    ) ??
                    const SizedBox.shrink();
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileHeader(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateProvider);

    if (authState.status == AuthStatus.loading) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(48),
          child: Center(child: CircularProgressIndicator()),
        ),
      );
    }

    if (authState.status != AuthStatus.authenticated || authState.user == null) {
      return const SizedBox.shrink();
    }

    final user = authState.user!;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Avatar
            Stack(
              children: [
                CircleAvatar(
                  radius: 50,
                  backgroundImage: user.avatarUrl != null
                      ? CachedNetworkImageProvider(user.avatarUrl!)
                      : null,
                  child: user.avatarUrl == null
                      ? Text(
                          user.username[0].toUpperCase(),
                          style: Theme.of(context).textTheme.displayMedium,
                        )
                      : null,
                ),
                Positioned(
                  right: 0,
                  bottom: 0,
                  child: CircleAvatar(
                    radius: 18,
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    child: IconButton(
                      icon: const Icon(Icons.camera_alt, size: 18),
                      color: Theme.of(context).colorScheme.onPrimary,
                      onPressed: () => context.push('/edit-profile'),
                      padding: EdgeInsets.zero,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Username
            Text(user.username, style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 4),

            // Email
            Text(
              user.email,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 12),

            // Away status
            if (user.isAway)
              Chip(
                avatar: const Icon(Icons.flight_takeoff, size: 16),
                label: Text(
                  user.awayUntil != null
                      ? AppLocalizations.of(
                          context,
                        )!.awayUntil(_formatDate(context, user.awayUntil!))
                      : AppLocalizations.of(context)!.away,
                ),
                backgroundColor: Theme.of(context).colorScheme.secondaryContainer,
              ),

            const SizedBox(height: 16),

            // Edit profile button
            FilledButton.tonalIcon(
              onPressed: () => context.push('/edit-profile'),
              icon: const Icon(Icons.edit),
              label: Text(AppLocalizations.of(context)!.editProfile),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatisticsSection(BuildContext context, statistics) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppLocalizations.of(context)!.statisticsTitle,
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                context,
                AppLocalizations.of(context)!.points,
                statistics.currentPointBalance.toString(),
                Icons.stars,
                Theme.of(context).colorScheme.primary,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildStatCard(
                context,
                AppLocalizations.of(context)!.completed,
                statistics.tasksCompleted.toString(),
                Icons.check_circle,
                Colors.green,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                context,
                AppLocalizations.of(context)!.completionRate,
                '${statistics.completionRate.toStringAsFixed(1)}%',
                Icons.trending_up,
                Colors.blue,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildStatCard(
                context,
                AppLocalizations.of(context)!.onTimeRate,
                '${statistics.onTimePercentage.toStringAsFixed(1)}%',
                Icons.schedule,
                Colors.orange,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatCard(
    BuildContext context,
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(height: 8),
            Text(
              value,
              style: Theme.of(
                context,
              ).textTheme.headlineMedium?.copyWith(color: color, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(label, style: Theme.of(context).textTheme.bodySmall, textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }

  Widget _buildGroupsSection(BuildContext context, List groups) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(AppLocalizations.of(context)!.myGroups, style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 12),
        if (groups.isEmpty)
          Card(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Center(
                child: Column(
                  children: [
                    Icon(
                      Icons.group_add,
                      size: 48,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      AppLocalizations.of(context)!.noGroupsYet,
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      AppLocalizations.of(context)!.joinOrCreateGroup,
                      style: Theme.of(context).textTheme.bodySmall,
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
          )
        else
          ...groups.map(
            (group) => Card(
              margin: const EdgeInsets.only(bottom: 8),
              child: ListTile(
                leading: CircleAvatar(child: Text(group.name[0].toUpperCase())),
                title: Text(group.name),
                subtitle: Text(group.description ?? AppLocalizations.of(context)!.noDescription),
                trailing: Chip(
                  label: Text(group.role),
                  backgroundColor: group.role == 'admin'
                      ? Theme.of(context).colorScheme.primaryContainer
                      : null,
                ),
                onTap: () {
                  // Navigate to group detail
                  // context.push('/groups/${group.id}');
                },
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildErrorCard(BuildContext context, String message) {
    return Card(
      color: Theme.of(context).colorScheme.errorContainer,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(Icons.error_outline, color: Theme.of(context).colorScheme.onErrorContainer),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: TextStyle(color: Theme.of(context).colorScheme.onErrorContainer),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(BuildContext context, DateTime date) {
    final now = DateTime.now();
    final difference = date.difference(now).inDays;

    if (difference == 0) {
      return AppLocalizations.of(context)!.today;
    } else if (difference == 1) {
      return AppLocalizations.of(context)!.tomorrow;
    } else if (difference < 7) {
      return AppLocalizations.of(context)!.inDays(difference);
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }
}
