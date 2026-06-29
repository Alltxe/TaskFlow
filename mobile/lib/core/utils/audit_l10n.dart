import 'package:flutter/material.dart';
import 'package:taskflow/core/utils/enum_l10n.dart';
import 'package:taskflow/data/models/audit_log.dart';
import 'package:taskflow/l10n/app_localizations.dart';

String auditActionLabel(AppLocalizations l10n, String action) {
  switch (action) {
    case 'USER_STATUS_CHANGED':
      return l10n.auditActionUserStatusChanged;
    case 'USER_PROFILE_UPDATED':
      return l10n.auditActionUserProfileUpdated;
    case 'GROUP_CREATED':
      return l10n.auditActionGroupCreated;
    case 'GROUP_UPDATED':
      return l10n.auditActionGroupUpdated;
    case 'GROUP_DELETED':
      return l10n.auditActionGroupDeleted;
    case 'MEMBER_ADDED':
      return l10n.auditActionMemberAdded;
    case 'MEMBER_REMOVED':
      return l10n.auditActionMemberRemoved;
    case 'MEMBER_ROLE_CHANGED':
      return l10n.auditActionMemberRoleChanged;
    case 'TASK_CREATED':
      return l10n.auditActionTaskCreated;
    case 'TASK_UPDATED':
      return l10n.auditActionTaskUpdated;
    case 'TASK_DELETED':
      return l10n.auditActionTaskDeleted;
    case 'TASK_ASSIGNED':
      return l10n.auditActionTaskAssigned;
    case 'TASK_COMPLETED':
      return l10n.auditActionTaskCompleted;
    case 'TASK_APPROVED':
      return l10n.auditActionTaskApproved;
    case 'TASK_REJECTED':
      return l10n.auditActionTaskRejected;
    case 'TASK_OVERDUE':
      return l10n.auditActionTaskOverdue;
    case 'REWARD_CREATED':
      return l10n.auditActionRewardCreated;
    case 'REWARD_UPDATED':
      return l10n.auditActionRewardUpdated;
    case 'REWARD_DELETED':
      return l10n.auditActionRewardDeleted;
    case 'REWARD_REQUESTED':
      return l10n.auditActionRewardRequested;
    case 'REWARD_REQUEST_APPROVED':
      return l10n.auditActionRewardRequestApproved;
    case 'REWARD_REQUEST_REJECTED':
      return l10n.auditActionRewardRequestRejected;
    case 'POINTS_EARNED':
      return l10n.auditActionPointsEarned;
    case 'POINTS_RESERVED':
      return l10n.auditActionPointsReserved;
    case 'POINTS_SPENT':
      return l10n.auditActionPointsSpent;
    case 'POINTS_REFUNDED':
      return l10n.auditActionPointsRefunded;
    default:
      return l10n.auditActionUnknown;
  }
}

String? auditLogDetail(AppLocalizations l10n, AuditLog log) {
  final newValues = log.newValues;
  final oldValues = log.oldValues;

  switch (log.action) {
    case 'TASK_CREATED':
      final title = _stringValue(newValues?['title']);
      if (title == null) return null;
      return newValues?['isRecurring'] == true
          ? l10n.auditDetailTaskTemplate(title)
          : l10n.auditDetailTaskTitle(title);

    case 'TASK_UPDATED':
    case 'TASK_ASSIGNED':
    case 'TASK_APPROVED':
      final title = _stringValue(newValues?['title']);
      return title != null ? l10n.auditDetailTaskTitle(title) : null;

    case 'TASK_REJECTED':
      final reason = _stringValue(newValues?['rejectionReason']);
      if (reason != null && reason.isNotEmpty) {
        return l10n.auditDetailRejectionReason(reason);
      }
      return null;

    case 'TASK_COMPLETED':
      if (newValues?['requiresApproval'] == true) {
        return l10n.auditDetailTaskAwaitingApproval;
      }
      return null;

    case 'GROUP_CREATED':
    case 'GROUP_DELETED':
      final name = _stringValue(newValues?['name']) ?? _stringValue(oldValues?['name']);
      return name != null ? l10n.auditDetailGroupName(name) : null;

    case 'GROUP_UPDATED':
      final oldName = _stringValue(oldValues?['name']);
      final newName = _stringValue(newValues?['name']);
      if (oldName != null && newName != null && oldName != newName) {
        return l10n.auditDetailGroupRenamed(oldName, newName);
      }
      final name = newName ?? oldName;
      return name != null ? l10n.auditDetailGroupName(name) : null;

    case 'MEMBER_ADDED':
      return l10n.auditDetailMemberJoined;

    case 'MEMBER_REMOVED':
      return newValues?['removedUserId'] != null
          ? l10n.auditDetailMemberRemovedByAdmin
          : l10n.auditDetailMemberLeft;

    case 'MEMBER_ROLE_CHANGED':
      final oldRole = _stringValue(oldValues?['role']);
      final newRole = _stringValue(newValues?['role']);
      if (oldRole != null && newRole != null) {
        return l10n.auditDetailRoleChanged(
          memberRoleLabel(l10n, oldRole),
          memberRoleLabel(l10n, newRole),
        );
      }
      return null;

    case 'POINTS_EARNED':
    case 'POINTS_RESERVED':
    case 'POINTS_REFUNDED':
      return _pointsDetail(l10n, newValues, spent: false);

    case 'POINTS_SPENT':
      return _pointsDetail(l10n, newValues, spent: true);

    case 'REWARD_CREATED':
    case 'REWARD_UPDATED':
    case 'REWARD_REQUESTED':
      final name = _stringValue(newValues?['name']) ?? _stringValue(newValues?['title']);
      return name != null ? l10n.auditDetailGroupName(name) : null;

    default:
      return null;
  }
}

