import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:taskflow/data/providers/audit_log_providers.dart';
import 'package:taskflow/l10n/app_localizations.dart';
import 'package:taskflow/presentation/widgets/audit/audit_log_list_widget.dart';
import 'package:taskflow/presentation/widgets/common/app_navigation_back_button.dart';

class GroupAuditLogScreen extends ConsumerWidget {
  final String groupId;

  const GroupAuditLogScreen({super.key, required this.groupId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final logsAsync = ref.watch(groupAuditLogProvider(groupId));

    return Scaffold(
      appBar: AppBar(
        leading: AppNavigationBackButton(fallbackRoute: '/groups/$groupId'),
        title: Text(l10n.groupAuditLog),
      ),
      body: logsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(error.toString()),
              const SizedBox(height: 16),
              FilledButton(
                onPressed: () => ref.invalidate(groupAuditLogProvider(groupId)),
                child: Text(l10n.retry),
              ),
            ],
          ),
        ),
        data: (logs) => RefreshIndicator(
          onRefresh: () async => ref.invalidate(groupAuditLogProvider(groupId)),
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              AuditLogListWidget(logs: logs),
            ],
          ),
        ),
      ),
    );
  }
}
