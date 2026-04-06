import 'package:flutter/material.dart';

class InfoBookCover extends StatelessWidget {
  final String? coverUrl;

  const InfoBookCover({super.key, this.coverUrl});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: SizedBox(
        width: 180,
        height: 270,
        child: ClipRRect(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
          child: Container(
            color: theme.colorScheme.surfaceContainerHighest,
            child: _buildCoverImage(theme),
          ),
        ),
      ),
    );
  }

  Widget _buildCoverImage(ThemeData theme) {
    if (coverUrl != null && coverUrl!.isNotEmpty) {
      return Image.network(
        coverUrl!,
        fit: BoxFit.cover,
        cacheWidth: 360,
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return Center(
            child: SizedBox(
              width: 30,
              height: 30,
              child: CircularProgressIndicator(
                value: loadingProgress.expectedTotalBytes != null
                    ? loadingProgress.cumulativeBytesLoaded /
                          loadingProgress.expectedTotalBytes!
                    : null,
                strokeWidth: 2,
              ),
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
      'assets/missingbook.webp',
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) =>
          Icon(Icons.book, size: 80, color: theme.colorScheme.outline),
    );
  }
}
