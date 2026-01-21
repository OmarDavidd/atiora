import 'package:flutter/material.dart';
import '../utils/app_colors.dart';
import '../utils/constants.dart';

class DarkTheme {
  static ThemeData get theme => ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: AppColors.primary,
      brightness: Brightness.dark,
    ),
    scaffoldBackgroundColor: AppColors.backgroundPrimary,
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.backgroundPrimary,
      foregroundColor: AppColors.neutral0,
      elevation: AppConstants.cardElevation,
      titleTextStyle: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: AppColors.neutral0,
      ),
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: AppColors.backgroundPrimary,
      selectedItemColor: AppColors.primary,
      unselectedItemColor: AppColors.neutral400,
      type: BottomNavigationBarType.fixed,
    ),
    cardTheme: CardThemeData(
      color: AppColors.surfacePrimary,
      elevation: AppConstants.cardElevation,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppConstants.borderRadiusMedium),
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.neutral0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppConstants.borderRadiusSmall),
        ),
        elevation: 2,
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppConstants.borderRadiusSmall),
      ),
      focusedBorder: OutlineInputBorder(
        borderSide: const BorderSide(color: AppColors.primary, width: 2),
        borderRadius: BorderRadius.circular(AppConstants.borderRadiusSmall),
      ),
      filled: true,
      fillColor: AppColors.neutral500.withAlpha(26), // Reemplaza withOpacity
    ),
    textTheme: const TextTheme(
      headlineLarge: TextStyle(
        fontSize: 28,
        fontWeight: FontWeight.w700,
        color: AppColors.neutral0,
      ),
      headlineMedium: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: AppColors.neutral0,
      ),
      bodyLarge: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        color: AppColors.neutral0,
      ),
      bodyMedium: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: AppColors.neutral400,
      ),
      labelLarge: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: AppColors.backgroundPrimary,
      ),
    ),
  );
}
