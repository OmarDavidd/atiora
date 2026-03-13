import 'package:flutter/material.dart';

class CustomStatCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final Widget widget;
  final bool emphasizeSubtitle;
  final double? height;

  const CustomStatCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.widget,
    this.emphasizeSubtitle = false,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                fontWeight: FontWeight.bold,
                letterSpacing: 0.8,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              subtitle,
              style:
                  (emphasizeSubtitle
                          ? Theme.of(context).textTheme.titleMedium
                          : Theme.of(context).textTheme.headlineSmall)
                      ?.copyWith(fontWeight: FontWeight.w700, height: 1.1),
              maxLines: emphasizeSubtitle ? 2 : 1,
              softWrap: emphasizeSubtitle,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 10),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: SizedBox.expand(child: widget),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
