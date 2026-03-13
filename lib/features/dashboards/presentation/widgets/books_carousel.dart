import 'package:atiora/core/navigation/app_router.dart';
import 'package:atiora/features/books/presentation/bloc/books_bloc.dart';
import 'package:atiora/features/books/presentation/bloc/books_event.dart';
import 'package:atiora/features/books/presentation/bloc/books_state.dart';
import 'package:atiora/features/dashboards/presentation/widgets/book_card.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class BooksCarousel extends StatefulWidget {
  const BooksCarousel({super.key});

  @override
  State<BooksCarousel> createState() => _BooksCarouselState();
}

class _BooksCarouselState extends State<BooksCarousel> {
  @override
  void initState() {
    super.initState();
    context.read<BooksBloc>().add(LoadBooks());
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            "LEYENDO AHORA",
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w900,
              color: Theme.of(context).colorScheme.primary,
              letterSpacing: 0.5,
            ),
          ),
        ),
        const SizedBox(height: 20),
        BlocBuilder<BooksBloc, BooksState>(
          builder: (context, state) {
            if (state is BooksLoading) {
              return const Center(child: CircularProgressIndicator());
            }
            if (state is BooksLoaded) {
              final books = state.books;

              if (books.isEmpty) {
                return Center(
                  child: Column(
                    children: [
                      Icon(
                        Icons.book_outlined,
                        size: 60,
                        color: Theme.of(context).colorScheme.outline,
                      ),
                      SizedBox(height: 12),
                      Text(
                        "No tienes libros aún",
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                  ),
                );
              }
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CarouselSlider.builder(
                    itemCount: books.length,
                    itemBuilder: (context, index, realIndex) {
                      final book = books[index];
                      return GestureDetector(
                        onTap: () {
                          Navigator.of(context).pushNamed(
                            AppRouter.bookDetail,
                            arguments: {
                              'bookId': book.id,
                              'booksBloc': context.read<BooksBloc>(),
                            },
                          );
                        },
                        child: BookCard(
                          title: book.title,
                          author: book.author ?? "",
                          coverPath: 'assets/missingbook.webp',
                        ),
                      );
                    },
                    options: CarouselOptions(
                      height: 300,
                      autoPlay: false,
                      autoPlayInterval: Duration(seconds: 4),
                      enlargeCenterPage: true,
                      aspectRatio: 16 / 9,
                      viewportFraction: 0.55,
                      clipBehavior: Clip.hardEdge,
                    ),
                  ),
                ],
              );
            }
            if (state is BooksError) {
              return Text("Error");
            }
            return const SizedBox.shrink();
          },
        ),
      ],
    );
  }
}
