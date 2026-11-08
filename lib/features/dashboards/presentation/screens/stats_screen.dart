import 'package:atiora/features/dashboards/presentation/bloc/stats_bloc.dart';
import 'package:atiora/features/dashboards/presentation/bloc/stats_event.dart';
import 'package:atiora/features/dashboards/presentation/bloc/stats_state.dart';
import 'package:atiora/features/dashboards/presentation/widgets/stats/charts/state_distribution_chart.dart';
import 'package:atiora/features/dashboards/presentation/widgets/stats/charts/monthly_books_chart.dart';
import 'package:atiora/features/dashboards/presentation/widgets/stats/charts/top_genres_chart.dart';
import 'package:atiora/features/dashboards/presentation/widgets/stats/quick_stats_section.dart';
import 'package:atiora/features/dashboards/presentation/widgets/stats/highlights_row.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class StatsScreen extends StatefulWidget {
  const StatsScreen({super.key});

  @override
  State<StatsScreen> createState() => _StatsScreenState();
}

class _StatsScreenState extends State<StatsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<StatsBloc>()
        ..add(LoadStats())
        ..add(RefreshStats());
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        titleSpacing: 30,
        title: Text(
          'Estadísticas',
          style: Theme.of(context).textTheme.headlineLarge,
        ),
      ),
      body: BlocBuilder<StatsBloc, StatsState>(
        builder: (context, state) {
          if (state is StatsLoading || state is StatsInitial) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state is StatsError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(state.message),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => context.read<StatsBloc>().add(LoadStats()),
                    child: const Text('Reintentar'),
                  ),
                ],
              ),
            );
          }
          if (state is StatsLoaded) {
            return _StatsContent(stats: state.stats);
          }
          return const Center(child: CircularProgressIndicator());
        },
      ),
    );
  }
}

class _StatsContent extends StatelessWidget {
  final StatsData stats;

  const _StatsContent({required this.stats});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            '${stats.totalBooks}',
            style: theme.textTheme.displaySmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            'libros en tu biblioteca',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: colorScheme.outline,
            ),
          ),
          const SizedBox(height: 32),

          // ESTE MES
          _SectionHeader(title: 'Este mes'),
          const SizedBox(height: 16),
          QuickStatsSection(stats: stats, isGlobal: false),
          const SizedBox(height: 16),
          HighlightsRow(stats: stats, isGlobal: false),
          const SizedBox(height: 32),

          // GLOBAL
          _SectionHeader(title: 'Global'),
          const SizedBox(height: 16),
          QuickStatsSection(stats: stats, isGlobal: true),
          const SizedBox(height: 16),
          HighlightsRow(stats: stats, isGlobal: true),
          const SizedBox(height: 32),

          StateDistributionChart(booksByState: stats.booksByState),
          const SizedBox(height: 32),
          MonthlyBooksChart(monthlyBooks: stats.monthlyBooks),
          const SizedBox(height: 32),
          TopGenresChart(topGenres: stats.topGenres),
          const SizedBox(height: 48),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;

  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 4,
          height: 20,
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primary,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 12),
        Text(
          title,
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
      ],
    );
  }
}
