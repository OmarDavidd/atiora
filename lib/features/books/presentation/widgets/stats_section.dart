import 'package:atiora/core/utils/helpers.dart';
import 'package:atiora/data/models/book_model.dart';
import 'package:atiora/features/books/presentation/widgets/custom_progress_bar_widget.dart';
import 'package:atiora/features/books/presentation/widgets/custom_rating_widget.dart';
import 'package:atiora/features/books/presentation/widgets/custom_stat_card.dart';
import 'package:flutter/material.dart';

class StatsSection extends StatelessWidget {
  final BookModel book;
  const StatsSection({super.key, required this.book});
  @override
  Widget build(BuildContext context) {
    final totalPages = book.totalPages;
    final currentPage = book.currentPage;
    final percentage = AppHelpers.calcPercentage(
      totalPages,
      currentPage,
    );
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          Expanded(
            child: CustomStatCard(
              title: "PÁGINAS LEIDAS",
              subtitle: percentage,
              widget: CustomProgressBarWidget(
                currentPage: currentPage,
                totalPages: totalPages,
              ),
            ),
          ),
          SizedBox(width: 12),
          Expanded(
            child: CustomStatCard(
              title: "CALIFICACION",
              subtitle: book.rating.toString(),
              widget: CustomRatingWidget(rating: book.rating),
            ),
          ),
        ],
      ),
    );
  }
}
