import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mime/mime.dart';
import 'package:taskflow/core/utils/date_l10n.dart';
import 'package:taskflow/core/utils/media_permission_helper.dart';
import 'package:taskflow/data/datasources/task_remote_datasource.dart';
import 'package:taskflow/data/models/task.dart';
import 'package:taskflow/data/models/task_attachment.dart';
import 'package:taskflow/data/models/task_enums.dart';
import 'package:taskflow/data/providers/auth_providers.dart';
import 'package:taskflow/data/providers/group_providers.dart';
import 'package:taskflow/l10n/app_localizations.dart';
import 'package:taskflow/presentation/providers/task_state_provider.dart';
import 'package:taskflow/presentation/widgets/task/deadline_countdown.dart';
import 'package:taskflow/presentation/widgets/task/priority_badge.dart';
import 'package:taskflow/presentation/widgets/task/status_badge.dart';
import 'package:taskflow/presentation/widgets/common/app_navigation_back_button.dart';
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
          SnackBar(content: Text(AppLocalizations.of(context)!.mediaPermissionDenied)),
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
          SnackBar(content: Text(AppLocalizations.of(context)!.attachmentAdded)),
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
      builder: (ctx) {
        final l10n = AppLocalizations.of(ctx)!;
        return AlertDialog(
          title: Text(l10n.deleteAttachmentTitle),
          content: Text(l10n.deleteAttachmentMessage),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text(l10n.cancel)),
            TextButton(
              onPressed: () => Navigator.pop(ctx, true),
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: Text(l10n.delete),
            ),
          ],
        );
      },
    );
    if (confirm != true) return;

    try {
      final ds = TaskRemoteDataSource();
      await ds.deleteTaskAttachment(attachmentId);
      ref.invalidate(taskDetailsProvider(widget.taskId));
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppLocalizations.of(context)!.attachmentDeleted)),
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
    final l10n = AppLocalizations.of(context)!;
    return showModalBottomSheet<ImageSource>(
      context: context,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.photo_library_outlined),
              title: Text(l10n.fromGallery),
              onTap: () => Navigator.pop(ctx, ImageSource.gallery),
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt_outlined),
              title: Text(l10n.takePhoto),
              onTap: () => Navigator.pop(ctx, ImageSource.camera),
            ),
            ListTile(
              leading: const Icon(Icons.close),
              title: Text(l10n.cancel),
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
    final currentTask = taskAsync.asData?.value;
    final currentStatus =
        currentTask != null ? TaskStatus.fromString(currentTask.status) : null;

    final currentUserId = ref.watch(authStateProvider).user?.id;
    final isAdmin = currentTask != null
        ? (ref.watch(isGroupAdminProvider(currentTask.groupId)).value ?? false)
        : false;
    final isCreator = currentTask != null &&
        currentUserId != null &&
        currentTask.createdById == currentUserId;
    // Backend allows editing for admins or the task creator; deletion is admin-only.
    final canEdit = currentStatus != TaskStatus.cancelled && (isAdmin || isCreator);
    final canDelete = currentStatus != TaskStatus.cancelled && isAdmin;

    return Scaffold(
      appBar: AppBar(
        leading: const AppNavigationBackButton(fallbackRoute: '/home'),
        title: Text(l10n.taskDetailsTitle),
        actions: [
          if (canEdit)
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () => context.push('/tasks/${widget.taskId}/edit'),
            ),
          if (canDelete)
            PopupMenuButton(
              itemBuilder: (context) => [
                PopupMenuItem(
                  value: 'delete',
                  child: Row(
                    children: [
                      const Icon(Icons.delete, color: Colors.red),
                      const SizedBox(width: 8),
                      Text(l10n.deleteTask),
                    ],
                  ),
                ),
              ],
              onSelected: (value) async {
                if (value == 'delete') {
                  final confirm = await showDialog<bool>(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: Text(l10n.deleteTaskConfirmTitle),
                      content: Text(l10n.deleteTaskConfirmMessage),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context, false),
                          child: Text(l10n.cancel),
                        ),
                        TextButton(
                          onPressed: () => Navigator.pop(context, true),
                          style: TextButton.styleFrom(foregroundColor: Colors.red),
                          child: Text(l10n.delete),
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
          final currentUserId = ref.watch(authStateProvider).user?.id;
          final isAdmin = ref.watch(isGroupAdminProvider(task.groupId)).value ?? false;

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
                                      ? l10n.recurringTemplateChip
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
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                _InfoCard(
                  title: l10n.deadlineLabel,
                  child: DeadlineCountdown(deadline: task.deadline, status: status),
                ),

                const SizedBox(height: 16),

                _InfoCard(
                  title: l10n.reward,
                  child: Row(
                    children: [
                      Icon(Icons.stars, color: colorScheme.primary),
                      const SizedBox(width: 8),
                      Text(
                        task.wasClaimedFromPool
                            ? '${(task.points * 1.5).round()} ${l10n.pts} (${l10n.bonusPoints})'
                            : '${task.points} ${l10n.pts}',
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                ),

                if (task.description != null) ...[
                  const SizedBox(height: 16),
                  _InfoCard(
                    title: l10n.description,
                    child: Text(task.description!, style: const TextStyle(fontSize: 14)),
                  ),
                ],

                const SizedBox(height: 16),
                _InfoCard(
                  title: l10n.createdBy,
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
                        formatMonthDayYear(context, task.createdAt),
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
                              l10n.rejectionReason,
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

                const SizedBox(height: 24),
                _buildAttachmentsSection(context, task.attachments, l10n),

                const SizedBox(height: 32),

                _buildActionButtons(
                  context,
                  ref,
                  task,
                  status,
                  l10n,
                  currentUserId: currentUserId,
                  isAdmin: isAdmin,
                ),
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
              Text(l10n.errorLoadingTask),
              const SizedBox(height: 8),
              Text(error.toString(), style: const TextStyle(fontSize: 12)),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => ref.invalidate(taskDetailsProvider(widget.taskId)),
                child: Text(l10n.retry),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAttachmentsSection(
    BuildContext context,
    List<TaskAttachment> attachments,
    AppLocalizations l10n,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              l10n.attachments,
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
                    label: Text(l10n.addAttachment),
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

  Widget _buildActionButtons(
    BuildContext context,
    WidgetRef ref,
    Task task,
    TaskStatus status,
    AppLocalizations l10n, {
    required String? currentUserId,
    required bool isAdmin,
  }) {
    if (status == TaskStatus.cancelled || status == TaskStatus.completed || status == TaskStatus.overdue) {
      return const SizedBox.shrink();
    }

    final isAssignedToMe =
        currentUserId != null && task.assigneeId != null && task.assigneeId == currentUserId;
    final isUpForGrabsTask = !task.isRecurring && task.assigneeId == null;

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
              label: Text(l10n.markAsComplete),
              style: ElevatedButton.styleFrom(padding: const EdgeInsets.all(16)),
            ),
          );
        }
        if (isUpForGrabsTask) {
          return SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () async {
                await ref
                    .read(taskActionsProvider.notifier)
                    .claimTask(widget.taskId, groupId: task.groupId);
              },
              icon: const Icon(Icons.volunteer_activism),
              label: Text(l10n.claimTask),
              style: ElevatedButton.styleFrom(padding: const EdgeInsets.all(16)),
            ),
          );
        }
        return const SizedBox.shrink();

      case TaskStatus.awaitingApproval:
        if (!isAdmin) {
          return Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.orange.shade50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.orange.shade200),
            ),
            child: Row(
              children: [
                Icon(Icons.hourglass_top, color: Colors.orange.shade700),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    l10n.taskCompletedAwaitingApproval,
                    style: TextStyle(color: Colors.orange.shade900),
                  ),
                ),
              ],
            ),
          );
        }
        return Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () async {
                  final reason = await _showRejectDialog(context, l10n);
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
                label: Text(l10n.reject),
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
                label: Text(l10n.approve),
                style: ElevatedButton.styleFrom(padding: const EdgeInsets.all(16)),
              ),
            ),
          ],
        );

      default:
        return const SizedBox.shrink();
    }
  }

  Future<String?> _showRejectDialog(BuildContext context, AppLocalizations l10n) {
    final controller = TextEditingController();
    return showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.rejectTaskTitle),
        content: TextField(
          controller: controller,
          decoration: InputDecoration(
            labelText: l10n.rejectionReason,
            hintText: l10n.rejectionReasonHint,
          ),
          maxLines: 3,
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text(l10n.cancel)),
          TextButton(
            onPressed: () => Navigator.pop(context, controller.text),
            child: Text(l10n.reject),
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
    // Images open in an in-app full-screen viewer; other files (PDF/docs)
    // are handed off to an external app.
    if (attachment.isImage) {
      await showDialog<void>(
        context: context,
        barrierColor: Colors.black,
        builder: (dialogContext) => _ImageViewer(attachment: attachment),
      );
      return;
    }

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

/// Full-screen in-app image viewer with pinch-to-zoom.
class _ImageViewer extends StatelessWidget {
  final TaskAttachment attachment;

  const _ImageViewer({required this.attachment});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.black,
      insetPadding: EdgeInsets.zero,
      child: Stack(
        children: [
          Positioned.fill(
            child: InteractiveViewer(
              minScale: 0.5,
              maxScale: 4,
              child: Center(
                child: Image.network(
                  attachment.url,
                  fit: BoxFit.contain,
                  loadingBuilder: (context, child, progress) {
                    if (progress == null) return child;
                    return const Center(
                      child: CircularProgressIndicator(color: Colors.white),
                    );
                  },
                  errorBuilder: (_, __, ___) => const Center(
                    child: Icon(
                      Icons.broken_image_outlined,
                      color: Colors.white54,
                      size: 64,
                    ),
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            top: 8,
            right: 8,
            child: SafeArea(
              child: IconButton(
                icon: const Icon(Icons.close, color: Colors.white),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ),
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
