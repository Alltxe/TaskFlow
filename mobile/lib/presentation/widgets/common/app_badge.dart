import 'package:flutter/material.dart';

/// Tonal badge with readable contrast: light fill, saturated text, subtle border.
class AppBadge extends StatelessWidget {
  final String label;
  final Color color;
  final IconData? icon;
  final bool compact;

  const AppBadge({
    super.key,
    required this.label,
    required this.color,
    this.icon,
    this.compact = false,
  });

  factory AppBadge.primary(
    BuildContext context, {
    required String label,
    IconData? icon,
    bool compact = false,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    return AppBadge(
      label: label,
      color: colorScheme.primary,
      icon: icon,
      compact: compact,
    );
  }

  factory AppBadge.secondary(
    BuildContext context, {
    required String label,
    IconData? icon,
    bool compact = false,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    return AppBadge(
      label: label,
      color: colorScheme.secondary,
      icon: icon,
      compact: compact,
    );
  }

  factory AppBadge.neutral(
    BuildContext context, {
    required String label,
    IconData? icon,
    bool compact = false,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    return AppBadge(
      label: label,
      color: colorScheme.onSurfaceVariant,
      icon: icon,
      compact: compact,
    );
  }

  factory AppBadge.success({
    required String label,
    IconData? icon,
    bool compact = false,
  }) {
    return AppBadge(
      label: label,
      color: Colors.green.shade700,
      icon: icon,
      compact: compact,
    );
  }

  factory AppBadge.error(
    BuildContext context, {
    required String label,
    IconData? icon,
    bool compact = false,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    return AppBadge(
      label: label,
      color: colorScheme.error,
      icon: icon,
      compact: compact,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: compact ? 8 : 10,
        vertical: compact ? 4 : 5,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(compact ? 8 : 12),
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, color: color, size: compact ? 14 : 16),
            const SizedBox(width: 4),
          ],
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: compact ? 11 : 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
