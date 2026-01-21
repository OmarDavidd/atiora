import 'package:flutter/material.dart';

class AppConstants {
  static const String appName = 'Notium';
  static const String appVersion = '1.0.0';
  static const String googleBooksApiKey = 'TU_API_KEY_AQUI';

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
    'leyendo',
    'completado',
    'pausado',
    'pendiente',
  ];

  // Storage Keys
  static const String themeModeKey = 'theme_mode';
  static const String lastSyncKey = 'last_sync';
}
