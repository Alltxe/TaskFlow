import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:taskflow/data/models/task_enums.dart';
import 'package:taskflow/data/providers/auth_providers.dart';
import 'package:taskflow/data/providers/group_providers.dart';
import 'package:taskflow/l10n/app_localizations.dart';
import 'package:taskflow/presentation/providers/task_state_provider.dart';
import 'package:taskflow/presentation/widgets/task/task_list_widget.dart';

/// Tasks screen with tab views (PRD 3.4.1)
class TasksScreen extends ConsumerStatefulWidget {
  final String? groupId;

  /// If [groupId] is provided, the Tasks screen will show tasks scoped to that group.
  const TasksScreen({super.key, this.groupId});

  @override
  ConsumerState<TasksScreen> createState() => _TasksScreenState();
}

class _TasksScreenState extends ConsumerState<TasksScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late int _tabsCount;

  @override
  void initState() {
    super.initState();
    _tabsCount = widget.groupId == null
        ? 3
        : 5; // include dedicated recurring templates tab in group scope
    _tabController = TabController(length: _tabsCount, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    // Check if user is admin when groupId is provided
    final isAdminAsync = widget.groupId != null
        ? ref.watch(isGroupAdminProvider(widget.groupId!))
        : const AsyncValue.data(true); // Show button for non-group tasks

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text(l10n.tasksTitle),
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          tabs: [
            if (widget.groupId != null) Tab(text: l10n.myTasksTab),
            Tab(text: l10n.groupTasksTab),
            Tab(text: l10n.upForGrabsTab),
            Tab(text: l10n.pendingApprovalTab),
            if (widget.groupId != null) Tab(text: l10n.recurringTemplatesTab),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () {
              // TODO: Show filter dialog
            },
          ),
        ],
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          if (widget.groupId != null) _MyTasksTab(groupId: widget.groupId),

          _GroupTasksTab(groupId: widget.groupId),

          _UpForGrabsTab(groupId: widget.groupId),

          _PendingApprovalTab(groupId: widget.groupId),

          if (widget.groupId != null)
            _RecurringTemplatesTab(groupId: widget.groupId!),
        ],
      ),
      floatingActionButton: isAdminAsync.when(
        data: (isAdmin) => isAdmin
            ? FloatingActionButton.extended(
                onPressed: () {
                  final uri = widget.groupId != null
                      ? Uri(
                          path: '/tasks/create',
                          queryParameters: {'groupId': widget.groupId!},
                        )
                      : Uri(path: '/tasks/create');
                  context.push(uri.toString());
                },
                icon: const Icon(Icons.add),
                label: Text(l10n.createTask),
              )
            : null,
        loading: () => null,
        error: (_, __) => null,
      ),
    );
  }
}

class _RecurringTemplatesTab extends ConsumerWidget {
  final String groupId;

  const _RecurringTemplatesTab({required this.groupId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final templatesAsync = ref.watch(recurringTemplatesProvider(groupId));
    final l10n = AppLocalizations.of(context)!;

    return templatesAsync.when(
      data: (templates) => Column(
        children: [
          Container(
            width: double.infinity,
            margin: const EdgeInsets.fromLTRB(12, 12, 12, 4),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Theme.of(
                context,
              ).colorScheme.primaryContainer.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Theme.of(
                  context,
                ).colorScheme.primary.withValues(alpha: 0.2),
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.info_outline,
                  size: 20,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.recurringTemplatesInfoTitle,
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        l10n.recurringTemplatesInfoBody,
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: TaskListWidget(
              tasks: templates,
              emptyStateMessage: l10n.noRecurringTemplates,
              onRefresh: () =>
                  ref.invalidate(recurringTemplatesProvider(groupId)),
            ),
          ),
        ],
      ),
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) =>
          Center(child: Text('${l10n.errorLoadingTasks}: ${error.toString()}')),
    );
  }
}

/// My Tasks tab - tasks assigned to current user
class _MyTasksTab extends ConsumerWidget {
  final String? groupId;

  const _MyTasksTab({this.groupId});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tasksAsync = groupId == null
        ? ref.watch(userTasksProvider)
        : ref.watch(groupTasksProvider(groupId!));
    final authState = ref.watch(authStateProvider);
    final l10n = AppLocalizations.of(context)!;

