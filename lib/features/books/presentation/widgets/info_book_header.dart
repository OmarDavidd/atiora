import 'package:atiora/core/utils/helpers.dart';
import 'package:atiora/data/models/book_model.dart';
import 'package:atiora/features/books/presentation/widgets/custom_state_widget.dart';
import 'package:flutter/material.dart';

class InfoBookHeader extends StatelessWidget {
  final String currentStatus;
  final BookModel book;
  final VoidCallback onStateTap;

  const InfoBookHeader({
    super.key,
    required this.currentStatus,
    required this.book,
    required this.onStateTap,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          CustomStateWidget(
            color: AppHelpers.getStatusColor(currentStatus),
            text: currentStatus,
            onTap: onStateTap,
          ),
          const SizedBox(height: 10),
          Text(
            book.title,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: 4),
          Text(
            book.genre.join(' • '),
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }
}
