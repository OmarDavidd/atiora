import 'package:atiora/core/utils/constants.dart';
import 'package:atiora/features/books/presentation/widgets/add_book_validation_tips.dart';
import 'package:flutter/foundation.dart';

class AddBookValidationHelper {
  const AddBookValidationHelper._();

  static List<AddBookValidationTip> collect({
    required String title,
    required List<String> selectedGenres,
    required int totalPages,
    required int currentPage,
    required String? status,
    required int rating,
    VoidCallback? onTitleTap,
    VoidCallback? onGenresTap,
    VoidCallback? onPagesTap,
    VoidCallback? onStatusTap,
    VoidCallback? onRatingTap,
  }) {
    final tips = <AddBookValidationTip>[];
    if (title.trim().isEmpty) {
      tips.add(
        AddBookValidationTip(
          id: 'title',
          message: 'Añade un título para identificar el libro',
          onTap: onTitleTap,
        ),
      );
    }
    if (selectedGenres.isEmpty) {
      tips.add(
        AddBookValidationTip(
          id: 'genres',
          message: 'Selecciona al menos un género',
          onTap: onGenresTap,
        ),
      );
    }
    if (totalPages < 1) {
      tips.add(
        AddBookValidationTip(
          id: 'pages',
          message: 'Ingresa el total de páginas del libro',
          onTap: onPagesTap,
        ),
      );
    } else if (currentPage > totalPages || currentPage < 1) {
      tips.add(
        AddBookValidationTip(
          id: 'pages',
          message: 'Revisa la página actual',
          onTap: onPagesTap,
        ),
      );
    }
    if (status == null) {
      tips.add(
        AddBookValidationTip(
          id: 'status',
          message: 'Selecciona el estado de lectura',
          onTap: onStatusTap,
        ),
      );
    } else if (status == AppConstants.statusCompletado && rating == 0) {
      tips.add(
        AddBookValidationTip(
          id: 'rating',
          message: 'Añade una calificación para libros completados',
          onTap: onRatingTap,
        ),
      );
    }
    return tips;
  }
}
