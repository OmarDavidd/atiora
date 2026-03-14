import 'package:atiora/features/books/presentation/widgets/add_book_form_section.dart';
import 'package:atiora/features/books/presentation/widgets/custom_genres_widget.dart';
import 'package:flutter/material.dart';

class AddBookGenresField extends StatelessWidget {
  final GlobalKey genresKey;
  final List<String> selectedGenres;
  final bool showError;
  final VoidCallback onClear;
  final void Function(String) onGenreToggled;

  const AddBookGenresField({
    super.key,
    required this.genresKey,
    required this.selectedGenres,
    required this.showError,
    required this.onClear,
    required this.onGenreToggled,
  });

  @override
  Widget build(BuildContext context) {
    return KeyedSubtree(
      key: genresKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AddBookFormSection(
            title: 'Géneros',
            contentPadding: const EdgeInsets.only(top: 12),
            trailing: TextButton(
              onPressed: selectedGenres.isEmpty ? null : onClear,
              child: const Text('Limpiar'),
            ),
            child: CustomGenresWidget(
              selectedGenres: selectedGenres,
              onGenreToggled: onGenreToggled,
            ),
          ),
          const SizedBox(height: 8),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 200),
            child: selectedGenres.isEmpty && showError
                ? Row(
                    key: const ValueKey('genre_helper'),
                    children: const [
                      Icon(Icons.info_outline, size: 18, color: Colors.red),
                      SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          'Elige al menos un género para recomendarte mejor',
                          style: TextStyle(color: Colors.red, fontSize: 13),
                        ),
                      ),
                    ],
                  )
                : const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }
}
