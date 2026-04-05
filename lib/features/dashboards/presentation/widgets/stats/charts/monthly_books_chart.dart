import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:atiora/core/utils/app_colors.dart';
import 'package:atiora/features/dashboards/presentation/bloc/stats_state.dart';

class MonthlyBooksChart extends StatefulWidget {
  final List<MonthlyBooks> monthlyBooks;

  const MonthlyBooksChart({super.key, required this.monthlyBooks});

  @override
  State<MonthlyBooksChart> createState() => _MonthlyBooksChartState();
}

class _MonthlyBooksChartState extends State<MonthlyBooksChart> {
  int touchedIndex = -1;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final maxY = widget.monthlyBooks.isEmpty
        ? 5.0
        : widget.monthlyBooks
                  .map((e) => e.count)
                  .reduce((a, b) => a > b ? a : b)
                  .toDouble() +
              2;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'TENDENCIA',
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w900,
            color: colorScheme.primary,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Libros por mes',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: colorScheme.outline,
          ),
        ),
        const SizedBox(height: 16),
        Container(
          height: 180,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: colorScheme.surface,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: colorScheme.outline.withValues(alpha: 0.08),
            ),
          ),
          child: widget.monthlyBooks.isEmpty
              ? Center(
                  child: Text(
                    'Sin datos suficientes',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: colorScheme.outline,
                    ),
                  ),
                )
              : BarChart(
                  BarChartData(
                    alignment: BarChartAlignment.spaceAround,
                    maxY: maxY,
                    barTouchData: BarTouchData(
                      touchTooltipData: BarTouchTooltipData(
                        getTooltipItem: (group, groupIndex, rod, rodIndex) {
                          return BarTooltipItem(
                            '${widget.monthlyBooks[group.x.toInt()].count} libros',
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
                            if (value.toInt() >= widget.monthlyBooks.length) {
                              return const SizedBox.shrink();
                            }
                            return Padding(
                              padding: const EdgeInsets.only(top: 8),
                              child: Text(
                                widget.monthlyBooks[value.toInt()].month,
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
                    barGroups: List.generate(widget.monthlyBooks.length, (
                      index,
                    ) {
                      return BarChartGroupData(
                        x: index,
                        barRods: [
                          BarChartRodData(
                            toY: widget.monthlyBooks[index].count.toDouble(),
                            color: index == touchedIndex
                                ? AppColors.primary
                                : AppColors.primary.withValues(alpha: 0.7),
                            width: 20,
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
