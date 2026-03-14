import 'package:atiora/core/utils/constants.dart';
import 'package:atiora/data/models/book_model.dart';
import 'package:atiora/features/books/presentation/bloc/books_bloc.dart';
import 'package:atiora/features/books/presentation/bloc/books_event.dart';
import 'package:atiora/features/books/presentation/bloc/books_state.dart';
import 'package:atiora/features/books/presentation/widgets/progress_input_dialog.dart';
import 'package:atiora/features/books/presentation/widgets/rating_input_dialog.dart';
import 'package:atiora/features/books/presentation/widgets/state_modal.dart';
import 'package:atiora/features/books/presentation/widgets/info_book_cover.dart';
import 'package:atiora/features/books/presentation/widgets/info_book_header.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class InfoBookSection extends StatefulWidget {
  final BookModel book;

  const InfoBookSection({super.key, required this.book});

  @override
  State<InfoBookSection> createState() => _InfoBookSectionState();
}

class _InfoBookSectionState extends State<InfoBookSection> {
  late String _currentStatus;
  BooksState? _lastSyncedState;
  BookModel? _bookSnapshot;
  bool _hasPendingSync = false;

  @override
  void initState() {
    super.initState();
    _currentStatus = widget.book.status;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _syncStatusWithBloc(context.read<BooksBloc>().state);
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<BooksBloc, BooksState>(
      listenWhen: (previous, current) {
        if (current is BookStateUpdateError) return true;
        return current is BooksLoaded;
      },
      listener: (context, state) {
        if (state is BookStateUpdateError) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(state.message)));
          if (_lastSyncedState != null) {
            _syncStatusWithBloc(_lastSyncedState!);
          }
        } else if (state is BooksLoaded) {
          _syncStatusWithBloc(state);
        }
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 40),
          InfoBookCover(),
          const SizedBox(height: 30),
          InfoBookHeader(
            currentStatus: _currentStatus,
            book: widget.book,
            onStateTap: _showStateModal,
          ),
        ],
      ),
    );
  }

  void _syncStatusWithBloc(BooksState state) {
    if (state is BooksLoaded) {
      _lastSyncedState = state;
      for (final book in state.books) {
        if (book.id == widget.book.id) {
          _bookSnapshot = book;
          final pending = book.pendingSync;
          if (_hasPendingSync != pending) {
            if (mounted) {
              setState(() => _hasPendingSync = pending);
            } else {
              _hasPendingSync = pending;
            }
          }
          if (book.status != _currentStatus) {
            if (mounted) {
              setState(() => _currentStatus = book.status);
            } else {
              _currentStatus = book.status;
            }
          }
          break;
        }
      }
    }
  }

  void _showStateModal() {
    final bloc = context.read<BooksBloc>();
    final referenceBook = _bookSnapshot ?? widget.book;
    final currentIndex = AppConstants.bookStates.indexWhere((estado) {
      return estado.toLowerCase() == _currentStatus.toLowerCase().trim();
    });

    final safeIndex = currentIndex >= 0 ? currentIndex : 0;

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
            color: Theme.of(modalContext).colorScheme.surface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              if (_hasPendingSync)
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 16, 24, 8),
                  child: Text(
                    'Este libro tiene cambios pendientes por sincronizar',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ),
              Expanded(
                child: StateModal(
                  estados: AppConstants.bookStates,
                  seleccionado: safeIndex,
                  onSeleccionar: (nuevoIndex) async {
                    final newState = AppConstants.bookStates[nuevoIndex];
                    final handled = await _handleStateChange(
                      bloc,
                      referenceBook,
                      newState,
                    );
                    return handled;
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<bool> _handleStateChange(
    BooksBloc bloc,
    BookModel book,
    String newState,
  ) async {
    final normalized = newState.toLowerCase();
    final completed = normalized == 'completado';
    final revertedToReading = normalized == 'leyendo';

    int? updatedPage;
    DateTime? finishedAt;
    bool clearFinishedAt = revertedToReading;
    double? rating;

    if (revertedToReading) {
      final newProgress = await _requestProgressInput(book);
      if (newProgress == null) {
        return false;
      }
      updatedPage = newProgress;
    } else if (completed) {
      updatedPage = book.totalPages;
      finishedAt = DateTime.now();
      rating = await _requestRatingInput(book);
      if (rating == null) {
        return false;
      }
    }

    if (!mounted) return true;

    setState(() => _currentStatus = newState);
    bloc.add(
      UpdateBookState(
        bookId: book.id,
        newState: newState,
        updatedPage: updatedPage,
        finishedAt: finishedAt,
        clearFinishedAt: clearFinishedAt,
        rating: rating,
      ),
    );

    return true;
  }

  Future<int?> _requestProgressInput(BookModel book) async {
    return showDialog<int>(
      context: context,
      barrierDismissible: false,
      useRootNavigator: true,
      builder: (_) => ProgressInputDialog(
        initialPage: book.currentPage,
        totalPages: book.totalPages,
      ),
    );
  }

  Future<double?> _requestRatingInput(BookModel book) {
    return showDialog<double>(
      context: context,
      barrierDismissible: false,
      useRootNavigator: true,
      builder: (_) => RatingInputDialog(initialValue: book.rating),
    );
  }
}
