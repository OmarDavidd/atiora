import 'package:flutter/material.dart';

class AppConstants {
  static const String appName = 'Atiora';
  static const String appVersion = '1.0.0';

  // Database
  static const String dbName = 'notium.db';
  static const int dbVersion = 1;

  // Sync
  static const Duration syncInterval = Duration(minutes: 5);
  static const int maxSyncRetries = 3;

  // UI
  static const double borderRadiusSmall = 8.0;
  static const double borderRadiusMedium = 12.0;
  static const double borderRadiusLarge = 16.0;
  static const double cardElevation = 4.0;
  static const EdgeInsets paddingSmall = EdgeInsets.all(8.0);
  static const EdgeInsets paddingMedium = EdgeInsets.all(16.0);
  static const EdgeInsets paddingLarge = EdgeInsets.all(24.0);

  // Book States
  static const List<String> bookStates = [
    statusLeyendo,
    statusCompletado,
    statusPausado,
    statusPendiente,
  ];

  static const String statusLeyendo = 'Leyendo';
  static const String statusCompletado = 'Completado';
  static const String statusPausado = 'Pausado';
  static const String statusPendiente = 'Pendiente';

  // Note Types
  static const List<String> noteTypes = [
    noteTypeResumen,
    noteTypeAnalisis,
    noteTypeCita,
    noteTypeReflexion,
    noteTypePregunta,
  ];

  static const String noteTypeResumen = 'resumen';
  static const String noteTypeAnalisis = 'análisis';
  static const String noteTypeCita = 'cita';
  static const String noteTypeReflexion = 'reflexión';
  static const String noteTypePregunta = 'pregunta';

  // Storage Keys
  static const String themeModeKey = 'theme_mode';
  static const String lastSyncKey = 'last_sync';
}

class PendingOperationType {
  static const String add = 'add';
  static const String update = 'update';
  static const String delete = 'delete';
  static const String state = 'state';
  static const String readingSession = 'reading_session';
  static const String noteAdd = 'note_add';
  static const String noteUpdate = 'note_update';
  static const String noteDelete = 'note_delete';
}
