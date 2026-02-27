import 'package:atiora/data/models/book_model.dart';
import 'package:atiora/features/books/presentation/widgets/info_book_section.dart';
import 'package:atiora/features/books/presentation/widgets/stats_section.dart';
import 'package:flutter/material.dart';

class BookDetailScreen extends StatelessWidget {
  final BookModel book;

  const BookDetailScreen({super.key, required this.book});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Detalles del libro")),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              InfoBookSection(book: book),
              SizedBox(height: 20),
              StatsSection(book: book),
              //NotesSection()
            ],
          ),
        ),
      ),
    );
  }
}
