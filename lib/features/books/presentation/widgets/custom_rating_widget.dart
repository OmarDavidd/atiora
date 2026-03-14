import 'package:flutter/material.dart';

class CustomRatingWidget extends StatelessWidget {
  final double rating;
  final double? size;
  final VoidCallback? onTap;

  const CustomRatingWidget({
    super.key,
    required this.rating,
    this.size = 20.0,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final stars = Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (index) {
        final icon = index < rating.floor()
            ? Icons.star
            : index < rating
            ? Icons.star_half
            : Icons.star_border;
        return Icon(
          icon,
          color: Theme.of(context).colorScheme.tertiary,
          size: size,
        );
      }),
    );

    if (onTap == null) return stars;

    return InkWell(onTap: onTap, child: stars);
  }
}
