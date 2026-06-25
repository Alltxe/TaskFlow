import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:taskflow/core/utils/date_l10n.dart';
import 'package:taskflow/core/utils/notification_l10n.dart';
import 'package:taskflow/data/models/notification.dart';
import 'package:taskflow/data/providers/notification_providers.dart';
import 'package:taskflow/l10n/app_localizations.dart';

class NotificationsScreen extends ConsumerStatefulWidget {
  const NotificationsScreen({super.key});

  @override
  ConsumerState<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends ConsumerState<NotificationsScreen> {
  bool _unreadOnly = false;

  Future<void> _markAllRead() async {
    final repo = ref.read(notificationRepositoryProvider);
    await repo.markAllNotificationsRead();
    ref.invalidate(myNotificationsProvider);
    ref.invalidate(unreadNotificationCountProvider);
  }

  Future<void> _markRead(String id) async {
    final repo = ref.read(notificationRepositoryProvider);
    await repo.markNotificationsRead([id]);
    ref.invalidate(myNotificationsProvider);
    ref.invalidate(unreadNotificationCountProvider);
  }

  void _handleTap(AppNotification n) {
    if (!n.isRead) _markRead(n.id);

    // Navigate to related entity if available
    if (n.relatedEntityType != null && n.relatedEntityId != null) {
      switch (n.relatedEntityType) {
        case 'task':
          context.push('/tasks/${n.relatedEntityId}');
          break;
        case 'group':
          context.push('/groups/${n.relatedEntityId}');
          break;
        default:
          break;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final notificationsAsync = ref.watch(myNotificationsProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.notifications),
        actions: [
          IconButton(
            icon: const Icon(Icons.done_all),
            tooltip: l10n.markAllRead,
            onPressed: _markAllRead,
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(48),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: Row(
              children: [
                FilterChip(
                  label: Text(l10n.unreadOnly),
                  selected: _unreadOnly,
                  onSelected: (val) => setState(() => _unreadOnly = val),
                ),
              ],
            ),
          ),
        ),
      ),
      body: notificationsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text(e.toString())),
        data: (list) {
          final items = _unreadOnly ? list.items.where((n) => !n.isRead).toList() : list.items;

          if (items.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.notifications_none,
                    size: 64,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    l10n.notificationsEmpty,
                    style: theme.textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    l10n.notificationsEmptyHint,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () async {
              ref.invalidate(myNotificationsProvider);
            },
            child: ListView.separated(
              itemCount: items.length,
              separatorBuilder: (_, __) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final n = items[index];
                return _NotificationTile(
                  notification: n,
                  onTap: () => _handleTap(n),
                  onMarkRead: n.isRead ? null : () => _markRead(n.id),
                );
              },
            ),
          );
        },
      ),
    );
  }
}

class _NotificationTile extends StatelessWidget {
  final AppNotification notification;
  final VoidCallback onTap;
  final VoidCallback? onMarkRead;

  const _NotificationTile({
    required this.notification,
    required this.onTap,
    this.onMarkRead,
  });

  IconData _iconForType(AppNotificationType type) {
    switch (type) {
      case AppNotificationType.taskAssigned:
        return Icons.assignment;
      case AppNotificationType.taskCompleted:
        return Icons.task_alt;
      case AppNotificationType.taskApproved:
        return Icons.check_circle;
      case AppNotificationType.taskRejected:
        return Icons.cancel;
      case AppNotificationType.rewardRequested:
      case AppNotificationType.rewardApproved:
      case AppNotificationType.rewardRejected:
        return Icons.card_giftcard;
      case AppNotificationType.pointAwarded:
        return Icons.stars;
      case AppNotificationType.invitation:
        return Icons.group_add;
      case AppNotificationType.system:
        return Icons.info;
    }
  }

  Color _colorForType(AppNotificationType type, ColorScheme cs) {
    switch (type) {
      case AppNotificationType.taskApproved:
      case AppNotificationType.rewardApproved:
      case AppNotificationType.pointAwarded:
        return cs.tertiary;
      case AppNotificationType.taskRejected:
      case AppNotificationType.rewardRejected:
        return cs.error;
      case AppNotificationType.invitation:
        return cs.primary;
      default:
        return cs.secondary;
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final isUnread = !notification.isRead;

    return InkWell(
      onTap: onTap,
      child: Container(
        color: isUnread ? cs.primaryContainer.withOpacity(0.15) : null,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(
              backgroundColor: _colorForType(notification.type, cs).withOpacity(0.15),
              child: Icon(
                _iconForType(notification.type),
                color: _colorForType(notification.type, cs),
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          notificationTitle(l10n, notification),
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontWeight: isUnread ? FontWeight.bold : FontWeight.normal,
                          ),
                        ),
                      ),
                      Text(
                        formatTimeAgo(l10n, notification.createdAt),
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: cs.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    notificationMessage(l10n, notification),
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: cs.onSurfaceVariant,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            if (isUnread) ...[
              const SizedBox(width: 8),
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: cs.primary,
                  shape: BoxShape.circle,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
