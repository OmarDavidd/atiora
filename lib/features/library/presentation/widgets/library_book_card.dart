import 'package:atiora/core/utils/helpers.dart';
import 'package:atiora/data/models/book_model.dart';
import 'package:flutter/material.dart';

class LibraryBookCard extends StatelessWidget {
  final BookModel book;
  final VoidCallback onTap;

  const LibraryBookCard({super.key, required this.book, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final progress = AppHelpers.calculateProgress(
      book.currentPage,
      book.totalPages,
    );
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        decoration: BoxDecoration(
          color: colors.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: colors.outline.withValues(alpha: 0.08)),
          boxShadow: [
            BoxShadow(
              color: colors.shadow.withValues(alpha: 0.04),
              blurRadius: 20,
              offset: const Offset(0, 14),
            ),
          ],
        ),
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _Cover(coverUrl: book.coverUrl),
                const SizedBox(width: 16),
                Expanded(child: _BookInfo(book: book)),
                _StatusBadge(status: book.status),
              ],
            ),
            const SizedBox(height: 16),
            _ProgressIndicator(progress: progress, book: book),
          ],
        ),
      ),
    );
  }
}

class _Cover extends StatelessWidget {
  final String? coverUrl;

  const _Cover({this.coverUrl});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 120,
      width: 90,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        image: DecorationImage(
          image: coverUrl != null
              ? NetworkImage(coverUrl!)
              : const AssetImage('assets/missingbook.webp') as ImageProvider,
          fit: BoxFit.cover,
          colorFilter: coverUrl == null
              ? ColorFilter.mode(
                  Theme.of(context).colorScheme.outlineVariant,
                  BlendMode.modulate,
                )
              : null,
        ),
      ),
    );
  }
}

class _BookInfo extends StatelessWidget {
  final BookModel book;

  const _BookInfo({required this.book});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          book.title,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 4),
        Text(
          book.author ?? 'Autor desconocido',
          style: textTheme.bodyMedium?.copyWith(
            color: textTheme.bodySmall?.color ?? Colors.grey,
          ),
        ),
      ],
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final String status;

  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    final color = AppHelpers.getStatusColor(status);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(999),
        color: color.withValues(alpha: 0.15),
      ),
      child: Text(
        status.toUpperCase(),
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
          fontWeight: FontWeight.w700,
          color: color,
        ),
      ),
    );
  }
}

class _ProgressIndicator extends StatelessWidget {
  final double progress;
  final BookModel book;

  const _ProgressIndicator({required this.progress, required this.book});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final progressPercent = (progress * 100).clamp(0, 100).toStringAsFixed(0);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Progreso de lectura',
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: colors.primary,
              ),
            ),
            Text(
              '$progressPercent%',
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: colors.primary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(999),
          child: LinearProgressIndicator(
            value: progress,
            minHeight: 6,
            backgroundColor: colors.surfaceContainerHighest,
            valueColor: AlwaysStoppedAnimation<Color>(colors.primary),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          'Pág ${book.currentPage} de ${book.totalPages}',
          style: Theme.of(
            context,
          ).textTheme.labelSmall?.copyWith(color: colors.outline),
        ),
      ],
    );
  }
}
