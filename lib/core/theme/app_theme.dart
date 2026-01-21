import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/constants.dart';
import 'light_theme.dart';
import 'dark_theme.dart';

class AppTheme {
  static ThemeData getTheme(BuildContext context, ThemeMode mode) {
    switch (mode) {
      case ThemeMode.light:
        return LightTheme.theme;
      case ThemeMode.dark:
        return DarkTheme.theme;
      case ThemeMode.system:
        final brightness = MediaQuery.of(context).platformBrightness;
        return brightness == Brightness.dark
            ? DarkTheme.theme
            : LightTheme.theme;
    }
  }

  static Future<void> saveThemeMode(ThemeMode mode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      AppConstants.themeModeKey,
      mode == ThemeMode.dark ? 'dark' : 'light',
    );
  }

  static Future<ThemeMode> loadThemeMode() async {
    final prefs = await SharedPreferences.getInstance();
    final themeString = prefs.getString(AppConstants.themeModeKey);

    if (themeString == 'dark') return ThemeMode.dark;
    return ThemeMode.light;
  }
}
