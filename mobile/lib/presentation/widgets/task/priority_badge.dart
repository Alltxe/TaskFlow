import 'package:flutter/material.dart';
import 'package:taskflow/core/theme/app_colors.dart';
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
      TaskPriority.critical => (
        AppColors.priorityCritical,
        Icons.priority_high_rounded,
        l10n.priorityCritical,
      ),
      TaskPriority.high => (
        Colors.red.shade700,
        Icons.keyboard_double_arrow_up_rounded,
        l10n.priorityHigh,
      ),
      TaskPriority.medium => (
        Colors.orange.shade800,
        Icons.drag_handle_rounded,
        l10n.priorityMedium,
      ),
      TaskPriority.low => (
        Colors.blue.shade700,
        Icons.keyboard_double_arrow_down_rounded,
        l10n.priorityLow,
      ),
    };

    if (compact) {
      return Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.16),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: color.withValues(alpha: 0.45)),
        ),
        child: Icon(icon, color: color, size: 18),
      );
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 16),
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
