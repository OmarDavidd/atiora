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

class InfoBookSection extends StatefulWidget {
  final BookModel book;

  const InfoBookSection({super.key, required this.book});

  @override
  State<InfoBookSection> createState() => _InfoBookSectionState();
}

class _InfoBookSectionState extends State<InfoBookSection> {
  int pendingIndex = 0;
  late int estadoActual;
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<BooksBloc, BooksState>(
      builder: (context, state) {
        final currentStatus = _getCurrentBookStatus(state);
        final currentIndex = _getSafeStateIndex(currentStatus);

        return BlocListener<BooksBloc, BooksState>(
          listener: (context, state) {
            if (state is BookStateUpdateError) {
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(SnackBar(content: Text(state.message)));
            }
          },
          child: Column(
            children: [
              const SizedBox(height: 40),
              SizedBox(
                height: 260,
                child: ClipRRect(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(12),
                  ),
                  child: Container(
                    color: Theme.of(context).colorScheme.surfaceVariant,
                    child: Image.asset(
                      'assets/missingbook.webp',
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Icon(
                        Icons.book,
                        size: 80,
                        color: Theme.of(context).colorScheme.outline,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 30),
              CustomStateWidget(
                color: AppHelpers.getStatusColor(currentStatus),
                text: currentStatus,
                onTap: _showStateModal,
              ),
              const SizedBox(height: 10),
              Text(
                widget.book.title,
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: 4),
              Text(
                widget.book.genre.join(' • '),
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  void initState() {
    super.initState();
    final index = AppConstants.bookStates.indexOf(widget.book.status);
    estadoActual = index >= 0 ? index : 0;
    debugPrint(
      '📌 initState: status=${widget.book.status}, index=$estadoActual',
    );
  }

  Widget buildStaticUI(int index) {
    return BlocListener<BooksBloc, BooksState>(
      listener: (context, state) {
        if (state is BookStateUpdateSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("¡Estado actualizado! ✅")),
          );
        } else if (state is BookStateUpdateError) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(state.message)));
        }
      },
      child: Column(
        children: [
          const SizedBox(height: 40),
          SizedBox(
            height: 260,
            child: ClipRRect(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(12),
              ),
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
          const SizedBox(height: 30),
          CustomStateWidget(
            color: AppHelpers.getStatusColor(AppConstants.bookStates[index]),
            text: AppConstants.bookStates[index],
            onTap: _showStateModal,
          ),
          const SizedBox(height: 10),
          Text(
            widget.book.title,
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: 4),
          Text(
            widget.book.genre.join(' • '),
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }

  String _getCurrentBookStatus(BooksState state) {
    if (state is BooksLoaded) {
      try {
        final book = state.books.firstWhere((b) => b.id == widget.book.id);
        return book.status;
      } catch (e) {
        debugPrint('Libro no encontrado en lista: ${widget.book.id}');
      }
    }
    return widget.book.status;
  }

  int _getSafeStateIndex(String status) {
    final index = AppConstants.bookStates.indexOf(status);
    return index >= 0 ? index : 0;
  }

  void _showStateModal() {
    final bloc = context.read<BooksBloc>();
    final currentStatus = _getCurrentBookStatus(bloc.state);
    debugPrint('🔍 Status actual: "$currentStatus"');
    debugPrint('🔍 Estados disponibles: ${AppConstants.bookStates}');
    final currentIndex = AppConstants.bookStates.indexWhere((estado) {
      return estado.toLowerCase() == currentStatus.toLowerCase().trim();
    });

    final safeIndex = currentIndex >= 0 ? currentIndex : 0;
    debugPrint('🔍 Índice calculado: $safeIndex');

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black54,
      isScrollControlled: true,
      builder: (modalContext) => BlocProvider.value(
        value: bloc,
        child: Container(
          height: MediaQuery.of(modalContext).size.height * 0.4,
          decoration: BoxDecoration(
            color: AppColors.backgroundPrimary,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: StateModal(
            estados: AppConstants.bookStates,
            seleccionado: safeIndex,
            onSeleccionar: (nuevoIndex) {
              pendingIndex = nuevoIndex;
              bloc.add(
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
