import 'package:atiora/core/di/injection_container.dart';
import 'package:atiora/features/books/presentation/bloc/books_bloc.dart';
import 'package:atiora/features/books/presentation/bloc/books_state.dart';
import 'package:atiora/features/books/presentation/bloc/notes_bloc.dart';
import 'package:atiora/features/books/presentation/bloc/notes_state.dart';
import 'package:atiora/features/dashboards/presentation/bloc/home_stats_bloc.dart';
import 'package:atiora/features/dashboards/presentation/bloc/home_stats_event.dart';
import 'package:atiora/features/dashboards/presentation/bloc/stats_bloc.dart';
import 'package:atiora/features/dashboards/presentation/bloc/stats_event.dart';
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
  late final BooksBloc _booksBloc;
  late final StatsBloc _statsBloc;
  late final HomeStatsBloc _homeStatsBloc;
  late final NotesBloc _notesBloc;
  late final List<Widget> _screens;

  void setTab(int index) {
    setState(() => _currentIndex = index);
  }

  @override
  void initState() {
    super.initState();
    _booksBloc = sl<BooksBloc>();
    _statsBloc = sl<StatsBloc>();
    _homeStatsBloc = sl<HomeStatsBloc>();
    _notesBloc = sl<NotesBloc>();
    final homeScreen = BlocProvider<BooksBloc>.value(
      value: _booksBloc,
      child: BlocProvider<HomeStatsBloc>.value(
        value: _homeStatsBloc,
        child: BlocProvider<StatsBloc>.value(
          value: _statsBloc,
          child: BlocProvider<NotesBloc>.value(
            value: _notesBloc,
            child: const HomeScreen(),
          ),
        ),
      ),
    );
    final libraryScreen = BlocProvider<BooksBloc>.value(
      value: _booksBloc,
      child: const LibraryScreen(),
    );
    _screens = [
      homeScreen,
      libraryScreen,
      BlocProvider.value(value: _statsBloc, child: const StatsScreen()),
      const ProfileScreen(),
    ];
  }

  @override
  void dispose() {
    _booksBloc.close();
    _statsBloc.close();
    _homeStatsBloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<BooksBloc>.value(value: _booksBloc),
        BlocProvider<NotesBloc>.value(value: _notesBloc),
      ],
      child: MultiBlocListener(
        listeners: [
          BlocListener<BooksBloc, BooksState>(
            listener: (context, state) {
              if (state is BooksLoaded ||
                  state is BookUpdateSuccess ||
                  state is BookStateUpdateSuccess ||
                  state is BookDeleteSuccess) {
                _homeStatsBloc.add(LoadHomeStats());
                _statsBloc.add(RefreshStats());
              }
            },
          ),
          BlocListener<NotesBloc, NotesState>(
            listener: (context, state) {
              debugPrint('📝 NotesBloc state: $state');
              if (state is NoteAddSuccess || state is NoteDeleteSuccess) {
                _homeStatsBloc.add(LoadHomeStats());
              }
            },
          ),
        ],
        child: Scaffold(
          body: IndexedStack(index: _currentIndex, children: _screens),
          bottomNavigationBar: NavigationBar(
            height: 72,
            selectedIndex: _currentIndex,
            onDestinationSelected: (index) =>
                setState(() => _currentIndex = index),
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
        ),
      ),
    );
  }
}
