import 'package:atiora/features/books/presentation/bloc/books_bloc.dart';
import 'package:atiora/features/books/presentation/bloc/books_state.dart';
import 'package:atiora/features/books/presentation/widgets/info_book_section.dart';
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
                    StatsSection(book: book),
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
