import 'package:flutter/material.dart';

import 'package:atiora/core/utils/app_colors.dart';

class AboutCard extends StatelessWidget {
  const AboutCard({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(
                'Early Access',
                style: textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppColors.primary,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Text(
              'By DGVO',
              style: textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.w600,
                color: AppColors.neutral400,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Text(
          '© 2026 Atiora. Todos los derechos reservados.',
          style: textTheme.bodySmall?.copyWith(color: AppColors.neutral500),
        ),
      ],
    );
  }
}
