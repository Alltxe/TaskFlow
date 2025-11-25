import 'dart:async';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:taskflow/data/models/task_enums.dart';
import 'package:taskflow/l10n/app_localizations.dart';

/// Deadline countdown widget with visual indicator (PRD 3.4.2)
class DeadlineCountdown extends StatefulWidget {
  final DateTime deadline;
  final TaskStatus? status;
  final bool compact;

  const DeadlineCountdown({super.key, required this.deadline, this.compact = false, this.status});

  @override
  State<DeadlineCountdown> createState() => _DeadlineCountdownState();
}

class _DeadlineCountdownState extends State<DeadlineCountdown> {
  Timer? _ticker;

  @override
  void initState() {
    super.initState();
    // Update at an interval to keep countdowns in sync; keep lightweight
    _ticker = Timer.periodic(const Duration(seconds: 30), (_) {
      setState(() {});
    });
  }

  @override
  void dispose() {
    _ticker?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // If the task is completed, we don't need to show a timer — show status instead
    final l10n = AppLocalizations.of(context)!;
    if (widget.status == TaskStatus.completed) {
      if (widget.compact) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.check_circle, color: Colors.green.shade700, size: 14),
            const SizedBox(width: 4),
            Text(l10n.completed, style: TextStyle(color: Colors.green.shade700, fontSize: 12)),
          ],
        );
      }

      return Row(
        children: [
          Icon(Icons.check_circle, color: Colors.green.shade700),
          const SizedBox(width: 8),
          Text(
            l10n.completed,
            style: TextStyle(color: Colors.green.shade700, fontWeight: FontWeight.w600),
          ),
        ],
      );
    }

    final now = DateTime.now();
    final difference = widget.deadline.difference(now);
    final isOverdue = difference.isNegative;
    // localized strings already taken above

    // Determine urgency
    Color color;
    IconData icon;
    if (isOverdue) {
      color = Colors.red.shade700;
      icon = Icons.error_outline;
    } else if (difference.inHours < 24) {
      color = Colors.orange.shade700;
      icon = Icons.warning_amber;
    } else if (difference.inDays < 3) {
      color = Colors.yellow.shade800;
      icon = Icons.schedule;
    } else {
      color = Colors.grey.shade600;
      icon = Icons.schedule;
    }

    // Format time remaining
    String timeText;
    if (isOverdue) {
      final overdue = now.difference(widget.deadline);
      if (overdue.inDays > 0) {
        timeText = l10n.daysOverdue(overdue.inDays);
      } else if (overdue.inHours > 0) {
        timeText = l10n.hoursOverdue(overdue.inHours);
      } else {
        timeText = l10n.minutesOverdue(overdue.inMinutes);
      }
    } else {
      if (difference.inDays > 0) {
        timeText = l10n.daysLeft(difference.inDays);
      } else if (difference.inHours > 0) {
        timeText = l10n.hoursLeft(difference.inHours);
      } else {
        timeText = l10n.minutesLeft(difference.inMinutes);
      }
    }

    // Format deadline date
    final dateFormatter = DateFormat('MMM dd, HH:mm');
    final dateText = dateFormatter.format(widget.deadline);

    if (widget.compact) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 14),
          const SizedBox(width: 4),
          Text(
            timeText,
            style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.w500),
          ),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: 16),
            const SizedBox(width: 6),
            Text(
              timeText,
              style: TextStyle(color: color, fontSize: 14, fontWeight: FontWeight.w600),
            ),
          ],
        ),
        const SizedBox(height: 2),
        Text(dateText, style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
      ],
    );
  }
}
