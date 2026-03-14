import 'package:atiora/data/models/book_model.dart';
import 'package:atiora/features/books/presentation/bloc/books_bloc.dart';
import 'package:atiora/features/books/presentation/bloc/books_event.dart';
import 'package:atiora/features/books/presentation/bloc/books_state.dart';
import 'package:atiora/features/books/presentation/widgets/info_book_section.dart';
import 'package:atiora/features/books/presentation/widgets/progress_input_dialog.dart';
import 'package:atiora/features/books/presentation/widgets/rating_input_dialog.dart';
import 'package:atiora/features/books/presentation/widgets/stats_section.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class BookDetailScreen extends StatelessWidget {
  final String bookId;

  const BookDetailScreen({super.key, required this.bookId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Detalles del libro")),
      body: BlocBuilder<BooksBloc, BooksState>(
        builder: (context, state) {
          if (state is BooksLoaded) {
            if (state.books.isEmpty) {
              return const Center(child: Text('Libro no encontrado'));
            }

            final bookIndex = state.books.indexWhere((b) => b.id == bookId);
            final book = bookIndex != -1 ? state.books[bookIndex] : null;

            if (book == null) {
              return const Center(child: Text('Libro no encontrado'));
            }

            return SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 30,
                  vertical: 20,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    InfoBookSection(book: book),
                    const SizedBox(height: 20),
                    StatsSection(
                      book: book,
                      onProgressTap: (b) => _onProgressTap(context, b),
                      onRatingTap: (b) => _onRatingTap(context, b),
                    ),
                  ],
                ),
              ),
            );
          } else if (state is BooksLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is BooksError) {
            return Center(child: Text(state.message));
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }
}

void _onProgressTap(BuildContext context, BookModel book) {
  final bloc = context.read<BooksBloc>();
  showDialog<int>(
    context: context,
    barrierDismissible: false,
    builder: (_) => ProgressInputDialog(
      initialPage: book.currentPage,
      totalPages: book.totalPages,
    ),
  ).then((value) {
    if (value == null) return;
    final normalizedStatus = book.status.toLowerCase().trim();
    final newStatus = value >= book.totalPages
        ? 'Completado'
        : (value > 0 || normalizedStatus == 'leyendo'
              ? 'Leyendo'
              : 'Pendiente');
    bloc.add(
      UpdateBookState(
        bookId: book.id,
        newState: newStatus,
        updatedPage: value.clamp(0, book.totalPages),
        finishedAt: newStatus.toLowerCase() == 'completado'
            ? DateTime.now()
            : null,
        clearFinishedAt: newStatus.toLowerCase() != 'completado',
      ),
    );
    final delta = value - book.currentPage;
    if (delta != 0) {
      bloc.add(LogReadingSession(bookId: book.id, pagesDelta: delta));
    }
  });
}

void _onRatingTap(BuildContext context, BookModel book) {
  if (book.status.toLowerCase() != 'completado') {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Completa el libro para calificar.')),
    );
    return;
  }
  final bloc = context.read<BooksBloc>();
  showDialog<double>(
    context: context,
    barrierDismissible: false,
    builder: (_) => RatingInputDialog(initialValue: book.rating),
  ).then((value) {
    if (value == null) return;
    bloc.add(
      UpdateBookState(bookId: book.id, newState: book.status, rating: value),
    );
  });
}
