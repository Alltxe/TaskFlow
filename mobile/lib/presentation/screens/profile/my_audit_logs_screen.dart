import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:taskflow/data/providers/audit_log_providers.dart';
import 'package:taskflow/l10n/app_localizations.dart';
import 'package:taskflow/presentation/widgets/audit/audit_log_list_widget.dart';

class MyAuditLogsScreen extends ConsumerWidget {
  const MyAuditLogsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final logsAsync = ref.watch(myAuditLogsProvider);
    final groupNamesAsync = ref.watch(userGroupNamesProvider);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.myActions)),
      body: logsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text(error.toString())),
        data: (logs) => groupNamesAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, _) => Center(child: Text(error.toString())),
          data: (groupNames) => RefreshIndicator(
            onRefresh: () async {
              ref.invalidate(myAuditLogsProvider);
              ref.invalidate(userGroupNamesProvider);
            },
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                AuditLogListWidget(
                  logs: logs,
                  variant: AuditLogListVariant.personal,
                  groupNames: groupNames,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
