import 'package:atiora/core/di/injection_container.dart';
import 'package:atiora/core/utils/app_colors.dart';
import 'package:atiora/features/books/domain/repositories/book_repository.dart';
import 'package:atiora/features/books/presentation/bloc/books_bloc.dart';
import 'package:atiora/features/books/presentation/bloc/books_event.dart';
import 'package:atiora/features/books/presentation/widgets/add_book_modal.dart';
import 'package:atiora/features/dashboards/presentation/bloc/home_stats_bloc.dart';
import 'package:atiora/features/dashboards/presentation/bloc/home_stats_event.dart';
import 'package:atiora/features/dashboards/presentation/bloc/home_stats_state.dart';
import 'package:atiora/features/dashboards/presentation/widgets/books_carousel.dart';
import 'package:atiora/features/dashboards/presentation/widgets/home_stats_section.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final BooksBloc _booksBloc = sl<BooksBloc>();
  final HomeStatsBloc _homeStatsBloc = sl<HomeStatsBloc>();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _booksBloc.add(LoadBooks());
      _homeStatsBloc.add(LoadHomeStats());
    });
  }

  @override
  Widget build(BuildContext context) {
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
            style: GoogleFonts.jaini(
              fontSize: 30,
              fontWeight: FontWeight.w300,
              color: AppColors.neutral0,
              letterSpacing: 6,
              height: 1.0,
            ),
          ),
        ),
        body: BlocListener<HomeStatsBloc, HomeStatsState>(
          listener: (context, state) {
            if (state is HomeStatsError) {
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(SnackBar(content: Text(state.message)));
            }
          },
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  BooksCarousel(),
                  SizedBox(height: 30),
                  BlocBuilder<HomeStatsBloc, HomeStatsState>(
                    builder: (context, state) {
                      final stats = state is HomeStatsLoaded ? state.stats : null;

                      return HomeStatsSection(
                        totalBooksRead: stats?.booksMonth.toString() ?? '0',
                        totalPagesRead: stats?.pagesMonth.toString() ?? '0',
                        streak: stats?.streak.toString() ?? '0',
                        average: '4.2', // TODO: hacerlo dinamico
                      );
                    },
                  ),

                ],
              ),
            ),
          ),
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () => _showAddBookModal(context),
          icon: Icon(Icons.add),
          label: Text("Añadir libro"),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _booksBloc.close();
    super.dispose();
  }

  Future<void> _showAddBookModal(BuildContext context) async {
    final repository = sl<BooksRepository>();
    final result = await showDialog(
      context: context,
      builder: (_) => Dialog(
        insetPadding: const EdgeInsets.all(20),
        child: AddBookModal(repository: repository),
      ),
    );

    if (result != null) {
      _booksBloc.add(LoadBooks());
    }
  }
}
