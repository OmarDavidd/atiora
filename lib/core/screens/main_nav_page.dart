import 'package:atiora/core/di/injection_container.dart';
import 'package:atiora/features/dashboards/presentation/bloc/stats_bloc.dart';
import 'package:atiora/features/dashboards/presentation/screens/home_screen.dart';
import 'package:atiora/features/dashboards/presentation/screens/stats_screen.dart';
import 'package:atiora/features/library/presentation/screens/library_screen.dart';
import 'package:atiora/features/profile/presentation/screens/profile_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class MainNavPage extends StatefulWidget {
  const MainNavPage({super.key});

  @override
  MainNavPageState createState() => MainNavPageState();
}

class MainNavPageState extends State<MainNavPage> {
  int _currentIndex = 0;
  late final StatsBloc _statsBloc;
  late final List<Widget> _screens;

  @override
  void initState() {
    super.initState();
    _statsBloc = sl<StatsBloc>();
    _screens = [
      const HomeScreen(),
      const LibraryScreen(),
      BlocProvider.value(value: _statsBloc, child: const StatsScreen()),
      const ProfileScreen(),
    ];
  }

  @override
  void dispose() {
    _statsBloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _currentIndex, children: _screens),
      bottomNavigationBar: NavigationBar(
        height: 72,
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) => setState(() => _currentIndex = index),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home_rounded),
            label: 'Inicio',
          ),
          NavigationDestination(
            icon: Icon(Icons.library_books_outlined),
            selectedIcon: Icon(Icons.library_books_rounded),
            label: 'Biblioteca',
          ),
          NavigationDestination(
            icon: Icon(Icons.bar_chart_outlined),
            selectedIcon: Icon(Icons.bar_chart_rounded),
            label: 'Estadísticas',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person),
            label: 'Perfil',
          ),
        ],
      ),
    );
  }
}
