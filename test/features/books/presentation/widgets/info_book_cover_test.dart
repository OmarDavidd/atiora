import 'package:atiora/features/books/presentation/widgets/info_book_cover.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('InfoBookCover renders fallback image', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(home: Scaffold(body: InfoBookCover())),
    );

    expect(find.byType(Image), findsOneWidget);
  });
}
