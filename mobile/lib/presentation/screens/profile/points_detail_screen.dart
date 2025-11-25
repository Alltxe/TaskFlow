import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:taskflow/data/models/point_balance.dart';
import 'package:taskflow/data/models/point_transaction.dart';
import 'package:taskflow/domain/usecases/reward/reward_usecase_providers.dart';
import 'package:taskflow/l10n/app_localizations.dart';
import 'package:intl/intl.dart';

class PointsDetailScreen extends ConsumerStatefulWidget {
  final String? groupId;

  const PointsDetailScreen({super.key, this.groupId});

  @override
  ConsumerState<PointsDetailScreen> createState() => _PointsDetailScreenState();
}

class _PointsDetailScreenState extends ConsumerState<PointsDetailScreen> {
  PointBalance? _balance;
  List<PointTransaction> _transactions = [];
  bool _isLoading = true;
  bool _isLoadingMore = false;
  String? _error;
  int _offset = 0;
  final int _limit = 20;
  int _total = 0;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _error = null;
      _offset = 0;
    });

    final getPointBalanceUseCase = ref.read(getPointBalanceUseCaseProvider);
    final getPointTransactionHistoryUseCase =
        ref.read(getPointTransactionHistoryUseCaseProvider);

    final balanceResult =
        await getPointBalanceUseCase(groupId: widget.groupId);
    final transactionsResult = await getPointTransactionHistoryUseCase(
      groupId: widget.groupId,
      limit: _limit,
      offset: _offset,
    );

    if (!mounted) return;

    setState(() {
      _isLoading = false;
      balanceResult.fold(
        (failure) => _error = failure.message,
        (balance) => _balance = balance,
      );
      transactionsResult.fold(
        (failure) => _error = failure.message,
        (history) {
          _transactions = history.items;
          _total = history.total;
        },
      );
    });
  }

  Future<void> _loadMore() async {
    if (_isLoadingMore || _transactions.length >= _total) return;

    setState(() {
      _isLoadingMore = true;
    });

    final getPointTransactionHistoryUseCase =
        ref.read(getPointTransactionHistoryUseCaseProvider);

    final result = await getPointTransactionHistoryUseCase(
      groupId: widget.groupId,
      limit: _limit,
      offset: _offset + _limit,
    );

    if (!mounted) return;

    setState(() {
      _isLoadingMore = false;
      result.fold(
        (failure) => null, // Ignore errors when loading more
        (history) {
          _transactions.addAll(history.items);
          _offset += _limit;
        },
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final l10n = AppLocalizations.of(context)!;

    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(
          title: Text(l10n.pointsHistory),
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_error != null) {
      return Scaffold(
        appBar: AppBar(
          title: Text(l10n.pointsHistory),
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error_outline, size: 64, color: colorScheme.error),
                const SizedBox(height: 16),
                Text(_error!, textAlign: TextAlign.center),
                const SizedBox(height: 16),
                FilledButton.icon(
                  onPressed: _loadData,
                  icon: const Icon(Icons.refresh),
                  label: Text(l10n.retry),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.pointsHistory),
      ),
      body: RefreshIndicator(
        onRefresh: _loadData,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Balance cards
            if (_balance != null) ...[
              _buildBalanceCard(context, l10n, colorScheme),
              const SizedBox(height: 16),
              _buildDetailedBalanceCards(context, l10n, colorScheme),
              const SizedBox(height: 24),
            ],

            // Transaction history header
            Row(
              children: [
                Icon(Icons.history, color: colorScheme.primary),
                const SizedBox(width: 8),
                Text(
                  l10n.transactionHistory,
                  style: theme.textTheme.titleLarge,
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Transaction list
            if (_transactions.isEmpty)
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(32),
                  child: Column(
                    children: [
                      Icon(
                        Icons.receipt_long,
                        size: 64,
                        color: colorScheme.onSurfaceVariant,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        l10n.noTransactionsYet,
                        style: theme.textTheme.titleLarge,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        l10n.startCompletingTasks,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              )
            else
              ..._transactions.map((transaction) =>
                  _buildTransactionCard(context, transaction, l10n, colorScheme)),

            // Load more button
            if (_transactions.length < _total) ...[
              const SizedBox(height: 16),
              if (_isLoadingMore)
                const Center(child: CircularProgressIndicator())
              else
                FilledButton.icon(
                  onPressed: _loadMore,
                  icon: const Icon(Icons.expand_more),
                  label: Text('Load More (${_transactions.length}/$_total)'),
                ),
            ],

            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildBalanceCard(
      BuildContext context, AppLocalizations l10n, ColorScheme colorScheme) {
    return Card(
      elevation: 4,
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              colorScheme.primaryContainer,
              colorScheme.secondaryContainer,
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Text(
              l10n.availablePoints,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: colorScheme.onPrimaryContainer,
                  ),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.stars,
                  size: 40,
                  color: colorScheme.primary,
                ),
                const SizedBox(width: 12),
                Text(
                  '${_balance!.availableBalance}',
                  style: Theme.of(context).textTheme.displayLarge?.copyWith(
                        color: colorScheme.primary,
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailedBalanceCards(
      BuildContext context, AppLocalizations l10n, ColorScheme colorScheme) {
    return Row(
      children: [
        Expanded(
          child: _buildSmallStatCard(
            context,
            l10n.totalEarned,
            '${_balance!.totalEarned}',
            Icons.add_circle,
            Colors.green,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildSmallStatCard(
            context,
            l10n.totalSpent,
            '${_balance!.totalSpentApproved}',
            Icons.remove_circle,
            Colors.red,
          ),
        ),
      ],
    );
  }

  Widget _buildSmallStatCard(
    BuildContext context,
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(height: 8),
            Text(
              value,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: color,
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: Theme.of(context).textTheme.bodySmall,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTransactionCard(
    BuildContext context,
    PointTransaction transaction,
    AppLocalizations l10n,
    ColorScheme colorScheme,
  ) {
    final isEarned = transaction.type == 'EARNED';
    final color = isEarned ? Colors.green : Colors.red;
    final icon = isEarned ? Icons.add_circle : Icons.remove_circle;
    final dateFormat = DateFormat('MMM dd, yyyy \'at\' HH:mm');

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: color.withValues(alpha: 0.1),
          child: Icon(icon, color: color, size: 24),
        ),
        title: Text(
          transaction.description,
          style: Theme.of(context).textTheme.titleSmall,
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            if (transaction.relatedTaskTitle != null)
              Text(
                'Task: ${transaction.relatedTaskTitle}',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
              ),
            if (transaction.relatedRewardName != null)
              Text(
                'Reward: ${transaction.relatedRewardName}',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
              ),
            const SizedBox(height: 2),
            Text(
              dateFormat.format(transaction.createdAt),
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
            ),
          ],
        ),
        trailing: Text(
          '${isEarned ? '+' : '-'}${transaction.amount}',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: color,
                fontWeight: FontWeight.bold,
              ),
        ),
      ),
    );
  }
}
