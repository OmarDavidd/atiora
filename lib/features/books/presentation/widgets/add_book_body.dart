import 'package:flutter/material.dart';

import 'add_book_actions_section.dart';
import 'add_book_genres_field.dart';
import 'add_book_inline_error_banner.dart';
import 'add_book_metadata_fields.dart';
import 'add_book_modal_header.dart';
import 'add_book_offline_notice.dart';
import 'add_book_pages_field.dart';
import 'add_book_validation_tips.dart';
import 'progress_section_widget.dart';

class AddBookBody extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final ScrollController scrollController;
  final TextEditingController titleController;
  final TextEditingController authorController;
  final FocusNode titleFocusNode;
  final FocusNode authorFocusNode;
  final GlobalKey titleFieldKey;
  final GlobalKey genresKey;
  final GlobalKey pagesKey;
  final GlobalKey statusKey;
  final List<String> selectedGenres;
  final int totalPages;
  final int currentPage;
  final String? status;
  final int rating;
  final List<AddBookValidationTip> validationTips;
  final bool showGenresError;
  final String? errorMessage;
  final bool isLoading;
  final bool isOffline;
  final bool hasPendingQueue;
  final bool canReset;
  final VoidCallback onTitleChanged;
  final VoidCallback onAuthorChanged;
  final ValueChanged<String> onGenreChanged;
  final ValueChanged<int> onTotalPagesChanged;
  final ValueChanged<int> onCurrentPageChanged;
  final ValueChanged<String?> onStatusChanged;
  final ValueChanged<int> onRatingChanged;
  final VoidCallback onSave;
  final VoidCallback onReset;
  final VoidCallback onExit;

  const AddBookBody({
    super.key,
    required this.formKey,
    required this.scrollController,
    required this.titleController,
    required this.authorController,
    required this.titleFocusNode,
    required this.authorFocusNode,
    required this.titleFieldKey,
    required this.genresKey,
    required this.pagesKey,
    required this.statusKey,
    required this.selectedGenres,
    required this.totalPages,
    required this.currentPage,
    required this.status,
    required this.rating,
    required this.validationTips,
    required this.showGenresError,
    required this.errorMessage,
    required this.isLoading,
    required this.isOffline,
    required this.hasPendingQueue,
    required this.canReset,
    required this.onTitleChanged,
    required this.onAuthorChanged,
    required this.onGenreChanged,
    required this.onTotalPagesChanged,
    required this.onCurrentPageChanged,
    required this.onStatusChanged,
    required this.onRatingChanged,
    required this.onSave,
    required this.onReset,
    required this.onExit,
  });

  @override
  Widget build(BuildContext context) {
    return Form(
      key: formKey,
      child: SingleChildScrollView(
        controller: scrollController,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            AddBookModalHeader(onClose: onExit),
            const SizedBox(height: 24),
            AddBookMetadataFields(
              titleFieldKey: titleFieldKey,
              titleController: titleController,
              authorController: authorController,
              titleFocusNode: titleFocusNode,
              authorFocusNode: authorFocusNode,
              onTitleChanged: onTitleChanged,
              onAuthorChanged: onAuthorChanged,
            ),
            const SizedBox(height: 20),
            AddBookGenresField(
              genresKey: genresKey,
              selectedGenres: selectedGenres,
              showError: showGenresError,
              onGenreToggled: onGenreChanged,
              onClear: onReset,
            ),
            const SizedBox(height: 20),
            AddBookPagesField(
              pagesKey: pagesKey,
              totalPages: totalPages,
              currentPage: currentPage,
              onTotalPagesChanged: onTotalPagesChanged,
              onCurrentPageChanged: onCurrentPageChanged,
            ),
            const SizedBox(height: 16),
            if (validationTips.isNotEmpty)
              AddBookValidationTipsWrap(validationTips: validationTips),
            if (errorMessage != null) ...[
              const SizedBox(height: 12),
              AddBookInlineErrorBanner(message: errorMessage!),
            ],
            const SizedBox(height: 20),
            KeyedSubtree(
              key: statusKey,
              child: ProgressSectionWidget(
                status: status,
                rating: rating,
                isOffline: isOffline,
                hasPendingQueue: hasPendingQueue,
                onStatusChanged: onStatusChanged,
                onRatingChanged: onRatingChanged,
              ),
            ),
            const SizedBox(height: 20),
            if (isOffline || hasPendingQueue)
              AddBookOfflineQueueNotice(
                isOffline: isOffline,
                hasPendingQueue: hasPendingQueue,
              ),
            AddBookActionsSection(
              isLoading: isLoading,
              canReset: canReset,
              onSave: onSave,
              onReset: onReset,
              onExit: onExit,
            ),
          ],
        ),
      ),
    );
  }
}
