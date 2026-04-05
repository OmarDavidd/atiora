import 'package:flutter/material.dart';
import 'package:atiora/features/dashboards/presentation/bloc/stats_state.dart';

class QuickStatsSection extends StatelessWidget {
  final StatsData stats;

  const QuickStatsSection({super.key, required this.stats});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final resolvedStats = [
      _StatData(
        title: 'Leyendo',
        value: stats.booksReading.toString(),
        helper: 'Libros activos',
        icon: Icons.auto_stories_rounded,
        accent: colorScheme.primary,
        accentBackground: colorScheme.primary.withValues(alpha: 0.12),
      ),
      _StatData(
        title: 'Completados',
        value: stats.booksCompleted.toString(),
        helper: 'Terminados',
        icon: Icons.check_circle_rounded,
        accent: Colors.green,
        accentBackground: Colors.green.withValues(alpha: 0.12),
      ),
      _StatData(
        title: 'Pausados',
        value: stats.booksPaused.toString(),
        helper: 'En pausa',
        icon: Icons.pause_circle_rounded,
        accent: Colors.orange,
        accentBackground: Colors.orange.withValues(alpha: 0.12),
      ),
      _StatData(
        title: 'Pendientes',
        value: stats.booksPending.toString(),
        helper: 'Por empezar',
        icon: Icons.bookmark_border_rounded,
        accent: colorScheme.outline,
        accentBackground: colorScheme.outline.withValues(alpha: 0.08),
      ),
    ];

    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      mainAxisSpacing: 8,
      crossAxisSpacing: 8,
      childAspectRatio: 2.8,
      children: resolvedStats.map((data) => _GridStatTile(data: data)).toList(),
    );
  }
}

class _GridStatTile extends StatelessWidget {
  final _StatData data;

  const _GridStatTile({required this.data});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colors.outline.withValues(alpha: 0.08)),
      ),
      child: Row(
        children: [
          Icon(data.icon, color: data.accent, size: 20),
          const SizedBox(width: 8),
          Text(
            data.value,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(width: 4),
          Text(
            data.title,
            style: theme.textTheme.labelSmall?.copyWith(color: colors.outline),
          ),
        ],
      ),
    );
  }
}

class _StatData {
  final String title;
  final String value;
  final String helper;
  final IconData icon;
  final Color accent;
  final Color accentBackground;

  const _StatData({
    required this.title,
    required this.value,
    required this.helper,
    required this.icon,
    required this.accent,
    required this.accentBackground,
  });
}
