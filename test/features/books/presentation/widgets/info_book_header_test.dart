import 'package:atiora/data/models/book_model.dart';
import 'package:atiora/features/books/presentation/widgets/info_book_header.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final book = BookModel(
    id: '1',
    userId: 'user',
    title: 'Clean Code',
    author: 'Robert Martin',
    genre: const ['Programación'],
    totalPages: 400,
    currentPage: 120,
    status: 'Leyendo',
    rating: 4.5,
    createdAt: DateTime(2024, 1, 1),
    updatedAt: DateTime(2024, 1, 2),
  );

  testWidgets('InfoBookHeader renders title and genres', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: InfoBookHeader(
            currentStatus: 'Leyendo',
            book: book,
            onStateTap: () {},
          ),
        ),
      ),
    );

    expect(find.text('Clean Code'), findsOneWidget);
    expect(find.text('Programación'), findsOneWidget);
  });
}
