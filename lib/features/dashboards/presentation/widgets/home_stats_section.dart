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
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final colorScheme = theme.colorScheme;

    final stats = [
      _HomeStatData(
        title: 'Libros leídos',
        value: totalBooksRead,
        helper: 'Este mes',
        icon: Icons.menu_book_rounded,
        accent: colorScheme.primary,
        accentBackground: colorScheme.primary.withValues(alpha: 0.12),
      ),
      _HomeStatData(
        title: 'Páginas',
        value: totalPagesRead,
        helper: 'Páginas totales',
        icon: Icons.auto_stories_rounded,
        accent: colorScheme.secondary,
        accentBackground: colorScheme.secondaryContainer.withValues(
          alpha: 0.25,
        ),
      ),
      _HomeStatData(
        title: 'Racha activa',
        value: '${streak}d',
        helper: 'Días consecutivos',
        icon: Icons.local_fire_department_rounded,
        accent: Colors.deepOrangeAccent,
        accentBackground: const Color(0x33FFAB76),
      ),
      _HomeStatData(
        title: 'Promedio',
        value: average,
        helper: 'Calificación estimada',
        icon: Icons.star_rate_rounded,
        accent: const Color(0xFFFFC947),
        accentBackground: const Color(0x33FFC947),
      ),
    ];

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
                    Text('Tu actividad', style: textTheme.headlineLarge),
                    const SizedBox(height: 6),
                    Text(
                      'Resumen rápido de tus hábitos recientes',
                      style: textTheme.bodySmall,
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
          const SizedBox(height: 20),
          LayoutBuilder(
            builder: (context, constraints) {
              final isSingleColumn = constraints.maxWidth < 520;
              final crossAxisCount = isSingleColumn ? 1 : 2;
              final aspectRatio = isSingleColumn ? 2.4 : 1.45;

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
    ScaffoldMessenger.of(context)
      ..clearSnackBars()
      ..showSnackBar(
        const SnackBar(
          content: Text(
            'La pantalla detallada de estadísticas estará disponible pronto.',
          ),
          duration: Duration(seconds: 2),
        ),
      );
  }
}

class _HomeStatData {
  final String title;
  final String value;
  final String helper;
  final IconData icon;
  final Color accent;
  final Color accentBackground;

  const _HomeStatData({
    required this.title,
    required this.value,
    required this.helper,
    required this.icon,
    required this.accent,
    required this.accentBackground,
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
            boxShadow: [
              BoxShadow(
                color: colors.shadow.withValues(
                  alpha: Theme.of(context).brightness == Brightness.dark
                      ? 0.18
                      : 0.04,
                ),
                blurRadius: 20,
                offset: const Offset(0, 12),
              ),
            ],
          ),
          padding: const EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _IconBadge(
                    icon: data.icon,
                    color: data.accent,
                    background: data.accentBackground,
                  ),
                  Icon(
                    Icons.arrow_outward_rounded,
                    color: colors.outlineVariant,
                    size: 18,
                  ),
                ],
              ),
              const Spacer(),
              Text(
                data.title,
                style: theme.textTheme.labelSmall?.copyWith(
                  letterSpacing: 0.6,
                  color: colors.outline,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 6),
              Text(data.value, style: theme.textTheme.headlineMedium),
              const SizedBox(height: 6),
              Text(data.helper, style: theme.textTheme.bodySmall),
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
