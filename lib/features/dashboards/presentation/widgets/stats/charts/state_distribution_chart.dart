import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:atiora/core/utils/app_colors.dart';

class StateDistributionChart extends StatefulWidget {
  final Map<String, int> booksByState;

  const StateDistributionChart({super.key, required this.booksByState});

  @override
  State<StateDistributionChart> createState() => _StateDistributionChartState();
}

class _StateDistributionChartState extends State<StateDistributionChart> {
  int touchedIndex = -1;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final total = widget.booksByState.values.fold<int>(0, (a, b) => a + b);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'DISTRIBUCIÓN',
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w900,
            color: colorScheme.primary,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Estado de libros',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: colorScheme.outline,
          ),
        ),
        const SizedBox(height: 16),
        if (total == 0)
          _emptyState(context)
        else
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: colorScheme.surface,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: colorScheme.outline.withValues(alpha: 0.08),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  flex: 3,
                  child: SizedBox(
                    height: 160,
                    child: PieChart(
                      PieChartData(
                        pieTouchData: PieTouchData(
                          touchCallback: (event, response) {
                            setState(() {
                              if (!event.isInterestedForInteractions ||
                                  response == null ||
                                  response.touchedSection == null) {
                                touchedIndex = -1;
                                return;
                              }
                              touchedIndex =
                                  response.touchedSection!.touchedSectionIndex;
                            });
                          },
                        ),
                        sectionsSpace: 2,
                        centerSpaceRadius: 35,
                        sections: _buildSections(total),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  flex: 2,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: _buildLegend(total),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  List<PieChartSectionData> _buildSections(int total) {
    final colors = {
      'Leyendo': AppColors.primary,
      'Completado': Colors.green,
      'Pausado': Colors.orange,
      'Pendiente': Colors.grey,
    };

    final entries = widget.booksByState.entries.toList();
    return List.generate(entries.length, (index) {
      final entry = entries[index];
      final isTouched = index == touchedIndex;
      final percentage = (entry.value / total * 100);

      return PieChartSectionData(
        color: colors[entry.key] ?? AppColors.primary,
        value: entry.value.toDouble(),
        title: isTouched ? '${percentage.toStringAsFixed(0)}%' : '',
        radius: isTouched ? 50 : 40,
        titleStyle: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      );
    });
  }

  List<Widget> _buildLegend(int total) {
    final colors = {
      'Leyendo': AppColors.primary,
      'Completado': Colors.green,
      'Pausado': Colors.orange,
      'Pendiente': Colors.grey,
    };

    return widget.booksByState.entries.map((entry) {
      final percentage = total > 0
          ? (entry.value / total * 100).toStringAsFixed(0)
          : '0';
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          children: [
            Container(
              width: 10,
              height: 10,
              decoration: BoxDecoration(
                color: colors[entry.key] ?? AppColors.primary,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                '${entry.key} ($percentage%)',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ),
          ],
        ),
      );
    }).toList();
  }

  Widget _emptyState(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      height: 160,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: colorScheme.outline.withValues(alpha: 0.08)),
      ),
      child: Text(
        'Sin libros aún',
        style: Theme.of(
          context,
        ).textTheme.bodyMedium?.copyWith(color: colorScheme.outline),
      ),
    );
  }
}
