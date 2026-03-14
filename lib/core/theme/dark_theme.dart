import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../utils/app_colors.dart';

class DarkTheme {
  static ThemeData get theme => ThemeData(
    useMaterial3: true,
    colorScheme:
        ColorScheme.fromSeed(
          seedColor: AppColors.primary,
          brightness: Brightness.dark,
        ).copyWith(
          surface: AppColors.surfacePrimary,
          onSurface: AppColors.neutral0,
          outline: AppColors.neutral500,
          surfaceContainerHighest: AppColors.surfacePrimary,
        ),
    scaffoldBackgroundColor: AppColors.backgroundPrimary,
    appBarTheme: AppBarTheme(
      backgroundColor: AppColors.backgroundPrimary,
      foregroundColor: AppColors.neutral0,
      elevation: 0,
      titleTextStyle: GoogleFonts.jaini(
        fontSize: 32,
        fontWeight: FontWeight.w400,
        letterSpacing: 4,
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
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.neutral0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 0,
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      focusedBorder: OutlineInputBorder(
        borderSide: const BorderSide(color: AppColors.primary, width: 2),
        borderRadius: BorderRadius.circular(12),
      ),
      filled: true,
      fillColor: AppColors.neutral500.withAlpha(30),
    ),
    textTheme: TextTheme(
      headlineLarge: GoogleFonts.jaini(
        fontSize: 32,
        fontWeight: FontWeight.w400,
        color: AppColors.neutral0,
        letterSpacing: 4,
      ),
      headlineMedium: GoogleFonts.jaini(
        fontSize: 24,
        fontWeight: FontWeight.w400,
        color: AppColors.neutral0,
      ),
      titleLarge: GoogleFonts.jaini(
        fontSize: 22,
        fontWeight: FontWeight.w400,
        color: AppColors.neutral0,
      ),
      bodyLarge: GoogleFonts.inter(
        fontSize: 16,
        fontWeight: FontWeight.w500,
        color: AppColors.neutral0,
      ),
      bodyMedium: GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: AppColors.neutral400,
      ),
      bodySmall: GoogleFonts.inter(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        color: AppColors.neutral500,
      ),
      labelLarge: GoogleFonts.inter(
        fontSize: 13,
        fontWeight: FontWeight.w700,
        color: AppColors.backgroundPrimary,
      ),
    ),
  );
}
