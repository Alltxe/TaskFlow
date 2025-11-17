import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile/data/models/group.dart';
import 'package:mobile/data/models/update_group_request.dart';
import 'package:mobile/data/providers/group_providers.dart';
import 'package:mobile/l10n/app_localizations.dart';
import 'package:mobile/presentation/providers/group_notifier.dart';

class GroupSettingsScreen extends ConsumerStatefulWidget {
  final String groupId;

  const GroupSettingsScreen({super.key, required this.groupId});

  @override
  ConsumerState<GroupSettingsScreen> createState() => _GroupSettingsScreenState();
}

class _GroupSettingsScreenState extends ConsumerState<GroupSettingsScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();

  Group? _group;
  String? _rotationType;
  bool? _gamificationEnabled;
  bool? _requiresApproval;
  bool _isLoading = true;
  bool _isSaving = false;

  final List<Map<String, String>> _rotationTypes = [
    {'value': 'ROUND_ROBIN', 'label': 'Round Robin'},
    {'value': 'RANDOM', 'label': 'Random'},
    {'value': 'LOAD_BALANCING', 'label': 'Load Balancing'},
    {'value': 'DISABLED', 'label': 'Disabled'},
  ];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
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
        _nameController.text = group.name;
        _descriptionController.text = group.description ?? '';
        _rotationType = group.rotationType;
        _gamificationEnabled = group.gamificationEnabled;
        _requiresApproval = group.requiresApproval;
      });
      // We don't use the members list in this screen currently; skip early fetch
    });
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
        ref.read(groupNotifierProvider.notifier).refresh();
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(AppLocalizations.of(context)!.settingsSaved)));
        context.pop();
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

    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(title: Text(AppLocalizations.of(context)!.groupSettingsTitle)),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_group == null) {
      return Scaffold(
        appBar: AppBar(title: Text(AppLocalizations.of(context)!.groupSettingsTitle)),
        body: Center(child: Text(AppLocalizations.of(context)!.failedToLoadGroupSettings)),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.groupSettingsTitle),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _isSaving ? null : _saveChanges,
            tooltip: AppLocalizations.of(context)!.save,
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
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

            DropdownButtonFormField<String>(
              initialValue: _rotationType,
                decoration: InputDecoration(
                labelText: AppLocalizations.of(context)!.rotationType,
                border: const OutlineInputBorder(),
                prefixIcon: const Icon(Icons.sync),
              ),
              items: _rotationTypes.map((type) {
                return DropdownMenuItem<String>(value: type['value'], child: Text(type['label']!));
              }).toList(),
              onChanged: _isSaving
                  ? null
                  : (value) {
                      setState(() => _rotationType = value);
                    },
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
    );
  }
}
