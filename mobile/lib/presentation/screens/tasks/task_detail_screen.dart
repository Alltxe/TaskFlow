import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:mobile/data/models/task_enums.dart';
import 'package:mobile/presentation/providers/task_state_provider.dart';
import 'package:mobile/presentation/widgets/task/deadline_countdown.dart';
import 'package:mobile/presentation/widgets/task/priority_badge.dart';
import 'package:mobile/presentation/widgets/task/status_badge.dart';

/// Task detail screen with full information (PRD 3.4.3)
class TaskDetailScreen extends ConsumerWidget {
  final String taskId;

  const TaskDetailScreen({super.key, required this.taskId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final taskAsync = ref.watch(taskDetailsProvider(taskId));
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text('Task Details'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () => context.push('/tasks/$taskId/edit'),
          ),
          PopupMenuButton(
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'delete',
                child: Row(
                  children: [
                    Icon(Icons.delete, color: Colors.red),
                    SizedBox(width: 8),
                    Text('Delete Task'),
                  ],
                ),
              ),
            ],
            onSelected: (value) async {
              if (value == 'delete') {
                final confirm = await showDialog<bool>(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Delete Task'),
                    content: const Text('Are you sure you want to delete this task?'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context, false),
                        child: const Text('Cancel'),
                      ),
                      TextButton(
                        onPressed: () => Navigator.pop(context, true),
                        style: TextButton.styleFrom(foregroundColor: Colors.red),
                        child: const Text('Delete'),
                      ),
                    ],
                  ),
                );

                if (confirm == true && context.mounted) {
                  // Read the task object from the provider to get groupId
                  final t = await ref.read(taskDetailsProvider(taskId).future);
                  await ref.read(taskActionsProvider.notifier).deleteTask(taskId, groupId: t.groupId);
                  if (context.mounted) context.pop();
                }
              }
            },
          ),
        ],
      ),
      body: taskAsync.when(
        data: (task) {
          final priority = TaskPriority.fromString(task.priority);
          final status = TaskStatus.fromString(task.status);

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title
                Text(
                  task.title,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),

                const SizedBox(height: 16),

                // Badges Row
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    PriorityBadge(priority: priority),
                    StatusBadge(status: status),
                  ],
                ),

                const SizedBox(height: 24),

                // Executor Info
                _InfoCard(
                  title: 'Executor',
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 20,
                        backgroundColor: task.assignee == null
                            ? Colors.purple.shade100
                            : colorScheme.primaryContainer,
                        child: task.assignee?.avatarUrl != null
                            ? ClipOval(
                                child: Image.network(
                                  task.assignee!.avatarUrl!,
                                  width: 40,
                                  height: 40,
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, __, ___) => const Icon(Icons.person),
                                ),
                              )
                            : Icon(
                                task.assignee == null ? Icons.volunteer_activism : Icons.person,
                                color: task.assignee == null
                                    ? Colors.purple.shade700
                                    : colorScheme.onPrimaryContainer,
                              ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              task.assignee?.username ?? 'Up-for-Grabs',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            if (task.assignee?.isAway == true)
                              Text(
                                'Away',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.orange.shade700,
                                ),
                              ),
                          ],
                        ),
                      ),
                      if (task.assignee == null)
                        ElevatedButton.icon(
                          onPressed: () async {
                            await ref.read(taskActionsProvider.notifier).claimTask(taskId, groupId: task.groupId);
                          },
                          icon: const Icon(Icons.volunteer_activism, size: 18),
                          label: const Text('Claim Task'),
                        ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // Deadline
                _InfoCard(
                  title: 'Deadline',
                  child: DeadlineCountdown(deadline: task.deadline, status: status),
                ),

                const SizedBox(height: 16),

                // Points
                _InfoCard(
                  title: 'Reward',
                  child: Row(
                    children: [
                      Icon(Icons.stars, color: colorScheme.primary),
                      const SizedBox(width: 8),
                      Text(
                        task.wasClaimedFromPool
                            ? '${(task.points * 1.5).round()} points (+50% bonus)'
                            : '${task.points} points',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),

                if (task.description != null) ...[
                  const SizedBox(height: 16),
                  _InfoCard(
                    title: 'Description',
                    child: Text(
                      task.description!,
                      style: const TextStyle(fontSize: 14),
                    ),
                  ),
                ],

                // Created By
                const SizedBox(height: 16),
                _InfoCard(
                  title: 'Created By',
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 16,
                        child: task.createdBy?.avatarUrl != null
                            ? ClipOval(
                                child: Image.network(
                                  task.createdBy!.avatarUrl!,
                                  width: 32,
                                  height: 32,
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, __, ___) => const Icon(Icons.person, size: 16),
                                ),
                              )
                            : const Icon(Icons.person, size: 16),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        task.createdBy?.username ?? 'Unknown',
                        style: const TextStyle(fontSize: 14),
                      ),
                      const Spacer(),
                      Text(
                        DateFormat('MMM dd, yyyy').format(task.createdAt),
                        style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                      ),
                    ],
                  ),
                ),

                // Rejection Reason
                if (task.rejectionReason != null) ...[
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.red.shade50,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.red.shade200),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.info_outline, color: Colors.red.shade700),
                            const SizedBox(width: 8),
                            Text(
                              'Rejection Reason',
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                color: Colors.red.shade700,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(task.rejectionReason!),
                      ],
                    ),
                  ),
                ],

                const SizedBox(height: 32),

                // Action Buttons
                _buildActionButtons(context, ref, task, status),
              ],
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 64, color: Colors.red),
              const SizedBox(height: 16),
              const Text('Error loading task'),
              const SizedBox(height: 8),
              Text(error.toString(), style: const TextStyle(fontSize: 12)),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => ref.invalidate(taskDetailsProvider(taskId)),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context, WidgetRef ref, task, TaskStatus status) {
    final isAssignedToMe = task.assigneeId != null; // TODO: Check against current user ID

    switch (status) {
      case TaskStatus.pending:
        if (isAssignedToMe) {
          return SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () async {
                await ref.read(taskActionsProvider.notifier).completeTask(taskId, groupId: task.groupId);
              },
              icon: const Icon(Icons.check_circle),
              label: const Text('Mark as Complete'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.all(16),
              ),
            ),
          );
        }
        return const SizedBox.shrink();

      case TaskStatus.awaitingApproval:
        // TODO: Check if user is admin
        return Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () async {
                  final reason = await _showRejectDialog(context);
                    if (reason != null) {
                    await ref.read(taskActionsProvider.notifier).approveTask(
                      taskId,
                      false,
                      rejectionReason: reason,
                      groupId: task.groupId,
                    );
                  }
                },
                icon: const Icon(Icons.close),
                label: const Text('Reject'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.red,
                  padding: const EdgeInsets.all(16),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () async {
                  await ref.read(taskActionsProvider.notifier).approveTask(taskId, true, groupId: task.groupId);
                },
                icon: const Icon(Icons.check),
                label: const Text('Approve'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.all(16),
                ),
              ),
            ),
          ],
        );

      default:
        return const SizedBox.shrink();
    }
  }

  Future<String?> _showRejectDialog(BuildContext context) {
    final controller = TextEditingController();
    return showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reject Task'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            labelText: 'Rejection Reason',
            hintText: 'Enter reason for rejection',
          ),
          maxLines: 3,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, controller.text),
            child: const Text('Reject'),
          ),
        ],
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  final String title;
  final Widget child;

  const _InfoCard({required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 8),
          child,
        ],
      ),
    );
  }
}
