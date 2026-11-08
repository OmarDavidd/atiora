import 'package:atiora/core/utils/helpers.dart';
import 'package:atiora/data/models/book_model.dart';
import 'package:atiora/features/books/presentation/widgets/custom_progress_bar_widget.dart';
import 'package:atiora/features/books/presentation/widgets/custom_rating_widget.dart';
import 'package:atiora/features/books/presentation/widgets/custom_stat_card.dart';
import 'package:flutter/material.dart';

class StatsSection extends StatelessWidget {
  final BookModel book;
  final void Function(BookModel book)? onProgressTap;
  final void Function(BookModel book)? onRatingTap;

  const StatsSection({
    super.key,
    required this.book,
    this.onProgressTap,
    this.onRatingTap,
  });

  @override
  Widget build(BuildContext context) {
    final totalPages = book.totalPages;
    final normalizedStatus = book.status.toLowerCase().trim();
    final isCompleted = normalizedStatus == 'completado';
    final currentPage = isCompleted ? totalPages : book.currentPage;
    final percentage = AppHelpers.calcPercentage(totalPages, currentPage);
    final isReading = normalizedStatus == 'leyendo';
    final hasPendingSync = book.pendingSync;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isCompact = constraints.maxWidth < 360;
          final cardHeight = isCompact ? 136.0 : 156.0;
          return Column(
            children: [
              if (hasPendingSync)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: _PendingSyncBanner(),
                ),
              Row(
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
                        book: book,
                        isReading: isReading,
                        isCompleted: isCompleted,
                        onTap: onProgressTap == null
                            ? null
                            : () => onProgressTap!.call(book),
                      ),
                    ),
                  ),
                  SizedBox(width: isCompact ? 10 : 16),
                  Expanded(
                    child: SizedBox(
                      height: cardHeight,
                      child: _RatingCard(
                        canRate: isCompleted,
                        rating: book.rating,
                        compact: isCompact,
                        book: book,
                        isCompleted: isCompleted,
                        onTap: onRatingTap == null
                            ? null
                            : () => onRatingTap!.call(book),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );
  }
}

class _PendingSyncBanner extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: theme.colorScheme.secondaryContainer.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(Icons.sync_problem_rounded, color: theme.colorScheme.secondary),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Cambios pendientes por sincronizar.',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSecondaryContainer,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ProgressCard extends StatelessWidget {
  final String percentage;
  final int currentPage;
  final int totalPages;
  final bool compact;
  final BookModel book;
  final bool isReading;
  final bool isCompleted;
  final VoidCallback? onTap;

  const _ProgressCard({
    required this.percentage,
    required this.currentPage,
    required this.totalPages,
    required this.compact,
    required this.book,
    required this.isReading,
    required this.isCompleted,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return CustomStatCard(
      title: "PÁGINAS LEÍDAS",
      subtitle: percentage,
      height: compact ? 60 : 72,
      onTap: onTap,
      widget: CustomProgressBarWidget(
        currentPage: currentPage,
        totalPages: totalPages,
        hintPercentage: true,
        onTap: onTap,
      ),
    );
  }
}

class _RatingCard extends StatelessWidget {
  final bool canRate;
  final double rating;
  final bool compact;
  final BookModel book;
  final bool isCompleted;
  final VoidCallback? onTap;

  const _RatingCard({
    required this.canRate,
    required this.rating,
    required this.compact,
    required this.book,
    required this.isCompleted,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return CustomStatCard(
      title: "CALIFICACIÓN",
      subtitle: canRate ? rating.toStringAsFixed(1) : 'Completa el libro',
      emphasizeSubtitle: !canRate,
      height: compact ? 60 : 72,
      onTap: canRate ? onTap : null,
      widget: IgnorePointer(
        ignoring: !canRate,
        child: Opacity(
          opacity: canRate ? 1 : 0.4,
          child: CustomRatingWidget(
            rating: rating,
            size: compact ? 16 : 18,
            onTap: onTap,
          ),
        ),
      ),
    );
  }
}