    return tasksAsync.when(
      data: (tasks) {
        // If we're viewing tasks within a group, show only tasks assigned to the
        // current user for the "My Tasks" tab.
        final list = groupId == null
            ? tasks
            : tasks.where((t) => t.assigneeId == authState.user?.id).toList();

        return TaskListWidget(
          tasks: list,
          emptyStateMessage: l10n.noTasksAssigned,
          onRefresh: () => groupId == null
              ? ref.invalidate(userTasksProvider)
              : ref.invalidate(groupTasksProvider(groupId!)),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text(l10n.errorLoadingTasks),
            const SizedBox(height: 8),
            Text(
              error.toString(),
              style: const TextStyle(fontSize: 12, color: Colors.grey),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => groupId == null
                  ? ref.invalidate(userTasksProvider)
                  : ref.invalidate(groupTasksProvider(groupId!)),
              child: Text(l10n.retry),
            ),
          ],
        ),
      ),
    );
  }
}

/// Group Tasks tab - placeholder for group selection
class _GroupTasksTab extends StatelessWidget {
  final String? groupId;

  const _GroupTasksTab({this.groupId});
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    if (groupId == null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.groups, size: 64, color: Colors.grey.shade400),
            const SizedBox(height: 16),
            Text(
              l10n.selectGroup,
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(color: Colors.grey.shade600),
            ),
            const SizedBox(height: 8),
            Text(
              l10n.viewGroupTasksFromGroupsTab,
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: Colors.grey.shade500),
            ),
          ],
        ),
      );
    }

    // When a groupId is provided, collect and show tasks for that group
    return Consumer(
      builder: (context, ref, _) {
        final tasksAsyncValue = ref.watch(groupTasksProvider(groupId!));

        return tasksAsyncValue.when(
          data: (tasks) => TaskListWidget(
            tasks: tasks,
            emptyStateMessage: l10n.noTasksFound,
            onRefresh: () => ref.invalidate(groupTasksProvider(groupId!)),
          ),
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, stack) => Center(
            child: Text('${l10n.errorLoadingTasks}: ${error.toString()}'),
          ),
        );
      },
    );
  }
}

/// Up-for-Grabs tab - unassigned tasks available for claiming
class _UpForGrabsTab extends ConsumerWidget {
  final String? groupId;

  const _UpForGrabsTab({this.groupId});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tasksAsync = groupId == null
        ? ref.watch(userTasksProvider)
        : ref.watch(groupTasksProvider(groupId!));
    final l10n = AppLocalizations.of(context)!;

    return tasksAsync.when(
      data: (allTasks) {
        // Filter for real pool tasks only (exclude recurring templates)
        final upForGrabsTasks = allTasks
            .where((task) => task.assigneeId == null && !task.isRecurring)
            .toList();

        return TaskListWidget(
          tasks: upForGrabsTasks,
          emptyStateMessage: l10n.noTasksAvailable,
          onRefresh: () => groupId == null
              ? ref.invalidate(userTasksProvider)
              : ref.invalidate(groupTasksProvider(groupId!)),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) =>
          Center(child: Text('${l10n.errorLoadingTasks}: ${error.toString()}')),
    );
  }
}

/// Pending Approval tab - tasks awaiting admin approval
class _PendingApprovalTab extends ConsumerWidget {
  final String? groupId;

  const _PendingApprovalTab({this.groupId});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tasksAsync = groupId == null
        ? ref.watch(userTasksProvider)
        : ref.watch(groupTasksProvider(groupId!));
    final l10n = AppLocalizations.of(context)!;

    return tasksAsync.when(
      data: (allTasks) {
        // Filter for tasks awaiting approval
        final pendingTasks = allTasks
            .where((task) => task.status == TaskStatus.awaitingApproval.value)
            .toList();

        return TaskListWidget(
          tasks: pendingTasks,
          emptyStateMessage: l10n.noTasksPendingApproval,
          onRefresh: () => groupId == null
              ? ref.invalidate(userTasksProvider)
              : ref.invalidate(groupTasksProvider(groupId!)),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) =>
          Center(child: Text('${l10n.errorLoadingTasks}: ${error.toString()}')),
    );
  }
}
