import 'package:atiora/core/navigation/app_router.dart';
import 'package:atiora/core/utils/app_colors.dart';
import 'package:atiora/features/books/presentation/bloc/books_bloc.dart';
import 'package:atiora/features/books/presentation/bloc/books_event.dart';
import 'package:atiora/features/books/presentation/bloc/books_state.dart';
import 'package:atiora/features/dashboards/presentation/widgets/book_card.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';

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
        Text(
          "Leyendo ahora",
          style: GoogleFonts.inter(
            fontSize: 20,
            fontWeight: FontWeight.w400,
            color: AppColors.neutral0,
          ),
        ),
        const SizedBox(height: 20),
        BlocBuilder<BooksBloc, BooksState>(
          builder: (context, state) {
            if (state is BooksLoading) {
              return CircularProgressIndicator();
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
                        color: AppColors.neutral400,
                      ),
                      SizedBox(height: 12),
                      Text(
                        "No tienes libros aún",
                        style: GoogleFonts.inter(
                          fontSize: 16,
                          color: AppColors.neutral400,
                        ),
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
                          Navigator.of(
                            context,
                          ).pushNamed(AppRouter.bookDetail, arguments: book);
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
