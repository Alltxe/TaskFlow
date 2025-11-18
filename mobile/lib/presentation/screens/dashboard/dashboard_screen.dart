import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:mobile/data/models/user_statistics.dart';
import 'package:mobile/data/providers/auth_providers.dart';
import 'package:mobile/data/providers/profile_providers.dart';
import 'package:mobile/domain/usecases/task/task_usecase_providers.dart';
import 'package:mobile/l10n/app_localizations.dart';
import 'package:mobile/presentation/widgets/task/task_card.dart';

/// Dashboard/Home tab screen showing user statistics, upcoming tasks, and calendar
class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  String? _selectedGroupId; // null means "All Groups"
  DateTime _selectedDate = DateTime.now();
  DateTime _weekStart = DateTime.now();

  @override
  void initState() {
    super.initState();
    // Set week start to Monday
    _weekStart = _getWeekStart(DateTime.now());
  }

  DateTime _getWeekStart(DateTime date) {
    // Get Monday of the week
    final weekday = date.weekday; // 1 = Monday, 7 = Sunday
    return date.subtract(Duration(days: weekday - 1));
  }

  List<DateTime> _getWeekDays() {
    return List.generate(7, (index) => _weekStart.add(Duration(days: index)));
  }

  void _previousWeek() {
    setState(() {
      _weekStart = _weekStart.subtract(const Duration(days: 7));
    });
  }

  void _nextWeek() {
    setState(() {
      _weekStart = _weekStart.add(const Duration(days: 7));
    });
  }

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authStateProvider);
    final username = authState.user?.username ?? '';

    return Scaffold(
      appBar: AppBar(title: Text(AppLocalizations.of(context)!.home)),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(getUserTasksUseCaseProvider);
          ref.invalidate(getUserGroupsUseCaseProvider);
        },
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Welcome message
            Text(
              AppLocalizations.of(context)!.welcomeUser(username),
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 24),

            // Group filter
            _buildGroupFilter(),
            const SizedBox(height: 24),

            // Statistics cards
            _buildStatisticsSection(),
            const SizedBox(height: 24),

            // Week calendar strip
            _buildWeekCalendar(),
            const SizedBox(height: 24),

            // Tasks for selected date
            _buildTasksForDate(),
          ],
        ),
      ),
    );
  }

  Widget _buildGroupFilter() {
    final getUserGroupsUseCase = ref.read(getUserGroupsUseCaseProvider);

    return FutureBuilder(
      future: getUserGroupsUseCase(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const SizedBox.shrink();

        final groupsResult = snapshot.data!;
        return groupsResult.fold((failure) => const SizedBox.shrink(), (groups) {
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
                  ...groups.map((group) {
                    return DropdownMenuItem<String?>(value: group.id, child: Text(group.name));
                  }),
                ],
                onChanged: (value) {
                  setState(() {
                    _selectedGroupId = value;
                  });
                },
              ),
            ),
          );
        });
      },
    );
  }

  Widget _buildStatisticsSection() {
    // Fetch statistics based on selected group
    final statsQuery = _selectedGroupId != null
        ? ref.read(profileRemoteDataSourceProvider).getUserStatistics(groupId: _selectedGroupId)
        : ref.read(profileRemoteDataSourceProvider).getUserStatistics();

    return FutureBuilder<UserStatistics>(
      future: statsQuery,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError || !snapshot.hasData) {
          return const SizedBox.shrink();
        }

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
                style: Theme.of(
                  context,
                ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold, color: color),
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
        // Week navigation
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            IconButton(
              icon: const Icon(Icons.chevron_left),
              onPressed: _previousWeek,
              tooltip: AppLocalizations.of(context)!.previousWeek,
            ),
            Text(
              '${DateFormat('MMM d').format(weekDays.first)} - ${DateFormat('MMM d, y').format(weekDays.last)}',
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

        // Week days strip
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
                onTap: () {
                  setState(() {
                    _selectedDate = date;
                  });
                },
                child: Container(
                  width: 70,
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? Theme.of(context).colorScheme.primaryContainer
                        : (isToday ? Theme.of(context).colorScheme.secondaryContainer : null),
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
      case 1:
        return l10n.monday.substring(0, 3);
      case 2:
        return l10n.tuesday.substring(0, 3);
      case 3:
        return l10n.wednesday.substring(0, 3);
      case 4:
        return l10n.thursday.substring(0, 3);
      case 5:
        return l10n.friday.substring(0, 3);
      case 6:
        return l10n.saturday.substring(0, 3);
      case 7:
        return l10n.sunday.substring(0, 3);
      default:
        return '';
    }
  }

  Widget _buildTasksForDate() {
    final getUserTasksUseCase = ref.read(getUserTasksUseCaseProvider);

    return FutureBuilder(
      future: getUserTasksUseCase(status: null),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError || !snapshot.hasData) {
          return Center(
            child: Text(
              AppLocalizations.of(
                context,
              )!.errorWithMessage(snapshot.error?.toString() ?? 'Unknown error'),
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
          );
        }

        final tasksResult = snapshot.data!;
        return tasksResult.fold(
          (failure) => Center(
            child: Text(
              AppLocalizations.of(context)!.errorWithMessage(failure.message),
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
          ),
          (allTasks) {
            // Filter tasks by selected date and group
            final filteredTasks = allTasks.where((task) {
              final taskDate = task.deadline;
              final matchesDate = _isSameDay(taskDate, _selectedDate);
              final matchesGroup = _selectedGroupId == null || task.groupId == _selectedGroupId;
              return matchesDate && matchesGroup;
            }).toList();

            // Sort tasks: active first (by deadline), then completed
            filteredTasks.sort((a, b) {
              if (a.status == 'COMPLETED' && b.status != 'COMPLETED') return 1;
              if (a.status != 'COMPLETED' && b.status == 'COMPLETED') return -1;
              return a.deadline.compareTo(b.deadline);
            });

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  AppLocalizations.of(
                    context,
                  )!.tasksForDate(DateFormat('MMM d, y').format(_selectedDate)),
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
                  ...filteredTasks.map((task) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: TaskCard(task: task, onTap: () => context.push('/tasks/${task.id}')),
                    );
                  }),
              ],
            );
          },
        );
      },
    );
  }
}
