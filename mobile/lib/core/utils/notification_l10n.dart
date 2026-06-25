import 'package:taskflow/data/models/notification.dart';
import 'package:taskflow/l10n/app_localizations.dart';

String notificationTitle(AppLocalizations l10n, AppNotification notification) {
  final title = notification.title.toLowerCase();

  if (title.contains('claimed') || title.contains('взята')) {
    return l10n.notificationTypeTaskClaimed;
  }
  if (title.contains('pending review') || title.contains('на проверке')) {
    return l10n.notificationTypeTaskPendingReview;
  }
  if ((title.contains('reward request') || title.contains('запрос награды')) &&
      !title.contains('approved') &&
      !title.contains('одобрен') &&
      !title.contains('rejected') &&
      !title.contains('отклон')) {
    return l10n.notificationTypeRewardRequest;
  }

  // Уже локализовано на бэкенде — показываем как есть.
  if (RegExp(r'[а-яё]', caseSensitive: false).hasMatch(notification.title)) {
    return notification.title;
  }

  switch (notification.type) {
    case AppNotificationType.taskAssigned:
      return l10n.notificationTypeTaskAssigned;
    case AppNotificationType.taskCompleted:
      return l10n.notificationTypeTaskCompleted;
    case AppNotificationType.taskApproved:
      return l10n.notificationTypeTaskApproved;
    case AppNotificationType.taskRejected:
      return l10n.notificationTypeTaskRejected;
    case AppNotificationType.rewardRequested:
      return l10n.notificationTypeRewardRequested;
    case AppNotificationType.rewardApproved:
      return l10n.notificationTypeRewardApproved;
    case AppNotificationType.rewardRejected:
      return l10n.notificationTypeRewardRejected;
    case AppNotificationType.pointAwarded:
      return l10n.notificationTypePointAwarded;
    case AppNotificationType.invitation:
      return l10n.notificationTypeInvitation;
    case AppNotificationType.system:
      return l10n.notificationTypeSystem;
  }
}

String notificationMessage(AppLocalizations l10n, AppNotification notification) {
  final message = notification.message;

  // Уже локализовано на бэкенде — показываем как есть.
  if (RegExp(r'[а-яё]', caseSensitive: false).hasMatch(message)) {
    return message;
  }

  final bonus = l10n.notificationMessageUpForGrabsBonus;

  RegExpMatch? match;

  match = RegExp(r'^You have been assigned: (.+)$').firstMatch(message);
  if (match != null) {
    return l10n.notificationMessageTaskAssigned(match.group(1)!);
  }

  match = RegExp(r'^You claimed: (.+)$').firstMatch(message);
  if (match != null) {
    return l10n.notificationMessageTaskClaimed(match.group(1)!);
  }

  match = RegExp(r'^Task "(.+)" is awaiting approval$').firstMatch(message);
  if (match != null) {
    return l10n.notificationMessageTaskAwaitingApproval(match.group(1)!);
  }

  match = RegExp(r'^Your task "(.+)" has been approved$').firstMatch(message);
  if (match != null) {
    return l10n.notificationMessageTaskApproved(match.group(1)!);
  }

  match = RegExp(r'^Your task "(.+)" was rejected: (.+)$').firstMatch(message);
  if (match != null) {
    final reason = match.group(2)! == 'No reason provided'
        ? l10n.notificationNoReason
        : match.group(2)!;
    return l10n.notificationMessageTaskRejected(match.group(1)!, reason);
  }

  match = RegExp(
    r'^You earned (\d+) points for completing "(.+)"( \(Up-for-Grabs bonus!\))?$',
  ).firstMatch(message);
  if (match != null) {
    return l10n.notificationMessagePointsEarnedCompletion(
      match.group(1)!,
      match.group(2)!,
      match.group(3) != null ? bonus : '',
    );
  }

  match = RegExp(
    r'^You earned (\d+) points for "(.+)" approval( \(Up-for-Grabs bonus!\))?$',
  ).firstMatch(message);
  if (match != null) {
    return l10n.notificationMessagePointsEarnedApproval(
      match.group(1)!,
      match.group(2)!,
      match.group(3) != null ? bonus : '',
    );
  }

  match = RegExp(r'^New reward request for "(.+)"$').firstMatch(message);
  if (match != null) {
    return l10n.notificationMessageRewardRequested(match.group(1)!);
  }

  match = RegExp(r'^Your reward request for "(.+)" has been approved$').firstMatch(message);
  if (match != null) {
    return l10n.notificationMessageRewardApproved(match.group(1)!);
  }

  match = RegExp(r'^Your reward request for "(.+)" was rejected: (.+)$').firstMatch(message);
  if (match != null) {
    final reason = match.group(2)! == 'No reason provided'
        ? l10n.notificationNoReason
        : match.group(2)!;
    return l10n.notificationMessageRewardRejected(match.group(1)!, reason);
  }

  match = RegExp(r'^"(.+)" is due in 24 hours$').firstMatch(message);
  if (match != null) {
    return l10n.notificationMessageDeadline24h(match.group(1)!);
  }

  match = RegExp(r'^"(.+)" is due in 1 hour$').firstMatch(message);
  if (match != null) {
    return l10n.notificationMessageDeadline1h(match.group(1)!);
  }

  return message;
}
