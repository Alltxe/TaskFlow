import 'package:taskflow/data/models/task_enums.dart';
import 'package:taskflow/l10n/app_localizations.dart';

String rotationTypeLabel(AppLocalizations l10n, RotationType type) {
  switch (type) {
    case RotationType.roundRobin:
      return l10n.rotationTypeRoundRobin;
    case RotationType.random:
      return l10n.rotationTypeRandom;
    case RotationType.weightedRandom:
      return l10n.rotationTypeWeightedRandom;
    case RotationType.loadBalancing:
      return l10n.rotationTypeLoadBalancing;
    case RotationType.disabled:
      return l10n.rotationTypeDisabled;
  }
}

String rotationTypeValueLabel(AppLocalizations l10n, String value) {
  return rotationTypeLabel(l10n, RotationType.fromString(value));
}

String priorityLabel(AppLocalizations l10n, TaskPriority priority) {
  switch (priority) {
    case TaskPriority.low:
      return l10n.priorityLow;
    case TaskPriority.medium:
      return l10n.priorityMedium;
    case TaskPriority.high:
      return l10n.priorityHigh;
    case TaskPriority.critical:
      return l10n.priorityCritical;
  }
}

String memberRoleLabel(AppLocalizations l10n, String role) {
  return role == 'ADMIN' ? l10n.roleAdmin : l10n.roleMember;
}

String formatRelativeJoinDate(AppLocalizations l10n, DateTime date) {
  final difference = DateTime.now().difference(date);

  if (difference.inDays < 1) {
    return l10n.dateToday;
  }
  if (difference.inDays < 7) {
    return l10n.dateDaysAgo(difference.inDays);
  }
  if (difference.inDays < 30) {
    return l10n.dateWeeksAgo((difference.inDays / 7).floor());
  }
  if (difference.inDays < 365) {
    return l10n.dateMonthsAgo((difference.inDays / 30).floor());
  }
  return l10n.dateYearsAgo((difference.inDays / 365).floor());
}
