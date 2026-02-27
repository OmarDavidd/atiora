import 'package:atiora/core/utils/app_colors.dart';
import 'package:atiora/core/utils/helpers.dart';
import 'package:atiora/data/models/book_model.dart';
import 'package:atiora/features/books/presentation/widgets/custom_state_widget.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class InfoBookSection extends StatelessWidget {
  const InfoBookSection({super.key, required this.book});

  final BookModel book;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(height: 40),
        SizedBox(
          height: 260,
          child: ClipRRect(
            borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
            child: Container(
              color: AppColors.neutral400,
              child: Image.asset(
                'assets/missingbook.webp',
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) =>
                    Icon(Icons.book, size: 80, color: AppColors.neutral400),
              ),
            ),
          ),
        ),
        SizedBox(height: 30),
        CustomStateWidget(
          color: AppHelpers.getStatusColor(book.status),
          text: '●  ESTADO: ${book.status}',
        ),
        SizedBox(height: 10),
        Text(
          book.title,
          style: GoogleFonts.jaini(
            fontSize: 30,
            fontWeight: FontWeight.w400,
            color: AppColors.neutral0,
          ),
        ),
        Text(book.genre.join('●')),
      ],
    );
  }
}
