import 'package:flutter/material.dart';

class BookCard extends StatelessWidget {
  final String title;
  final String author;
  final String? coverUrl;
  final String coverPath;
  final VoidCallback? onTap;
  final bool isPendingSync;

  const BookCard({
    super.key,
    required this.title,
    required this.author,
    this.coverUrl,
    required this.coverPath,
    this.onTap,
    this.isPendingSync = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 180,
        margin: const EdgeInsets.symmetric(horizontal: 8),
        child: _BookCardContent(
          title: title,
          author: author,
          coverUrl: coverUrl,
          coverPath: coverPath,
          isPendingSync: isPendingSync,
        ),
      ),
    );
  }
}

class _BookCardContent extends StatelessWidget {
  final String title;
  final String author;
  final String? coverUrl;
  final String coverPath;
  final bool isPendingSync;

  const _BookCardContent({
    required this.title,
    required this.author,
    this.coverUrl,
    required this.coverPath,
    required this.isPendingSync,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Stack(
      children: [
        Card(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 3,
                child: ClipRRect(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(12),
                  ),
                  child: Container(
                    height: 200,
                    width: double.infinity,
                    color: theme.colorScheme.surfaceContainerHighest,
                    child: _buildCoverImage(theme),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: theme.textTheme.titleMedium),
                    const SizedBox(height: 4),
                    Text(author, style: theme.textTheme.bodySmall),
                  ],
                ),
              ),
            ],
          ),
        ),
        if (isPendingSync)
          const Positioned(top: 12, right: 12, child: _SyncBadge()),
      ],
    );
  }

  Widget _buildCoverImage(ThemeData theme) {
    if (coverUrl != null && coverUrl!.isNotEmpty) {
      return Image.network(
        coverUrl!,
        fit: BoxFit.cover,
        width: double.infinity,
        cacheWidth: 360,
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return Center(
            child: CircularProgressIndicator(
              value: loadingProgress.expectedTotalBytes != null
                  ? loadingProgress.cumulativeBytesLoaded /
                        loadingProgress.expectedTotalBytes!
                  : null,
              strokeWidth: 2,
            ),
          );
        },
        errorBuilder: (context, error, stackTrace) => _buildPlaceholder(theme),
      );
    }
    return _buildPlaceholder(theme);
  }

  Widget _buildPlaceholder(ThemeData theme) {
    return Image.asset(
      coverPath,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) =>
          Icon(Icons.book, size: 60, color: theme.colorScheme.outline),
    );
  }
}

class _SyncBadge extends StatelessWidget {
  const _SyncBadge();

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: colors.secondaryContainer,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.cloud_off, size: 14, color: colors.onSecondaryContainer),
          const SizedBox(width: 4),
          Text(
            'En cola',
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: colors.onSecondaryContainer,
            ),
          ),
        ],
      ),
    );
  }
}
