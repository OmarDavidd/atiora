import 'package:atiora/core/navigation/app_router.dart';
import 'package:atiora/core/screens/splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:atiora/core/di/injection_container.dart';
import 'package:atiora/core/theme/app_theme.dart';
import 'package:atiora/core/theme/theme_cubit.dart';
import 'package:atiora/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:atiora/features/auth/presentation/widgets/auth_wrapper.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");
  await init();
  runApp(const AtioraApp());
}

class AtioraApp extends StatefulWidget {
  const AtioraApp({super.key});
  @override
  State<AtioraApp> createState() => _AtioraAppState();
}

class _AtioraAppState extends State<AtioraApp> {
  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<AuthBloc>(
          create: (_) => sl<AuthBloc>()..add(CheckAuthEvent()),
        ),
        BlocProvider<ThemeCubit>(create: (_) => ThemeCubit()..loadTheme()),
      ],
      child: BlocBuilder<ThemeCubit, ThemeMode>(
        builder: (context, mode) {
          return MaterialApp(
            title: 'Atiora',
            debugShowCheckedModeBanner: false,
            themeMode: mode,
            theme: AppTheme.getTheme(context, ThemeMode.light),
            darkTheme: AppTheme.getTheme(context, ThemeMode.dark),
            home: const SplashGate(child: AuthWrapper()),
            onGenerateRoute: AppRouter.generateRoute,
          );
        },
      ),
    );
  }
}
