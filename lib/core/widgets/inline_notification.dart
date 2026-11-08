import 'package:flutter/material.dart';
import 'package:atiora/core/utils/app_colors.dart';
import 'package:atiora/core/utils/notification_helper.dart';

class InlineNotification extends StatelessWidget {
  final String message;
  final NotificationType type;
  final VoidCallback? onDismiss;

  const InlineNotification({
    super.key,
    required this.message,
    this.type = NotificationType.error,
    this.onDismiss,
  });

  Color get _backgroundColor {
    switch (type) {
      case NotificationType.success:
        return AppColors.success.withValues(alpha: 0.15);
      case NotificationType.error:
        return AppColors.error.withValues(alpha: 0.15);
      case NotificationType.warning:
        return AppColors.warning.withValues(alpha: 0.15);
      case NotificationType.info:
        return AppColors.reading.withValues(alpha: 0.15);
    }
  }

  Color get _iconColor {
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

  IconData get _icon {
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

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: _backgroundColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _iconColor.withValues(alpha: 0.3), width: 1),
      ),
      child: Row(
        children: [
          Icon(_icon, color: _iconColor, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              message,
              style: TextStyle(color: _iconColor, fontWeight: FontWeight.w500),
            ),
          ),
          if (onDismiss != null)
            GestureDetector(
              onTap: onDismiss,
              child: Icon(Icons.close, color: _iconColor, size: 18),
            ),
        ],
      ),
    );
  }
}
