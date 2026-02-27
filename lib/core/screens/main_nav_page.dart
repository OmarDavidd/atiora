import 'package:atiora/features/dashboards/presentation/screens/home_screen.dart';
import 'package:flutter/material.dart';

class MainNavPage extends StatefulWidget {
  const MainNavPage({super.key});

  @override
  MainNavPageState createState() => MainNavPageState();
}

class MainNavPageState extends State<MainNavPage> {
  int _currentIndex = 0;

  // Una pantalla real por tab — las otras son placeholders por ahora
  final List<Widget> _screens = const [
    HomeScreen(),
    Scaffold(body: Center(child: Text("Search"))),
    Scaffold(body: Center(child: Text("Perfil"))),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _currentIndex, children: _screens),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.search), label: 'Search'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Perfil'),
        ],
        type: BottomNavigationBarType.fixed,
      ),
    );
  }
}
