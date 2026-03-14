import 'package:flutter/material.dart';

class BookCard extends StatelessWidget {
  final String title;
  final String author;
  final String coverPath;
  final VoidCallback? onTap;
  final bool isPendingSync;

  const BookCard({
    super.key,
    required this.title,
    required this.author,
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
        margin: EdgeInsets.symmetric(horizontal: 8),
        child: Stack(
          children: [
            Card(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Portada del libro
                  Expanded(
                    flex: 3,
                    child: ClipRRect(
                      borderRadius: BorderRadius.vertical(
                        top: Radius.circular(12),
                      ),
                      child: Container(
                        height: 200,
                        width: double.infinity,
                        color: Theme.of(
                          context,
                        ).colorScheme.surfaceContainerHighest,
                        child: Image.asset(
                          coverPath,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) => Icon(
                            Icons.book,
                            size: 60,
                            color: Theme.of(context).colorScheme.outline,
                          ),
                        ),
                      ),
                    ),
                  ),
                  // Info del libro
                  Padding(
                    padding: EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        SizedBox(height: 4),
                        Text(
                          author,
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            if (isPendingSync)
              Positioned(
                top: 12,
                right: 12,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.secondaryContainer,
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    'Sin conexión',
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
