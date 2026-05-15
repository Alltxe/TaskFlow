import 'package:dartz/dartz.dart' hide Task;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:taskflow/core/errors/failure.dart';
import 'package:taskflow/data/models/group_summary.dart';
import 'package:taskflow/data/models/task.dart';
import 'package:taskflow/data/models/user_statistics.dart';
import 'package:taskflow/data/providers/auth_providers.dart';
import 'package:taskflow/data/providers/profile_providers.dart';
import 'package:taskflow/domain/usecases/task/task_usecase_providers.dart';
import 'package:taskflow/l10n/app_localizations.dart';
import 'package:taskflow/presentation/widgets/task/task_card.dart';

/// Dashboard/Home tab screen showing user statistics, upcoming tasks, and calendar
class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  String? _selectedGroupId;
  DateTime _selectedDate = DateTime.now();
  DateTime _weekStart = DateTime.now();

  // Cached futures — stable across rebuilds caused by setState
  Future<Either<Failure, List<GroupSummary>>>? _groupsFuture;
  Future<UserStatistics>? _statsFuture;
  Future<Either<Failure, List<Task>>>? _tasksFuture;

  @override
  void initState() {
    super.initState();
    _weekStart = _getWeekStart(DateTime.now());
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Only initialise once per widget lifecycle
    _groupsFuture ??= ref.read(getUserGroupsUseCaseProvider).call();
    _statsFuture ??= ref.read(profileRemoteDataSourceProvider).getUserStatistics();
    _tasksFuture ??= ref.read(getUserTasksUseCaseProvider).call(status: null);
  }

  void _onGroupChanged(String? groupId) {
    final ds = ref.read(profileRemoteDataSourceProvider);
    setState(() {
      _selectedGroupId = groupId;
      // Stats are group-specific — re-fetch only stats, keep groups/tasks stable
      _statsFuture = groupId != null
          ? ds.getUserStatistics(groupId: groupId)
          : ds.getUserStatistics();
    });
  }

  void _refresh() {
    final ds = ref.read(profileRemoteDataSourceProvider);
    setState(() {
      _groupsFuture = ref.read(getUserGroupsUseCaseProvider).call();
      _statsFuture = ds.getUserStatistics(groupId: _selectedGroupId);
      _tasksFuture = ref.read(getUserTasksUseCaseProvider).call(status: null);
    });
  }

  // ── Helpers ───────────────────────────────────────────────────────────────

  DateTime _getWeekStart(DateTime date) {
    return date.subtract(Duration(days: date.weekday - 1));
  }

  List<DateTime> _getWeekDays() =>
      List.generate(7, (i) => _weekStart.add(Duration(days: i)));

  void _previousWeek() =>
      setState(() => _weekStart = _weekStart.subtract(const Duration(days: 7)));

  void _nextWeek() =>
      setState(() => _weekStart = _weekStart.add(const Duration(days: 7)));

  bool _isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final username = ref.watch(authStateProvider).user?.username ?? '';

    return Scaffold(
      appBar: AppBar(title: Text(AppLocalizations.of(context)!.home)),
      body: RefreshIndicator(
        onRefresh: () async => _refresh(),
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Text(
              AppLocalizations.of(context)!.welcomeUser(username),
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 24),
            _buildGroupFilter(),
            const SizedBox(height: 24),
            _buildStatisticsSection(),
            const SizedBox(height: 24),
            _buildWeekCalendar(),
            const SizedBox(height: 24),
            _buildTasksForDate(),
          ],
        ),
      ),
    );
  }

  Widget _buildGroupFilter() {
    return FutureBuilder<Either<Failure, List<GroupSummary>>>(
      future: _groupsFuture,
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const SizedBox.shrink();

        return snapshot.data!.fold(
          (_) => const SizedBox.shrink(),
          (groups) {
            if (groups.isEmpty) return const SizedBox.shrink();
            return Card(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: DropdownButton<String?>(
                  isExpanded: true,
                  value: _selectedGroupId,
                  underline: const SizedBox.shrink(),
                  hint: Text(AppLocalizations.of(context)!.filterByGroup),
                  items: [
                    DropdownMenuItem<String?>(
                      value: null,
                      child: Text(AppLocalizations.of(context)!.allGroups),
                    ),
                    ...groups.map(
                      (g) => DropdownMenuItem<String?>(
                        value: g.id,
                        child: Text(g.name),
                      ),
                    ),
                  ],
                  onChanged: _onGroupChanged,
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildStatisticsSection() {
    return FutureBuilder<UserStatistics>(
      future: _statsFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (!snapshot.hasData) return const SizedBox.shrink();

        final stats = snapshot.data!;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              AppLocalizations.of(context)!.quickStats,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 12),
            GridView.count(
              crossAxisCount: 3,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: 8,
              crossAxisSpacing: 8,
              childAspectRatio: 0.85,
              children: [
                _buildStatCard(
                  AppLocalizations.of(context)!.tasksAssigned,
                  stats.tasksAssigned.toString(),
                  Icons.assignment,
                  Colors.blue,
                ),
                _buildStatCard(
                  AppLocalizations.of(context)!.tasksCompletedLabel,
                  stats.tasksCompleted.toString(),
                  Icons.check_circle,
                  Colors.green,
                ),
                _buildStatCard(
                  AppLocalizations.of(context)!.pointsBalance,
                  stats.currentPointBalance.toString(),
                  Icons.star,
                  Colors.amber,
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 4),
            Flexible(
              child: Text(
                value,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(height: 1),
            Flexible(
              child: Text(
                title,
                style: Theme.of(context).textTheme.bodySmall,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWeekCalendar() {
    final weekDays = _getWeekDays();
    final now = DateTime.now();

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            IconButton(
              icon: const Icon(Icons.chevron_left),
              onPressed: _previousWeek,
              tooltip: AppLocalizations.of(context)!.previousWeek,
            ),
            Text(
              '${DateFormat('MMM d').format(weekDays.first)} – '
              '${DateFormat('MMM d, y').format(weekDays.last)}',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            IconButton(
              icon: const Icon(Icons.chevron_right),
              onPressed: _nextWeek,
              tooltip: AppLocalizations.of(context)!.nextWeek,
            ),
          ],
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 80,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: weekDays.length,
            itemBuilder: (context, index) {
              final date = weekDays[index];
              final isSelected = _isSameDay(date, _selectedDate);
              final isToday = _isSameDay(date, now);

              return GestureDetector(
                onTap: () => setState(() => _selectedDate = date),
                child: Container(
                  width: 70,
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? Theme.of(context).colorScheme.primaryContainer
                        : (isToday
                            ? Theme.of(context).colorScheme.secondaryContainer
                            : null),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isSelected
                          ? Theme.of(context).colorScheme.primary
                          : Theme.of(context).colorScheme.outline.withOpacity(0.3),
                      width: isSelected ? 2 : 1,
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        _getWeekdayName(date.weekday),
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: isSelected
                              ? Theme.of(context).colorScheme.onPrimaryContainer
                              : Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        DateFormat('d').format(date),
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: isSelected
                              ? Theme.of(context).colorScheme.onPrimaryContainer
                              : Theme.of(context).colorScheme.onSurface,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  String _getWeekdayName(int weekday) {
    final l10n = AppLocalizations.of(context)!;
    switch (weekday) {
      case 1: return l10n.monday.substring(0, 3);
      case 2: return l10n.tuesday.substring(0, 3);
      case 3: return l10n.wednesday.substring(0, 3);
      case 4: return l10n.thursday.substring(0, 3);
      case 5: return l10n.friday.substring(0, 3);
      case 6: return l10n.saturday.substring(0, 3);
      case 7: return l10n.sunday.substring(0, 3);
      default: return '';
    }
  }

  Widget _buildTasksForDate() {
    return FutureBuilder<Either<Failure, List<Task>>>(
      future: _tasksFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (!snapshot.hasData) {
          return Center(
            child: Text(
              AppLocalizations.of(context)!.errorWithMessage(
                snapshot.error?.toString() ?? 'Unknown error',
              ),
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
          );
        }

        return snapshot.data!.fold(
          (failure) => Center(
            child: Text(
              AppLocalizations.of(context)!.errorWithMessage(failure.message),
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
          ),
          (allTasks) {
            final filteredTasks = allTasks.where((task) {
              final matchesDate = _isSameDay(task.deadline, _selectedDate);
              final matchesGroup =
                  _selectedGroupId == null || task.groupId == _selectedGroupId;
              return matchesDate && matchesGroup;
            }).toList()
              ..sort((a, b) {
                if (a.status == 'COMPLETED' && b.status != 'COMPLETED') return 1;
                if (a.status != 'COMPLETED' && b.status == 'COMPLETED') return -1;
                return a.deadline.compareTo(b.deadline);
              });

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  AppLocalizations.of(context)!.tasksForDate(
                    DateFormat('MMM d, y').format(_selectedDate),
                  ),
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 12),
                if (filteredTasks.isEmpty)
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.all(32),
                      child: Column(
                        children: [
                          Icon(
                            Icons.task_alt,
                            size: 64,
                            color: Theme.of(context).colorScheme.outline,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            AppLocalizations.of(context)!.noTasksDueToday,
                            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              color: Theme.of(context).colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                else
                  ...filteredTasks.map(
                    (task) => Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: TaskCard(
                        task: task,
                        onTap: () => context.push('/tasks/${task.id}'),
                      ),
                    ),
                  ),
              ],
            );
          },
        );
      },
    );
  }
}
