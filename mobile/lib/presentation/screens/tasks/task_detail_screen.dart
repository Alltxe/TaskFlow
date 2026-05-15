import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:mime/mime.dart';
import 'package:taskflow/core/utils/media_permission_helper.dart';
import 'package:taskflow/data/datasources/task_remote_datasource.dart';
import 'package:taskflow/data/models/task_attachment.dart';
import 'package:taskflow/data/models/task_enums.dart';
import 'package:taskflow/l10n/app_localizations.dart';
import 'package:taskflow/presentation/providers/task_state_provider.dart';
import 'package:taskflow/presentation/widgets/task/deadline_countdown.dart';
import 'package:taskflow/presentation/widgets/task/priority_badge.dart';
import 'package:taskflow/presentation/widgets/task/status_badge.dart';
import 'package:url_launcher/url_launcher.dart';

/// Task detail screen with full information (PRD 3.4.3)
class TaskDetailScreen extends ConsumerStatefulWidget {
  final String taskId;

  const TaskDetailScreen({super.key, required this.taskId});

  @override
  ConsumerState<TaskDetailScreen> createState() => _TaskDetailScreenState();
}

class _TaskDetailScreenState extends ConsumerState<TaskDetailScreen> {
  bool _uploadingAttachment = false;

  Future<void> _pickAndAddAttachment() async {
    final source = await _showAttachmentSourceDialog();
    if (source == null) return;

    final hasPermission = await _requestMediaPermission(source);
    if (!hasPermission) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Нет разрешения на доступ к медиафайлам')),
        );
      }
      return;
    }

    final picker = ImagePicker();
    final XFile? picked = await picker.pickImage(
      source: source,
      maxWidth: 1920,
      maxHeight: 1920,
      imageQuality: 85,
    );
    if (picked == null) return;

    setState(() => _uploadingAttachment = true);
    try {
      final ds = TaskRemoteDataSource();
      final mimeType = lookupMimeType(picked.path) ?? 'image/jpeg';
      await ds.uploadAndAddAttachment(
        taskId: widget.taskId,
        filePath: picked.path,
        filename: picked.name,
        mimeType: mimeType,
      );
      // Refresh task to get updated attachments list
      ref.invalidate(taskDetailsProvider(widget.taskId));
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Вложение добавлено')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Ошибка: ${e.toString()}'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _uploadingAttachment = false);
    }
  }

  Future<void> _deleteAttachment(String attachmentId) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Удалить вложение?'),
        content: const Text('Файл будет удалён без возможности восстановления.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Отмена')),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Удалить'),
          ),
        ],
      ),
    );
    if (confirm != true) return;

    try {
      final ds = TaskRemoteDataSource();
      await ds.deleteTaskAttachment(attachmentId);
      ref.invalidate(taskDetailsProvider(widget.taskId));
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Вложение удалено')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Ошибка: ${e.toString()}'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
  }

  Future<ImageSource?> _showAttachmentSourceDialog() {
    return showModalBottomSheet<ImageSource>(
      context: context,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.photo_library_outlined),
              title: const Text('Из галереи'),
              onTap: () => Navigator.pop(ctx, ImageSource.gallery),
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt_outlined),
              title: const Text('Сделать фото'),
              onTap: () => Navigator.pop(ctx, ImageSource.camera),
            ),
            ListTile(
              leading: const Icon(Icons.close),
              title: const Text('Отмена'),
              onTap: () => Navigator.pop(ctx),
            ),
          ],
        ),
      ),
    );
  }

  Future<bool> _requestMediaPermission(ImageSource source) =>
      requestMediaPermission(source);

  @override
  Widget build(BuildContext context) {
    final taskAsync = ref.watch(taskDetailsProvider(widget.taskId));
    final colorScheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text('Task Details'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () => context.push('/tasks/${widget.taskId}/edit'),
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
                  final t = await ref.read(taskDetailsProvider(widget.taskId).future);
                  await ref
                      .read(taskActionsProvider.notifier)
                      .deleteTask(widget.taskId, groupId: t.groupId);
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
          final isTemplateWithoutAssignee = task.isRecurring && task.assignee == null;
          final isUpForGrabsTask = !task.isRecurring && task.assignee == null;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  task.title,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 16),

                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    PriorityBadge(priority: priority),
                    StatusBadge(status: status),
                  ],
                ),

                const SizedBox(height: 24),

                _InfoCard(
                  title: l10n.executor,
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 20,
                        backgroundColor: isTemplateWithoutAssignee
                            ? colorScheme.secondaryContainer
                            : isUpForGrabsTask
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
                                isTemplateWithoutAssignee
                                    ? Icons.inventory_2_outlined
                                    : isUpForGrabsTask
                                    ? Icons.volunteer_activism
                                    : Icons.person,
                                color: isTemplateWithoutAssignee
                                    ? colorScheme.onSecondaryContainer
                                    : isUpForGrabsTask
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
                              task.assignee?.username ??
                                  (isTemplateWithoutAssignee
                                      ? l10n.recurrenceTemplateLabel
                                      : l10n.upForGrabs),
                              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                            ),
                            if (task.assignee?.isAway == true)
                              Text(
                                l10n.away,
                                style: TextStyle(fontSize: 12, color: Colors.orange.shade700),
                              ),
                          ],
                        ),
                      ),
                      if (isUpForGrabsTask)
                        ElevatedButton.icon(
                          onPressed: () async {
                            await ref
                                .read(taskActionsProvider.notifier)
                                .claimTask(widget.taskId, groupId: task.groupId);
                          },
                          icon: const Icon(Icons.volunteer_activism, size: 18),
                          label: Text(l10n.claimTask),
                        ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                _InfoCard(
                  title: 'Deadline',
                  child: DeadlineCountdown(deadline: task.deadline, status: status),
                ),

                const SizedBox(height: 16),

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
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                ),

                if (task.description != null) ...[
                  const SizedBox(height: 16),
                  _InfoCard(
                    title: 'Description',
                    child: Text(task.description!, style: const TextStyle(fontSize: 14)),
                  ),
                ],

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
                      Text(task.createdBy?.username ?? 'Unknown', style: const TextStyle(fontSize: 14)),
                      const Spacer(),
                      Text(
                        DateFormat('MMM dd, yyyy').format(task.createdAt),
                        style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                      ),
                    ],
                  ),
                ),

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

                // ── Attachments ──────────────────────────────────────────────
                const SizedBox(height: 24),
                _buildAttachmentsSection(context, task.attachments),

                const SizedBox(height: 32),

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
                onPressed: () => ref.invalidate(taskDetailsProvider(widget.taskId)),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAttachmentsSection(BuildContext context, List<TaskAttachment> attachments) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'Вложения',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const Spacer(),
            _uploadingAttachment
                ? const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : TextButton.icon(
                    onPressed: _pickAndAddAttachment,
                    icon: const Icon(Icons.attach_file, size: 18),
                    label: const Text('Добавить'),
                  ),
          ],
        ),
        const SizedBox(height: 8),
        if (attachments.isEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: Text(
              'Нет вложений',
              style: TextStyle(color: Colors.grey.shade500),
              textAlign: TextAlign.center,
            ),
          )
        else
          Container(
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: attachments.length,
              separatorBuilder: (_, __) => Divider(height: 1, color: Colors.grey.shade200),
              itemBuilder: (context, index) {
                final attachment = attachments[index];
                return _AttachmentTile(
                  attachment: attachment,
                  onDelete: () => _deleteAttachment(attachment.id),
                );
              },
            ),
          ),
      ],
    );
  }

  Widget _buildActionButtons(BuildContext context, WidgetRef ref, task, TaskStatus status) {
    final isAssignedToMe = task.assigneeId != null;

    switch (status) {
      case TaskStatus.pending:
        if (isAssignedToMe) {
          return SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () async {
                await ref
                    .read(taskActionsProvider.notifier)
                    .completeTask(widget.taskId, groupId: task.groupId);
              },
              icon: const Icon(Icons.check_circle),
              label: const Text('Mark as Complete'),
              style: ElevatedButton.styleFrom(padding: const EdgeInsets.all(16)),
            ),
          );
        }
        return const SizedBox.shrink();

      case TaskStatus.awaitingApproval:
        return Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () async {
                  final reason = await _showRejectDialog(context);
                  if (reason != null) {
                    await ref.read(taskActionsProvider.notifier).approveTask(
                      widget.taskId,
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
                  await ref
                      .read(taskActionsProvider.notifier)
                      .approveTask(widget.taskId, true, groupId: task.groupId);
                },
                icon: const Icon(Icons.check),
                label: const Text('Approve'),
                style: ElevatedButton.styleFrom(padding: const EdgeInsets.all(16)),
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
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          TextButton(
            onPressed: () => Navigator.pop(context, controller.text),
            child: const Text('Reject'),
          ),
        ],
      ),
    );
  }
}

