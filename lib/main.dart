import 'package:atiora/core/navigation/app_router.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:atiora/core/di/injection_container.dart';
import 'package:atiora/core/theme/app_theme.dart';
import 'package:atiora/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:atiora/features/auth/presentation/widgets/auth_wrapper.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");
  // ignore: invalid_use_of_visible_for_testing_member
  SharedPreferences.setMockInitialValues({});
  await init();
  runApp(const AtioraApp());
}

class AtioraApp extends StatefulWidget {
  const AtioraApp({super.key});
  @override
  State<AtioraApp> createState() => _AtioraAppState();
}

class _AtioraAppState extends State<AtioraApp> {
  late Future<void> _themeFuture;

  @override
  void initState() {
    super.initState();
    _themeFuture = AppTheme.loadThemeMode();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _themeFuture,
      builder: (context, snapshot) {
        return BlocProvider<AuthBloc>(
          create: (_) => sl<AuthBloc>()..add(CheckAuthEvent()),
          child: MaterialApp(
            title: 'Atiora',
            debugShowCheckedModeBanner: false,
            themeMode: ThemeMode.dark,
            theme: AppTheme.getTheme(context, ThemeMode.light),
            darkTheme: AppTheme.getTheme(context, ThemeMode.dark),
            home: const AuthWrapper(),
            onGenerateRoute: AppRouter.generateRoute,
          ),
        );
      },
    );
  }
}
