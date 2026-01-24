import 'package:atiora/core/screens/main_nav_page.dart';
import 'package:atiora/features/auth/presentation/screens/login_screen.dart';
import 'package:atiora/features/auth/presentation/screens/register_screen.dart';
import 'package:flutter/material.dart';

class AppRouter {
  static const String login = '/login';
  static const String register = '/register';
  static const String home = '/home';
  static const String main = '/main';

  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case login:
        return MaterialPageRoute(builder: (_) => const LoginScreen());
      case register:
        return MaterialPageRoute(builder: (_) => const RegisterScreen());
      case main:
        return MaterialPageRoute(builder: (_) => const MainNavPage());
      default:
        return MaterialPageRoute(builder: (_) => const LoginScreen());
    }
  }
}
