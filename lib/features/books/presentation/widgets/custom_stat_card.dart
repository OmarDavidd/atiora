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
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: Theme.of(
                context,
              ).textTheme.labelMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Text(
              subtitle,
              style: Theme.of(
                context,
              ).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w700),
            ),
            SizedBox(height: 20),
            SizedBox(height: 40, child: widget),
          ],
        ),
      ),
    );
  }
}
