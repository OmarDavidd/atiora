import 'package:flutter/material.dart';

class CustomProgressBarWidget extends StatelessWidget {
  final String? status;
  final int totalPages;
  final int currentPage;
  final bool? hintPercentage;
  final VoidCallback? onTap;

  const CustomProgressBarWidget({
    super.key,
    this.status,
    required this.totalPages,
    required this.currentPage,
    this.hintPercentage,
    this.onTap,
  });

  double get progress =>
      totalPages == 0 ? 0 : (currentPage / totalPages).clamp(0.0, 1.0);

  String get percentage => '${(progress * 100).toStringAsFixed(0)}%';

  @override
  Widget build(BuildContext context) {
    final content = Container(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (hintPercentage == true)
            Text(
              percentage,
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          const SizedBox(height: 2),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(value: progress, minHeight: 6),
          ),
          const SizedBox(height: 2),
          Text(
            "Página $currentPage/$totalPages",
            style: Theme.of(
              context,
            ).textTheme.labelSmall?.copyWith(fontSize: 11, letterSpacing: 0.25),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );

    if (onTap == null) return content;

    return InkWell(
      borderRadius: BorderRadius.circular(10),
      onTap: onTap,
      child: content,
    );
  }
}
