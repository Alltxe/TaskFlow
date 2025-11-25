import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:taskflow/data/models/create_group_request.dart';
import 'package:taskflow/data/providers/group_providers.dart';
import 'package:taskflow/l10n/app_localizations.dart';
import 'package:taskflow/presentation/providers/group_notifier.dart';

class CreateGroupScreen extends ConsumerStatefulWidget {
  const CreateGroupScreen({super.key});

  @override
  ConsumerState<CreateGroupScreen> createState() => _CreateGroupScreenState();
}

class _CreateGroupScreenState extends ConsumerState<CreateGroupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();

  String _rotationType = 'ROUND_ROBIN';
  bool _gamificationEnabled = true;
  bool _requiresApproval = true;
  bool _isLoading = false;

  final List<Map<String, String>> _rotationTypes = [
    {'value': 'ROUND_ROBIN', 'label': 'Round Robin'},
    {'value': 'RANDOM', 'label': 'Random'},
    {'value': 'LOAD_BALANCING', 'label': 'Load Balancing'},
    {'value': 'DISABLED', 'label': 'Disabled'},
  ];

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _createGroup() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final request = CreateGroupRequest(
      name: _nameController.text.trim(),
      description: _descriptionController.text.trim().isEmpty
          ? null
          : _descriptionController.text.trim(),
      rotationType: _rotationType,
      gamificationEnabled: _gamificationEnabled,
      requiresApproval: _requiresApproval,
    );

    final createGroupUseCase = ref.read(createGroupUseCaseProvider);
    final result = await createGroupUseCase(request);

    if (!mounted) return;

    setState(() => _isLoading = false);

    result.fold(
      (failure) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${failure.message}'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      },
      (group) {
        // Refresh the groups list
        ref.read(groupNotifierProvider.notifier).refresh();

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppLocalizations.of(context)!.groupCreatedSuccessfully)),
        );

        // Navigate to group detail
        context.go('/groups/${group.id}');
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(title: Text(AppLocalizations.of(context)!.createGroup)),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Name field
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Group Name',
                hintText: 'Enter group name',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.group),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Group name is required';
                }
                if (value.trim().length < 3) {
                  return 'Group name must be at least 3 characters';
                }
                return null;
              },
              textCapitalization: TextCapitalization.words,
              enabled: !_isLoading,
            ),
            const SizedBox(height: 16),

            // Description field
            TextFormField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                labelText: 'Description (Optional)',
                hintText: 'Enter group description',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.description),
              ),
              maxLines: 3,
              textCapitalization: TextCapitalization.sentences,
              enabled: !_isLoading,
            ),
            const SizedBox(height: 24),

            // Configuration section
            Text(AppLocalizations.of(context)!.configuration, style: theme.textTheme.titleMedium),
            const SizedBox(height: 12),

            // Rotation type dropdown
            DropdownButtonFormField<String>(
              initialValue: _rotationType,
              decoration: const InputDecoration(
                labelText: 'Rotation Type',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.sync),
              ),
              items: _rotationTypes.map((type) {
                return DropdownMenuItem<String>(value: type['value'], child: Text(type['label']!));
              }).toList(),
              onChanged: _isLoading
                  ? null
                  : (value) {
                      if (value != null) {
                        setState(() => _rotationType = value);
                      }
                    },
            ),
            const SizedBox(height: 16),

            // Gamification toggle
            Card(
              child: SwitchListTile(
                value: _gamificationEnabled,
                onChanged: _isLoading
                    ? null
                    : (value) {
                        setState(() => _gamificationEnabled = value);
                      },
                title: Text(AppLocalizations.of(context)!.gamificationLabel),
                subtitle: Text(AppLocalizations.of(context)!.enablePointsAndRewardsSystem),
                secondary: Icon(
                  Icons.emoji_events,
                  color: _gamificationEnabled ? colorScheme.primary : colorScheme.onSurfaceVariant,
                ),
              ),
            ),
            const SizedBox(height: 8),

            // Requires approval toggle
            Card(
              child: SwitchListTile(
                value: _requiresApproval,
                onChanged: _isLoading
                    ? null
                    : (value) {
                        setState(() => _requiresApproval = value);
                      },
                title: Text(AppLocalizations.of(context)!.requireApprovalTitle),
                subtitle: Text(AppLocalizations.of(context)!.adminMustApproveCompletedTasks),
                secondary: Icon(
                  Icons.check_circle,
                  color: _requiresApproval ? colorScheme.primary : colorScheme.onSurfaceVariant,
                ),
              ),
            ),
            const SizedBox(height: 32),

            // Create button
            FilledButton(
              onPressed: _isLoading ? null : _createGroup,
              child: _isLoading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Text(AppLocalizations.of(context)!.createGroup),
            ),
          ],
        ),
      ),
    );
  }
}
