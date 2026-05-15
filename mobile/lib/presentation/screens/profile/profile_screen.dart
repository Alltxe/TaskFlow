import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:taskflow/core/utils/media_permission_helper.dart';
import 'package:taskflow/core/errors/failure.dart';
import 'package:taskflow/data/models/group_summary.dart';
import 'package:taskflow/data/models/user_statistics.dart';
import 'package:taskflow/data/providers/auth_providers.dart';
import 'package:taskflow/data/providers/profile_providers.dart';
import 'package:taskflow/l10n/app_localizations.dart';
import 'package:dartz/dartz.dart';

/// Profile tab screen
class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  bool _uploadingAvatar = false;

  // Cached futures — created once and kept stable across rebuilds
  Future<Either<Failure, UserStatistics>>? _statisticsFuture;
  Future<Either<Failure, List<GroupSummary>>>? _groupsFuture;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _statisticsFuture ??= ref.read(getUserStatisticsUseCaseProvider).call();
    _groupsFuture ??= ref.read(getUserGroupsUseCaseProvider).call();
  }

  void _refresh() {
    setState(() {
      _statisticsFuture = ref.read(getUserStatisticsUseCaseProvider).call();
      _groupsFuture = ref.read(getUserGroupsUseCaseProvider).call();
    });
    ref.invalidate(getUserProfileUseCaseProvider);
  }

  // ── Avatar upload ─────────────────────────────────────────────────────────

  Future<void> _pickAndUploadAvatar() async {
    final source = await _showImageSourceDialog();
    if (source == null) return;

    final hasPermission = await _requestMediaPermission(source);
    if (!hasPermission) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Нет разрешения на доступ к медиафайлам')),
        );
      }
      return;
    }

    final picker = ImagePicker();
    final XFile? picked = await picker.pickImage(
      source: source,
      maxWidth: 512,
      maxHeight: 512,
      imageQuality: 85,
    );
    if (picked == null) return;

    setState(() => _uploadingAvatar = true);
    try {
      final useCase = ref.read(uploadAvatarUseCaseProvider);
      final result = await useCase(picked.path);
      result.fold(
        (failure) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Ошибка: ${failure.message}'),
                backgroundColor: Theme.of(context).colorScheme.error,
              ),
            );
          }
        },
        (newAvatarUrl) {
          print('[Profile] Upload success, URL: $newAvatarUrl');
          final currentUser = ref.read(authStateProvider).user;
          print('[Profile] Current user avatarUrl before: ${currentUser?.avatarUrl}');
          if (currentUser != null) {
            final updated = currentUser.copyWith(avatarUrl: newAvatarUrl);
            print('[Profile] Updated user avatarUrl: ${updated.avatarUrl}');
            ref.read(authStateProvider.notifier).updateUser(updated);
          }
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Аватар обновлён')),
            );
          }
        },
      );
    } finally {
      if (mounted) setState(() => _uploadingAvatar = false);
    }
  }

  Future<ImageSource?> _showImageSourceDialog() {
    return showModalBottomSheet<ImageSource>(
      context: context,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.photo_library_outlined),
              title: const Text('Из галереи'),
              onTap: () => Navigator.pop(ctx, ImageSource.gallery),
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt_outlined),
              title: const Text('Сделать фото'),
              onTap: () => Navigator.pop(ctx, ImageSource.camera),
            ),
            ListTile(
              leading: const Icon(Icons.close),
              title: const Text('Отмена'),
              onTap: () => Navigator.pop(ctx),
            ),
          ],
        ),
      ),
    );
  }

  Future<bool> _requestMediaPermission(ImageSource source) =>
      requestMediaPermission(source);

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.profileTitle),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => context.push('/settings'),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async => _refresh(),
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _buildProfileHeader(context),
            const SizedBox(height: 24),

            FutureBuilder<Either<Failure, UserStatistics>>(
              future: _statisticsFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                return snapshot.data?.fold(
                      (failure) => _buildErrorCard(context, failure.message),
                      (stats) => _buildStatisticsSection(context, stats),
                    ) ??
                    const SizedBox.shrink();
              },
            ),

            const SizedBox(height: 24),

            FutureBuilder<Either<Failure, List<GroupSummary>>>(
              future: _groupsFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                return snapshot.data?.fold(
                      (failure) => _buildErrorCard(context, failure.message),
                      (groups) => _buildGroupsSection(context, groups),
                    ) ??
                    const SizedBox.shrink();
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileHeader(BuildContext context) {
    final authState = ref.watch(authStateProvider);

    if (authState.status == AuthStatus.loading) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(48),
          child: Center(child: CircularProgressIndicator()),
        ),
      );
    }

    if (authState.status != AuthStatus.authenticated || authState.user == null) {
      return const SizedBox.shrink();
    }

    final user = authState.user!;
    print('[Profile] Building header, avatarUrl: ${user.avatarUrl}');
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Stack(
              children: [
                CircleAvatar(
                  radius: 50,
                  backgroundImage: user.avatarUrl != null
                      ? CachedNetworkImageProvider(user.avatarUrl!)
                      : null,
                  child: user.avatarUrl == null
                      ? Text(
                          user.username[0].toUpperCase(),
                          style: Theme.of(context).textTheme.displayMedium,
                        )
                      : null,
                ),
                Positioned(
                  right: 0,
                  bottom: 0,
                  child: CircleAvatar(
                    radius: 18,
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    child: _uploadingAvatar
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : IconButton(
                            icon: const Icon(Icons.camera_alt, size: 18),
                            color: Theme.of(context).colorScheme.onPrimary,
                            onPressed: _uploadingAvatar ? null : _pickAndUploadAvatar,
                            padding: EdgeInsets.zero,
                            tooltip: 'Изменить аватар',
                          ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(user.username, style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 4),
            Text(
              user.email,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 12),
            if (user.isAway)
              Chip(
                avatar: const Icon(Icons.flight_takeoff, size: 16),
                label: Text(
                  user.awayUntil != null
                      ? AppLocalizations.of(context)!.awayUntil(_formatDate(context, user.awayUntil!))
                      : AppLocalizations.of(context)!.away,
                ),
                backgroundColor: Theme.of(context).colorScheme.secondaryContainer,
              ),
            const SizedBox(height: 16),
            FilledButton.tonalIcon(
              onPressed: () => context.push('/edit-profile'),
              icon: const Icon(Icons.edit),
              label: Text(AppLocalizations.of(context)!.editProfile),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatisticsSection(BuildContext context, UserStatistics statistics) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppLocalizations.of(context)!.statisticsTitle,
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                context,
                AppLocalizations.of(context)!.points,
                statistics.currentPointBalance.toString(),
                Icons.stars,
                Theme.of(context).colorScheme.primary,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildStatCard(
                context,
                AppLocalizations.of(context)!.completed,
                statistics.tasksCompleted.toString(),
                Icons.check_circle,
                Colors.green,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                context,
                AppLocalizations.of(context)!.completionRate,
                '${statistics.completionRate.toStringAsFixed(1)}%',
                Icons.trending_up,
                Colors.blue,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildStatCard(
                context,
                AppLocalizations.of(context)!.onTimeRate,
                '${statistics.onTimePercentage.toStringAsFixed(1)}%',
                Icons.schedule,
                Colors.orange,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatCard(
    BuildContext context,
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    final isPointsCard = label == AppLocalizations.of(context)!.points;
    return Card(
      child: InkWell(
        onTap: isPointsCard ? () => context.push('/points-detail') : null,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Icon(icon, color: color, size: 32),
              const SizedBox(height: 8),
              Text(
                value,
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  color: color,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(label, style: Theme.of(context).textTheme.bodySmall, textAlign: TextAlign.center),
                  if (isPointsCard) ...[
                    const SizedBox(width: 4),
                    Icon(Icons.arrow_forward, size: 14, color: color),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGroupsSection(BuildContext context, List<GroupSummary> groups) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(AppLocalizations.of(context)!.myGroups, style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 12),
        if (groups.isEmpty)
          Card(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Center(
                child: Column(
                  children: [
                    Icon(Icons.group_add, size: 48, color: Theme.of(context).colorScheme.onSurfaceVariant),
                    const SizedBox(height: 12),
                    Text(AppLocalizations.of(context)!.noGroupsYet, style: Theme.of(context).textTheme.bodyLarge),
                    const SizedBox(height: 8),
                    Text(
                      AppLocalizations.of(context)!.joinOrCreateGroup,
                      style: Theme.of(context).textTheme.bodySmall,
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
          )
        else
          ...groups.map(
            (group) => Card(
              margin: const EdgeInsets.only(bottom: 8),
              child: ListTile(
                leading: CircleAvatar(child: Text(group.name[0].toUpperCase())),
                title: Text(group.name),
                subtitle: Text(group.description ?? AppLocalizations.of(context)!.noDescription),
                trailing: Chip(
                  label: Text(group.role),
                  backgroundColor: group.role == 'admin'
                      ? Theme.of(context).colorScheme.primaryContainer
                      : null,
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildErrorCard(BuildContext context, String message) {
    return Card(
      color: Theme.of(context).colorScheme.errorContainer,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(Icons.error_outline, color: Theme.of(context).colorScheme.onErrorContainer),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: TextStyle(color: Theme.of(context).colorScheme.onErrorContainer),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(BuildContext context, DateTime date) {
    final now = DateTime.now();
    final difference = date.difference(now).inDays;
    if (difference == 0) return AppLocalizations.of(context)!.today;
    if (difference == 1) return AppLocalizations.of(context)!.tomorrow;
    if (difference < 7) return AppLocalizations.of(context)!.inDays(difference);
    return '${date.day}/${date.month}/${date.year}';
  }
}
