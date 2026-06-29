import 'package:dartz/dartz.dart' hide Task;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:taskflow/core/errors/failure.dart';
import 'package:taskflow/core/utils/enum_l10n.dart';
import 'package:taskflow/core/utils/recurrence_preview_calculator.dart';
import 'package:taskflow/core/utils/recurrence_rule_builder.dart';
import 'package:taskflow/data/models/create_task_request.dart';
import 'package:taskflow/data/models/group.dart';
import 'package:taskflow/data/models/group_member.dart';
import 'package:taskflow/data/models/task.dart';
import 'package:taskflow/data/models/task_enums.dart';
import 'package:taskflow/data/models/update_task_request.dart';
import 'package:taskflow/data/providers/auth_providers.dart';
import 'package:taskflow/data/providers/group_providers.dart';
import 'package:taskflow/domain/usecases/task/task_usecase_providers.dart';
import 'package:taskflow/l10n/app_localizations.dart';
import 'package:taskflow/presentation/providers/task_state_provider.dart';
import 'package:taskflow/presentation/widgets/common/app_navigation_back_button.dart';

/// Create/Edit Task Screen with form and validation (PRD 3.4.4, 3.4.5)
class CreateTaskScreen extends ConsumerStatefulWidget {
  final String? taskId; // null for create, non-null for edit
  final String groupId;
  final DateTime? initialDeadline;

  const CreateTaskScreen({
    super.key,
    this.taskId,
    required this.groupId,
    this.initialDeadline,
  });

  @override
  ConsumerState<CreateTaskScreen> createState() => _CreateTaskScreenState();
}

