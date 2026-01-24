import 'package:atiora/features/auth/presentation/screens/login_screen.dart';
import 'package:atiora/features/auth/presentation/screens/register_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'core/di/injection_container.dart';
import 'core/theme/app_theme.dart';
import 'core/navigation/app_router.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");
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
  @override
  void initState() {
    super.initState();
    _loadTheme();
  }

  Future<void> _loadTheme() async {
    await AppTheme.loadThemeMode();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Atiora',
      debugShowCheckedModeBanner: false,
      themeMode: ThemeMode.dark,
      //themeMode: _themeMode,
      theme: AppTheme.getTheme(context, ThemeMode.light),
      darkTheme: AppTheme.getTheme(context, ThemeMode.dark),
      initialRoute: AppRouter.login,
      onGenerateRoute: _generateRoute,
    );
  }

  Route<dynamic> _generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case AppRouter.login:
        return MaterialPageRoute(builder: (_) => const LoginScreen());
      case AppRouter.register:
        return MaterialPageRoute(builder: (_) => const RegisterScreen());
      case AppRouter.home:
        return MaterialPageRoute(
          builder: (_) => Scaffold(body: Text('Home TODO')),
        );
      default:
        return MaterialPageRoute(builder: (_) => const LoginScreen());
    }
  }
}
