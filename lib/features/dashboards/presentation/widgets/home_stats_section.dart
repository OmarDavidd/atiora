import 'package:flutter/material.dart';
import 'package:atiora/core/utils/notification_helper.dart';

class HomeStatsSection extends StatelessWidget {
  final String totalBooksRead;
  final String pagesThisMonth;
  final String streakDays;
  final String averageRating;
  final bool isLoading;
  final VoidCallback? onStatsTap;

  const HomeStatsSection({
    super.key,
    required this.totalBooksRead,
    required this.pagesThisMonth,
    required this.streakDays,
    required this.averageRating,
    this.isLoading = false,
    this.onStatsTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final colorScheme = theme.colorScheme;

    final resolvedStats = [
      _HomeStatData(
        title: 'Libros activos',
        value: totalBooksRead,
        helper: 'Libros tocados',
        icon: Icons.menu_book_rounded,
        accent: colorScheme.primary,
        accentBackground: colorScheme.primary.withValues(alpha: 0.12),
        loading: isLoading,
      ),
      _HomeStatData(
        title: 'Páginas',
        value: pagesThisMonth,
        helper: 'Páginas totales',
        icon: Icons.auto_stories_rounded,
        accent: colorScheme.secondary,
        accentBackground: colorScheme.secondaryContainer.withValues(
          alpha: 0.25,
        ),
        loading: isLoading,
      ),
      _HomeStatData(
        title: 'Racha activa',
        value: '${streakDays}d',
        helper: 'Días consecutivos',
        icon: Icons.local_fire_department_rounded,
        accent: Colors.deepOrangeAccent,
        accentBackground: const Color(0x33FFAB76),
        loading: isLoading,
      ),
      _HomeStatData(
        title: 'Promedio',
        value: averageRating,
        helper: 'Calificación promedio',
        icon: Icons.star_rate_rounded,
        accent: const Color(0xFFFFC947),
        accentBackground: const Color(0x33FFC947),
        loading: isLoading,
      ),
    ];
    final stats = resolvedStats;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'TU ACTIVIDAD',
                      style: textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w900,
                        color: colorScheme.primary,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
              ),
              TextButton.icon(
                onPressed: () => _handleStatsTap(context),
                icon: const Icon(Icons.assessment_outlined, size: 18),
                label: const Text('Ver más'),
              ),
            ],
          ),
          const SizedBox(height: 16),
          LayoutBuilder(
            builder: (context, constraints) {
              final fallbackWidth = MediaQuery.sizeOf(context).width - 32;
              final availableWidth = constraints.hasBoundedWidth
                  ? constraints.maxWidth
                  : fallbackWidth;
              final forceTwoColumns = availableWidth >= 220;
              final crossAxisCount = forceTwoColumns ? 2 : 1;
              final isSingleColumn = crossAxisCount == 1;
              final totalSpacing = (crossAxisCount - 1) * 16;
              final tileWidth =
                  (availableWidth - totalSpacing) / crossAxisCount;
              final desiredHeight = isSingleColumn ? 190.0 : 160.0;
              final aspectRatio = tileWidth / desiredHeight;

              return GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: crossAxisCount,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: aspectRatio,
                ),
                itemCount: stats.length,
                itemBuilder: (context, index) => _StatTile(
                  data: stats[index],
                  onTap: () => _handleStatsTap(context),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  void _handleStatsTap(BuildContext context) {
    if (onStatsTap != null) {
      onStatsTap!();
    } else {
      NotificationHelper.showInfo(
        context,
        'La pantalla detallada de estadísticas estará disponible pronto.',
      );
    }
  }
}

class _HomeStatData {
  final String title;
  final String value;
  final String helper;
  final IconData icon;
  final Color accent;
  final Color accentBackground;
  final bool loading;

  const _HomeStatData({
    required this.title,
    required this.value,
    required this.helper,
    required this.icon,
    required this.accent,
    required this.accentBackground,
    this.loading = false,
  });
}

class _StatTile extends StatelessWidget {
  final _HomeStatData data;
  final VoidCallback onTap;

  const _StatTile({required this.data, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(24),
        child: Ink(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            color: colors.surface,
            border: Border.all(color: colors.outline.withValues(alpha: 0.08)),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _IconBadge(
                icon: data.icon,
                color: data.accent,
                background: data.accentBackground,
              ),
              const SizedBox(height: 10),
              Text(
                data.title,
                style: theme.textTheme.labelSmall?.copyWith(
                  letterSpacing: 0.6,
                  color: colors.outline,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                data.loading ? '—' : data.value,
                style: theme.textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: data.loading
                      ? colors.outline.withValues(alpha: 0.5)
                      : colors.onSurface,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              Text(
                data.helper,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: colors.outline,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _IconBadge extends StatelessWidget {
  final IconData icon;
  final Color color;
  final Color background;

  const _IconBadge({
    required this.icon,
    required this.color,
    required this.background,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 40,
      width: 40,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        color: background,
      ),
      child: Icon(icon, color: color, size: 22),
    );
  }
}