class _CreateTaskScreenState extends ConsumerState<CreateTaskScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _pointsController = TextEditingController(text: '50');
  final _customRecurrenceRuleController = TextEditingController();
  final _recurrenceIntervalController = TextEditingController(text: '1');
  final _recurringDeadlineIntervalController = TextEditingController(text: '1');
  final _recurrenceCountController = TextEditingController(text: '10');

  DateTime? _selectedDeadline;
  TaskPriority _selectedPriority = TaskPriority.medium;
  RotationType? _selectedRotationType;
  bool _requiresApproval = true;
  bool _isSubmitting = false;
  bool _isRecurring = false;

  RecurrenceFrequency _recurrenceFrequency = RecurrenceFrequency.daily;
  int _recurrenceInterval = 1;
  Set<int> _weeklyDays = <int>{DateTime.monday};
  int _monthlyDay = 1;
  RecurrenceEndType _recurrenceEndType = RecurrenceEndType.never;
  int _recurrenceCount = 10;
  DateTime? _recurrenceUntil;
  int _recurringDeadlineInterval = 1;
  RecurringDeadlineUnit _recurringDeadlineUnit = RecurringDeadlineUnit.day;

  // Admin-only fields
  String _assigneeType = 'auto'; // 'auto', 'upForGrabs', or userId
  int _difficulty = 1;
  String? _cachedGroupRotationType;
  bool _isLoadingEditTask = false;
  String? _editTaskLoadError;
  String? _resolvedGroupId;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    final baseDate = widget.initialDeadline ?? now;
    _selectedDeadline = widget.initialDeadline;
    _monthlyDay = baseDate.day;
    _weeklyDays = <int>{baseDate.weekday};
    _recurrenceUntil = baseDate.add(const Duration(days: 30));
    _recurrenceIntervalController.text = _recurrenceInterval.toString();
    _recurringDeadlineIntervalController.text = _recurringDeadlineInterval.toString();
    _recurrenceCountController.text = _recurrenceCount.toString();

    if (widget.taskId != null) {
      _loadTaskForEdit(widget.taskId!);
    }
  }

  Future<void> _loadTaskForEdit(String taskId) async {
    setState(() {
      _isLoadingEditTask = true;
      _editTaskLoadError = null;
    });

    try {
      final task = await ref.read(taskDetailsProvider(taskId).future);
      if (!mounted) return;
      _applyTaskToForm(task);
      setState(() {
        _resolvedGroupId = task.groupId;
        _isLoadingEditTask = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoadingEditTask = false;
        _editTaskLoadError = e.toString();
      });
    }
  }

  void _applyTaskToForm(Task task) {
    _titleController.text = task.title;
    _descriptionController.text = task.description ?? '';
    _pointsController.text = task.points.toString();
    _selectedDeadline = task.deadline;
    _selectedPriority = TaskPriority.fromString(task.priority);
    _requiresApproval = task.requiresApproval;
    _isRecurring = task.isRecurring;
    _difficulty = task.weight;

    final recurrenceRule = task.recurrenceRule;
    if (recurrenceRule != null && recurrenceRule.isNotEmpty) {
      _customRecurrenceRuleController.text = recurrenceRule;
    }

    if (task.assigneeId != null && task.assigneeId!.isNotEmpty) {
      _assigneeType = task.assigneeId!;
      _selectedRotationType = null;
    } else if (task.rotationType == RotationType.disabled.value) {
      _assigneeType = 'upForGrabs';
      _selectedRotationType = RotationType.disabled;
    } else {
      _assigneeType = 'auto';
      final rotationType = task.rotationType;
      if (rotationType != null && rotationType.isNotEmpty) {
        _selectedRotationType = RotationType.fromString(rotationType);
      }
    }
  }

  String get _effectiveGroupId =>
      widget.groupId.isNotEmpty ? widget.groupId : (_resolvedGroupId ?? '');

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _pointsController.dispose();
    _customRecurrenceRuleController.dispose();
    _recurrenceIntervalController.dispose();
    _recurringDeadlineIntervalController.dispose();
    _recurrenceCountController.dispose();
    super.dispose();
  }

  String _getRotationTypeLabel(BuildContext context, RotationType type) {
    return rotationTypeLabel(AppLocalizations.of(context)!, type);
  }

  /// Режим ротации, который реально применится к задаче.
  RotationType? _effectiveRotationType([String? groupRotationType]) {
    if (_assigneeType != 'auto') return null;

    final groupDefault = groupRotationType ?? _cachedGroupRotationType;
    if (_selectedRotationType != null) {
      return _selectedRotationType;
    }
    if (groupDefault != null && groupDefault.isNotEmpty) {
      return RotationType.fromString(groupDefault);
    }
    return RotationType.roundRobin;
  }

  bool _usesLoadBalancing([String? groupRotationType]) {
    return _effectiveRotationType(groupRotationType) ==
        RotationType.loadBalancing;
  }

  Future<void> _selectDeadline() async {
    final date = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 1)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );

    if (date != null && mounted) {
      final time = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.now(),
      );

      if (time != null) {
        setState(() {
          _selectedDeadline = DateTime(
            date.year,
            date.month,
            date.day,
            time.hour,
            time.minute,
          );
          _monthlyDay = date.day;
          _weeklyDays = <int>{date.weekday};
          _recurrenceUntil = date.add(const Duration(days: 30));
        });
      }
    }
  }

  Future<void> _selectRecurrenceUntilDate() async {
    final initialDate = _recurrenceUntil ?? DateTime.now().add(const Duration(days: 30));
    final date = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 3650)),
    );

    if (date != null) {
      final base = _selectedDeadline ?? DateTime.now();
      setState(() {
        _recurrenceUntil = DateTime(
          date.year,
          date.month,
          date.day,
          base.hour,
          base.minute,
        );
      });
    }
  }

  String _getRecurrenceFrequencyLabel(
    AppLocalizations l10n,
    RecurrenceFrequency frequency,
  ) {
    switch (frequency) {
      case RecurrenceFrequency.daily:
        return l10n.recurrenceFrequencyDaily;
      case RecurrenceFrequency.weekly:
        return l10n.recurrenceFrequencyWeekly;
      case RecurrenceFrequency.monthly:
        return l10n.recurrenceFrequencyMonthly;
    }
  }

  String _getRecurrenceEndTypeLabel(
    AppLocalizations l10n,
    RecurrenceEndType endType,
  ) {
    switch (endType) {
      case RecurrenceEndType.never:
        return l10n.recurrenceEndNever;
      case RecurrenceEndType.count:
        return l10n.recurrenceEndAfterCount;
      case RecurrenceEndType.until:
        return l10n.recurrenceEndUntilDate;
    }
  }

  String _getWeekdayShortLabel(AppLocalizations l10n, int weekday) {
    switch (weekday) {
      case DateTime.monday:
        return l10n.weekdayShortMon;
      case DateTime.tuesday:
        return l10n.weekdayShortTue;
      case DateTime.wednesday:
        return l10n.weekdayShortWed;
      case DateTime.thursday:
        return l10n.weekdayShortThu;
      case DateTime.friday:
        return l10n.weekdayShortFri;
      case DateTime.saturday:
        return l10n.weekdayShortSat;
      case DateTime.sunday:
        return l10n.weekdayShortSun;
      default:
        return '-';
    }
  }

  String _getRecurringDeadlineUnitLabel(
    AppLocalizations l10n,
    RecurringDeadlineUnit unit,
  ) {
    switch (unit) {
      case RecurringDeadlineUnit.day:
        return l10n.recurringDeadlineUnitDay;
      case RecurringDeadlineUnit.week:
        return l10n.recurringDeadlineUnitWeek;
      case RecurringDeadlineUnit.month:
        return l10n.recurringDeadlineUnitMonth;
    }
  }

  DateTime _addMonths(DateTime date, int months) {
    final monthIndex = date.month - 1 + months;
    final year = date.year + monthIndex ~/ 12;
    final month = monthIndex % 12 + 1;
    final maxDay = DateTime(year, month + 1, 0).day;
    final day = date.day > maxDay ? maxDay : date.day;
    return DateTime(
      year,
      month,
      day,
      date.hour,
      date.minute,
      date.second,
      date.millisecond,
      date.microsecond,
    );
  }

  DateTime _calculateRecurringTemplateDeadline() {
    final now = DateTime.now();
    switch (_recurringDeadlineUnit) {
      case RecurringDeadlineUnit.day:
        return now.add(Duration(days: _recurringDeadlineInterval));
      case RecurringDeadlineUnit.week:
        return now.add(Duration(days: _recurringDeadlineInterval * 7));
      case RecurringDeadlineUnit.month:
        return _addMonths(now, _recurringDeadlineInterval);
    }
  }

  RecurrenceRuleBuilder _buildRecurrenceBuilder() {
    return RecurrenceRuleBuilder(
      frequency: _recurrenceFrequency,
      interval: _recurrenceInterval,
      weeklyDays: _weeklyDays,
      monthlyDay: _monthlyDay,
      endType: _recurrenceEndType,
      count: _recurrenceEndType == RecurrenceEndType.count
          ? _recurrenceCount
          : null,
      until: _recurrenceEndType == RecurrenceEndType.until
          ? _recurrenceUntil
          : null,
    );
  }

  String? _buildRecurrenceRule() {
    final builder = _buildRecurrenceBuilder();
    final validationError = builder.validate();
    if (validationError != null) {
      return null;
    }

    return builder.toRRule();
  }

  String _formatShortDate(DateTime date) {
    final d = date.day.toString().padLeft(2, '0');
    final m = date.month.toString().padLeft(2, '0');
    return '$d.$m.${date.year}';
  }

  String _formatPreviewDateTime(DateTime date) {
    final datePart = _formatShortDate(date);
    if (date.hour == 0 && date.minute == 0) {
      return datePart;
    }
    final h = date.hour.toString().padLeft(2, '0');
    final m = date.minute.toString().padLeft(2, '0');
    return '$datePart $h:$m';
  }

  String? _effectiveRecurrenceRuleForPreview() {
    if (kDebugMode) {
      final custom = _normalizeCustomRecurrenceRule(
        _customRecurrenceRuleController.text,
      );
      if (custom != null) {
        return custom;
      }
    }
    return _buildRecurrenceRule();
  }

  RecurrencePreviewResult? _buildRecurrencePreview() {
    final rule = _effectiveRecurrenceRuleForPreview();
    if (rule == null) {
      return null;
    }

    return RecurrencePreviewCalculator.preview(
      rruleString: rule,
      templateDeadline: _calculateRecurringTemplateDeadline(),
      endType: _recurrenceEndType,
      count: _recurrenceEndType == RecurrenceEndType.count
          ? _recurrenceCount
          : null,
      until: _recurrenceEndType == RecurrenceEndType.until
          ? _recurrenceUntil
          : null,
    );
  }

  Widget _buildRecurrencePreviewCard(AppLocalizations l10n) {
    final preview = _buildRecurrencePreview();
    final theme = Theme.of(context);

    if (preview == null) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: theme.colorScheme.errorContainer,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          l10n.recurrenceRuleInvalid,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onErrorContainer,
          ),
        ),
      );
    }

    final onColor = theme.colorScheme.onPrimaryContainer;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.event_repeat,
                size: 16,
                color: onColor,
              ),
              const SizedBox(width: 6),
              Text(
                l10n.recurrenceSummaryTitle,
                style: theme.textTheme.labelMedium?.copyWith(
                  color: onColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ...preview.occurrences.map((occurrence) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.recurrencePreviewTask(occurrence.index),
                    style: theme.textTheme.titleSmall?.copyWith(
                      color: onColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    occurrence.appearsImmediately
                        ? l10n.recurrencePreviewAppearsImmediately
                        : l10n.recurrencePreviewAppears(
                            _formatPreviewDateTime(occurrence.appearsAt),
                          ),
                    style: theme.textTheme.bodySmall?.copyWith(color: onColor),
                  ),
                  Text(
                    l10n.recurrencePreviewDeadline(
                      _formatPreviewDateTime(occurrence.deadline),
                    ),
                    style: theme.textTheme.bodySmall?.copyWith(color: onColor),
                  ),
                ],
              ),
            );
          }),
          if (preview.remainingCount != null)
            Text(
              l10n.recurrencePreviewMoreTasks(preview.remainingCount!),
              style: theme.textTheme.bodySmall?.copyWith(
                color: onColor,
                fontStyle: FontStyle.italic,
              ),
            )
          else if (preview.repeatsForever)
            Text(
              l10n.recurrencePreviewRepeatsForever,
              style: theme.textTheme.bodySmall?.copyWith(
                color: onColor,
                fontStyle: FontStyle.italic,
              ),
            ),
        ],
      ),
    );
  }

  String? _normalizeCustomRecurrenceRule(String rawRule) {
    final trimmed = rawRule.trim();
    if (trimmed.isEmpty) {
      return null;
    }

    if (trimmed.startsWith('RRULE:')) {
      return trimmed.substring('RRULE:'.length).trim();
    }

    return trimmed;
  }

  Future<void> _submitForm() async {
    final l10n = AppLocalizations.of(context)!;

    if (!_formKey.currentState!.validate()) return;
    if (!_isRecurring && _selectedDeadline == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.pleaseSelectDeadline)));
      return;
    }

    // Validate groupId
    if (_effectiveGroupId.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Group ID is required')));
      debugPrint('[CreateTask] ERROR: groupId is empty!');
      return;
    }

    String? recurrenceRule;
    if (_isRecurring) {
      final customRule = kDebugMode
          ? _normalizeCustomRecurrenceRule(
              _customRecurrenceRuleController.text,
            )
          : null;

      if (customRule != null) {
        if (!customRule.contains('FREQ=')) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(l10n.recurrenceTestRuleInvalid),
            ),
          );
          return;
        }
        recurrenceRule = customRule;
      } else {
        recurrenceRule = _buildRecurrenceRule();
      }

      if (recurrenceRule == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.recurrenceRuleInvalid),
          ),
        );
        return;
      }
    }

    setState(() => _isSubmitting = true);

    // Build request based on user role
    String? assigneeId;
    String? rotationType;
    int? weight;

    if (_assigneeType == 'upForGrabs') {
      // Up-for-Grabs task (no assignee, rotation disabled)
      assigneeId = null;
      rotationType = 'DISABLED';
    } else if (_assigneeType != 'auto') {
      // Specific user assigned
      assigneeId = _assigneeType;
      rotationType = null; // Use group default when specific user assigned
    } else {
      // Auto assignment (use rotation)
      assigneeId = null;
      rotationType = _selectedRotationType?.value;

      if (_usesLoadBalancing()) {
        weight = _difficulty;
      }
    }

    final deadline = _isRecurring
        ? _calculateRecurringTemplateDeadline()
        : (_selectedDeadline ?? DateTime.now());

    final request = CreateTaskRequest(
      title: _titleController.text.trim(),
      description: _descriptionController.text.trim().isEmpty
          ? null
          : _descriptionController.text.trim(),
      deadline: deadline,
      priority: _selectedPriority.value,
      points: int.parse(_pointsController.text),
      requiresApproval: _requiresApproval,
      groupId: _effectiveGroupId,
      assigneeId: assigneeId,
      rotationType: rotationType,
      weight: weight,
      isRecurring: _isRecurring,
      recurrenceRule: recurrenceRule,
    );

    final isEditMode = widget.taskId != null;
    final result = isEditMode
        ? await ref.read(updateTaskUseCaseProvider)(
            widget.taskId!,
            UpdateTaskRequest(
              title: request.title,
              description: request.description,
              deadline: request.deadline,
              priority: request.priority,
              points: request.points,
              assigneeId: request.assigneeId,
            ),
          )
        : await ref.read(createTaskUseCaseProvider)(request);

    setState(() => _isSubmitting = false);

    result.fold(
      (failure) {
        if (mounted) {
          final l10n = AppLocalizations.of(context)!;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(l10n.errorWithMessage(failure.message))),
          );
        }
      },
      (task) {
        if (mounted) {
          final l10n = AppLocalizations.of(context)!;

          // Invalidate task lists to trigger automatic refresh
          ref.invalidate(userTasksProvider);
          ref.invalidate(groupTasksProvider(_effectiveGroupId));
          ref.invalidate(recurringTemplatesProvider(_effectiveGroupId));
          if (widget.taskId != null) {
            ref.invalidate(taskDetailsProvider(widget.taskId!));
          }

          ScaffoldMessenger.of(
            context,
          ).showSnackBar(
            SnackBar(
              content: Text(
                isEditMode ? l10n.updateTask : l10n.taskCreatedSuccessfully,
              ),
            ),
          );
          context.pop();
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final authState = ref.watch(authStateProvider);
    final groupId = _effectiveGroupId;

    // Fetch group members and group settings (rotation type)
    final getMembersUseCase = ref.watch(getGroupMembersUseCaseProvider);
    final getGroupUseCase = ref.watch(getGroupDetailUseCaseProvider);

    if (groupId.isEmpty) {
      return _buildForm(context, l10n, false, const <GroupMember>[], null);
    }

    return FutureBuilder(
      future: Future.wait([
        getMembersUseCase(groupId),
        getGroupUseCase(groupId),
      ]),
      builder: (context, snapshot) {
        // Determine if user is admin and get members list
        bool isAdmin = false;
        List<GroupMember> members = [];
        String? groupRotationType;

        if (snapshot.hasData) {
          final membersResult =
              snapshot.data![0] as Either<Failure, List<GroupMember>>;
          final groupResult = snapshot.data![1] as Either<Failure, Group>;

          membersResult.fold(
            (failure) {},
            (membersList) {
              members = membersList;
              final currentMember = membersList.firstWhere(
                (m) => m.userId == authState.user?.id,
                orElse: () => membersList.first,
              );
              isAdmin = currentMember.role == 'ADMIN';
            },
          );

          groupResult.fold(
            (failure) {},
            (group) => groupRotationType = group.rotationType,
          );
        }

        return _buildForm(
          context,
          l10n,
          isAdmin,
          members,
          groupRotationType,
        );
      },
    );
  }

  Widget _buildForm(
    BuildContext context,
    AppLocalizations l10n,
    bool isAdmin,
    List<GroupMember> members,
    String? groupRotationType,
  ) {
    _cachedGroupRotationType = groupRotationType;

    if (_isLoadingEditTask) {
      return Scaffold(
        appBar: AppBar(
          leading: AppNavigationBackButton(
            fallbackRoute: widget.groupId.isNotEmpty ? '/groups/${widget.groupId}' : '/home',
          ),
          title: Text(l10n.editTask),
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_editTaskLoadError != null) {
      return Scaffold(
        appBar: AppBar(
          leading: AppNavigationBackButton(
            fallbackRoute: widget.groupId.isNotEmpty ? '/groups/${widget.groupId}' : '/home',
          ),
          title: Text(l10n.editTask),
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  l10n.errorWithMessage(_editTaskLoadError!),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                ElevatedButton(
                  onPressed: widget.taskId == null
                      ? null
                      : () => _loadTaskForEdit(widget.taskId!),
                  child: Text(l10n.retry),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        leading: AppNavigationBackButton(
          fallbackRoute: widget.groupId.isNotEmpty ? '/groups/${widget.groupId}' : '/home',
        ),
        title: Text(widget.taskId == null ? l10n.createTask : l10n.editTask),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Title
            TextFormField(
              controller: _titleController,
              decoration: InputDecoration(
                labelText: l10n.taskTitle,
                hintText: l10n.enterTaskTitle,
                border: const OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return l10n.enterTitleValidation;
                }
                return null;
              },
              maxLength: 100,
            ),

            const SizedBox(height: 16),

            // Description
            TextFormField(
              controller: _descriptionController,
              decoration: InputDecoration(
                labelText: l10n.descriptionOptional,
                hintText: l10n.enterTaskDescription,
                border: const OutlineInputBorder(),
              ),
              maxLines: 4,
              maxLength: 500,
            ),

            const SizedBox(height: 16),

            if (_isRecurring)
              Padding(
                padding: const EdgeInsets.only(top: 2),
                child: Text(
                  l10n.recurringDeadlineAutoHint,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.grey.shade700,
                      ),
                ),
              ),

            if (!_isRecurring)
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(l10n.deadlineLabel),
                subtitle: Text(
                  _selectedDeadline == null
                      ? l10n.tapToSelectDeadline
                      : _selectedDeadline.toString().substring(0, 16),
                ),
                leading: const Icon(Icons.calendar_today),
                trailing: const Icon(Icons.chevron_right),
                onTap: _selectDeadline,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                  side: BorderSide(color: Colors.grey.shade300),
                ),
              ),

            const SizedBox(height: 16),

            // Priority
            DropdownButtonFormField<TaskPriority>(
              initialValue: _selectedPriority,
              decoration: InputDecoration(
                labelText: l10n.priority,
                border: const OutlineInputBorder(),
              ),
              items: TaskPriority.values.map((priority) {
                return DropdownMenuItem(
                  value: priority,
                  child: Text(priorityLabel(l10n, priority)),
                );
              }).toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() => _selectedPriority = value);
                }
              },
            ),

            const SizedBox(height: 16),

            // Points
            TextFormField(
              controller: _pointsController,
              decoration: InputDecoration(
                labelText: l10n.pointsLabelDetail,
                hintText: l10n.enterPointValue,
                border: const OutlineInputBorder(),
                prefixIcon: const Icon(Icons.stars),
              ),
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return l10n.enterPointValueValidation;
                }
                final points = int.tryParse(value);
                if (points == null || points < 1 || points > 1000) {
                  return l10n.pointsRangeValidation;
                }
                return null;
              },
            ),

            const SizedBox(height: 16),

            SwitchListTile(
              title: Text(l10n.recurrenceTemplateLabel),
              subtitle: Text(
                l10n.recurrenceTemplateSubtitle,
              ),
              value: _isRecurring,
              onChanged: (value) {
                setState(() => _isRecurring = value);
              },
            ),

            if (_isRecurring) ...[
              const SizedBox(height: 8),
              Card(
                margin: EdgeInsets.zero,
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.recurringDeadlineSelectorLabel,
                        style: Theme.of(context).textTheme.titleSmall,
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _recurringDeadlineIntervalController,
                              decoration: InputDecoration(
                                labelText: l10n.recurringDeadlineIntervalLabel,
                                border: const OutlineInputBorder(),
                              ),
                              keyboardType: TextInputType.number,
                              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                              validator: (value) {
                                if (!_isRecurring) return null;
                                final parsed = int.tryParse(value ?? '');
                                if (parsed == null || parsed < 1 || parsed > 30) {
                                  return '1..30';
                                }
                                return null;
                              },
                              onChanged: (value) {
                                final parsed = int.tryParse(value);
                                if (parsed != null && parsed >= 1 && parsed <= 30) {
                                  setState(() => _recurringDeadlineInterval = parsed);
                                }
                              },
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: DropdownButtonFormField<RecurringDeadlineUnit>(
                              initialValue: _recurringDeadlineUnit,
                              decoration: InputDecoration(
                                labelText: l10n.recurringDeadlineUnitLabel,
                                border: const OutlineInputBorder(),
                              ),
                              items: RecurringDeadlineUnit.values
                                  .map(
                                    (unit) => DropdownMenuItem(
                                      value: unit,
                                      child: Text(_getRecurringDeadlineUnitLabel(l10n, unit)),
                                    ),
                                  )
                                  .toList(),
                              onChanged: (value) {
                                if (value != null) {
                                  setState(() => _recurringDeadlineUnit = value);
                                }
                              },
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        l10n.recurringDeadlineSelectorHint,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Colors.grey.shade700,
                            ),
                      ),
                      const Divider(height: 24),
                      Text(
                        l10n.recurrenceSectionWhen,
                        style: Theme.of(context).textTheme.titleSmall,
                      ),
                      const SizedBox(height: 12),
                      DropdownButtonFormField<RecurrenceFrequency>(
                        initialValue: _recurrenceFrequency,
                        decoration: InputDecoration(
                          labelText: l10n.recurrenceFrequencyLabel,
                          border: const OutlineInputBorder(),
                        ),
                        items: RecurrenceFrequency.values.map((frequency) {
                          return DropdownMenuItem(
                            value: frequency,
                            child: Text(_getRecurrenceFrequencyLabel(l10n, frequency)),
                          );
                        }).toList(),
                        onChanged: (value) {
                          if (value != null) {
                            setState(() => _recurrenceFrequency = value);
                          }
                        },
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _recurrenceIntervalController,
                        decoration: InputDecoration(
                          labelText: l10n.recurrenceIntervalLabel,
                          border: const OutlineInputBorder(),
                        ),
                        keyboardType: TextInputType.number,
                        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                        validator: (value) {
                          if (!_isRecurring) return null;
                          final parsed = int.tryParse(value ?? '');
                          if (parsed == null || parsed < 1 || parsed > 30) {
                            return '1..30';
                          }
                          return null;
                        },
                        onChanged: (value) {
                          final parsed = int.tryParse(value);
                          if (parsed != null && parsed >= 1 && parsed <= 30) {
                            setState(() => _recurrenceInterval = parsed);
                          }
                        },
                      ),
                      if (_recurrenceFrequency == RecurrenceFrequency.weekly) ...[
                        const SizedBox(height: 12),
                        Text(l10n.recurrenceWeekdaysLabel),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: List.generate(7, (index) => index + 1)
                              .map(
                                (weekday) => FilterChip(
                                  label: Text(_getWeekdayShortLabel(l10n, weekday)),
                                  selected: _weeklyDays.contains(weekday),
                                  onSelected: (selected) {
                                    setState(() {
                                      final updated = <int>{..._weeklyDays};
                                      if (selected) {
                                        updated.add(weekday);
                                      } else {
                                        updated.remove(weekday);
                                      }
                                      _weeklyDays = updated;
                                    });
                                  },
                                ),
                              )
                              .toList(),
                        ),
                        if (_weeklyDays.isEmpty)
                          Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: Text(
                              l10n.recurrenceSelectWeekday,
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.error,
                              ),
                            ),
                          ),
                      ],
                      if (_recurrenceFrequency == RecurrenceFrequency.monthly) ...[
                        const SizedBox(height: 12),
                        Text(l10n.recurrenceDayOfMonth(_monthlyDay)),
                        Slider(
                          value: _monthlyDay.toDouble(),
                          min: 1,
                          max: 31,
                          divisions: 30,
                          label: '$_monthlyDay',
                          onChanged: (value) {
                            setState(() => _monthlyDay = value.toInt());
                          },
                        ),
                      ],
                      const SizedBox(height: 12),
                      DropdownButtonFormField<RecurrenceEndType>(
                        initialValue: _recurrenceEndType,
                        decoration: InputDecoration(
                          labelText: l10n.recurrenceEndsLabel,
                          border: const OutlineInputBorder(),
                        ),
                        items: RecurrenceEndType.values.map((endType) {
                          return DropdownMenuItem(
                            value: endType,
                            child: Text(_getRecurrenceEndTypeLabel(l10n, endType)),
                          );
                        }).toList(),
                        onChanged: (value) {
                          if (value != null) {
                            setState(() => _recurrenceEndType = value);
                          }
                        },
                      ),
                      if (_recurrenceEndType == RecurrenceEndType.count) ...[
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: _recurrenceCountController,
                          decoration: InputDecoration(
                            labelText: l10n.recurrenceOccurrencesLabel,
                            border: const OutlineInputBorder(),
                          ),
                          keyboardType: TextInputType.number,
                          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                          validator: (value) {
                            if (!_isRecurring || _recurrenceEndType != RecurrenceEndType.count) {
                              return null;
                            }
                            final parsed = int.tryParse(value ?? '');
                            if (parsed == null || parsed < 1 || parsed > 100) {
                              return '1..100';
                            }
                            return null;
                          },
                          onChanged: (value) {
                            final parsed = int.tryParse(value);
                            if (parsed != null && parsed >= 1 && parsed <= 100) {
                              setState(() => _recurrenceCount = parsed);
                            }
                          },
                        ),
                      ],
                      if (_recurrenceEndType == RecurrenceEndType.until) ...[
                        const SizedBox(height: 12),
                        ListTile(
                          contentPadding: EdgeInsets.zero,
                          title: Text(l10n.recurrenceUntilDateLabel),
                          subtitle: Text(
                            _recurrenceUntil == null
                                ? l10n.recurrenceSelectUntilDate
                                : _recurrenceUntil.toString().substring(0, 16),
                          ),
                          leading: const Icon(Icons.event_repeat),
                          trailing: const Icon(Icons.chevron_right),
                          onTap: _selectRecurrenceUntilDate,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                            side: BorderSide(color: Colors.grey.shade300),
                          ),
                        ),
                      ],
                      const SizedBox(height: 12),
                      _buildRecurrencePreviewCard(l10n),
                      if (kDebugMode) ...[
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: _customRecurrenceRuleController,
                          decoration: InputDecoration(
                            labelText: l10n.recurrenceTestRuleLabel,
                            hintText: l10n.recurrenceTestRuleHint,
                            border: const OutlineInputBorder(),
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          l10n.recurrenceTestRuleDescription,
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: Colors.grey.shade700,
                              ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],

            // ADMIN-ONLY FIELDS
            if (isAdmin) ...[
              // Assignment Type
              DropdownButtonFormField<String>(
                initialValue: _assigneeType,
                decoration: InputDecoration(
                  labelText: l10n.assignTo,
                  border: const OutlineInputBorder(),
                ),
                items: [
                  DropdownMenuItem(
                    value: 'auto',
                    child: Text(l10n.autoByRotation),
                  ),
                  DropdownMenuItem(
                    value: 'upForGrabs',
                    child: Text(l10n.upForGrabsBonus),
                  ),
                  ...members.map((member) {
                    return DropdownMenuItem(
                      value: member.userId,
                      child: Text(member.user.username),
                    );
                  }),
                ],
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      _assigneeType = value;
                      // Reset rotation type if not auto
                      if (value != 'auto') {
                        _selectedRotationType = null;
                      }
                    });
                  }
                },
              ),

              const SizedBox(height: 16),

              // Rotation Type (only if auto assignment)
              if (_assigneeType == 'auto') ...[
                DropdownButtonFormField<RotationType>(
                  initialValue: _selectedRotationType,
                  decoration: InputDecoration(
                    labelText: l10n.rotationTypeLabel,
                    border: const OutlineInputBorder(),
                  ),
                  items: [
                    DropdownMenuItem<RotationType>(
                      value: null,
                      child: Text(l10n.useGroupDefault),
                    ),
                    ...RotationType.values.map((rotationType) {
                      return DropdownMenuItem(
                        value: rotationType,
                        child: Text(_getRotationTypeLabel(context, rotationType)),
                      );
                    }),
                  ],
                  onChanged: (value) {
                    setState(() => _selectedRotationType = value);
                  },
                ),

                const SizedBox(height: 16),
              ],

              // Сложность — только при балансировке нагрузки
              // (явно на задаче или по умолчанию в группе).
              if (_assigneeType == 'auto' &&
                  _usesLoadBalancing(groupRotationType)) ...[
                Text(
                  l10n.taskDifficultyLabel,
                  style: Theme.of(context).textTheme.titleSmall,
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Text(
                      '1',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    Expanded(
                      child: Slider(
                        value: _difficulty.toDouble(),
                        min: 1,
                        max: 10,
                        divisions: 9,
                        label: '$_difficulty',
                        onChanged: (value) {
                          setState(() => _difficulty = value.toInt());
                        },
                      ),
                    ),
                    Text(
                      '10',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
                Align(
                  alignment: Alignment.center,
                  child: Text(
                    '$_difficulty',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 4, bottom: 4),
                  child: Text(
                    l10n.taskDifficultyHint,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.grey.shade700,
                        ),
                  ),
                ),
                const SizedBox(height: 16),
              ],
            ],

            // Requires Approval
            SwitchListTile(
              title: Text(l10n.requiresApprovalTitle),
              subtitle: Text(l10n.requiresApprovalSubtitle),
              value: _requiresApproval,
              onChanged: (value) {
                setState(() => _requiresApproval = value);
              },
            ),

            const SizedBox(height: 32),

            // Submit Button
            SizedBox(
              height: 50,
              child: ElevatedButton(
                onPressed: _isSubmitting ? null : _submitForm,
                child: _isSubmitting
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Text(
                        widget.taskId == null
                            ? l10n.createTask
                            : l10n.updateTask,
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

enum RecurringDeadlineUnit {
  day,
  week,
  month,
}
