import 'package:flutter/material.dart';
import 'package:atiora/core/utils/app_colors.dart';
import 'package:atiora/core/utils/helpers.dart';

class ProgressSectionWidget extends StatelessWidget {
  final String? status;
  final int rating;
  final ValueChanged<String?> onStatusChanged;
  final ValueChanged<int> onRatingChanged;

  const ProgressSectionWidget({
    super.key,
    required this.status,
    required this.rating,
    required this.onStatusChanged,
    required this.onRatingChanged,
  });

  @override
  Widget build(BuildContext context) {
    final isRead = status == 'Completado';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Progreso",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 12),
        DropdownButtonFormField<String>(
          initialValue: status,
          decoration: InputDecoration(
            labelText: "Status *",
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            prefixIcon: const Icon(Icons.bookmark),
          ),
          items: AppHelpers.status
              .map(
                (s) => DropdownMenuItem(value: s, child: Text(s.toUpperCase())),
              )
              .toList(),
          onChanged: onStatusChanged,
          validator: (v) => v == null ? 'Selecciona status' : null,
        ),
        const SizedBox(height: 16),

        if (isRead) ...[
          Row(
            children: [
              const Icon(Icons.star, color: AppColors.warning, size: 24),
              const SizedBox(width: 8),
              const Text(
                "Calificación",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              ),
              const Spacer(),
              Row(
                children: List.generate(
                  5,
                  (i) => GestureDetector(
                    onTap: () => onRatingChanged(i + 1),
                    child: Icon(
                      i < rating ? Icons.star : Icons.star_border,
                      color: AppColors.warning,
                      size: 28,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
        ],
      ],
    );
  }
}
