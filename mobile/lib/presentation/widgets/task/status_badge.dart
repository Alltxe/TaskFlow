import 'package:flutter/material.dart';
import 'package:mobile/data/models/task_enums.dart';
import 'package:mobile/l10n/app_localizations.dart';

/// Status indicator badge (PRD 3.4.2)
class StatusBadge extends StatelessWidget {
  final TaskStatus status;
  final bool compact;

  const StatusBadge({
    super.key,
    required this.status,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    final (color, icon, label) = switch (status) {
      TaskStatus.pending => (Colors.blue, Icons.schedule, l10n.statusActive),
      TaskStatus.awaitingApproval => (Colors.orange, Icons.pending, l10n.statusPendingReview),
      TaskStatus.completed => (Colors.green, Icons.check_circle, l10n.statusCompleted),
      TaskStatus.overdue => (Colors.red, Icons.warning, l10n.statusOverdue),
    };

    if (compact) {
      return Icon(icon, color: color, size: 16);
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 14),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
