import 'package:atiora/core/utils/app_colors.dart';
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
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "TU ACTIVIDAD",
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w900,
              color: AppColors.primaryDark,
              letterSpacing: 0.5,
            ),
          ),
          SizedBox(height: 20),
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            childAspectRatio: 0.85,
            crossAxisSpacing: 8,
            mainAxisSpacing: 8,
            children: [
              CustomStatCard(
                title: "LEIDOS",
                subtitle: totalBooksRead,
                widget: Text("Libros totales leidos"),
              ),
              CustomStatCard(
                title: "LEIDAS",
                subtitle: totalPagesRead,
                widget: Text("Paginas totales leidas"),
              ),
              CustomStatCard(
                title: "RACHA",
                subtitle: streak,
                widget: Text("Dias de racha"),
              ),
              CustomStatCard(
                title: "PROMEDIO",
                subtitle: average,
                widget: Text("Estrellas en promedio"),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
