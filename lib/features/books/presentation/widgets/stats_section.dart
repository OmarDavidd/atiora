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
    final currentPage = book.status.toLowerCase() == 'completado'
        ? totalPages
        : book.currentPage;
    final percentage = AppHelpers.calcPercentage(totalPages, currentPage);
    final canRate = book.status.toLowerCase() == 'completado';

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isCompact = constraints.maxWidth < 360;
          final cardHeight = isCompact ? 136.0 : 156.0;
          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: SizedBox(
                  height: cardHeight,
                  child: _ProgressCard(
                    percentage: percentage,
                    currentPage: currentPage,
                    totalPages: totalPages,
                    compact: isCompact,
                  ),
                ),
              ),
              SizedBox(width: isCompact ? 10 : 16),
              Expanded(
                child: SizedBox(
                  height: cardHeight,
                  child: _RatingCard(
                    canRate: canRate,
                    rating: book.rating,
                    compact: isCompact,
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _ProgressCard extends StatelessWidget {
  final String percentage;
  final int currentPage;
  final int totalPages;
  final bool compact;

  const _ProgressCard({
    required this.percentage,
    required this.currentPage,
    required this.totalPages,
    required this.compact,
  });

  @override
  Widget build(BuildContext context) {
    return CustomStatCard(
      title: "PÁGINAS LEÍDAS",
      subtitle: percentage,
      height: compact ? 60 : 72,
      widget: CustomProgressBarWidget(
        currentPage: currentPage,
        totalPages: totalPages,
        hintPercentage: true,
      ),
    );
  }
}

class _RatingCard extends StatelessWidget {
  final bool canRate;
  final double rating;
  final bool compact;

  const _RatingCard({
    required this.canRate,
    required this.rating,
    required this.compact,
  });

  @override
  Widget build(BuildContext context) {
    return CustomStatCard(
      title: "CALIFICACIÓN",
      subtitle: canRate ? rating.toStringAsFixed(1) : 'Completa el libro',
      emphasizeSubtitle: !canRate,
      height: compact ? 60 : 72,
      widget: IgnorePointer(
        ignoring: !canRate,
        child: Opacity(
          opacity: canRate ? 1 : 0.4,
          child: CustomRatingWidget(rating: rating, size: compact ? 16 : 18),
        ),
      ),
    );
  }
}
