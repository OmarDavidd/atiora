import 'package:flutter/material.dart';
import 'package:atiora/features/dashboards/presentation/bloc/stats_state.dart';

class HighlightsRow extends StatelessWidget {
  final StatsData stats;

  const HighlightsRow({super.key, required this.stats});

  @override
  Widget build(BuildContext context) {
    final highlights = [
      _HighlightData(
        title: 'Rating',
        value: stats.averageRating.toStringAsFixed(1),
        icon: Icons.star_rounded,
        accent: const Color(0xFFFFC947),
        background: const Color(0x33FFC947),
      ),
      _HighlightData(
        title: 'Notas',
        value: stats.totalNotes.toString(),
        icon: Icons.description_rounded,
        accent: Colors.purple,
        background: Colors.purple.withValues(alpha: 0.12),
      ),
      _HighlightData(
        title: 'Páginas',
        value: stats.pagesThisMonth.toString(),
        icon: Icons.auto_stories_rounded,
        accent: Colors.teal,
        background: Colors.teal.withValues(alpha: 0.12),
      ),
      _HighlightData(
        title: 'Racha',
        value: '${stats.currentStreak}d',
        icon: Icons.local_fire_department_rounded,
        accent: Colors.deepOrangeAccent,
        background: const Color(0x33FFAB76),
      ),
    ];

    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      mainAxisSpacing: 8,
      crossAxisSpacing: 8,
      childAspectRatio: 2.5,
      children: highlights.map((h) => _GridHighlight(h: h)).toList(),
    );
  }
}

class _GridHighlight extends StatelessWidget {
  final _HighlightData h;

  const _GridHighlight({required this.h});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colors.outline.withValues(alpha: 0.08)),
      ),
      child: Row(
        children: [
          Icon(h.icon, color: h.accent, size: 20),
          const SizedBox(width: 8),
          Text(
            h.value,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(width: 4),
          Text(
            h.title,
            style: theme.textTheme.labelSmall?.copyWith(color: colors.outline),
          ),
        ],
      ),
    );
  }
}

class _HighlightData {
  final String title;
  final String value;
  final IconData icon;
  final Color accent;
  final Color background;

  const _HighlightData({
    required this.title,
    required this.value,
    required this.icon,
    required this.accent,
    required this.background,
  });
}
