import 'package:atiora/core/theme/app_theme.dart';
import 'package:atiora/core/theme/theme_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('ThemeCubit', () {
    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      AppTheme.sharedPreferences = await SharedPreferences.getInstance();
    });

    test('loadTheme emite el modo persistido', () async {
      final cubit = ThemeCubit();
      await cubit.setTheme(ThemeMode.light);

      await cubit.loadTheme();

      expect(cubit.state, ThemeMode.light);
    });

    test('setTheme persiste y emite el nuevo modo', () async {
      final cubit = ThemeCubit();

      await cubit.setTheme(ThemeMode.light);

      expect(cubit.state, ThemeMode.light);
    });

    test('toggleTheme alterna entre light/dark', () async {
      final cubit = ThemeCubit();

      await cubit.setTheme(ThemeMode.dark);
      await cubit.toggleTheme();

      expect(cubit.state, ThemeMode.light);

      await cubit.toggleTheme();

      expect(cubit.state, ThemeMode.dark);
    });
  });
}
