import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:atiora/core/utils/app_colors.dart';

class TopGenresChart extends StatefulWidget {
  final Map<String, int> topGenres;

  const TopGenresChart({super.key, required this.topGenres});

  @override
  State<TopGenresChart> createState() => _TopGenresChartState();
}

class _TopGenresChartState extends State<TopGenresChart> {
  int touchedIndex = -1;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    if (widget.topGenres.isEmpty) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'GÉNEROS',
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w900,
              color: colorScheme.primary,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Géneros más leídos',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: colorScheme.outline,
            ),
          ),
          const SizedBox(height: 16),
          Container(
            height: 120,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: colorScheme.surface,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: colorScheme.outline.withValues(alpha: 0.08),
              ),
            ),
            child: Text(
              'Sin géneros registrados',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colorScheme.outline,
              ),
            ),
          ),
        ],
      );
    }

    final maxValue = widget.topGenres.values.isEmpty
        ? 1
        : widget.topGenres.values.reduce((a, b) => a > b ? a : b);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'GÉNEROS',
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w900,
            color: colorScheme.primary,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Géneros más leídos',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: colorScheme.outline,
          ),
        ),
        const SizedBox(height: 16),
        Container(
          height: 160,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: colorScheme.surface,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: colorScheme.outline.withValues(alpha: 0.08),
            ),
          ),
          child: BarChart(
            BarChartData(
              alignment: BarChartAlignment.spaceAround,
              maxY: maxValue.toDouble() + 1,
              barTouchData: BarTouchData(
                touchTooltipData: BarTouchTooltipData(
                  getTooltipItem: (group, groupIndex, rod, rodIndex) {
                    final entries = widget.topGenres.entries.toList();
                    return BarTooltipItem(
                      '${entries[group.x.toInt()].key}\n${entries[group.x.toInt()].value} libros',
                      const TextStyle(color: Colors.white),
                    );
                  },
                ),
                touchCallback: (event, response) {
                  setState(() {
                    if (!event.isInterestedForInteractions ||
                        response == null ||
                        response.spot == null) {
                      touchedIndex = -1;
                      return;
                    }
                    touchedIndex = response.spot!.touchedBarGroupIndex;
                  });
                },
              ),
              titlesData: FlTitlesData(
                show: true,
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    getTitlesWidget: (value, meta) {
                      if (value.toInt() >= widget.topGenres.length) {
                        return const SizedBox.shrink();
                      }
                      final entries = widget.topGenres.entries.toList();
                      return Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Text(
                          entries[value.toInt()].key.length > 8
                              ? '${entries[value.toInt()].key.substring(0, 8)}...'
                              : entries[value.toInt()].key,
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: colorScheme.outline,
                          ),
                        ),
                      );
                    },
                    reservedSize: 28,
                  ),
                ),
                leftTitles: const AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
                topTitles: const AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
                rightTitles: const AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
              ),
              borderData: FlBorderData(show: false),
              gridData: const FlGridData(show: false),
              barGroups: List.generate(widget.topGenres.length, (index) {
                return BarChartGroupData(
                  x: index,
                  barRods: [
                    BarChartRodData(
                      toY: widget.topGenres.values.elementAt(index).toDouble(),
                      color: index == touchedIndex
                          ? AppColors.secondary
                          : AppColors.secondary.withValues(alpha: 0.7),
                      width: 24,
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(6),
                      ),
                    ),
                  ],
                );
              }),
            ),
            duration: const Duration(milliseconds: 300),
          ),
        ),
      ],
    );
  }
}
