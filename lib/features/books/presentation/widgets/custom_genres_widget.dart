import 'package:atiora/core/utils/helpers.dart';
import 'package:flutter/material.dart';

class CustomGenresWidget extends StatelessWidget {
  final List<String> selectedGenres;
  final Function(String) onGenreToggled;

  const CustomGenresWidget({
    super.key,
    required this.selectedGenres,
    required this.onGenreToggled,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 85,
      child: GridView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.only(right: 40),
        itemCount: AppHelpers.allGenres.length,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: 8,
          crossAxisSpacing: 4,
          childAspectRatio: 0.35,
        ),
        itemBuilder: (context, index) {
          final genre = AppHelpers.allGenres[index];
          final isSelected = selectedGenres.contains(genre);
          return ChoiceChip(
            visualDensity: const VisualDensity(horizontal: -4, vertical: -4),
            showCheckmark: isSelected,
            checkmarkColor: Theme.of(context).primaryColor,
            avatarBorder: const CircleBorder(),
            padding: const EdgeInsets.symmetric(horizontal: 4),
            label: Container(
              width: double.infinity,
              alignment: Alignment.center,
              child: Text(
                genre,
                style: const TextStyle(fontSize: 12),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            selected: isSelected,
            onSelected: (_) => onGenreToggled(genre),
          );
        },
      ),
    );
  }
}
