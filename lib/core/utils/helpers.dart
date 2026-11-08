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

  static String formatMonthYear(DateTime date) {
    const months = [
      'enero',
      'febrero',
      'marzo',
      'abril',
      'mayo',
      'junio',
      'julio',
      'agosto',
      'septiembre',
      'octubre',
      'noviembre',
      'diciembre',
    ];
    final monthName = months[date.month - 1];
    return '${_capitalized(monthName)} de ${date.year}';
  }

  static String _capitalized(String text) {
    if (text.isEmpty) return text;
    return text[0].toUpperCase() + text.substring(1);
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

  static const List<String> status = [
    'Leyendo',
    'Completado',
    'Pausado',
    'Pendiente',
  ];

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

  static const List<String> allGenres = [
    'Ficción',
    'Ciencia Ficción',
    'Fantasía',
    'Romance',
    'Misterio',
    'Terror',
    'No Ficción',
    'Biografía',
    'Autoayuda',
  ];

  static const List<String> noteTypes = [
    'resumen',
    'análisis',
    'cita',
    'reflexión',
    'pregunta',
  ];

  static Color getNoteTypeColor(String type) {
    switch (type.toLowerCase()) {
      case 'resumen':
        return AppColors.primary; // azul
      case 'análisis':
        return AppColors.secondary; // morado
      case 'cita':
        return AppColors.warning; // amarillo/naranja
      case 'reflexión':
        return AppColors.success; // verde
      case 'pregunta':
        return AppColors.error; // rojo/coral
      default:
        return AppColors.neutral500;
    }
  }

  // Calcular porcentaje
  static String calcPercentage(int totalPages, int currentPage) {
    if (totalPages == 0) return "0%";
    double percentage = (currentPage / totalPages) * 100.0;
    return "${percentage.toStringAsFixed(0)}%";
  }

  static Color getStatusColor(String? status) {
    switch (status?.toLowerCase()) {
      case 'leyendo':
        return AppColors.reading;
      case 'completado':
      case 'terminado':
        return AppColors.completed;
      case 'pausado':
        return AppColors.paused;
      case 'pendiente':
        return AppColors.pending;
      default:
        return Colors.grey;
    }
  }
}