String? _pointsDetail(AppLocalizations l10n, Map<String, dynamic>? values, {required bool spent}) {
  if (values == null) return null;

  final amount = _intValue(values['amount']);
  if (amount == null) return null;

  if (spent) {
    return l10n.auditDetailPointsSpent(amount);
  }

  final description = _localizedPointDescription(l10n, _stringValue(values['description']));
  if (description != null && description.isNotEmpty) {
    return l10n.auditDetailPointsWithDescription(amount, description);
  }
  return l10n.auditDetailPoints(amount);
}

String? _localizedPointDescription(AppLocalizations l10n, String? description) {
  if (description == null || description.isEmpty) return null;

  if (description.startsWith('Task completed')) {
    final bonus = description.contains('Up-for-Grabs bonus');
    return bonus ? l10n.auditDetailPointsTaskCompletedBonus : l10n.auditDetailPointsTaskCompleted;
  }
  if (description.startsWith('Task approved')) {
    final bonus = description.contains('Up-for-Grabs bonus');
    return bonus ? l10n.auditDetailPointsTaskApprovedBonus : l10n.auditDetailPointsTaskApproved;
  }

  return description;
}

String auditPerformerName(AppLocalizations l10n, AuditLog log) {
  return log.performedBy?.username ??
      log.user?.username ??
      l10n.auditLogSystemUser;
}

String? auditLogGroupId(AuditLog log) {
  final groupId = _stringValue(log.newValues?['groupId']) ??
      _stringValue(log.oldValues?['groupId']);
  if (groupId != null) return groupId;

  if (log.entityType == 'Group' && log.entityId != null) {
    return log.entityId;
  }

  if (log.entityType == 'GroupMember' && log.entityId != null) {
    final separatorIndex = log.entityId!.lastIndexOf('-');
    if (separatorIndex > 0) {
      return log.entityId!.substring(0, separatorIndex);
    }
  }

  return null;
}

String? auditLogGroupLabel(
  AppLocalizations l10n,
  AuditLog log,
  Map<String, String> groupNames,
) {
  final groupId = auditLogGroupId(log);
  if (groupId == null) {
    if (log.entityType == 'User' ||
        log.action == 'USER_PROFILE_UPDATED' ||
        log.action == 'USER_STATUS_CHANGED') {
      return l10n.auditLogPersonalScope;
    }
    return null;
  }

  final groupName = groupNames[groupId] ?? _stringValue(log.newValues?['name']);
  if (groupName != null) {
    return l10n.auditLogInGroup(groupName);
  }

  return null;
}

IconData auditActionIcon(String action) {
  switch (action) {
    case 'GROUP_CREATED':
    case 'GROUP_UPDATED':
    case 'GROUP_DELETED':
      return Icons.groups_outlined;
    case 'MEMBER_ADDED':
    case 'MEMBER_REMOVED':
    case 'MEMBER_ROLE_CHANGED':
      return Icons.person_outline;
    case 'POINTS_EARNED':
    case 'POINTS_RESERVED':
    case 'POINTS_SPENT':
    case 'POINTS_REFUNDED':
      return Icons.star_outline;
    case 'REWARD_CREATED':
    case 'REWARD_UPDATED':
    case 'REWARD_DELETED':
    case 'REWARD_REQUESTED':
    case 'REWARD_REQUEST_APPROVED':
    case 'REWARD_REQUEST_REJECTED':
      return Icons.card_giftcard_outlined;
    case 'USER_STATUS_CHANGED':
    case 'USER_PROFILE_UPDATED':
      return Icons.account_circle_outlined;
    case 'TASK_REJECTED':
      return Icons.cancel_outlined;
    case 'TASK_APPROVED':
    case 'TASK_COMPLETED':
      return Icons.check_circle_outline;
    default:
      return Icons.task_alt_outlined;
  }
}

Color auditActionColor(BuildContext context, String action) {
  final scheme = Theme.of(context).colorScheme;

  switch (action) {
    case 'GROUP_CREATED':
    case 'GROUP_UPDATED':
    case 'MEMBER_ADDED':
      return scheme.primary;
    case 'GROUP_DELETED':
    case 'MEMBER_REMOVED':
    case 'TASK_REJECTED':
    case 'REWARD_REQUEST_REJECTED':
      return scheme.error;
    case 'POINTS_EARNED':
    case 'POINTS_REFUNDED':
    case 'TASK_APPROVED':
    case 'REWARD_REQUEST_APPROVED':
      return Colors.amber.shade700;
    case 'POINTS_SPENT':
    case 'POINTS_RESERVED':
      return scheme.tertiary;
    case 'MEMBER_ROLE_CHANGED':
      return scheme.secondary;
    default:
      return scheme.primary;
  }
}

String? _stringValue(dynamic value) {
  if (value is String && value.isNotEmpty) return value;
  return null;
}

int? _intValue(dynamic value) {
  if (value is int) return value;
  if (value is num) return value.toInt();
  return null;
}
