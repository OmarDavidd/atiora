import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'app_theme.dart';

class ThemeCubit extends Cubit<ThemeMode> {
  ThemeCubit() : super(ThemeMode.dark);

  Future<void> loadTheme() async {
    final mode = await AppTheme.loadThemeMode();
    emit(mode);
  }

  Future<void> setTheme(ThemeMode mode) async {
    emit(mode);
    await AppTheme.saveThemeMode(mode);
  }

  Future<void> toggleTheme() async {
    final nextMode = state == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
    await setTheme(nextMode);
  }
}
