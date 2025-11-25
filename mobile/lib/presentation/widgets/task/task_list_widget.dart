import 'package:flutter/material.dart';
import 'package:taskflow/data/models/task.dart';
import 'package:taskflow/data/models/task_enums.dart';
import 'package:taskflow/l10n/app_localizations.dart';
import 'package:taskflow/presentation/widgets/task/task_card.dart';

/// Filterable/sortable task list widget (PRD 3.4.2)
class TaskListWidget extends StatelessWidget {
  final List<Task> tasks;
  final TaskStatus? statusFilter;
  final bool showEmptyState;
  final String? emptyStateMessage;
  final VoidCallback? onRefresh;

  const TaskListWidget({
    super.key,
    required this.tasks,
    this.statusFilter,
    this.showEmptyState = true,
    this.emptyStateMessage,
    this.onRefresh,
  });

  List<Task> get filteredTasks {
    if (statusFilter == null) return tasks;
    return tasks.where((task) => task.status == statusFilter!.value).toList();
  }

  @override
  Widget build(BuildContext context) {
    final filtered = filteredTasks;
    final l10n = AppLocalizations.of(context)!;

    if (filtered.isEmpty && showEmptyState) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.task_alt,
              size: 64,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 16),
            Text(
              emptyStateMessage ?? l10n.noTasks,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Colors.grey.shade600,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              l10n.tasksWillAppearHere,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey.shade500,
                  ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () async {
        onRefresh?.call();
      },
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(vertical: 8),
        itemCount: filtered.length,
        itemBuilder: (context, index) {
          return TaskCard(task: filtered[index]);
        },
      ),
    );
  }
}
