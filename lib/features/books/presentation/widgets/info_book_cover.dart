import 'package:flutter/material.dart';

class InfoBookCover extends StatelessWidget {
  const InfoBookCover({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox(
        height: 260,
        child: ClipRRect(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
          child: Container(
            color: Theme.of(context).colorScheme.surfaceContainerHighest,
            child: Image.asset(
              'assets/missingbook.webp',
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => Icon(
                Icons.book,
                size: 80,
                color: Theme.of(context).colorScheme.outline,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
