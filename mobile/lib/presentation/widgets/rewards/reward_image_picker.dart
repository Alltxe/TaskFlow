import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:taskflow/core/utils/media_permission_helper.dart';
import 'package:taskflow/data/datasources/reward_remote_datasource.dart';

/// Image picker widget for reward dialogs.
/// Displays current image (or placeholder), lets user pick from gallery/camera,
/// uploads to MinIO and returns the resulting URL via [onUploaded].
class RewardImagePicker extends StatefulWidget {
  /// Currently selected image URL (null = no image).
  final String? imageUrl;

  /// Called with the new URL after a successful upload.
  final ValueChanged<String?> onUploaded;

  /// Whether to disable interaction (e.g. while saving).
  final bool enabled;

  const RewardImagePicker({
    super.key,
    this.imageUrl,
    required this.onUploaded,
    this.enabled = true,
  });

  @override
  State<RewardImagePicker> createState() => _RewardImagePickerState();
}

class _RewardImagePickerState extends State<RewardImagePicker> {
  bool _uploading = false;
  String? _localUrl; // overrides widget.imageUrl after upload

  String? get _displayUrl => _localUrl ?? widget.imageUrl;

  Future<void> _pick() async {
    final source = await _showSourceSheet();
    if (source == null) return;

    final granted = await _requestPermission(source);
    if (!granted) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Нет разрешения на доступ к медиафайлам')),
        );
      }
      return;
    }

    final picker = ImagePicker();
    final XFile? file = await picker.pickImage(
      source: source,
      maxWidth: 800,
      maxHeight: 800,
      imageQuality: 85,
    );
    if (file == null) return;

    setState(() => _uploading = true);
    try {
      final ds = RewardRemoteDataSource();
      final url = await ds.uploadRewardImage(file.path);
      setState(() => _localUrl = url);
      widget.onUploaded(url);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Ошибка: ${e.toString()}'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _uploading = false);
    }
  }

  void _removeImage() {
    setState(() => _localUrl = null);
    widget.onUploaded(null);
  }

  Future<ImageSource?> _showSourceSheet() {
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

  Future<bool> _requestPermission(ImageSource source) =>
      requestMediaPermission(source);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final hasImage = _displayUrl != null && _displayUrl!.isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Изображение награды',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: (widget.enabled && !_uploading) ? _pick : null,
          child: Container(
            height: 120,
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: theme.colorScheme.outlineVariant),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(11),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  if (hasImage)
                    CachedNetworkImage(
                      imageUrl: _displayUrl!,
                      fit: BoxFit.cover,
                      errorWidget: (_, __, ___) => _placeholder(theme),
                    )
                  else
                    _placeholder(theme),

                  // Upload overlay
                  if (_uploading)
                    Container(
                      color: Colors.black45,
                      child: const Center(
                        child: CircularProgressIndicator(color: Colors.white),
                      ),
                    ),

                  // Top-right remove button
                  if (hasImage && !_uploading && widget.enabled)
                    Positioned(
                      top: 6,
                      right: 6,
                      child: GestureDetector(
                        onTap: _removeImage,
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: const BoxDecoration(
                            color: Colors.black54,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.close, color: Colors.white, size: 16),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          _uploading
              ? 'Загрузка...'
              : hasImage
                  ? 'Нажмите для замены изображения'
                  : 'Нажмите для выбора изображения',
          style: theme.textTheme.labelSmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }

  Widget _placeholder(ThemeData theme) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.add_photo_alternate_outlined,
            size: 36, color: theme.colorScheme.onSurfaceVariant),
        const SizedBox(height: 6),
        Text(
          'Выбрать изображение',
          style: theme.textTheme.labelMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}
