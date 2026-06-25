import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:taskflow/data/models/rotation.dart';
import 'package:taskflow/data/providers/rotation_providers.dart';
import 'package:taskflow/l10n/app_localizations.dart';
import 'package:taskflow/presentation/widgets/common/app_navigation_back_button.dart';

class GroupRotationScreen extends ConsumerStatefulWidget {
  final String groupId;

  const GroupRotationScreen({super.key, required this.groupId});

  @override
  ConsumerState<GroupRotationScreen> createState() => _GroupRotationScreenState();
}

class _GroupRotationScreenState extends ConsumerState<GroupRotationScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        leading: AppNavigationBackButton(fallbackRoute: '/groups/${widget.groupId}'),
        title: Text(l10n.rotationSchedule),
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(text: l10n.rotationScheduleTitle),
            Tab(text: l10n.rotationHistoryTitle),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _ScheduleTab(groupId: widget.groupId),
          _HistoryTab(groupId: widget.groupId),
        ],
      ),
    );
  }
}

class _ScheduleTab extends ConsumerWidget {
  final String groupId;

  const _ScheduleTab({required this.groupId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final scheduleAsync = ref.watch(rotationScheduleProvider(groupId));

    return scheduleAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text(e.toString())),
      data: (entries) {
        if (entries.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.event_available,
                  size: 64,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
                const SizedBox(height: 16),
                Text(l10n.rotationScheduleEmpty),
              ],
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: () async => ref.invalidate(rotationScheduleProvider(groupId)),
          child: ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: entries.length,
            itemBuilder: (_, i) => _ScheduleCard(entry: entries[i]),
          ),
        );
      },
    );
  }
}

class _ScheduleCard extends StatelessWidget {
  final RotationScheduleEntry entry;

  const _ScheduleCard({required this.entry});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final d = entry.scheduledDate;
    final dateStr =
        '${d.day.toString().padLeft(2, '0')}.${d.month.toString().padLeft(2, '0')}.${d.year}';

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(child: Text(entry.username[0].toUpperCase())),
        title: Text(entry.taskTitle),
        subtitle: Text(l10n.assignedTo(entry.username)),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              dateStr,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.primary,
              ),
            ),
            Text(
              '${entry.points} pts',
              style: theme.textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }
}

class _HistoryTab extends ConsumerWidget {
  final String groupId;

  const _HistoryTab({required this.groupId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final historyAsync = ref.watch(rotationHistoryProvider(groupId));

    return historyAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text(e.toString())),
      data: (result) {
        if (result.items.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.history,
                  size: 64,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
                const SizedBox(height: 16),
                Text(l10n.rotationHistoryEmpty),
              ],
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: () async => ref.invalidate(rotationHistoryProvider(groupId)),
          child: ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: result.items.length,
            itemBuilder: (_, i) => _HistoryCard(entry: result.items[i]),
          ),
        );
      },
    );
  }
}

class _HistoryCard extends StatelessWidget {
  final RotationHistoryEntry entry;

  const _HistoryCard({required this.entry});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    Color statusColor;
    IconData statusIcon;
    switch (entry.status) {
      case 'COMPLETED':
        statusColor = cs.tertiary;
        statusIcon = Icons.check_circle;
        break;
      case 'CANCELLED':
        statusColor = cs.error;
        statusIcon = Icons.cancel;
        break;
      default:
        statusColor = cs.primary;
        statusIcon = Icons.pending;
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: statusColor.withOpacity(0.15),
          child: Icon(statusIcon, color: statusColor, size: 20),
        ),
        title: Text(entry.taskTitle),
        subtitle: Text(l10n.assignedTo(entry.username)),
        trailing: entry.pointsEarned > 0
            ? Text(
                l10n.pointsEarned(entry.pointsEarned),
                style: theme.textTheme.bodySmall?.copyWith(color: cs.tertiary),
              )
            : null,
      ),
    );
  }
}