/// Tile for a single attachment
class _AttachmentTile extends StatelessWidget {
  final TaskAttachment attachment;
  final VoidCallback onDelete;

  const _AttachmentTile({required this.attachment, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: _attachmentIcon(context),
      title: Text(
        attachment.filename,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: const TextStyle(fontSize: 14),
      ),
      subtitle: Text(
        attachment.fileSizeFormatted,
        style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
      ),
      trailing: IconButton(
        icon: const Icon(Icons.delete_outline, color: Colors.red),
        onPressed: onDelete,
        tooltip: 'Удалить',
      ),
      onTap: () => _openAttachment(context),
    );
  }

  Widget _attachmentIcon(BuildContext context) {
    if (attachment.isImage) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(4),
        child: Image.network(
          attachment.url,
          width: 40,
          height: 40,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => _fileIcon(context),
        ),
      );
    }
    return _fileIcon(context);
  }

  Widget _fileIcon(BuildContext context) {
    IconData icon;
    Color color;
    if (attachment.isPdf) {
      icon = Icons.picture_as_pdf;
      color = Colors.red;
    } else if (attachment.mimeType.contains('word')) {
      icon = Icons.description;
      color = Colors.blue;
    } else if (attachment.mimeType.contains('excel') || attachment.mimeType.contains('sheet')) {
      icon = Icons.table_chart;
      color = Colors.green;
    } else {
      icon = Icons.insert_drive_file;
      color = Colors.grey;
    }
    return Icon(icon, color: color, size: 32);
  }

  Future<void> _openAttachment(BuildContext context) async {
    final uri = Uri.parse(attachment.url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Не удалось открыть файл')),
        );
      }
    }
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
