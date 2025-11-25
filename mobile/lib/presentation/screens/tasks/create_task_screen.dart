import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:taskflow/data/models/create_task_request.dart';
import 'package:taskflow/data/models/task_enums.dart';
import 'package:taskflow/domain/usecases/task/task_usecase_providers.dart';
import 'package:taskflow/l10n/app_localizations.dart';
import 'package:taskflow/presentation/providers/task_state_provider.dart';

/// Create/Edit Task Screen with form and validation (PRD 3.4.4, 3.4.5)
class CreateTaskScreen extends ConsumerStatefulWidget {
  final String? taskId; // null for create, non-null for edit
  final String groupId;

  const CreateTaskScreen({super.key, this.taskId, required this.groupId});

  @override
  ConsumerState<CreateTaskScreen> createState() => _CreateTaskScreenState();
}

class _CreateTaskScreenState extends ConsumerState<CreateTaskScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _pointsController = TextEditingController(text: '50');

  DateTime? _selectedDeadline;
  TaskPriority _selectedPriority = TaskPriority.medium;
  RotationType _selectedRotationType = RotationType.roundRobin;
  bool _requiresApproval = true;
  bool _isSubmitting = false;

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _pointsController.dispose();
    super.dispose();
  }

  String _getRotationTypeLabel(BuildContext context, RotationType type) {
    final l10n = AppLocalizations.of(context)!;
    switch (type) {
      case RotationType.roundRobin:
        return l10n.rotationTypeRoundRobin;
      case RotationType.random:
        return l10n.rotationTypeRandom;
      case RotationType.loadBalancing:
        return l10n.rotationTypeLoadBalancing;
      case RotationType.disabled:
        return l10n.rotationTypeDisabled;
    }
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
        });
      }
    }
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedDeadline == null) {
      final l10n = AppLocalizations.of(context)!;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.pleaseSelectDeadline)));
      return;
    }

    // Validate groupId
    if (widget.groupId.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Group ID is required')));
      debugPrint('[CreateTask] ERROR: groupId is empty!');
      return;
    }

    setState(() => _isSubmitting = true);

    final request = CreateTaskRequest(
      title: _titleController.text.trim(),
      description: _descriptionController.text.trim().isEmpty
          ? null
          : _descriptionController.text.trim(),
      deadline: _selectedDeadline!,
      priority: _selectedPriority.value,
      points: int.parse(_pointsController.text),
      requiresApproval: _requiresApproval,
      groupId: widget.groupId,
      rotationType: _selectedRotationType.value,
      isRecurring: false,
    );

    debugPrint('[CreateTask] Request data:');
    debugPrint('  - groupId: ${widget.groupId}');
    debugPrint('  - title: ${request.title}');
    debugPrint('  - priority: ${request.priority}');
    debugPrint('  - points: ${request.points}');
    debugPrint('  - requiresApproval: ${request.requiresApproval}');
    debugPrint('  - rotationType: ${request.rotationType}');

    final useCase = ref.read(createTaskUseCaseProvider);
    final result = await useCase(request);

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
          ref.invalidate(groupTasksProvider(widget.groupId));

          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(l10n.taskCreatedSuccessfully)));
          context.pop();
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
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

            // Deadline
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
                  child: Text(priority.value),
                );
              }).toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() => _selectedPriority = value);
                }
              },
            ),

            const SizedBox(height: 16),

            // Rotation Type
            DropdownButtonFormField<RotationType>(
              initialValue: _selectedRotationType,
              decoration: InputDecoration(
                labelText: l10n.rotationTypeLabel,
                border: const OutlineInputBorder(),
              ),
              items: RotationType.values.map((rotationType) {
                return DropdownMenuItem(
                  value: rotationType,
                  child: Text(_getRotationTypeLabel(context, rotationType)),
                );
              }).toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() => _selectedRotationType = value);
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
