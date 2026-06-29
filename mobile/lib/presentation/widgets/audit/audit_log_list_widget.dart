import 'package:flutter/material.dart';
import 'package:taskflow/core/utils/audit_l10n.dart';
import 'package:taskflow/core/utils/date_l10n.dart';
import 'package:taskflow/data/models/audit_log.dart';
import 'package:taskflow/l10n/app_localizations.dart';

enum AuditLogListVariant {
  group,
  personal,
}

class AuditLogListWidget extends StatelessWidget {
  final List<AuditLog> logs;
  final bool compact;
  final AuditLogListVariant variant;
  final Map<String, String> groupNames;

  const AuditLogListWidget({
    super.key,
    required this.logs,
    this.compact = false,
    this.variant = AuditLogListVariant.group,
    this.groupNames = const {},
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    if (logs.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Text(
          l10n.noAuditLogs,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      );
    }

    return ListView.separated(
      shrinkWrap: true,
      physics: compact ? const NeverScrollableScrollPhysics() : null,
      itemCount: logs.length,
      separatorBuilder: (_, __) => const Divider(height: 1),
      itemBuilder: (context, index) {
        final log = logs[index];
        final title = auditActionLabel(l10n, log.action);
        final detail = auditLogDetail(l10n, log);
        final performer = auditPerformerName(l10n, log);
        final date = formatMonthDayYearTime(context, log.performedAt);
        final iconColor = auditActionColor(context, log.action);
        final isPersonal = variant == AuditLogListVariant.personal;
        final groupLabel = isPersonal ? auditLogGroupLabel(l10n, log, groupNames) : null;
        final metaStyle = theme.textTheme.bodySmall?.copyWith(
          color: theme.colorScheme.onSurfaceVariant,
        );
        final subtitleLines = <Widget>[
          if (isPersonal && groupLabel != null)
            Text(
              groupLabel,
              style: theme.textTheme.labelMedium?.copyWith(
                color: theme.colorScheme.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          if (detail != null)
            Text(
              detail,
              style: theme.textTheme.bodyMedium,
            ),
          Text(
            isPersonal ? date : l10n.auditLogEntryMeta(performer, date),
            style: metaStyle,
          ),
        ];

        return ListTile(
          dense: compact,
          contentPadding: compact ? EdgeInsets.zero : const EdgeInsets.symmetric(vertical: 4),
          leading: CircleAvatar(
            radius: compact ? 18 : 22,
            backgroundColor: iconColor.withValues(alpha: 0.12),
            child: Icon(
              auditActionIcon(log.action),
              size: compact ? 18 : 22,
              color: iconColor,
            ),
          ),
          title: Text(
            title,
            style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
          ),
          subtitle: Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: subtitleLines,
            ),
          ),
          isThreeLine: subtitleLines.length > 1,
        );
      },
    );
  }
}
