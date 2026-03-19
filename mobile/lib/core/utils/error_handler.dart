import 'package:flutter/material.dart';
import 'package:taskflow/core/errors/exceptions.dart';
import 'package:taskflow/l10n/app_localizations.dart';

/// Helper class for handling errors and converting them to user-friendly messages
class ErrorHandler {
  ErrorHandler._();

  /// Get user-friendly error message from exception
  static String getUserMessage(BuildContext context, dynamic error) {
    final l10n = AppLocalizations.of(context)!;

    if (error is NetworkException) {
      return error.message.isNotEmpty ? error.message : l10n.networkError;
    }

    if (error is TimeoutException) {
      return error.message.isNotEmpty ? error.message : l10n.timeoutError;
    }

    if (error is AuthException) {
      return error.message.isNotEmpty ? error.message : l10n.authError;
    }

    if (error is ValidationException) {
      return error.message.isNotEmpty ? error.message : l10n.validationError;
    }

    if (error is ServerException) {
      return error.message.isNotEmpty ? error.message : l10n.serverError;
    }

    if (error is NotFoundException) {
      return error.message.isNotEmpty ? error.message : l10n.notFoundError;
    }

    if (error is PermissionException) {
      return error.message.isNotEmpty ? error.message : l10n.permissionError;
    }

    // Default error message
    return l10n.unknownError;
  }

  /// Show error snackbar
  static void showErrorSnackBar(BuildContext context, dynamic error) {
    if (!context.mounted) return;

    final message = getUserMessage(context, error);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Theme.of(context).colorScheme.error,
        duration: const Duration(seconds: 4),
        action: SnackBarAction(
          label: AppLocalizations.of(context)!.dismiss,
          textColor: Colors.white,
          onPressed: () {
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
          },
        ),
      ),
    );
  }

  /// Show error dialog
  static Future<void> showErrorDialog(
    BuildContext context,
    dynamic error, {
    String? title,
    VoidCallback? onRetry,
  }) async {
    if (!context.mounted) return;

    final l10n = AppLocalizations.of(context)!;
    final message = getUserMessage(context, error);

    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title ?? l10n.error),
        content: Text(message),
        actions: [
          if (onRetry != null)
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                onRetry();
              },
              child: Text(l10n.retry),
            ),
          TextButton(onPressed: () => Navigator.of(context).pop(), child: Text(l10n.ok)),
        ],
      ),
    );
  }
}
