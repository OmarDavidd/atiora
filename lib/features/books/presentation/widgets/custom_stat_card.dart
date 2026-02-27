import 'package:atiora/core/utils/app_colors.dart';
import 'package:flutter/material.dart';

class CustomStatCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final Widget widget;

  const CustomStatCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.widget,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: AppColors.surfacePrimary,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(
                color: AppColors.neutral500,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 10),
            Text(
              subtitle,
              style: TextStyle(
                color: AppColors.neutral0,
                fontSize: 30,
                fontWeight: FontWeight.w700,
              ),
            ),
            SizedBox(height: 20),
            SizedBox(
              height: 40,
              child: widget,
            ),
          ],
        ),
      ),
    );
  }
}
