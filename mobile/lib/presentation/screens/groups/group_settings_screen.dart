import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:taskflow/core/utils/enum_l10n.dart';
import 'package:taskflow/data/models/group.dart';
import 'package:taskflow/data/models/task_enums.dart';
import 'package:taskflow/data/models/update_group_request.dart';
import 'package:taskflow/data/providers/group_providers.dart';
import 'package:taskflow/l10n/app_localizations.dart';
import 'package:taskflow/presentation/providers/group_notifier.dart';
import 'package:taskflow/presentation/widgets/common/app_navigation_back_button.dart';
import 'package:taskflow/presentation/widgets/groups/rotation_types_help_dialog.dart';

class GroupSettingsScreen extends ConsumerStatefulWidget {
  final String groupId;

  const GroupSettingsScreen({super.key, required this.groupId});

  @override
  ConsumerState<GroupSettingsScreen> createState() => _GroupSettingsScreenState();
}

class _GroupSettingsScreenState extends ConsumerState<GroupSettingsScreen> {
  Group? _group;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);

    final getGroupUseCase = ref.read(getGroupDetailUseCaseProvider);
    final groupResult = await getGroupUseCase(widget.groupId);

    if (!mounted) return;

    setState(() {
      _isLoading = false;
      groupResult.fold((failure) {}, (group) {
        _group = group;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(
          leading: AppNavigationBackButton(fallbackRoute: '/groups/${widget.groupId}'),
          title: Text(AppLocalizations.of(context)!.groupSettingsTitle),
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_group == null) {
      return Scaffold(
        appBar: AppBar(
          leading: AppNavigationBackButton(fallbackRoute: '/groups/${widget.groupId}'),
          title: Text(AppLocalizations.of(context)!.groupSettingsTitle),
        ),
        body: Center(child: Text(AppLocalizations.of(context)!.failedToLoadGroupSettings)),
      );
    }

    return Scaffold(
      appBar: AppBar(
        leading: AppNavigationBackButton(fallbackRoute: '/groups/${widget.groupId}'),
        title: Text(AppLocalizations.of(context)!.groupSettingsTitle),
      ),
      body: GroupSettingsContent(groupId: widget.groupId, group: _group!),
    );
  }
}

/// Reusable settings content widget that can be embedded in tabs or standalone screens
class GroupSettingsContent extends ConsumerStatefulWidget {
  final String groupId;
  final Group group;

  const GroupSettingsContent({super.key, required this.groupId, required this.group});

  @override
  ConsumerState<GroupSettingsContent> createState() => _GroupSettingsContentState();
}

class _GroupSettingsContentState extends ConsumerState<GroupSettingsContent> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();

  Group? _group;
  String? _rotationType;
  bool? _gamificationEnabled;
  bool? _requiresApproval;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _initializeFromGroup();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _initializeFromGroup() {
    _group = widget.group;
    _nameController.text = widget.group.name;
    _descriptionController.text = widget.group.description ?? '';
    _rotationType = widget.group.rotationType;
    _gamificationEnabled = widget.group.gamificationEnabled;
    _requiresApproval = widget.group.requiresApproval;
  }

  Future<void> _saveChanges() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    final request = UpdateGroupRequest(
      name: _nameController.text.trim() != _group?.name ? _nameController.text.trim() : null,
      description: _descriptionController.text.trim() != _group?.description
          ? (_descriptionController.text.trim().isEmpty ? null : _descriptionController.text.trim())
          : null,
      rotationType: _rotationType != _group?.rotationType ? _rotationType : null,
      gamificationEnabled: _gamificationEnabled != _group?.gamificationEnabled
          ? _gamificationEnabled
          : null,
      requiresApproval: _requiresApproval != _group?.requiresApproval ? _requiresApproval : null,
    );

    final updateGroupUseCase = ref.read(updateGroupUseCaseProvider);
    final result = await updateGroupUseCase(widget.groupId, request);

    if (!mounted) return;

    setState(() => _isSaving = false);

    result.fold(
      (failure) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context)!.errorWithMessage(failure.message)),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      },
      (group) {
        setState(() => _group = group);
        ref.read(groupNotifierProvider.notifier).refresh();
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(AppLocalizations.of(context)!.settingsSaved)));
      },
    );
  }

  Future<void> _regenerateInviteToken() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(AppLocalizations.of(context)!.regenerateInviteToken),
        content: Text(AppLocalizations.of(context)!.regenerateInviteTokenConfirm),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: Text(AppLocalizations.of(context)!.cancel)),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(AppLocalizations.of(context)!.regenerateInviteToken),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;

    final regenerateUseCase = ref.read(regenerateInviteTokenUseCaseProvider);
    final result = await regenerateUseCase(widget.groupId);

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
      (group) {
        setState(() => _group = group);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(AppLocalizations.of(context)!.inviteTokenRegenerated)));
      },
    );
  }

  Future<void> _deleteGroup() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(AppLocalizations.of(context)!.deleteGroup),
        content: Text(AppLocalizations.of(context)!.deleteGroupConfirm),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: Text(AppLocalizations.of(context)!.cancel)),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            style: FilledButton.styleFrom(backgroundColor: Theme.of(context).colorScheme.error),
            child: Text(AppLocalizations.of(context)!.deleteGroup),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;

    final deleteGroupUseCase = ref.read(deleteGroupUseCaseProvider);
    final result = await deleteGroupUseCase(widget.groupId);

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
        ref.read(groupNotifierProvider.notifier).refresh();
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(AppLocalizations.of(context)!.deleteGroupSuccess)));
        context.go('/groups');
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    if (_group == null) {
      return Center(child: Text(AppLocalizations.of(context)!.failedToLoadGroupSettings));
    }

    return Form(
      key: _formKey,
      child: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              children: [
          // Basic info section
          Text(AppLocalizations.of(context)!.basicInformation, style: theme.textTheme.titleMedium),
          const SizedBox(height: 12),

          TextFormField(
            controller: _nameController,
            decoration: InputDecoration(
              labelText: AppLocalizations.of(context)!.groupName,
              border: const OutlineInputBorder(),
              prefixIcon: const Icon(Icons.group),
            ),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return AppLocalizations.of(context)!.groupNameRequired;
              }
              return null;
            },
            enabled: !_isSaving,
          ),
          const SizedBox(height: 16),

          TextFormField(
            controller: _descriptionController,
            decoration: InputDecoration(
              labelText: AppLocalizations.of(context)!.descriptionLabel,
              border: const OutlineInputBorder(),
              prefixIcon: const Icon(Icons.description),
            ),
            maxLines: 3,
            enabled: !_isSaving,
          ),
          const SizedBox(height: 24),

          // Configuration section
          Text(AppLocalizations.of(context)!.configuration, style: theme.textTheme.titleMedium),
          const SizedBox(height: 12),

          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: DropdownButtonFormField<String>(
                  initialValue: _rotationType,
                  decoration: InputDecoration(
                    labelText: AppLocalizations.of(context)!.rotationType,
                    border: const OutlineInputBorder(),
                    prefixIcon: const Icon(Icons.sync),
                  ),
                  items: RotationType.values.map((type) {
                    final l10n = AppLocalizations.of(context)!;
                    return DropdownMenuItem<String>(
                      value: type.value,
                      child: Text(rotationTypeLabel(l10n, type)),
                    );
                  }).toList(),
                  onChanged: _isSaving
                      ? null
                      : (value) {
                          setState(() => _rotationType = value);
                        },
                ),
              ),
              const RotationTypesHelpIconButton(),
            ],
          ),
          const SizedBox(height: 16),

          Card(
            child: SwitchListTile(
              value: _gamificationEnabled ?? false,
              onChanged: _isSaving
                  ? null
                  : (value) {
                      setState(() => _gamificationEnabled = value);
                    },
              title: Text(AppLocalizations.of(context)!.gamification),
              subtitle: Text(AppLocalizations.of(context)!.enablePointsAndRewards),
              secondary: const Icon(Icons.emoji_events),
            ),
          ),
          const SizedBox(height: 8),

          Card(
            child: SwitchListTile(
              value: _requiresApproval ?? false,
              onChanged: _isSaving
                  ? null
                  : (value) {
                      setState(() => _requiresApproval = value);
                    },
              title: Text(AppLocalizations.of(context)!.requireApproval),
              subtitle: Text(AppLocalizations.of(context)!.adminMustApproveTasks),
              secondary: const Icon(Icons.check_circle),
            ),
          ),
          const SizedBox(height: 24),

          // Member management section
          Text(AppLocalizations.of(context)!.memberManagement, style: theme.textTheme.titleMedium),
          const SizedBox(height: 12),

          FilledButton.tonalIcon(
            onPressed: _regenerateInviteToken,
            icon: const Icon(Icons.refresh),
            label: Text(AppLocalizations.of(context)!.regenerateInviteToken),
          ),
          const SizedBox(height: 12),
          ListTile(
            leading: const Icon(Icons.history),
            title: Text(AppLocalizations.of(context)!.groupAuditLog),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => context.push('/groups/${widget.groupId}/audit-log'),
          ),
          ListTile(
            leading: const Icon(Icons.rotate_right),
            title: Text(AppLocalizations.of(context)!.viewRotation),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => context.push('/groups/${widget.groupId}/rotation'),
          ),
          ListTile(
            leading: const Icon(Icons.repeat),
            title: Text(AppLocalizations.of(context)!.viewRecurringTemplates),
            trailing: const Icon(Icons.chevron_right),
            onTap: () =>
                context.push('/groups/${widget.groupId}/recurring-templates'),
          ),
          const SizedBox(height: 32),

          // Danger zone
          Text(
            AppLocalizations.of(context)!.dangerZone,
            style: theme.textTheme.titleMedium?.copyWith(color: colorScheme.error),
          ),
          const SizedBox(height: 12),

          OutlinedButton.icon(
            onPressed: _deleteGroup,
            icon: const Icon(Icons.delete_forever),
            label: Text(AppLocalizations.of(context)!.deleteGroup),
            style: OutlinedButton.styleFrom(
              foregroundColor: colorScheme.error,
              side: BorderSide(color: colorScheme.error),
            ),
          ),
              ],
            ),
          ),
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
              child: SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: _isSaving ? null : _saveChanges,
                  icon: _isSaving
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.save),
                  label: Text(AppLocalizations.of(context)!.save),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
