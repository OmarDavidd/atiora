import 'package:flutter/material.dart';
import '../utils/app_colors.dart';

class AppHelpers {
  static double calculateProgress(int currentPage, int totalPages) {
    if (totalPages == 0) return 0.0;
    return (currentPage / totalPages).clamp(0.0, 1.0);
  }

  static String formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  static Color getBookStateColor(String state) {
    switch (state.toLowerCase()) {
      case 'leyendo':
        return AppColors.reading;
      case 'completado':
        return AppColors.completed;
      case 'pausado':
        return AppColors.paused;
      case 'pendiente':
        return AppColors.pending;
      default:
        return AppColors.neutral500;
    }
  }

  /// Icono por tipo de nota
  static IconData getNoteTypeIcon(String type) {
    switch (type.toLowerCase()) {
      case 'resumen':
        return Icons.summarize;
      case 'análisis':
        return Icons.analytics;
      case 'cita':
        return Icons.format_quote;
      case 'reflexión':
        return Icons.lightbulb_outline;
      case 'pregunta':
        return Icons.help_outline;
      default:
        return Icons.note;
    }
  }
}
