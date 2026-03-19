import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:taskflow/data/models/task.dart';
import 'package:taskflow/data/models/task_enums.dart';
import 'package:taskflow/l10n/app_localizations.dart';
import 'package:taskflow/presentation/widgets/task/deadline_countdown.dart';
import 'package:taskflow/presentation/widgets/task/priority_badge.dart';
import 'package:taskflow/presentation/widgets/task/status_badge.dart';

/// Task card widget for list view (PRD 3.4.2)
class TaskCard extends StatelessWidget {
  final Task task;
  final VoidCallback? onTap;

  const TaskCard({super.key, required this.task, this.onTap});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context)!;
    final priority = TaskPriority.fromString(task.priority);
    final status = TaskStatus.fromString(task.status);

    // Calculate point multiplier display
    String pointsDisplay = '${task.points} ${l10n.pts}';
    if (task.wasClaimedFromPool) {
      final bonusPoints = (task.points * 1.5).round();
      pointsDisplay = '$bonusPoints ${l10n.pts} (${l10n.bonusPoints})';
    }

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 2,
      child: InkWell(
        onTap: onTap ?? () => context.push('/tasks/${task.id}'),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title and Priority
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          task.title,
                          style: Theme.of(
                            context,
                          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        if (task.isRecurring) ...[
                          const SizedBox(height: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: colorScheme.secondaryContainer,
                              borderRadius: BorderRadius.circular(999),
                            ),
                            child: Text(
                              l10n.recurringTemplateChip,
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: colorScheme.onSecondaryContainer,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  PriorityBadge(priority: priority, compact: true),
                ],
              ),

              const SizedBox(height: 12),

              // Assignee or Up-for-Grabs
              Row(
                children: [
                  CircleAvatar(
                    radius: 12,
                    backgroundColor: task.assignee == null
                        ? Colors.purple.shade100
                        : colorScheme.primaryContainer,
                    child: task.assignee?.avatarUrl != null
                        ? ClipOval(
                            child: Image.network(
                              task.assignee!.avatarUrl!,
                              width: 24,
                              height: 24,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => Icon(
                                Icons.person,
                                size: 14,
                                color: colorScheme.onPrimaryContainer,
                              ),
                            ),
                          )
                        : Icon(
                            task.assignee == null ? Icons.volunteer_activism : Icons.person,
                            size: 14,
                            color: task.assignee == null
                                ? Colors.purple.shade700
                                : colorScheme.onPrimaryContainer,
                          ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    task.assignee?.username ?? l10n.upForGrabs,
                    style: TextStyle(
                      fontSize: 13,
                      color: task.assignee == null ? Colors.purple.shade700 : Colors.grey.shade700,
                      fontWeight: task.assignee == null ? FontWeight.w600 : FontWeight.normal,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              // Deadline and Points
              Row(
                children: [
                  Expanded(
                    child: DeadlineCountdown(
                      deadline: task.deadline,
                      compact: true,
                      status: TaskStatus.fromString(task.status),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: task.wasClaimedFromPool
                          ? Colors.purple.shade50
                          : colorScheme.primaryContainer.withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: task.wasClaimedFromPool
                            ? Colors.purple.shade200
                            : colorScheme.primary.withValues(alpha: 0.3),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.stars,
                          size: 14,
                          color: task.wasClaimedFromPool
                              ? Colors.purple.shade700
                              : colorScheme.primary,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          pointsDisplay,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: task.wasClaimedFromPool
                                ? Colors.purple.shade700
                                : colorScheme.primary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              if (task.isRecurring) ...[
                const SizedBox(height: 6),
                Text(
                  l10n.templateAnchorDeadlineShortHint,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.grey.shade700,
                      ),
                ),
              ],

              const SizedBox(height: 12),

              // Status Badge
              StatusBadge(status: status),

              // Rejection Reason (if rejected)
              if (task.rejectionReason != null) ...[
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.red.shade200),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.info_outline, size: 16, color: Colors.red.shade700),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          task.rejectionReason!,
                          style: TextStyle(fontSize: 12, color: Colors.red.shade700),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
