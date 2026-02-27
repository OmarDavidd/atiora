import 'package:atiora/core/di/injection_container.dart';
import 'package:atiora/core/utils/app_colors.dart';
import 'package:atiora/features/books/domain/repositories/book_repository.dart';
import 'package:atiora/features/books/presentation/bloc/books_bloc.dart';
import 'package:atiora/features/books/presentation/bloc/books_event.dart';
import 'package:atiora/features/books/presentation/widgets/add_book_modal.dart';
import 'package:atiora/features/dashboards/presentation/widgets/books_carousel.dart';
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

  @override
  void dispose() {
    _booksBloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
      body: BlocProvider.value(
        value: _booksBloc,
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 24),
            child: Column(children: [BooksCarousel()]),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddBookModal(context),
        icon: Icon(Icons.add),
        label: Text("Añadir libro"),
      ),
    );
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
