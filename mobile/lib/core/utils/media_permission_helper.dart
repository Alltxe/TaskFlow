import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';

/// Requests the correct media permission based on the [source] and the
/// current platform/Android API level.
///
/// - Camera (any platform): requests [Permission.camera].
/// - Gallery on Android 13+ (API ≥ 33): requests [Permission.photos]
///   → READ_MEDIA_IMAGES.
/// - Gallery on Android < 13 (API ≤ 32): requests [Permission.storage]
///   → READ_EXTERNAL_STORAGE.
/// - Gallery on iOS: requests [Permission.photos].
///
/// Returns `true` when the relevant permission is granted, `false` otherwise.
Future<bool> requestMediaPermission(ImageSource source) async {
  if (source == ImageSource.camera) {
    final status = await Permission.camera.request();
    return status.isGranted;
  }

  // Gallery
  if (Platform.isAndroid) {
    final sdkInt =
        (await DeviceInfoPlugin().androidInfo).version.sdkInt;
    if (sdkInt >= 33) {
      // Android 13+: granular media permission
      final status = await Permission.photos.request();
      return status.isGranted || status.isLimited;
    } else {
      // Android < 13: legacy storage permission
      final status = await Permission.storage.request();
      return status.isGranted;
    }
  }

  // iOS
  final status = await Permission.photos.request();
  return status.isGranted || status.isLimited;
}
