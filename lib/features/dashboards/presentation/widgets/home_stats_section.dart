import 'package:atiora/features/books/presentation/widgets/custom_stat_card.dart';
import 'package:flutter/material.dart';

class HomeStatsSection extends StatelessWidget {
  final String totalBooksRead;
  final String totalPagesRead;
  final String streak;
  final String average;
  const HomeStatsSection({
    super.key,
    required this.totalBooksRead,
    required this.totalPagesRead,
    required this.streak,
    required this.average,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "TU ACTIVIDAD",
            style: textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w900,
              color: colorScheme.primary,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 20),
          LayoutBuilder(
            builder: (context, constraints) {
              final isCompact = constraints.maxWidth < 520;
              return GridView.count(
                crossAxisCount: isCompact ? 1 : 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                childAspectRatio: isCompact ? 2.4 : 1.2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                children: [
                  CustomStatCard(
                    title: "LEÍDOS",
                    subtitle: totalBooksRead,
                    widget: Text(
                      "Libros totales leídos",
                      style: textTheme.bodySmall,
                    ),
                  ),
                  CustomStatCard(
                    title: "PÁGINAS",
                    subtitle: totalPagesRead,
                    widget: Text(
                      "Páginas totales leídas",
                      style: textTheme.bodySmall,
                    ),
                  ),
                  CustomStatCard(
                    title: "RACHA",
                    subtitle: streak,
                    widget: Text("Días de racha", style: textTheme.bodySmall),
                  ),
                  CustomStatCard(
                    title: "PROMEDIO",
                    subtitle: average,
                    widget: Text(
                      "Estrellas en promedio",
                      style: textTheme.bodySmall,
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}
