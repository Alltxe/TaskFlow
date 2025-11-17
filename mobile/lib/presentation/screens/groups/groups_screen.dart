import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile/data/models/group.dart';
import 'package:mobile/l10n/app_localizations.dart';
import 'package:mobile/presentation/providers/group_notifier.dart';

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
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: ListTile(
            contentPadding: const EdgeInsets.all(16),
            leading: CircleAvatar(
              backgroundColor: colorScheme.primaryContainer,
              child: Icon(Icons.groups, color: colorScheme.onPrimaryContainer),
            ),
            title: Text(group.name, style: Theme.of(context).textTheme.titleMedium),
            subtitle: group.description != null
                ? Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(group.description!, maxLines: 2, overflow: TextOverflow.ellipsis),
                  )
                : null,
            trailing: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (group.gamificationEnabled)
                  Chip(
                    label: Text(AppLocalizations.of(context)!.gamified),
                    labelStyle: TextStyle(fontSize: 11, color: colorScheme.onSecondaryContainer),
                    backgroundColor: colorScheme.secondaryContainer,
                    visualDensity: VisualDensity.compact,
                  ),
              ],
            ),
            onTap: () => context.push('/groups/${group.id}'),
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
