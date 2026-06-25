import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:taskflow/data/models/group_preview.dart';
import 'package:taskflow/data/models/join_group_request.dart';
import 'package:taskflow/data/providers/group_providers.dart';
import 'package:taskflow/l10n/app_localizations.dart';
import 'package:taskflow/presentation/providers/group_notifier.dart';

class JoinByTokenScreen extends ConsumerStatefulWidget {
  final String? initialToken;

  const JoinByTokenScreen({super.key, this.initialToken});

  @override
  ConsumerState<JoinByTokenScreen> createState() => _JoinByTokenScreenState();
}

class _JoinByTokenScreenState extends ConsumerState<JoinByTokenScreen> {
  late final TextEditingController _tokenController;
  GroupPreview? _preview;
  bool _loadingPreview = false;
  bool _joining = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _tokenController = TextEditingController(text: widget.initialToken);
    if (widget.initialToken != null && widget.initialToken!.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _loadPreview());
    }
  }

  @override
  void dispose() {
    _tokenController.dispose();
    super.dispose();
  }

  String? _validateToken(String raw) {
    final token = raw.trim();
    if (token.isEmpty) return 'empty';
    if (token.length < 8) return 'invalid';
    return null;
  }

  Future<void> _pasteFromClipboard() async {
    final data = await Clipboard.getData(Clipboard.kTextPlain);
    if (data?.text != null && mounted) {
      _tokenController.text = data!.text!.trim();
      setState(() {
        _preview = null;
        _error = null;
      });
    }
  }

  Future<void> _loadPreview() async {
    final token = _tokenController.text.trim();
    final validation = _validateToken(token);
    if (validation != null) {
      setState(() {
        _preview = null;
        _error = validation == 'empty'
            ? AppLocalizations.of(context)!.enterInviteToken
            : AppLocalizations.of(context)!.invalidInviteToken;
      });
      return;
    }

    setState(() {
      _loadingPreview = true;
      _error = null;
      _preview = null;
    });

    final useCase = ref.read(getGroupPreviewByInviteTokenUseCaseProvider);
    final result = await useCase(token);

    if (!mounted) return;

    result.fold(
      (failure) {
        setState(() {
          _loadingPreview = false;
          _error = failure.message;
        });
      },
      (preview) {
        setState(() {
          _loadingPreview = false;
          _preview = preview;
        });
      },
    );
  }

  Future<void> _joinGroup() async {
    final token = _tokenController.text.trim();
    if (_validateToken(token) != null) {
      setState(() {
        _error = AppLocalizations.of(context)!.invalidInviteToken;
      });
      return;
    }

    setState(() {
      _joining = true;
      _error = null;
    });

    final result = await ref.read(joinGroupUseCaseProvider).call(JoinGroupRequest(inviteToken: token));

    if (!mounted) return;

    result.fold(
      (failure) {
        setState(() {
          _joining = false;
          _error = failure.message;
        });
      },
      (group) {
        ref.read(groupNotifierProvider.notifier).refresh();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppLocalizations.of(context)!.joinedSuccessfully(group.name))),
        );
        context.go('/groups/${group.id}');
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.joinGroupByToken)),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          Text(l10n.enterInviteToken, style: theme.textTheme.titleMedium),
          const SizedBox(height: 12),
          TextField(
            controller: _tokenController,
            decoration: InputDecoration(
              hintText: l10n.enterInviteToken,
              border: const OutlineInputBorder(),
              suffixIcon: IconButton(
                icon: const Icon(Icons.content_paste),
                tooltip: l10n.pasteFromClipboard,
                onPressed: _pasteFromClipboard,
              ),
            ),
            onChanged: (_) => setState(() {
              _preview = null;
              _error = null;
            }),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: FilledButton.tonal(
                  onPressed: _loadingPreview ? null : _loadPreview,
                  child: _loadingPreview
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : Text(l10n.groupPreviewTitle, overflow: TextOverflow.ellipsis),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: FilledButton(
                  onPressed: _joining ? null : _joinGroup,
                  child: _joining
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : Text(l10n.joinGroupConfirm, overflow: TextOverflow.ellipsis),
                ),
              ),
            ],
          ),
          if (_error != null) ...[
            const SizedBox(height: 16),
            Text(_error!, style: TextStyle(color: theme.colorScheme.error)),
          ],
          if (_preview != null) ...[
            const SizedBox(height: 24),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(_preview!.name, style: theme.textTheme.titleLarge),
                    if (_preview!.description != null) ...[
                      const SizedBox(height: 8),
                      Text(_preview!.description!),
                    ],
                    const SizedBox(height: 8),
                    Text(l10n.memberCount(_preview!.memberCount)),
                    if (_preview!.requiresApproval)
                      Text(l10n.requiresApproval, style: theme.textTheme.bodySmall),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
