import 'package:flutter/material.dart';
import 'package:atiora/core/utils/app_colors.dart';

enum NotificationType {
  success,
  error,
  warning,
  info,
}

class NotificationHelper {
  static Color _getBackgroundColor(NotificationType type) {
    switch (type) {
      case NotificationType.success:
        return AppColors.success;
      case NotificationType.error:
        return AppColors.error;
      case NotificationType.warning:
        return AppColors.warning;
      case NotificationType.info:
        return AppColors.reading;
    }
  }

  static IconData _getIcon(NotificationType type) {
    switch (type) {
      case NotificationType.success:
        return Icons.check_circle_outline;
      case NotificationType.error:
        return Icons.error_outline;
      case NotificationType.warning:
        return Icons.warning_amber_outlined;
      case NotificationType.info:
        return Icons.info_outline;
    }
  }

  static void show(
    BuildContext context,
    String message, {
    NotificationType type = NotificationType.info,
    Duration duration = const Duration(seconds: 3),
  }) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              _getIcon(type),
              color: AppColors.neutral0,
              size: 20,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(
                  color: AppColors.neutral0,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: _getBackgroundColor(type),
        behavior: SnackBarBehavior.floating,
        duration: duration,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }

  static void showSuccess(BuildContext context, String message) {
    show(context, message, type: NotificationType.success);
  }

  static void showError(BuildContext context, String message) {
    show(context, message, type: NotificationType.error, duration: const Duration(seconds: 4));
  }

  static void showWarning(BuildContext context, String message) {
    show(context, message, type: NotificationType.warning);
  }

  static void showInfo(BuildContext context, String message) {
    show(context, message, type: NotificationType.info);
  }
}
