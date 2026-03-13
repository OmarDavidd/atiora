import 'package:flutter/material.dart';

class CustomRatingWidget extends StatelessWidget {
  final double rating;
  final double? size;

  const CustomRatingWidget({super.key, required this.rating, this.size = 20.0});

  @override
  Widget build(BuildContext context) {
    return Row(
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
  }
}
