import 'dart:async';

import 'package:connectivity_plus_platform_interface/connectivity_plus_platform_interface.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:atiora/core/di/injection_container.dart';
import 'package:atiora/core/theme/theme_cubit.dart';
import 'package:atiora/features/books/domain/repositories/book_repository.dart';
import 'package:atiora/features/books/domain/repositories/notes_repository.dart';
import 'package:atiora/features/books/presentation/bloc/books_bloc.dart';
import 'package:atiora/features/books/presentation/bloc/books_event.dart';
import 'package:atiora/features/books/presentation/widgets/add_book_modal.dart';
import 'package:atiora/features/dashboards/presentation/bloc/home_stats_bloc.dart';
import 'package:atiora/features/dashboards/presentation/bloc/home_stats_event.dart';
import 'package:atiora/features/dashboards/presentation/bloc/home_stats_state.dart';
import 'package:atiora/features/dashboards/presentation/widgets/books_carousel.dart';
import 'package:atiora/features/dashboards/presentation/widgets/home_stats_section.dart';
import 'package:atiora/features/dashboards/presentation/widgets/recent_notes_section.dart';
import 'package:atiora/data/models/note_model.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late final BooksBloc _booksBloc;
  final HomeStatsBloc _homeStatsBloc = sl<HomeStatsBloc>();
  late final Stream<List<ConnectivityResult>> _connectivityStream;
  late final ConnectivityPlatform _connectivity;
  StreamSubscription<List<ConnectivityResult>>? _connectivitySubscription;
  List<NoteModel> _recentNotes = [];
  bool _notesLoading = true;

  @override
  void initState() {
    super.initState();
    _booksBloc = sl<BooksBloc>();
    _connectivity = sl<ConnectivityPlatform>();
    _connectivityStream = _connectivity.onConnectivityChanged;
    _connectivitySubscription = _connectivityStream.listen((results) {
      final hasConnection = results.any(
        (result) => result != ConnectivityResult.none,
      );
      if (hasConnection) {
        _booksBloc.add(SyncPendingOperations());
        _loadRecentNotes();
      }
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _booksBloc.add(LoadBooks());
      _homeStatsBloc.add(LoadHomeStats());
      _loadRecentNotes();
    });
  }

  Future<void> _loadRecentNotes() async {
    setState(() => _notesLoading = true);
    try {
      final repository = sl<NotesRepository>();
      final notes = await repository.getRecentNotes(limit: 5);
      if (mounted) {
        setState(() {
          _recentNotes = notes;
          _notesLoading = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() => _notesLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeMode = context.watch<ThemeCubit>().state;
    final isDark = themeMode == ThemeMode.dark;
    return MultiBlocProvider(
      providers: [
        BlocProvider.value(value: _booksBloc),
        BlocProvider.value(value: _homeStatsBloc),
      ],
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          title: Text(
            "Atiora",
            style: Theme.of(context).textTheme.headlineLarge,
          ),
          actions: [
            IconButton(
              tooltip: 'Cambiar tema',
              icon: Icon(
                isDark ? Icons.wb_sunny_outlined : Icons.nightlight_round,
              ),
              onPressed: () => context.read<ThemeCubit>().toggleTheme(),
            ),
          ],
        ),
        body: BlocListener<HomeStatsBloc, HomeStatsState>(
          listener: (context, state) {
            if (state is HomeStatsError) {
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(SnackBar(content: Text(state.message)));
            }
          },
          child: RefreshIndicator(
            onRefresh: () async {
              _booksBloc.add(LoadBooks());
              _homeStatsBloc.add(LoadHomeStats());
            },
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 30,
                  vertical: 24,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    BooksCarousel(),
                    const SizedBox(height: 30),
                    BlocBuilder<HomeStatsBloc, HomeStatsState>(
                      builder: (context, state) {
                        final stats = state is HomeStatsLoaded
                            ? state.stats
                            : null;

                        return HomeStatsSection(
                          totalBooksRead: stats?.booksMonth.toString() ?? '0',
                          pagesThisMonth: stats?.pagesMonth.toString() ?? '0',
                          streakDays: stats?.streak.toString() ?? '0',
                          averageRating:
                              stats?.averageRating.toStringAsFixed(1) ?? '0.0',
                          isLoading: state is HomeStatsLoading,
                        );
                      },
                    ),
                    const SizedBox(height: 30),
                    RecentNotesSection(
                      notes: _recentNotes,
                      isLoading: _notesLoading,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        floatingActionButton: FloatingActionButton.extended(
          heroTag: 'home-add-book-fab',
          onPressed: () => _showAddBookModal(context),
          icon: const Icon(Icons.add),
          label: const Text("Añadir libro"),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _booksBloc.close();
    _connectivitySubscription?.cancel();
    super.dispose();
  }

  Future<void> _showAddBookModal(BuildContext context) async {
    final repository = sl<BooksRepository>();
    final result = await showDialog(
      context: context,
      builder: (_) => Dialog(
        insetPadding: const EdgeInsets.all(20),
        child: AddBookModal(repository: repository, booksBloc: _booksBloc),
      ),
    );

    if (result != null) {
      _booksBloc.add(LoadBooks());
    }
  }
}
