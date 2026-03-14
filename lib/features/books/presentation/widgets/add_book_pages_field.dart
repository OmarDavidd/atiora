import 'package:atiora/features/books/presentation/widgets/add_book_form_section.dart';
import 'package:atiora/features/books/presentation/widgets/pages_config_widget.dart';
import 'package:flutter/material.dart';

class AddBookPagesField extends StatelessWidget {
  final GlobalKey pagesKey;
  final int totalPages;
  final int currentPage;
  final void Function(int) onTotalPagesChanged;
  final void Function(int) onCurrentPageChanged;

  const AddBookPagesField({
    super.key,
    required this.pagesKey,
    required this.totalPages,
    required this.currentPage,
    required this.onTotalPagesChanged,
    required this.onCurrentPageChanged,
  });

  @override
  Widget build(BuildContext context) {
    return KeyedSubtree(
      key: pagesKey,
      child: AddBookFormSection(
        title: 'Progreso',
        contentPadding: const EdgeInsets.only(top: 12),
        child: PagesConfigWidget(
          totalPages: totalPages,
          currentPage: currentPage,
          onTotalPagesChanged: onTotalPagesChanged,
          onCurrentPageChanged: onCurrentPageChanged,
        ),
      ),
    );
  }
}
