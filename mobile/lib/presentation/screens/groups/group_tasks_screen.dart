import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:mobile/data/models/task.dart';
import 'package:mobile/data/providers/auth_providers.dart';
import 'package:mobile/domain/usecases/task/task_usecase_providers.dart';
import 'package:mobile/l10n/app_localizations.dart';

class GroupTasksScreen extends ConsumerStatefulWidget {
  final String groupId;

  const GroupTasksScreen({super.key, required this.groupId});

  @override
  ConsumerState<GroupTasksScreen> createState() => _GroupTasksScreenState();
}

class _GroupTasksScreenState extends ConsumerState<GroupTasksScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<Task> _tasks = [];
  bool _isLoading = true;
  String? _error;
  String? _currentUserId;
  String _searchQuery = '';
  String? _priorityFilter;
  String? _statusFilter;

  final List<String> _priorities = ['LOW', 'MEDIUM', 'HIGH'];
  final List<String> _statuses = ['PENDING', 'AWAITING_APPROVAL', 'COMPLETED', 'OVERDUE'];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _loadTasks();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadTasks() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    // Get current user ID
    final authState = ref.read(authStateProvider);
    if (authState.status == AuthStatus.authenticated && authState.user != null) {
      _currentUserId = authState.user!.id;
    } else {
      _currentUserId = null;
    }

    // Load group tasks
    final getTasksUseCase = ref.read(getGroupTasksUseCaseProvider);
    final result = await getTasksUseCase(widget.groupId);

    if (!mounted) return;

    setState(() {
      _isLoading = false;
      result.fold((failure) => _error = failure.message, (tasks) => _tasks = tasks);
    });
  }

  List<Task> get _filteredTasks {
    var tasks = _tasks;

    // Apply tab filter
    switch (_tabController.index) {
      case 0: // All tasks
        break;
      case 1: // My tasks
        tasks = tasks.where((task) => task.assigneeId == _currentUserId).toList();
        break;
      case 2: // Available (up for grabs)
        tasks = tasks.where((task) => task.assigneeId == null && task.status == 'PENDING').toList();
        break;
      case 3: // Awaiting approval
        tasks = tasks.where((task) => task.status == 'AWAITING_APPROVAL').toList();
        break;
    }

    // Apply search filter
    if (_searchQuery.isNotEmpty) {
      tasks = tasks.where((task) {
        final titleMatch = task.title.toLowerCase().contains(_searchQuery.toLowerCase());
        final descMatch =
            task.description?.toLowerCase().contains(_searchQuery.toLowerCase()) ?? false;
        return titleMatch || descMatch;
      }).toList();
    }

    // Apply priority filter
    if (_priorityFilter != null) {
      tasks = tasks.where((task) => task.priority == _priorityFilter).toList();
    }

    // Apply status filter
    if (_statusFilter != null) {
      tasks = tasks.where((task) => task.status == _statusFilter).toList();
    }

    return tasks;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Column(
      children: [
        // Filters
        Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              // Search bar
              TextField(
                decoration: InputDecoration(
                  hintText: AppLocalizations.of(context)!.searchTasks,
                  prefixIcon: const Icon(Icons.search),
                  border: const OutlineInputBorder(),
                  suffixIcon: _searchQuery.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () {
                            setState(() => _searchQuery = '');
                          },
                        )
                      : null,
                ),
                onChanged: (value) {
                  setState(() => _searchQuery = value);
                },
              ),
              const SizedBox(height: 12),

              // Filter chips
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    // Priority filter
                    ChoiceChip(
                      label: Text(_priorityFilter ?? AppLocalizations.of(context)!.allPriorities),
                      selected: _priorityFilter != null,
                      onSelected: (selected) {
                        _showPriorityFilter(context);
                      },
                    ),
                    const SizedBox(width: 8),

                    // Status filter
                    ChoiceChip(
                      label: Text(_statusFilter ?? AppLocalizations.of(context)!.allStatuses),
                      selected: _statusFilter != null,
                      onSelected: (selected) {
                        _showStatusFilter(context);
                      },
                    ),
                    const SizedBox(width: 8),

                    // Clear filters button
                    if (_priorityFilter != null || _statusFilter != null)
                      ActionChip(
                        label: Text(AppLocalizations.of(context)!.clearFilters),
                        onPressed: () {
                          setState(() {
                            _priorityFilter = null;
                            _statusFilter = null;
                          });
                        },
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),

        // Tabs
        TabBar(
          controller: _tabController,
          onTap: (_) => setState(() {}),
          tabs: [
            Tab(text: AppLocalizations.of(context)!.allTab),
            Tab(text: AppLocalizations.of(context)!.myTasksTab),
            Tab(text: AppLocalizations.of(context)!.availableTab),
            Tab(text: AppLocalizations.of(context)!.reviewTab),
          ],
        ),

        // Task list
        Expanded(
          child: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _error != null
              ? _buildErrorState(colorScheme)
              : RefreshIndicator(onRefresh: _loadTasks, child: _buildTasksList(colorScheme)),
        ),
      ],
    );
  }

  Widget _buildErrorState(ColorScheme colorScheme) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error_outline, size: 64, color: colorScheme.error),
            const SizedBox(height: 16),
            Text(_error!, textAlign: TextAlign.center),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: _loadTasks,
              icon: const Icon(Icons.refresh),
              label: Text(AppLocalizations.of(context)!.retry),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTasksList(ColorScheme colorScheme) {
    final tasks = _filteredTasks;

    if (tasks.isEmpty) {
      return ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                children: [
                  Icon(Icons.task_alt, size: 64, color: colorScheme.onSurfaceVariant),
                  const SizedBox(height: 16),
                  Text(
                    AppLocalizations.of(context)!.noTasksFound,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    AppLocalizations.of(context)!.tryAdjustingFilters,
                    style: Theme.of(
                      context,
                    ).textTheme.bodyMedium?.copyWith(color: colorScheme.onSurfaceVariant),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        ],
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: tasks.length,
      itemBuilder: (context, index) {
        final task = tasks[index];
        return _buildTaskCard(task, colorScheme);
      },
    );
  }

  Widget _buildTaskCard(Task task, ColorScheme colorScheme) {
    final isMyTask = task.assigneeId == _currentUserId;
    final isOverdue = task.deadline.isBefore(DateTime.now()) && task.status != 'COMPLETED';

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () => _showTaskDetails(task),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header row
              Row(
                children: [
                  Expanded(
                    child: Text(
                      task.title,
                      style: Theme.of(context).textTheme.titleMedium,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 8),
                  // Priority badge
                  _buildPriorityBadge(task.priority, colorScheme),
                ],
              ),
              if (task.description != null) ...[
                const SizedBox(height: 8),
                Text(
                  task.description!,
                  style: Theme.of(
                    context,
                  ).textTheme.bodyMedium?.copyWith(color: colorScheme.onSurfaceVariant),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
              const SizedBox(height: 12),

              // Metadata row
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  // Deadline
                  Chip(
                    avatar: Icon(
                      Icons.calendar_today,
                      size: 16,
                      color: isOverdue ? colorScheme.error : null,
                    ),
                    label: Text(
                      DateFormat('MMM d, y').format(task.deadline),
                      style: TextStyle(fontSize: 12, color: isOverdue ? colorScheme.error : null),
                    ),
                    visualDensity: VisualDensity.compact,
                    backgroundColor: isOverdue ? colorScheme.errorContainer : null,
                  ),

                  // Points
                  if (task.points > 0)
                    Chip(
                      avatar: const Icon(Icons.stars, size: 16),
                      label: Text(
                        AppLocalizations.of(context)!.taskPoints(task.points),
                        style: const TextStyle(fontSize: 12),
                      ),
                      visualDensity: VisualDensity.compact,
                    ),

                  // Assignee
                  if (task.assignee != null)
                    Chip(
                      avatar: const Icon(Icons.person, size: 16),
                      label: Text(
                        isMyTask ? AppLocalizations.of(context)!.you : task.assignee!.username,
                        style: const TextStyle(fontSize: 12),
                      ),
                      visualDensity: VisualDensity.compact,
                      backgroundColor: isMyTask
                          ? colorScheme.primaryContainer
                          : colorScheme.secondaryContainer,
                    ),

                  // Status
                  _buildStatusBadge(task.status, colorScheme),
                ],
              ),

              // Action buttons for available tasks
              if (task.assigneeId == null && task.status == 'PENDING') ...[
                const SizedBox(height: 12),
                FilledButton.icon(
                  onPressed: () => _claimTask(task),
                  icon: const Icon(Icons.add_task),
                  label: Text(AppLocalizations.of(context)!.claimTask),
                ),
              ],

              // Complete button for my pending tasks
              if (isMyTask && task.status == 'PENDING') ...[
                const SizedBox(height: 12),
                FilledButton.icon(
                  onPressed: () => _completeTask(task),
                  icon: const Icon(Icons.check_circle),
                  label: Text(AppLocalizations.of(context)!.markComplete),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPriorityBadge(String priority, ColorScheme colorScheme) {
    Color color;
    IconData icon;

    switch (priority) {
      case 'HIGH':
        color = colorScheme.error;
        icon = Icons.arrow_upward;
        break;
      case 'MEDIUM':
        color = Colors.orange;
        icon = Icons.remove;
        break;
      case 'LOW':
      default:
        color = Colors.green;
        icon = Icons.arrow_downward;
        break;
    }

    return Chip(
      avatar: Icon(icon, size: 16, color: color),
      label: Text(
        priority,
        style: TextStyle(fontSize: 12, color: color, fontWeight: FontWeight.bold),
      ),
      visualDensity: VisualDensity.compact,
      side: BorderSide(color: color),
    );
  }

  Widget _buildStatusBadge(String status, ColorScheme colorScheme) {
    Color backgroundColor;
    String label;

    switch (status) {
      case 'COMPLETED':
        backgroundColor = colorScheme.primaryContainer;
        label = AppLocalizations.of(context)!.statusCompleted;
        break;
      case 'AWAITING_APPROVAL':
        backgroundColor = colorScheme.tertiaryContainer;
        label = AppLocalizations.of(context)!.statusAwaitingApproval;
        break;
      case 'OVERDUE':
        backgroundColor = colorScheme.errorContainer;
        label = AppLocalizations.of(context)!.statusOverdue;
        break;
      case 'PENDING':
      default:
        backgroundColor = colorScheme.secondaryContainer;
        label = AppLocalizations.of(context)!.statusPending;
        break;
    }

    return Chip(
      label: Text(label, style: const TextStyle(fontSize: 12)),
      backgroundColor: backgroundColor,
      visualDensity: VisualDensity.compact,
    );
  }

  Future<void> _claimTask(Task task) async {
    final claimUseCase = ref.read(claimTaskUseCaseProvider);
    final result = await claimUseCase(task.id);

    if (!mounted) return;

    result.fold(
      (failure) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${failure.message}'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      },
      (_) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppLocalizations.of(context)!.taskClaimedSuccessfully)),
        );
        _loadTasks();
      },
    );
  }

  Future<void> _completeTask(Task task) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(AppLocalizations.of(context)!.markComplete),
        content: Text(AppLocalizations.of(context)!.markTaskCompleteConfirm(task.title)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(AppLocalizations.of(context)!.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(AppLocalizations.of(context)!.complete),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;

    final completeUseCase = ref.read(completeTaskUseCaseProvider);
    final result = await completeUseCase(task.id);

    if (!mounted) return;

    result.fold(
      (failure) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${failure.message}'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      },
      (_) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppLocalizations.of(context)!.taskCompletedAwaitingApproval)),
        );
        _loadTasks();
      },
    );
  }

  void _showTaskDetails(Task task) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        expand: false,
        builder: (context, scrollController) {
          return SingleChildScrollView(
            controller: scrollController,
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(task.title, style: Theme.of(context).textTheme.headlineSmall),
                const SizedBox(height: 16),
                if (task.description != null) ...[
                  Text(
                    AppLocalizations.of(context)!.description,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  Text(task.description!),
                  const SizedBox(height: 16),
                ],
                Text(
                  AppLocalizations.of(context)!.details,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                _buildDetailRow(AppLocalizations.of(context)!.priorityLabel, task.priority),
                _buildDetailRow(AppLocalizations.of(context)!.statusLabel, task.status),
                _buildDetailRow(AppLocalizations.of(context)!.pointsLabelDetail, '${task.points}'),
                _buildDetailRow(
                  AppLocalizations.of(context)!.deadlineLabel,
                  DateFormat('MMM d, y').format(task.deadline),
                ),
                if (task.assignee != null)
                  _buildDetailRow(
                    AppLocalizations.of(context)!.assignedToLabel,
                    task.assignee!.username,
                  ),
                if (task.requiresApproval)
                  _buildDetailRow(
                    AppLocalizations.of(context)!.requiresApprovalLabel,
                    AppLocalizations.of(context)!.yes,
                  ),
                const SizedBox(height: 24),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant),
            ),
          ),
          Expanded(
            child: Text(value, style: const TextStyle(fontWeight: FontWeight.w500)),
          ),
        ],
      ),
    );
  }

  void _showPriorityFilter(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(AppLocalizations.of(context)!.filterByPriority),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            RadioListTile<String?>(
              title: Text(AppLocalizations.of(context)!.allPriorities),
              value: null,
              groupValue: _priorityFilter,
              onChanged: (value) {
                setState(() => _priorityFilter = value);
                Navigator.pop(context);
              },
            ),
            ..._priorities.map((priority) {
              return RadioListTile<String?>(
                title: Text(priority),
                value: priority,
                groupValue: _priorityFilter,
                onChanged: (value) {
                  setState(() => _priorityFilter = value);
                  Navigator.pop(context);
                },
              );
            }),
          ],
        ),
      ),
    );
  }

  void _showStatusFilter(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(AppLocalizations.of(context)!.filterByStatus),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            RadioListTile<String?>(
              title: Text(AppLocalizations.of(context)!.allStatuses),
              value: null,
              groupValue: _statusFilter,
              onChanged: (value) {
                setState(() => _statusFilter = value);
                Navigator.pop(context);
              },
            ),
            ..._statuses.map((status) {
              return RadioListTile<String?>(
                title: Text(status.replaceAll('_', ' ')),
                value: status,
                groupValue: _statusFilter,
                onChanged: (value) {
                  setState(() => _statusFilter = value);
                  Navigator.pop(context);
                },
              );
            }),
          ],
        ),
      ),
    );
  }
}
