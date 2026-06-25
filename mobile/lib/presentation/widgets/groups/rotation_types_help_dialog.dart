import 'package:flutter/material.dart';
import 'package:taskflow/core/utils/enum_l10n.dart';
import 'package:taskflow/data/models/task_enums.dart';
import 'package:taskflow/l10n/app_localizations.dart';

String rotationTypeHelpBody(AppLocalizations l10n, RotationType type) {
  switch (type) {
    case RotationType.roundRobin:
      return l10n.rotationTypeHelpRoundRobin;
    case RotationType.random:
      return l10n.rotationTypeHelpRandom;
    case RotationType.weightedRandom:
      return l10n.rotationTypeHelpWeightedRandom;
    case RotationType.loadBalancing:
      return l10n.rotationTypeHelpLoadBalancing;
    case RotationType.disabled:
      return l10n.rotationTypeHelpDisabled;
  }
}

Future<void> showRotationTypesHelpDialog(BuildContext context) {
  final l10n = AppLocalizations.of(context)!;
  final theme = Theme.of(context);

  return showDialog<void>(
    context: context,
    builder: (dialogContext) {
      return AlertDialog(
        title: Row(
          children: [
            Icon(Icons.info_outline, color: theme.colorScheme.primary),
            const SizedBox(width: 8),
            Expanded(child: Text(l10n.rotationTypesHelpTitle)),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                l10n.rotationTypesHelpIntro,
                style: theme.textTheme.bodyMedium,
              ),
              const SizedBox(height: 16),
              for (final type in RotationType.values) ...[
                Text(
                  rotationTypeLabel(l10n, type),
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  rotationTypeHelpBody(l10n, type),
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                if (type != RotationType.values.last) const SizedBox(height: 12),
              ],
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: Text(l10n.ok),
          ),
        ],
      );
    },
  );
}

class RotationTypesHelpIconButton extends StatelessWidget {
  const RotationTypesHelpIconButton({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return IconButton(
      icon: const Icon(Icons.info_outline),
      tooltip: l10n.rotationTypesHelpTitle,
      onPressed: () => showRotationTypesHelpDialog(context),
    );
  }
}
