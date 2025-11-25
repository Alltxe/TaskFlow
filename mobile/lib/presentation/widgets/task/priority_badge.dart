import 'package:flutter/material.dart';
import 'package:taskflow/data/models/task_enums.dart';
import 'package:taskflow/l10n/app_localizations.dart';

/// Priority indicator badge (PRD 3.4.2)
class PriorityBadge extends StatelessWidget {
  final TaskPriority priority;
  final bool compact;

  const PriorityBadge({
    super.key,
    required this.priority,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    final (color, icon, label) = switch (priority) {
      TaskPriority.high => (Colors.red.shade700, Icons.priority_high, l10n.priorityHigh),
      TaskPriority.medium => (Colors.orange.shade700, Icons.remove, l10n.priorityMedium),
      TaskPriority.low => (Colors.blue.shade700, Icons.arrow_downward, l10n.priorityLow),
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
