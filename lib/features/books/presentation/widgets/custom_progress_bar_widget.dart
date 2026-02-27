import 'package:atiora/core/utils/app_colors.dart';
import 'package:flutter/material.dart';

class CustomProgressBarWidget extends StatelessWidget {
  final String? status;
  final int totalPages;
  final int currentPage;
  final bool? hintPercentage;

  const CustomProgressBarWidget({
    super.key,
    this.status,
    required this.totalPages,
    required this.currentPage,
    this.hintPercentage,
  });

  double get progress => (currentPage / totalPages).clamp(0.0, 1.0);

  String get percentage => '${(progress * 100).toStringAsFixed(0)}%';

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (hintPercentage == true)
            Text(percentage, style: TextStyle(fontWeight: FontWeight.bold)),
          SizedBox(height: 8),
          LinearProgressIndicator(value: progress),
          SizedBox(height: 4),
          Text(
            "Página $currentPage de $totalPages",
            style: TextStyle(color: AppColors.neutral600, fontSize: 10),
          ),
        ],
      ),
    );
  }
}
