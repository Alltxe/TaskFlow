import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:taskflow/data/models/group.dart';
import 'package:taskflow/l10n/app_localizations.dart';
import 'package:taskflow/presentation/providers/group_notifier.dart';

/// Groups tab screen
class GroupsScreen extends ConsumerStatefulWidget {
  const GroupsScreen({super.key});

  @override
  ConsumerState<GroupsScreen> createState() => _GroupsScreenState();
}

class _GroupsScreenState extends ConsumerState<GroupsScreen> {
  @override
  void initState() {
    super.initState();
    // Load groups on init
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(groupNotifierProvider.notifier).loadGroups();
    });
  }

  @override
  Widget build(BuildContext context) {
    final groupState = ref.watch(groupNotifierProvider);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(title: Text(AppLocalizations.of(context)!.groups)),
      body: RefreshIndicator(
        onRefresh: () async {
          await ref.read(groupNotifierProvider.notifier).refresh();
        },
        child: groupState.when(
          initial: () => const Center(child: CircularProgressIndicator()),
          loading: () => const Center(child: CircularProgressIndicator()),
          loaded: (groups) {
            if (groups.isEmpty) {
              return _buildEmptyState(context, colorScheme);
            }
            return _buildGroupsList(groups, context, colorScheme);
          },
          error: (message) => _buildErrorState(context, message, colorScheme),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/groups/create'),
        icon: const Icon(Icons.add),
        label: Text(AppLocalizations.of(context)!.createGroup),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context, ColorScheme colorScheme) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                Icon(Icons.group_add, size: 64, color: colorScheme.onSurfaceVariant),
                const SizedBox(height: 16),
                Text(
                  AppLocalizations.of(context)!.noGroupsYet,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 8),
                Text(
                  'Create a new group or join one with an invite link',
                  textAlign: TextAlign.center,
                  style: Theme.of(
                    context,
                  ).textTheme.bodyMedium?.copyWith(color: colorScheme.onSurfaceVariant),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildGroupsList(List<Group> groups, BuildContext context, ColorScheme colorScheme) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: groups.length,
      itemBuilder: (context, index) {
        final group = groups[index];
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: colorScheme.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: colorScheme.outlineVariant.withValues(alpha: 0.5),
              width: 1,
            ),
          ),
          child: InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: () => context.push('/groups/${group.id}'),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      // Group icon
                      Container(
                        width: 56,
                        height: 56,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              colorScheme.primary.withValues(alpha: 0.8),
                              colorScheme.primary,
                            ],
                          ),
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: colorScheme.primary.withValues(alpha: 0.3),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Icon(
                          Icons.groups_rounded,
                          color: colorScheme.onPrimary,
                          size: 32,
                        ),
                      ),
                      const SizedBox(width: 16),
                      // Group name
                      Expanded(
                        child: Text(
                          group.name,
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: colorScheme.onSurface,
                          ),
                        ),
                      ),
                      // Arrow icon
                      Icon(
                        Icons.chevron_right,
                        color: colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
                        size: 28,
                      ),
                    ],
                  ),
                  if (group.description != null || group.gamificationEnabled) ...[
                    const SizedBox(height: 12),
                    if (group.description != null) ...[
                      Text(
                        group.description!,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                          height: 1.4,
                        ),
                      ),
                    ],
                    if (group.gamificationEnabled) ...[
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: const Color(0xFF2196F3).withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: const Color(0xFF2196F3).withValues(alpha: 0.3),
                                width: 1,
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons.stars_rounded,
                                  size: 16,
                                  color: Color(0xFF2196F3),
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  AppLocalizations.of(context)!.gamified,
                                  style: const TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFF2196F3),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildErrorState(BuildContext context, String message, ColorScheme colorScheme) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Card(
          color: colorScheme.errorContainer,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Icon(Icons.error_outline, color: colorScheme.onErrorContainer),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Error',
                        style: Theme.of(
                          context,
                        ).textTheme.titleMedium?.copyWith(color: colorScheme.onErrorContainer),
                      ),
                      const SizedBox(height: 4),
                      Text(message, style: TextStyle(color: colorScheme.onErrorContainer)),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        FilledButton.icon(
          onPressed: () {
            ref.read(groupNotifierProvider.notifier).refresh();
          },
          icon: const Icon(Icons.refresh),
          label: Text(AppLocalizations.of(context)!.retry),
        ),
      ],
    );
  }
}
