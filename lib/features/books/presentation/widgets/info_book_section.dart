import 'package:atiora/core/utils/app_colors.dart';
import 'package:atiora/core/utils/constants.dart';
import 'package:atiora/core/utils/helpers.dart';
import 'package:atiora/data/models/book_model.dart';
import 'package:atiora/features/books/presentation/bloc/books_bloc.dart';
import 'package:atiora/features/books/presentation/bloc/books_event.dart';
import 'package:atiora/features/books/presentation/bloc/books_state.dart';
import 'package:atiora/features/books/presentation/widgets/custom_state_widget.dart';
import 'package:atiora/features/books/presentation/widgets/state_modal.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';

class InfoBookSection extends StatefulWidget {
  const InfoBookSection({super.key, required this.book});

  final BookModel book;

  @override
  State<InfoBookSection> createState() => _InfoBookSectionState();
}

class _InfoBookSectionState extends State<InfoBookSection> {
  int estadoActual = 0;
  int _pendingIndex = 0;

  @override
  void initState() {
    super.initState();
    final index = AppConstants.bookStates.indexOf(widget.book.status);
    estadoActual = index >= 0 ? index : 0;
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<BooksBloc, BooksState>(
      listener: (context, state) {
        if (state is BookStateUpdateSuccess) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text("¡Estado actualizado!")));
        } else if (state is BookStateUpdateError) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(state.message)));
        }
      },
      child: Column(
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
            color: AppHelpers.getStatusColor(
              AppConstants.bookStates[estadoActual],
            ),
            text: AppConstants.bookStates[estadoActual],
            onTap: _showStateModal,
          ),
          SizedBox(height: 10),
          Text(
            widget.book.title,
            style: GoogleFonts.jaini(
              fontSize: 30,
              fontWeight: FontWeight.w400,
              color: AppColors.neutral0,
            ),
          ),
          Text(widget.book.genre.join('●')),
        ],
      ),
    );
  }

  void _showStateModal() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black54,
      isScrollControlled: true,
      builder: (modalContext) => BlocProvider.value(
        value: context.read<BooksBloc>(),
        child: Container(
          height: MediaQuery.of(context).size.height * 0.4,
          decoration: BoxDecoration(
            color: AppColors.backgroundPrimary,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: StateModal(
            estados: AppConstants.bookStates,
            seleccionado: estadoActual,
            onSeleccionar: (nuevoIndex) {
              _pendingIndex = nuevoIndex;
              modalContext.read<BooksBloc>().add(
                UpdateBookState(
                  bookId: widget.book.id,
                  newState: AppConstants.bookStates[nuevoIndex],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
