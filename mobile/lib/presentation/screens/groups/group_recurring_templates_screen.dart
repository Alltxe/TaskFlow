import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:taskflow/data/models/task.dart';
import 'package:taskflow/domain/usecases/task/task_usecase_providers.dart';
import 'package:taskflow/l10n/app_localizations.dart';
import 'package:taskflow/presentation/providers/task_state_provider.dart';
import 'package:taskflow/presentation/widgets/common/app_navigation_back_button.dart';

class GroupRecurringTemplatesScreen extends ConsumerWidget {
  final String groupId;

  const GroupRecurringTemplatesScreen({super.key, required this.groupId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final templatesAsync = ref.watch(recurringTemplatesProvider(groupId));

    return Scaffold(
      appBar: AppBar(
        leading: AppNavigationBackButton(fallbackRoute: '/groups/$groupId'),
        title: Text(l10n.recurringTemplates),
      ),
      body: templatesAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text(e.toString())),
        data: (templates) {
          if (templates.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.repeat,
                    size: 64,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(height: 16),
                  Text(l10n.recurringTemplatesEmpty),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: templates.length,
            itemBuilder: (_, i) => _TemplateCard(
              template: templates[i],
              groupId: groupId,
            ),
          );
        },
      ),
    );
  }
}

class _TemplateCard extends ConsumerStatefulWidget {
  final Task template;
  final String groupId;

  const _TemplateCard({required this.template, required this.groupId});

  @override
  ConsumerState<_TemplateCard> createState() => _TemplateCardState();
}

class _TemplateCardState extends ConsumerState<_TemplateCard> {
  bool _generating = false;

  Future<void> _generateNext() async {
    final l10n = AppLocalizations.of(context)!;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.generateNextTask),
        content: Text(l10n.generateNextTaskConfirm),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(l10n.yes),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;

    setState(() => _generating = true);

    final useCase = ref.read(generateNextRecurringTaskUseCaseProvider);
    final result = await useCase(widget.template.id);

    if (!mounted) return;

    setState(() => _generating = false);

    result.fold(
      (failure) => ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context)!.errorWithMessage(failure.message)),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      ),
      (task) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppLocalizations.of(context)!.taskGenerated)),
        );
        context.push('/tasks/${task.id}');
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final t = widget.template;

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.repeat, size: 18),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    t.title,
                    style: theme.textTheme.titleSmall,
                  ),
                ),
              ],
            ),
            if (t.description != null) ...[
              const SizedBox(height: 4),
              Text(
                t.description!,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
            if (t.recurrenceRule != null) ...[
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: theme.colorScheme.secondaryContainer,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  '${l10n.recurrenceRule}: ${t.recurrenceRule}',
                  style: theme.textTheme.bodySmall,
                ),
              ),
            ],
            const SizedBox(height: 12),
            Align(
              alignment: Alignment.centerRight,
              child: FilledButton.tonal(
                onPressed: _generating ? null : _generateNext,
                child: _generating
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Text(l10n.generateNextTask),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
