import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:taskflow/domain/usecases/reward/reward_usecase_providers.dart';
import 'package:taskflow/l10n/app_localizations.dart';

class CreateRewardDialog extends ConsumerStatefulWidget {
  final String groupId;

  const CreateRewardDialog({super.key, required this.groupId});

  @override
  ConsumerState<CreateRewardDialog> createState() => _CreateRewardDialogState();
}

class _CreateRewardDialogState extends ConsumerState<CreateRewardDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _costController = TextEditingController();
  final _imageUrlController = TextEditingController();

  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _costController.dispose();
    _imageUrlController.dispose();
    super.dispose();
  }

  Future<void> _handleCreate() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final l10n = AppLocalizations.of(context)!;
    final createUseCase = ref.read(createRewardUseCaseProvider);

    final result = await createUseCase(
      groupId: widget.groupId,
      name: _nameController.text.trim(),
      cost: int.parse(_costController.text),
      description: _descriptionController.text.trim().isEmpty
          ? null
          : _descriptionController.text.trim(),
      imageUrl: _imageUrlController.text.trim().isEmpty
          ? null
          : _imageUrlController.text.trim(),
      isActive: true,
    );

    if (!mounted) return;

    setState(() => _isLoading = false);

    result.fold(
      (failure) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(failure.message),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      },
      (reward) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.rewardCreatedSuccess),
            backgroundColor: Theme.of(context).colorScheme.primary,
          ),
        );
        Navigator.of(context).pop(true);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return Dialog(
      child: Container(
        constraints: const BoxConstraints(maxWidth: 500),
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    l10n.createReward,
                    style: theme.textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 24),
                  TextFormField(
                    controller: _nameController,
                    decoration: InputDecoration(
                      labelText: l10n.rewardName,
                      hintText: l10n.enterRewardName,
                      border: const OutlineInputBorder(),
                    ),
                    enabled: !_isLoading,
                    textCapitalization: TextCapitalization.words,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return l10n.rewardNameRequired;
                      }
                      if (value.trim().length < 3) {
                        return l10n.rewardNameMinLength;
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _descriptionController,
                    decoration: InputDecoration(
                      labelText: l10n.rewardDescription,
                      hintText: l10n.enterRewardDescription,
                      border: const OutlineInputBorder(),
                    ),
                    enabled: !_isLoading,
                    maxLines: 3,
                    textCapitalization: TextCapitalization.sentences,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _costController,
                    decoration: InputDecoration(
                      labelText: l10n.rewardCost,
                      hintText: l10n.enterRewardCost,
                      border: const OutlineInputBorder(),
                      prefixIcon: const Icon(Icons.stars),
                    ),
                    enabled: !_isLoading,
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                    ],
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return l10n.rewardCostRequired;
                      }
                      final cost = int.tryParse(value);
                      if (cost == null || cost <= 0) {
                        return l10n.rewardCostMustBePositive;
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _imageUrlController,
                    decoration: InputDecoration(
                      labelText: l10n.rewardImageUrl,
                      hintText: l10n.enterImageUrl,
                      border: const OutlineInputBorder(),
                      prefixIcon: const Icon(Icons.image),
                    ),
                    enabled: !_isLoading,
                    keyboardType: TextInputType.url,
                  ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: _isLoading
                            ? null
                            : () => Navigator.of(context).pop(),
                        child: Text(l10n.cancel),
                      ),
                      const SizedBox(width: 8),
                      FilledButton(
                        onPressed: _isLoading ? null : _handleCreate,
                        child: _isLoading
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              )
                            : Text(l10n.create),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
