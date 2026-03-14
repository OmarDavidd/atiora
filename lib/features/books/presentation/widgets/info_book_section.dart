import 'package:atiora/core/utils/constants.dart';
import 'package:atiora/data/models/book_model.dart';
import 'package:atiora/features/books/presentation/bloc/books_bloc.dart';
import 'package:atiora/features/books/presentation/bloc/books_event.dart';
import 'package:atiora/features/books/presentation/bloc/books_state.dart';
import 'package:atiora/features/books/presentation/widgets/state_modal.dart';
import 'package:atiora/features/books/presentation/widgets/info_book_cover.dart';
import 'package:atiora/features/books/presentation/widgets/info_book_header.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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

    if (revertedToReading) {
      final newProgress = await _requestProgressInput(book);
      if (newProgress == null) {
        return false;
      }
      updatedPage = newProgress;
    } else if (completed) {
      updatedPage = book.totalPages;
      finishedAt = DateTime.now();
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
      ),
    );

    return true;
  }

  Future<int?> _requestProgressInput(BookModel book) async {
    return showDialog<int>(
      context: context,
      barrierDismissible: false,
      useRootNavigator: true,
      builder: (_) => _ProgressInputDialog(
        initialPage: book.currentPage,
        totalPages: book.totalPages,
      ),
    );
  }
}

class _ProgressInputDialog extends StatefulWidget {
  final int initialPage;
  final int totalPages;

  const _ProgressInputDialog({
    required this.initialPage,
    required this.totalPages,
  });

  @override
  State<_ProgressInputDialog> createState() => _ProgressInputDialogState();
}

class _ProgressInputDialogState extends State<_ProgressInputDialog> {
  late final TextEditingController _controller;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialPage.toString());
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final maxPage = widget.totalPages;
    return AlertDialog(
      title: const Text('Actualiza tu progreso'),
      content: Form(
        key: _formKey,
        child: TextFormField(
          controller: _controller,
          keyboardType: TextInputType.number,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          decoration: InputDecoration(labelText: 'Página actual (0-$maxPage)'),
          validator: (value) {
            final text = value?.trim();
            if (text == null || text.isEmpty) {
              return 'Ingresa un número válido';
            }
            final page = int.tryParse(text);
            if (page == null) {
              return 'Solo números';
            }
            if (page < 0 || page > maxPage) {
              return 'Debe estar entre 0 y $maxPage';
            }
            return null;
          },
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancelar'),
        ),
        FilledButton(
          onPressed: () {
            if (_formKey.currentState?.validate() != true) return;
            final value = int.tryParse(_controller.text.trim());
            Navigator.of(context).pop(value);
          },
          child: const Text('Guardar'),
        ),
      ],
    );
  }
}
